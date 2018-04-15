---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity evnt_cntr is
    generic(
        SIG_W           :   integer:=   1;       -- CW of the input signal which is watched
        REG_LAYER       :   boolean:=   false;
        CW              :   integer:=   7
    );
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        wr              :   in  std_logic;
        wdata           :   in  std_logic_vector(1  downto  0);
        -- coverage off t
        rdata           :   out std_logic_vector(CW-1   downto  0);
        -- coverage on
        signal_from_DUV :   in  std_logic_vector(SIG_W-1 downto 0);
        trig_in         :   in  std_logic;
        trig_out        :   out std_logic
    );
end entity evnt_cntr;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of evnt_cntr is

    -- Write Data Register
    -- ===================
    signal  wdata_reg   :   std_logic_vector(1 downto 0);


    -- Signals from/to 'cntr'
    -- ===================
    -- coverage off t
    signal  cntr_out_w  :   std_logic_vector(CW-1 downto 0);
    -- coverage on
    signal  cntr_en_w   :   std_logic;


    -- Register layer
    -- ==============
    signal  trig_out_reg    :   std_logic;
    signal  trig_out_reg_en :   std_logic;


    -- SC FF on 'trig_in' input
    -- ========================
    signal  trig_in_sc_ff   :   std_logic;
    signal  sc_ff_set       :   std_logic;

    -- Global enable signal
    -- ====================
    signal  global_en       :   std_logic;
    signal  global_clr      :   std_logic;


    -- Change detector signals
    -- =======================
    signal  chg_det_reg     :   std_logic_vector(SIG_W-1 downto 0);
    signal  chg_det_en      :   std_logic;
    signal  chg_det_out     :   std_logic;

begin
    ---------------------------------------------------------------------
    L_GLOBAL:   block
                begin

                    -- Processor or a component can enable the module
                    global_en   <=  wdata_reg(0) or  trig_in_sc_ff;
                    global_clr  <=  wdata_reg(1);

                    sc_ff_set   <=  trig_in;

                    -- Counter is incremented when the module is globally enabled
                    -- and there was a change 'signal_from_DUV' vector
                    cntr_en_w   <=  global_en   and     chg_det_out;

                end block;
    ---------------------------------------------------------------------
    L_RDATA:    block
                begin
                    rdata   <= cntr_out_w;
                end block;
    ---------------------------------------------------------------------
    L_WDATA:    block
                begin

                    process(clk, rstn) is
                    begin
                        if(rstn = '0')  then
                            wdata_reg   <= (others =>'0');
                        elsif(rising_edge(clk)) then

                            if(wr = '1')    then
                                wdata_reg <= wdata;
                            end if;

                        end if;
                    end process;

                end block;
    ---------------------------------------------------------------------
    L_REG_LAYER:    block
                    begin
                        ------------------------------------------------
                        L_REGLAY:   if(REG_LAYER = true)    generate

                                        process(clk,rstn) is
                                        begin
                                            if(rstn = '0')  then
                                                trig_out_reg    <= '0';
                                            elsif(rising_edge(clk)) then

                                                -- Drive the 'chg_det_out' signal from flop
                                                if(trig_out_reg_en = '1') then
                                                    trig_out_reg    <= chg_det_out;
                                                end if;

                                            end if;
                                        end process;

                                        -- 'trig_out_reg' is enabled globally
                                        trig_out_reg_en <= global_en;

                                        -- Drive the output from the extra register
                                        trig_out    <= trig_out_reg;

                                    end generate;
                        ------------------------------------------------
                        L_NO_REGL:  if(REG_LAYER = false)   generate

                                        -- Drive the output directly
                                        trig_out    <= chg_det_out;
                                    end generate;
                        ------------------------------------------------
                    end block;
    ---------------------------------------------------------------------
    L_CHG_DET:  block
                begin
                    chg_det_en  <=  global_en;

                    chg_det_out <=  '1' when( chg_det_reg /= signal_from_DUV
                                            ) else '0';

                    process(clk,rstn)   is
                    begin
                        if(rstn = '0')  then
                            chg_det_reg <= (others => '0');

                        elsif(rising_edge(clk)) then

                            if(chg_det_en = '1')    then
                                chg_det_reg <= signal_from_DUV;
                            end if;

                        end if;
                    end process;
                end block;
    ---------------------------------------------------------------------
    L_SC_FF:    entity work.sc_ff(rtl)
                    port map(
                        clk         => clk          ,
                        rstn        => rstn         ,
                        set         => sc_ff_set    ,
                        clr         => global_clr   ,
                        q           => trig_in_sc_ff
                    );
    ---------------------------------------------------------------------
    L_CNTR:     entity work.cntr(rtl)
                    generic map(
                        CW       =>  CW
                    )
                    port map(
                        clk         => clk          ,
                        rstn        => rstn         ,
                        en          => cntr_en_w    ,
                        clr         => global_clr   ,
                        cntr_out    => cntr_out_w
                    );
    ---------------------------------------------------------------------
end architecture rtl;

