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


entity re_det_fsm is
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        en              :   in  std_logic;
        clr             :   in  std_logic;
        sig_from_re_det :   in  std_logic;
        re_caught       :   out std_logic
    );
end entity re_det_fsm;

architecture rtl of re_det_fsm is
    
    type state_t is(
        IDLE,
        ENABLED_AND_WAIT_FOR_RE,
        RE_CAUGHT_AND_WAIT_FOR_CLR
    );
    
    signal  cur_state   : state_t;
    signal  nxt_state   : state_t;
    
begin
    
    -----------------------------------------------------------------
    -- Modeling the output and the next-state logic,
    -- with two-process FSM description, so it is expected from the synthesizer to generate non-buffered (non-registered) outputs.
    
    L_LOGIC: process(cur_state, en, clr, sig_from_re_det) is
    begin
        
        re_caught   <= '0'  ;   
        nxt_state   <= cur_state ;   
        
        case (cur_state)    is
            ------------------------------------------
            when IDLE =>                                    -- Waiting for the enablement
                
                re_caught   <= '0';
                
                if(en = '1' and clr = '0')  then            -- If it is enabled and not cleared, at the same time
                    nxt_state   <= ENABLED_AND_WAIT_FOR_RE;
                end if;
            ------------------------------------------
            when ENABLED_AND_WAIT_FOR_RE =>                -- It is enabled, waiting for a rise-edge on the watched signal
                                                            
                if(clr = '1' and en = '0')  then            -- Or it can be cleared (disabled)
                    nxt_state   <= IDLE;
                
                elsif(sig_from_re_det = '1')   then
                    nxt_state   <= RE_CAUGHT_AND_WAIT_FOR_CLR;
                    
                end if;
            ------------------------------------------
            when RE_CAUGHT_AND_WAIT_FOR_CLR  =>             -- After the enablement, a rise-edge was caught, stays here until clearing
                
                re_caught   <= '1';                         -- Signaling the successfull rise-edge capturing
                
                if(clr = '1' and en = '0')  then
                    nxt_state   <= IDLE;
                    
                end if;
            ------------------------------------------
            -- When the FSM reached an undefined state.
            when others =>
                report "?"severity failure;
                nxt_state   <= IDLE;
            ------------------------------------------
        end case;
    end process;
    
    
    
    
    ------------------------------------------
    -- Modeling the state-register.
    
    L_STATE_REG_P:  process(clk, rstn)  is
    begin
        if(rstn = '0')  then
            cur_state   <= IDLE;
        elsif(rising_edge(clk)) then
            cur_state   <= nxt_state;
        end if;
    end process;
    ------------------------------------------
    
    
    
end architecture rtl;