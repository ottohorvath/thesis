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

    signal de_reg   :   std_logic;
    signal de_xor   :   std_logic;
    
    signal dout     :   std_logic;
    
    
begin
    
    
    -----------------------------------------------
    L_DE_DET:
        process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                de_reg  <= '0';
                
            elsif(rising_edge(clk)) then
                de_reg  <= sig; 
            
            end if;
        end process;
        
        de_xor <= de_reg xor sig;                   -- Simple dual-edge detection: XOR-ing the input and the output of the flop
    -----------------------------------------------
    
    
    
    -----------------------------------------------
    L_DE_DOUT:
        process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                dout    <= '0';
                
            elsif(rising_edge(clk)) then
                ----------------------------------------
                if(en = '1' and clr = '0')    then  -- When it needs to watch the DUV signal
                
                    dout <= de_xor;                 -- Just pass the change indicator signal to the flop.
                    
                end if;
                ----------------------------------------     
                if(en = '0' and clr = '1')   then   -- When it needs to be cleared
                
                    dout <= '0';
                    
                end if;
                ----------------------------------------
            end if;
        end process;
        
        det_out <= dout;
    -----------------------------------------------
    
end architecture rtl;























