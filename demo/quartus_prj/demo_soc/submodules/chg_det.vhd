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
entity chg_det is

    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        en              :   in  std_logic;
        clr             :   in  std_logic;
        sig             :   in  std_logic;
        det_out         :   out std_logic
    );
end entity chg_det;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of chg_det is

    -- Sampler flop
    -- ============
    signal  sample      :   std_logic;

    -- Enable signal from FSM
    -- ======================
    signal  en_sampling :   std_logic;


    -- AND gate on 'sig' input
    -- =======================
    signal  sig_gated:   std_logic;




begin

    ---------------------------------------------------------------
    L_GATE: block
            begin
                sig_gated   <= sig and en_sampling;
            end block;
    ---------------------------------------------------------------
    L_SAMPLER:  process(clk,rstn)  is
    begin
        if(rstn = '0')  then
            sample <= '0';

        elsif(rising_edge(clk)) then
            -----------------------------
            if(en_sampling = '1')   then
                sample  <= sig_gated;

            end if;
            -----------------------------
        end if;
    end process;
    ---------------------------------------------------------------
    L_FSM:      entity work.chg_det_fsm(rtl)
                    port map(
                        clk             =>  clk         ,
                        rstn            =>  rstn        ,
                        en_fsm          =>  en          ,
                        clr_fsm         =>  clr         ,
                        sig_fsm         =>  sig_gated   ,
                        sample_fsm      =>  sample      ,
                        en_sampling_fsm =>  en_sampling ,
                        sig_changed_fsm =>  det_out
                    );
    ---------------------------------------------------------------------
end architecture rtl;

