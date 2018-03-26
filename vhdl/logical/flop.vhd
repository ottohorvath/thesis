---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Generic D flip-flop with adjustable reseting sensitivity
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity flop is
    generic(
        ACTIVE_LOW  :   boolean :=  true
    );
    port(
        clk         :   in  std_logic;
        rst         :   in  std_logic;
        d           :   in  std_logic;
        q           :   out std_logic
    );
end entity flop;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of flop is

    -- D flop
    -- =======
    signal  flop    :   std_logic;

begin
    ---------------------------------------------
    L_Q :   q   <=  flop;
    ---------------------------------------------
    L_ALOW: if(ACTIVE_LOW = true)   generate
                ---------------------------------
                process(clk,rst)   is
                begin

                    if( rst = '0')  then
                        flop    <=  '0';
                    elsif(rising_edge(clk)) then
                        flop    <=  d;
                    end if;

                end process;
                ---------------------------------
            end generate;
    ---------------------------------------------
    L_AHIGH:if(ACTIVE_LOW = false)   generate
                ---------------------------------
                process(clk,rst)   is
                begin

                    if( rst = '1')  then
                        flop    <=  '0';
                    elsif(rising_edge(clk)) then
                        flop    <=  d;
                    end if;

                end process;
                ---------------------------------
            end generate;
    ---------------------------------------------
end architecture rtl;
---------------------------------------------------------------------------