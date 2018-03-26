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
entity mode_sel_mux is
    generic(
        WIDTH   :       natural := 32                                      -- Width of one input lane
    );
    port(
        data_i  :   in  std_logic_vector((WIDTH*2)-1    downto  0);
        data_o  :   out std_logic_vector(WIDTH-1        downto  0);
        sel     :   in  std_logic                                          -- Only two input lanes will be implemented (Normal, Test)
    );
end entity mode_sel_mux;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
architecture rtl of mode_sel_mux is

begin

    data_o  <=  data_i((WIDTH*2)-1  downto WIDTH)    when sel = '1'  else
                data_i(WIDTH-1      downto 0);


end architecture rtl;
---------------------------------------------------------------------------