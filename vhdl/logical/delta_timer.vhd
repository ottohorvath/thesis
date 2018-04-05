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
entity delta_timer is
    generic(
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
        signal_from_DUV :   in  std_logic;
        trig_in         :   in  std_logic;
        trig_out        :   out std_logic
    );
end entity delta_timer;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of delta_timer is

    -- Write Data Register
    -- ===================
    signal  wdata_reg   :   std_logic_vector(1 downto 0);


    -- Signals from/to 'cntr'
    -- ===================
    -- coverage off t
    signal  cntr_out_w  :   std_logic_vector(CW-1 downto 0);
    -- coverage on
    signal  cntr_en_w   :   std_logic;
    signal  cntr_clr_w  :   std_logic;


    -- Signals from FSM
    -- ===================
    signal  show_cntr_w :   std_logic;
    signal  chg_caught_w:   std_logic;
    signal  det_clr_w   :   std_logic;
    signal  det_en_w    :   std_logic;


    -- Signals to FSM
    -- ==============
    signal  fsm_en      :   std_logic;
    signal  fsm_clr     :   std_logic;


    -- Register layer
    -- ==============
    signal  trig_out_reg    :   std_logic;
    signal  trig_out_reg_en :   std_logic;


    -- SC FF on 'trig_in' input
    -- ========================
    signal  trig_in_sc_ff   :   std_logic;
    signal  sc_ff_en        :   std_logic;
    signal  sc_ff_clr       :   std_logic;

begin
    ---------------------------------------------------------------------
    L_EN_CLR:   block
                begin
                    -- Clear function is driven from 'wdata_reg'
                    fsm_clr <=  wdata_reg(1);

                    -- Enable function is driven from 'wdata_reg'
                    -- or from 'trig_in_sc_ff'
                    fsm_en  <=  wdata_reg(0)    or
                                trig_in_sc_ff;

                    -- SC FF is set from 'trig_in'
                    sc_ff_en    <=  trig_in;
                    -- Cleared from 'fsm_clr'
                    sc_ff_clr   <= fsm_clr;
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
    L_RDATA:    block
                begin
                    rdata   <= cntr_out_w   when(show_cntr_w = '1'
                                                ) else (others => '0');
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

                                                -- Drive the 'show_cntr' signal from FSM
                                                if(trig_out_reg_en = '1') then
                                                    trig_out_reg    <= show_cntr_w;
                                                end if;

                                            end if;
                                        end process;

                                        -- 'trig_out_reg' is enabled from
                                        -- 'fsm_en'
                                        trig_out_reg_en <= fsm_en;

                                        -- Drive the output from the extra register
                                        trig_out    <= trig_out_reg;

                                    end generate;
                        ------------------------------------------------
                        L_NO_REGL:  if(REG_LAYER = false)   generate

                                        -- Drive the output from FSM directly
                                        trig_out    <= show_cntr_w;
                                    end generate;
                        ------------------------------------------------
                    end block;
    ---------------------------------------------------------------------
    L_SC_FF:    entity work.sc_ff(rtl)
                    port map(
                        clk         => clk          ,
                        rstn        => rstn         ,
                        set         => sc_ff_en     ,  
                        clr         => sc_ff_clr    ,
                        q           => trig_in_sc_ff
                    );
    ---------------------------------------------------------------------
    L_CHG_DET:  entity work.chg_det(rtl)
                    port map(
                        clk         => clk         ,
                        rstn        => rstn        ,
                        en          => det_en_w    ,
                        clr         => det_clr_w   ,
                        sig         => signal_from_DUV,
                        det_out     => chg_caught_w
                    );
    ---------------------------------------------------------------------
    L_CNTR:     entity work.cntr(rtl)
                    generic map(
                        CW          =>  CW
                    )
                    port map(
                        clk         => clk          ,
                        rstn        => rstn         ,
                        en          => cntr_en_w    ,
                        clr         => cntr_clr_w   ,
                        cntr_out    => cntr_out_w
                    );
    ---------------------------------------------------------------------
    L_FSM:      entity work.delta_timer_fsm(rtl)
                    port map(
                        clk         =>  clk         ,
                        rstn        =>  rstn        ,
                        en          =>  fsm_en      ,
                        clr         =>  fsm_clr     ,
                        chg_caught  =>  chg_caught_w,
                        show_cntr   =>  show_cntr_w ,
                        cntr_clr    =>  cntr_clr_w  ,
                        cntr_en     =>  cntr_en_w   ,
                        det_clr     =>  det_clr_w   ,
                        det_en      =>  det_en_w
                    );
    ---------------------------------------------------------------------
end architecture rtl;

