---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description:
--
--
--
--
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity fifo_rd_if is
    generic (
        REG_LAYER       :           boolean :=  false;  -- For timing closure purposes
        DWIDTH          :           integer :=  32      -- Data width
    );
    port (
        clk             :       in  std_logic                           ;
        rstn            :       in  std_logic                           ;-- Async. active LOW reset

        trig_in         :       in  std_logic                           ;--
        trig_out_0      :       out std_logic                           ;-- Trigger IF
        trig_out_1      :       out std_logic                           ;--

        rdata           :       out std_logic_vector(DWIDTH-1 downto 0) ;--
        wr              :       in  std_logic                           ;
        wdata           :       in  std_logic_vector(DWIDTH-1  downto 0);

        empty_to_DUV    :       out std_logic                           ;--
        rd_from_DUV     :       in  std_logic                           ;-- Read side
        rdata_to_DUV    :       out std_logic_vector(DWIDTH-1 downto 0)  --
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of fifo_rd_if is

    --------------------------------------------------------------------------------------------------
    function slv(
        N: natural;
        B: std_logic
    )   return std_logic_vector  -- Replacate std_logic-s to slv, like Verilog's replicate operator (e.g. {32{1b1}} )
    is
        variable result: std_logic_vector(1 to N);
    begin
        for i in 1 to N loop
            result(i) := B;
        end loop;

        return result;
    end;
    --------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------



    -- Read Data output
    -- ================
    -- [0]: Shows if the module is enabled
    -- [1]: Shows the value of 'empty_to_DUV'
    -- [2]: Shows if data got read out
    signal      rdata_int_w     :   std_logic_vector(DWIDTH-1 downto 0);


    -- Write Data Register
    -- ===================
    -- Stores write data which will be eventually read out by the DUV
    signal      wdata_reg       :   std_logic_vector(DWIDTH-1 downto 0);
    signal      wdata_reg_en    :   std_logic;


    -- Signals from FSM
    -- ================
    signal      data_got_read_out   :   std_logic;
    signal      fifo_empty          :   std_logic;
    signal      enabled_from_fsm    :   std_logic;


    -- Register layer on output
    -- ========================
    signal      fifo_empty_reg      :   std_logic;


    -- Trigger output registers
    -- ========================
    signal      trig_out_0_reg      :   std_logic;
    signal      trig_out_1_reg      :   std_logic;

begin

    -------------------------------------------------------------
    L_WDATA_REG:    process(clk,rstn) is
                    begin
                        if(rstn = '0')  then
                            wdata_reg   <= slv(DWIDTH, '0');

                        elsif( rising_edge(clk))    then

                            if(wdata_reg_en = '1')    then
                                wdata_reg   <= wdata;
                            end if;

                        end if;
                    end process;
    -------------------------------------------------------------
    L_RDATA:    block
                begin
                    rdata   <=  slv(DWIDTH-3, '0')  &
                                data_got_read_out   &   -- [2]
                                fifo_empty          &   -- [1]
                                enabled_from_fsm    ;   -- [0]
                end block;
    -------------------------------------------------------------
    L_DUV_SIDE: block
                begin
                    ---------------------------------------------
                    L_EMPTY_REG:    if(REG_LAYER = true)    generate
                                        -------------------------------------
                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')    then
                                                fifo_empty_reg  <= '1';

                                            elsif(rising_edge(clk)) then
                                                fifo_empty_reg  <= fifo_empty;

                                            end if;
                                        end process;
                                        -------------------------------------
                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')    then
                                                trig_out_0_reg  <= '0';

                                            elsif(rising_edge(clk)) then
                                                trig_out_0_reg  <= enabled_from_fsm;

                                            end if;
                                        end process;
                                        -------------------------------------
                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')    then
                                                trig_out_1_reg  <= '0';

                                            elsif(rising_edge(clk)) then
                                                trig_out_1_reg  <= data_got_read_out;

                                            end if;
                                        end process;
                                        -------------------------------------

                                        -- Drive the output from register
                                        empty_to_DUV    <=  fifo_empty_reg;
                                        trig_out_0      <=  trig_out_0_reg;
                                        trig_out_1      <=  trig_out_1_reg;


                                    end generate;
                    ---------------------------------------------
                    L_NO_REG_LAYER: if(REG_LAYER = false)   generate

                                        -- Drive output signal from FSM
                                        empty_to_DUV    <=  fifo_empty;
                                        trig_out_0      <=  enabled_from_fsm;
                                        trig_out_1      <=  data_got_read_out;

                                    end generate;
                    ---------------------------------------------

                    -- Drive the data from processor to the DUV IF
                    rdata_to_DUV    <= wdata_reg;
                    ---------------------------------------------
                end block;
    -------------------------------------------------------------


    -------------------------------------------------------------
    L_FSM:  entity  work.fifo_rd_if_fsm(rtl)
                generic map(
                    DW              =>  DWIDTH
                )
                port map(
                    clk             =>  clk                 ,
                    rstn            =>  rstn                ,
                    trig_in_fsm     =>  trig_in             ,
                    wr              =>  wr                  ,
                    wdata           =>  wdata               ,
                    fifo_rd         =>  rd_from_DUV         ,
                    wdata_reg_en    =>  wdata_reg_en        ,
                    empty           =>  fifo_empty          ,
                    got_read_out    =>  data_got_read_out   ,
                    enabled_fsm     =>  enabled_from_fsm
                );
    -------------------------------------------------------------





end architecture;