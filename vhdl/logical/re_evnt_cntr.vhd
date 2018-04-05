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
entity re_evnt_cntr is
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
end entity re_evnt_cntr;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of re_evnt_cntr is

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

    
    -- Falling-edge detector signals
    -- =======================
    signal  re_det_reg     :   std_logic;
    signal  re_det_reg_en  :   std_logic;
    signal  re_det_out     :   std_logic;
    
begin
    ---------------------------------------------------------------------
    L_GLOBAL:   block
                begin
                    
                    -- Processor or a component can enable the module
                    global_en   <=  wdata_reg(0) or  trig_in_sc_ff;
                    global_clr  <=  wdata_reg(1);
                    
                    sc_ff_set   <=  trig_in;
                    
                    -- Counter is incremented when the module is globally enabled
                    -- and there was a catch by the edge detector
                    cntr_en_w   <=  global_en   and     re_det_out;
                    
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

                                                -- Drive the 're_det_out' signal from flop
                                                if(trig_out_reg_en = '1') then
                                                    trig_out_reg    <= re_det_out;
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
                                        trig_out    <= re_det_out;
                                    end generate;
                        ------------------------------------------------
                    end block;
    ---------------------------------------------------------------------
    L_RE_DET:  block
                begin
                    re_det_reg_en   <=  global_en;
                    
                    re_det_out  <=  re_det_reg and not(signal_from_DUV);
                                    
                    
                    process(clk,rstn)   is
                    begin
                        if(rstn = '0')  then
                            re_det_reg <= '1';
                            
                        elsif(rising_edge(clk)) then
                            
                            if(re_det_reg_en = '1')    then
                                re_det_reg <= signal_from_DUV;
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

