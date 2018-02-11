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
entity wtf is
    --generic(
    --
    --);
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        
        en              :   in  std_logic;
        do              :   out std_logic_vector(31 downto 0)
    );
end entity wtf;
---------------------------------------------------------------------------


architecture rtl of wtf is
    
    signal  tmp:    std_logic_vector(31 downto 0);
    
begin
    
    process(clk,rstn)   is
    begin
        if( rstn = '0') then
            tmp <= (others => '0');
            
        elsif( rising_edge(clk) )   then
            
            if(en = '1')    then
                tmp <= std_logic_vector( unsigned(tmp) + 1);
            end if;
            
        end if;
    end process;
    
    
    do <= tmp;
    
    
end architecture;