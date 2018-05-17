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
        CW              :   natural:= 7
    );
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        en              :   in  std_logic;
        clr             :   in  std_logic;
        cntr_out        :   out std_logic_vector(CW-1    downto  0)
    );
end entity cntr;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of cntr is

    -- coverage off t
    signal q:   std_logic_vector(CW-1    downto  0);
    -- coverage on

    function and_reduc(
        slv :   in std_logic_vector
    ) return std_logic
    is
        variable res_v : std_logic:= '1';
    begin
        for i in slv'range loop
            res_v := res_v and slv(i);
        end loop;

        return res_v;
    end function;


begin


    -------------------------------------------------------
    L_CNTR_P:   process(clk, rstn)  is
    begin
        if(rstn = '0')  then
            q   <= (others =>'0');

        elsif(rising_edge(clk)) then

            if(en = '1')  then
                -- Prevent from overflow
                if (not(and_reduc(q)) = '1')  then
                    q   <= std_logic_vector(unsigned(q) + 1);
                end if;
            end if;

            if (clr = '1')    then
                q   <= (others =>'0');
            end if;

        end if;
    end process;




    cntr_out    <= q;

    -------------------------------------------------------

end architecture rtl;
