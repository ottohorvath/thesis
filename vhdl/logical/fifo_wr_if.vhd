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
entity fifo_wr_if is
    generic (
        REG_LAYER       :           boolean :=  false;  -- For timing closure purposes
        DW              :           integer :=  32      -- Data width
    );
    port (
        clk             :       in  std_logic                           ;
        rstn            :       in  std_logic                           ;-- Async. active LOW reset

        trig_in         :       in  std_logic                           ;--
        trig_out_0      :       out std_logic                           ;-- Trigger IF
        trig_out_1      :       out std_logic                           ;--

        rdata           :       out std_logic_vector(DW-1 downto 0) ;
        wr              :       in  std_logic                           ;
        wdata           :       in  std_logic_vector(2  downto 0);

        full_to_DUV     :       out std_logic                           ;--
        wr_from_DUV     :       in  std_logic                           ;-- Write side
        wdata_from_DUV  :       in std_logic_vector(DW-1 downto 0)
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of fifo_wr_if is

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



    -- Read Data Mux
    -- =============
    -- 1: Selects the register which contains data written in by the DUV
    -- 0: Selects status signals from the FSM
    signal      rdata_mux       :   std_logic_vector(DW-1 downto 0);
    signal      rdata_mux_1     :   std_logic_vector(DW-1 downto 0);
    signal      rdata_mux_0     :   std_logic_vector(DW-1 downto 0);


    -- Read Data Register
    -- ===================
    -- Stores the data which is written by the DUV, which will be eventually read by the Processor
    signal      rdata_reg       :   std_logic_vector(DW-1 downto 0);
    signal      rdata_reg_en    :   std_logic;


    -- Signal from  FSM
    -- ====================
    signal      show_data       :   std_logic;
    signal      rcvd_data       :   std_logic;
    signal      fifo_full       :   std_logic;
    signal      enabled         :   std_logic;

    -- Register layer on output
    -- ========================
    signal      fifo_full_reg   :   std_logic;


    -- Trigger output registers
    -- ========================
    signal      trig_out_0_reg      :   std_logic;
    signal      trig_out_1_reg      :   std_logic;



begin

    -------------------------------------------------------------
    L_RDATA:    block
                begin
                    ---------------------------------------------
                    L_RDATA_REG:    process(clk,rstn) is
                                    begin
                                        if( rstn='0' )then
                                            rdata_reg   <= slv(DW,'0');

                                        elsif( rising_edge(clk) ) then

                                            -- Get data from DUV side
                                            if(rdata_reg_en = '1')  then
                                                rdata_reg   <= wdata_from_DUV;
                                            end if;

                                        end if;
                                    end process;
                    ---------------------------------------------
                    rdata_mux_1 <=  rdata_reg;

                    rdata_mux_0 <=  slv(DW-3,'0')   &
                                    rcvd_data           &   -- [2]
                                    fifo_full           &   -- [1]
                                    enabled             ;   -- [0]

                    rdata_mux   <=  rdata_mux_1 when (show_data = '1') else
                                    rdata_mux_0;
                    ---------------------------------------------

                    -- Drive the MUX to the output
                    rdata   <= rdata_mux;

                end block;
    -------------------------------------------------------------
    L_DUV_SIDE: block
                begin
                    ---------------------------------------------
                    L_REG:     if(REG_LAYER = true)    generate
                                        -------------------------------------
                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')    then
                                                fifo_full_reg   <= '0';

                                            elsif(rising_edge(clk)) then
                                                fifo_full_reg   <= fifo_full;

                                            end if;
                                        end process;
                                        -------------------------------------
                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')    then
                                                trig_out_0_reg  <= '0';

                                            elsif(rising_edge(clk)) then
                                                trig_out_0_reg  <= enabled;

                                            end if;
                                        end process;
                                        -------------------------------------
                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')    then
                                                trig_out_1_reg  <= '0';

                                            elsif(rising_edge(clk)) then
                                                trig_out_1_reg  <= rcvd_data;

                                            end if;
                                        end process;
                                        -------------------------------------

                                        -- Drive the output from register
                                        full_to_DUV     <= fifo_full_reg;
                                        trig_out_0      <= trig_out_0_reg;
                                        trig_out_1      <= trig_out_1_reg;

                                    end generate;
                    ---------------------------------------------
                    L_NO_REG_LAYER: if(REG_LAYER = false)   generate

                                        -- Drive output signal from FSM
                                        full_to_DUV     <= fifo_full;
                                        trig_out_0      <= enabled  ;
                                        trig_out_1      <= rcvd_data;

                                    end generate;
                    ---------------------------------------------
                end block;
    -------------------------------------------------------------


    -------------------------------------------------------------
    L_FSM:  entity  work.fifo_wr_if_fsm(rtl)
--                generic map(
--                    DW              =>  DW
--                )
                port map(
                    clk             =>  clk         ,
                    rstn            =>  rstn        ,
                    trig_in_fsm     =>  trig_in     ,
                    wr              =>  wr          ,
                    wdata           =>  wdata       ,
                    fifo_wr         =>  wr_from_DUV ,
                    show_data_fsm   =>  show_data   ,
                    rdata_reg_en    =>  rdata_reg_en,
                    full            =>  fifo_full   ,
                    rcvd_data_fsm   =>  rcvd_data   ,
                    enabled_fsm     =>  enabled
                );
    -------------------------------------------------------------





end architecture;