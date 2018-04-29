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
entity loeff_A3 is
    port(
        dataIn  :   in  dctArray;
        dataOut :   out dctArray
    );
end entity loeff_A3;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of loeff_A3 is

    -- Type of inner data,
    -- By defualt it an array of 8 16 bits signed data
    signal data_inside_A3:  dctArray;

begin

    L_BUTTERFLY_A3: process(dataIn)
                    begin
                        data_inside_A3(0) <= std_logic_vector( signed(dataIn(0)) + signed(dataIn(1)) );
                        data_inside_A3(1) <= std_logic_vector( signed(dataIn(0)) - signed(dataIn(1)) );

                        -- Multiply, then divide by 8 and finally narrow it to signed 16 bits
                        data_inside_A3(2) <= std_logic_vector(  resize(shift_right((139*signed(dataIn(2))) + (334*signed(dataIn(3))),8), 16)    );
                        data_inside_A3(3) <= std_logic_vector(  resize(shift_right((139*signed(dataIn(3))) - (334*signed(dataIn(2))),8), 16)    );


                        data_inside_A3(4) <= std_logic_vector( signed(dataIn(4)) + signed(dataIn(6)) );
                        data_inside_A3(5) <= std_logic_vector( signed(dataIn(7)) - signed(dataIn(5)) );
                        data_inside_A3(6) <= std_logic_vector( signed(dataIn(4)) - signed(dataIn(6)) );
                        data_inside_A3(7) <= std_logic_vector( signed(dataIn(7)) + signed(dataIn(5)) );
                    end process;

    L_DRIVE_OUTPUTS:block
                    begin
                        dataOut(0)  <= data_inside_A3(0);
                        dataOut(1)  <= data_inside_A3(1);
                        dataOut(2)  <= data_inside_A3(2);
                        dataOut(3)  <= data_inside_A3(3);
                        dataOut(4)  <= data_inside_A3(4);
                        dataOut(5)  <= data_inside_A3(5);
                        dataOut(6)  <= data_inside_A3(6);
                        dataOut(7)  <= data_inside_A3(7);
                    end block;

end architecture rtl;
------------------------------------------------------------------