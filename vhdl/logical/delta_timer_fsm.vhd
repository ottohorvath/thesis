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

entity delta_timer_fsm is
    port(
        clk         :   in      std_logic;
        rstn        :   in      std_logic;
        en          :   in      std_logic;
        clr         :   in      std_logic;
        chg_caught  :   in      std_logic;
        show_cntr   :   out     std_logic;
        cntr_clr    :   out     std_logic;
        cntr_en     :   out     std_logic;
        det_clr     :   out     std_logic;
        det_en      :   out     std_logic
    );
end entity delta_timer_fsm;


architecture rtl of delta_timer_fsm   is

    type state_t is(
        IDLE    ,
        ENABLED ,
        COUNTING,
        DONE
    );

    signal  cur_state:  state_t;
    signal  nxt_state:  state_t;



begin

    L_FSM:  block
    begin
        ------------------------------------------------
        L_NEXT_STATE:   process(cur_state,en,clr,chg_caught) is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                ----------------------------------------
                when IDLE       =>  if(en='1' and clr='0')  then
                                        nxt_state   <= ENABLED;
                                    end if;
                ----------------------------------------
                when ENABLED    =>  if(en='0' and clr='1')  then
                                        nxt_state   <= IDLE;
                                    elsif(chg_caught = '1')  then
                                        nxt_state   <= COUNTING;
                                    end if;
                ----------------------------------------
                when COUNTING   =>  if(en='0' and clr='1')  then
                                        nxt_state   <= IDLE;
                                    elsif(chg_caught = '1')  then
                                        nxt_state   <= DONE;
                                    end if;
                ----------------------------------------
                when DONE       =>  if(en='0' and clr='1')  then
                                        nxt_state   <= IDLE;
                                    end if;
                ----------------------------------------
                -- coverage off
                when others =>  nxt_state   <= IDLE;
                -- coverage on
                ----------------------------------------
            end case;
        end process;
        ------------------------------------------------

        -- FSM outputs
        show_cntr   <=  '1' when (cur_state = DONE) else '0';
        cntr_clr    <=  '1' when (cur_state = IDLE) else '0';
        cntr_en     <=  '1' when (cur_state = COUNTING) else '0';
        det_clr     <=  '1' when (cur_state = IDLE) else '0';
        det_en      <=  '1' when ((cur_state = ENABLED) or (cur_state = COUNTING)) else '0';


        ----------------------------------------
        L_STATE_REG:    process(clk,rstn)  is
        begin
            if(rstn = '0')  then
                cur_state   <= IDLE;

            elsif(rising_edge(clk)) then
                cur_state   <= nxt_state;

            end if;
        end process;
        ----------------------------------------
    end block;

end architecture;