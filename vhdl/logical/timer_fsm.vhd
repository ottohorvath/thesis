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

entity timer_fsm is
    port(
        clk         :   in      std_logic;
        rstn        :   in      std_logic;
        en_fsm      :   in      std_logic;
        clr_fsm     :   in      std_logic;
        de_caught   :   in      std_logic;
        show_cntr   :   out     std_logic;
        cntr_clr    :   out     std_logic;
        cntr_en     :   out     std_logic;
        det_clr     :   out     std_logic;
        det_en      :   out     std_logic
    );
end entity timer_fsm;


architecture rtl of timer_fsm   is
    
    type state_t is(
        IDLE,
        FSM_ENABLED,
        DE_DET_AND_CNTR_ENABLED,
        DE_CAUGHT_AND_WAIT_FOR_CLR
    );
    
    signal  cur_state:  state_t;
    signal  nxt_state:  state_t;
    
begin
    
    
    -----------------------------------------------------------------
    -- Modeling the output and the next-state logic,
    -- with two-process FSM description, so it is expected from the synthesizer to generate non-buffered (non-registered) outputs.
    
    L_LOGIC:    process(cur_state, en_fsm, clr_fsm, de_caught) is
    begin
        
        nxt_state   <= IDLE;    --
                                
        show_cntr   <= '0';     --  
        cntr_clr    <= '0';     -- Default assignments (otherwise these would model latches)
        cntr_en     <= '0';     --
        det_clr     <= '0';     --
        det_en      <= '0';     --
        
        case(cur_state) is
            ------------------------------------------
            when IDLE =>
            
                --show_cntr   <= '0';
                cntr_clr    <= '1';
                --cntr_en     <= '0';
                det_clr     <= '1';
                --det_en      <= '0';
                
                if(en_fsm = '1' and clr_fsm = '0')  then
                    nxt_state   <= FSM_ENABLED;
                else
                    nxt_state   <= IDLE;
                end if;

            ------------------------------------------
            when FSM_ENABLED =>
                
                det_en  <= '1';
                
                if(en_fsm = '0' and clr_fsm = '1')  then
                    nxt_state   <= IDLE;
                    
                elsif(de_caught = '1')  then
                    nxt_state   <= DE_DET_AND_CNTR_ENABLED;
                
                else
                    nxt_state   <= FSM_ENABLED;
                
                end if;
            ------------------------------------------
            when DE_DET_AND_CNTR_ENABLED =>
                
                cntr_en <= '1';
                det_en  <= '1';
                
                if(en_fsm = '0' and clr_fsm = '1')  then
                    nxt_state   <= IDLE;
                    
                elsif(de_caught = '1')  then
                    nxt_state   <= DE_CAUGHT_AND_WAIT_FOR_CLR;
                    
                else
                    nxt_state   <= DE_DET_AND_CNTR_ENABLED;
                
                end if;
            ------------------------------------------
            when DE_CAUGHT_AND_WAIT_FOR_CLR =>
            
                show_cntr   <= '1';
                
                if(en_fsm = '0' and clr_fsm = '1')  then
                    nxt_state   <= IDLE;
                    
                else
                    nxt_state   <= DE_CAUGHT_AND_WAIT_FOR_CLR;
                    
                end if;
                
            ------------------------------------------
            -- When the FSM reached an undefined state.
            when others =>
            
                report "?" severity failure;
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
end architecture;