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

entity chg_det_fsm is
    port(
        clk             :   in      std_logic;
        rstn            :   in      std_logic;
        en_fsm          :   in      std_logic;
        clr_fsm         :   in      std_logic;
        sig_fsm         :   in      std_logic;
        sample_fsm      :   in      std_logic;
        en_sampling_fsm :   out     std_logic;
        sig_changed_fsm :   out     std_logic
    );
end entity chg_det_fsm;


architecture rtl of chg_det_fsm   is

    type state_t is(
        IDLE    ,
        ENABLED 
    );

    signal  cur_state:  state_t;
    signal  nxt_state:  state_t;

begin

     ---------------------------------------------------------------
    L_FSM:  block
    begin
        ----------------------------------------
        L_NEXT_STATE:   process(cur_state,en_fsm,clr_fsm)   is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                ----------------------------------------
                when IDLE       =>  if(en_fsm = '1' and clr_fsm = '0')   then
                                        nxt_state   <= ENABLED;
                                    end if;
                ----------------------------------------
                when ENABLED    =>  if(clr_fsm = '1' and en_fsm = '0')  then
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
        en_sampling_fsm <=  '1' when( cur_state = ENABLED )   else '0';
        sig_changed_fsm <=  '1' when((cur_state = ENABLED) and (sig_fsm /= sample_fsm)) else '0';

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

end architecture;