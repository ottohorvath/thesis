---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Generic "Reset D flip-flop" with adjustable reseting sensitivity
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity reset_flop is
    generic(
        ACTIVE_LOW  :   boolean :=  true
    );
    port(
        clk         :   in  std_logic;
        rst         :   in  std_logic;
        d           :   in  std_logic;
        q           :   out std_logic
    );
end entity reset_flop;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of reset_flop is

    -- D flop
    -- =======
    signal  reset_flop    :   std_logic;

begin
    ---------------------------------------------
    L_Q :   q   <=  reset_flop;
    ---------------------------------------------
    L_ALOW: if(ACTIVE_LOW = true)   generate
                ---------------------------------
                process(clk,rst)   is
                begin

                    if( rst = '0')  then
                        reset_flop    <=  '0';
                    elsif(rising_edge(clk)) then
                        reset_flop    <=  d;
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
                        reset_flop    <=  '1';
                    elsif(rising_edge(clk)) then
                        reset_flop    <=  d;
                    end if;

                end process;
                ---------------------------------
            end generate;
    ---------------------------------------------
end architecture rtl;
---------------------------------------------------------------------------