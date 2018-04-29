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
---------------------------------
use     work.dct_package.all    ;
---------------------------------



------------------------------------------------------------------
entity loeff_A1 is
    port(
        dataIn  :   in  dctArray;
        dataOut :   out dctArray
    );
end entity loeff_A1;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of loeff_A1 is

    -- Type of inner data,
    -- By defualt it an array of 8 16 bits signed data
    signal data_inside_A1: dctArray;

begin

    L_BUTTERFLY_A1: process(dataIn)
                    begin
                        data_inside_A1(0) <= std_logic_vector( signed(dataIn(0)) + signed(dataIn(7)) );
                        data_inside_A1(1) <= std_logic_vector( signed(dataIn(1)) + signed(dataIn(6)) );
                        data_inside_A1(2) <= std_logic_vector( signed(dataIn(2)) + signed(dataIn(5)) );
                        data_inside_A1(3) <= std_logic_vector( signed(dataIn(3)) + signed(dataIn(4)) );
                        data_inside_A1(4) <= std_logic_vector( signed(dataIn(3)) - signed(dataIn(4)) );
                        data_inside_A1(5) <= std_logic_vector( signed(dataIn(2)) - signed(dataIn(5)) );
                        data_inside_A1(6) <= std_logic_vector( signed(dataIn(1)) - signed(dataIn(6)) );
                        data_inside_A1(7) <= std_logic_vector( signed(dataIn(0)) - signed(dataIn(7)) );
                    end process;

    L_DRIVE_OUTPUTS:block
                    begin
                        dataOut(0)  <= data_inside_A1(0);
                        dataOut(1)  <= data_inside_A1(1);
                        dataOut(2)  <= data_inside_A1(2);
                        dataOut(3)  <= data_inside_A1(3);
                        dataOut(4)  <= data_inside_A1(4);
                        dataOut(5)  <= data_inside_A1(5);
                        dataOut(6)  <= data_inside_A1(6);
                        dataOut(7)  <= data_inside_A1(7);
                    end block;

end architecture rtl;
------------------------------------------------------------------