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


entity fe_det_fsm is
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        en              :   in  std_logic;
        clr             :   in  std_logic;
        sig_from_fe_det :   in  std_logic;
        fe_caught       :   out std_logic
    );
end entity fe_det_fsm;

architecture rtl of fe_det_fsm is

    type state_t is(
        IDLE        ,
        ENABLED     ,
        CAPTURED
    );

    signal  cur_state   : state_t;
    signal  nxt_state   : state_t;

begin

    L_FSM:  block
    begin
        ---------------------------------------------------
        L_NEXT_STATE: process(cur_state,en,clr,sig_from_fe_det) is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                -------------------------------------------
                when IDLE       =>  if(en='1' and clr='0')  then
                                        nxt_state   <= ENABLED;
                                    end if;
                -------------------------------------------
                when ENABLED    =>  if(clr='1' and en='0')  then
                                        nxt_state   <= IDLE;
                                    elsif(sig_from_fe_det = '1')    then
                                        nxt_state   <= CAPTURED;
                                    end if;
                -------------------------------------------
                when CAPTURED  =>  if(clr='1' and en='0')  then
                                        nxt_state   <= IDLE;
                                    end if;
                -------------------------------------------
                -- coverage off
                when others =>  nxt_state   <= IDLE;
                                report "?"severity failure;
                -- coverage on
                -------------------------------------------
            end case;
        end process;
        ---------------------------------------------------


        -- FSM outputs
        fe_caught   <= '1'  when (cur_state = CAPTURED)    else '0';


        ---------------------------------------
        L_STATE_REG:  process(clk,rstn)  is
        begin
            if(rstn = '0')  then
                cur_state   <= IDLE;

            elsif(rising_edge(clk)) then
                cur_state   <= nxt_state;

            end if;
        end process;
        ---------------------------------------
    end block;




end architecture rtl;