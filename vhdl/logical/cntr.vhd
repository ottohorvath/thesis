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
entity cntr is
    generic(
        WIDTH           :   natural:= 32
    );
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        en              :   in  std_logic;
        clr             :   in  std_logic;
        number_of_cycles:   out std_logic_vector(WIDTH-1    downto  0)
    );
end entity cntr;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of cntr is
    
    -- coverage off t
    signal q:   std_logic_vector(WIDTH-1    downto  0);
    -- coverage on
    
    
begin

    
    -------------------------------------------------------
    L_CNTR_P:   process(clk, rstn)  is
    begin
        if(rstn = '0')  then
            q   <= (others =>'0');
            
        elsif(rising_edge(clk)) then
        
            if(en = '1')  then
                q   <= std_logic_vector(unsigned(q) + 1);
            end if;
            
            if (clr = '1')    then
                q   <= (others =>'0');
            end if;
            
        end if;
    end process;
    
    
    
    
    number_of_cycles    <= q;
    
    -------------------------------------------------------

end architecture rtl;
