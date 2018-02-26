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
entity de_det is

    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        en              :   in  std_logic;
        clr             :   in  std_logic;
        sig             :   in  std_logic;
        det_out         :   out std_logic
    );
end entity de_det;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of de_det is   


    type    state_t is (
        IDLE        ,
        ENABLED     ,
        SAMPLING
    );
    signal  state       :           state_t;
    
    signal  en_sampling :           std_logic;
    signal  sample      :           std_logic;
    signal  sig_changed :           std_logic;
    
begin
    
    
    det_out <=  sig_changed;      
    
    
    ---------------------------------------------------------------
    L_FSM:  process(clk,rstn)   is
    begin
        if(rstn = '0')  then
            state           <= IDLE;
            en_sampling     <= '0';
            sig_changed     <= '0';
            
            
        elsif(rising_edge(clk)) then
        
            case(state) is
                ----------------------------------------
                when IDLE       => sig_changed  <= '0';
                                   en_sampling  <= '0';
                                   
                                   
                                   if(en = '1')   then
                                       state    <= ENABLED;
                                   end if;
                ----------------------------------------
                when ENABLED    => en_sampling  <= '1';
                                    
                                   state        <= SAMPLING;
                ----------------------------------------
                when SAMPLING   => if(sample /= sig)   then--
                                      sig_changed <= '1';  --
                                   else                    -- Dual edge detector :D
                                      sig_changed <= '0';  --
                                   end if;                 --
                                                           
                                   if(clr = '1')  then
                                      state     <= IDLE;
                                   end if;
                ----------------------------------------
                when others     =>  state <= IDLE;
                
            end case;
        end if;
        
        
        
    
    end process;
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























