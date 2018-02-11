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
entity asd is
    --generic(
    --
    --);
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        do              :   out std_logic_vector(31 downto 0)
    );
end entity asd;
---------------------------------------------------------------------------


architecture rtl of asd is

begin
    
    process(clk,rstn)   is
        variable tmp:   std_logic_vector(31 downto 0);
    begin
        if( rstn = '0') then
            tmp := (others => '0');
            
        elsif( rising_edge(clk) )   then
            tmp := std_logic_vector( unsigned(tmp) + 1);
        
        end if;
        
        
        do <= tmp;
        
    end process;
    
    
    
    
    
end architecture;