---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ This module is implementing a D-FF style operation with only
--                'set' and 'clr' inputs to change the output 'q'.
--
--              ~ It is built around a rising-edge D flop.
--
--              ~ The storage inside is reset to logic 0 by default with an
--                async. active LOW reset input pin 'rstn'.
--
--              ~ Whenever 'set' input is asserted for one 'clk' cycle, it makes
--                the output 'q' to logic 1, regardless what was its prev. value.
--
--              ~ The same can be said for the 'clr' input, with the only difference
--                that it flips the output 'q' to logic 0.
--
--              ~ At all other cases of the 'set' and 'clr' inputs, the output 'q'
--                remains unchanged.
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity sc_ff  is
    --generic(
    --
    --);
    port(
        clk     :   in  std_logic;
        rstn    :   in  std_logic;
        set     :   in  std_logic;  -- control input
        clr     :   in  std_logic;  -- control input
        q       :   out std_logic   -- status output
    );
end entity sc_ff;
---------------------------------------------------------------------------





---------------------------------------------------------------------------
architecture rtl  of  sc_ff is

    signal  int_q   :   std_logic;
begin


    --------------------------------------------------------
    L_SEQ_P:    process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                int_q   <= '0';                         -- Reset to 0

            elsif(rising_edge(clk)) then

                if(set = '1' and clr = '0') then    -- When the flop must be logic 1
                    int_q <= '1';
                end if;

                if(set = '0' and clr = '1') then    -- When the flop must be logic 0
                    int_q <= '0';
                end if;

            end if;
        end process;

        q   <= int_q;                   -- Driving the output
    --------------------------------------------------------

end architecture rtl;
---------------------------------------------------------------------------
