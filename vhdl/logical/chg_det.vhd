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

    type    state_t is (
        IDLE        ,
        ENABLED
    );
    signal  cur_state:  state_t;
    signal  nxt_state:  state_t;

    signal  en_sampling :           std_logic;
    signal  sig_changed :           std_logic;

    signal  sample      :           std_logic;
begin


    -- Driving FSM output to primer output
    det_out <=  sig_changed;


    ---------------------------------------------------------------
    L_FSM:  block
    begin
        ----------------------------------------
        L_NEXT_STATE:   process(cur_state,en,clr)   is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                ----------------------------------------
                when IDLE       =>  if(en = '1' and clr = '0')   then
                                        nxt_state   <= ENABLED;
                                    end if;
                ----------------------------------------
                when ENABLED    =>  if(clr = '1' and en = '0')  then
                                        nxt_state   <= IDLE;
                                    end if;
                ----------------------------------------
                -- coverage off
                when others     =>  nxt_state <= IDLE;
                -- coverage on
            end case;
        end process;
        ----------------------------------------

        -- FSM outputs
        en_sampling <=  '1' when( cur_state = ENABLED )   else '0';
        sig_changed <=  '1' when((cur_state = ENABLED) and (sig /= sample)) else '0';

        ----------------------------------
        L_STATE_REG: process (clk,rstn) is
        begin
            if(rstn='0')    then
                cur_state   <= IDLE;

            elsif(rising_edge(clk)) then
                cur_state   <= nxt_state;

            end if;
        end process;
        ----------------------------------

    end block;
    ---------------------------------------------------------------


    ---------------------------------------------------------------
    L_SAMPLER:  process(clk,rstn)  is
    begin
        if(rstn = '0')  then
            sample <= '0';

        elsif(rising_edge(clk)) then
            -----------------------------
            if(en_sampling = '1')   then
                sample  <= sig;

            end if;
            -----------------------------
        end if;
    end process;
    ---------------------------------------------------------------

end architecture rtl;

