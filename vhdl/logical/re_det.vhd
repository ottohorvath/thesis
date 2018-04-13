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
entity re_det is
    generic(
        REG_LAYER       :       boolean     :=  false  -- For timing closure purposes
    );
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        wr              :   in  std_logic;
        wdata           :   in  std_logic_vector(1  downto  0);
        rdata           :   out std_logic;
        trig_out        :   out std_logic;
        signal_from_DUV :   in  std_logic
    );
end entity re_det;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of re_det is

    -- Write Data Register
    -- ===================
    -- [0]: Module is enabled
    -- [1]: Module is cleared
    -- These bits are fed into the FSM as inputs
    signal      wdata_reg   :   std_logic_vector(1 downto 0);


    -- Rising-edge detector signals
    -- =============================
    signal      re_det_reg      :   std_logic;
    signal      re_det_reg_en   :   std_logic;
    signal      re_det_out      :   std_logic;


    -- Signals from FSM
    -- ===================
    signal      fsm_re_caught       :   std_logic;


    -- Trigger output signals
    -- ======================
    signal      trig_out_reg        :   std_logic;

begin
    ---------------------------------------------------------------------
    L_WDATA:    block
                begin
                    -----------------------------------------------------
                    L_WDATA_REG:    process(clk,rstn) is
                                    begin
                                        if(rstn = '0') then
                                            wdata_reg <= b"00";

                                        elsif(rising_edge(clk)) then

                                            if(wr = '1')    then
                                                wdata_reg   <= wdata;
                                            end if;

                                        end if;
                                    end process;
                    -----------------------------------------------------
                end block;
    ---------------------------------------------------------------------
    L_TRIG:     block
                begin
                    L_REG:  if(REG_LAYER = true)    generate
                                process(clk,rstn) is
                                begin
                                    if(rstn = '0')  then
                                        trig_out_reg    <= '0';
                                    elsif(rising_edge(clk)) then
                                        trig_out_reg    <= fsm_re_caught;
                                    end if;
                                end process;

                                -- Drive trig_out from flop
                                trig_out    <= trig_out_reg;
                            end generate;

                    L_NOREG:if(REG_LAYER = false)   generate

                                -- Drive it directly
                                trig_out    <= fsm_re_caught;
                            end generate;
                end block;
    ---------------------------------------------------------------------
    L_RDATA:    block
                begin
                    -- FSM caught the rising-edge event
                    rdata   <=  fsm_re_caught;
                end block;
    ---------------------------------------------------------------------
    L_RE_DETECTOR:  block
                    begin
                        -----------------------------------------------------
                        L_RE_DET_REG:   process(clk,rstn) is
                                        begin
                                            if(rstn = '0')  then
                                                re_det_reg <= '1';

                                            elsif(rising_edge(clk)) then

                                                -- Only sampling when it is needed
                                                if(re_det_reg_en = '1') then
                                                    re_det_reg  <= signal_from_DUV;
                                                end if;

                                            end if;
                                        end process;
                        -----------------------------------------------------
                        -- Enablement is coming from 'wdata_reg'
                        re_det_reg_en   <= wdata_reg(0);
                        -----------------------------------------------------
                        -- Detector output
                        re_det_out      <=  not(re_det_reg)  and signal_from_DUV;
                    end block;
    ---------------------------------------------------------------------
    L_FSM:  entity work.re_det_fsm(rtl)
                port map(
                    clk             =>  clk             ,
                    rstn            =>  rstn            ,
                    en              =>  wdata_reg(0)    ,
                    clr             =>  wdata_reg(1)    ,
                    sig_from_re_det =>  re_det_out      ,
                    re_caught       =>  fsm_re_caught
                );
    ---------------------------------------------------------------------
end architecture rtl;
