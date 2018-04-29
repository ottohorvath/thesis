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
entity loeff_A2 is
    port(
        dataIn  :   in  dctArray;
        dataOut :   out dctArray
    );
end entity loeff_A2;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of loeff_A2 is

    -- Type of inner data,
    -- By defualt it an array of 8 16 bits signed data
    signal data_inside_A2:  dctArray;

begin

    L_BUTTERFLY_A2: process(dataIn)
                    begin
                        data_inside_A2(0) <= std_logic_vector( signed(dataIn(0)) + signed(dataIn(3)) );
                        data_inside_A2(1) <= std_logic_vector( signed(dataIn(1)) + signed(dataIn(2)) );
                        data_inside_A2(2) <= std_logic_vector( signed(dataIn(1)) - signed(dataIn(2)) );
                        data_inside_A2(3) <= std_logic_vector( signed(dataIn(0)) - signed(dataIn(3)) );

                        -- Multiply, then divide by 8 and finally narrow it to signed 16 bits
                        data_inside_A2(4) <= std_logic_vector(  resize(shift_right((301*signed(dataIn(4))) + (201*signed(dataIn(7))),8), 16)    );
                        data_inside_A2(5) <= std_logic_vector(  resize(shift_right((355*signed(dataIn(5))) + (71*signed(dataIn(6))) ,8), 16)    );
                        data_inside_A2(6) <= std_logic_vector(  resize(shift_right((355*signed(dataIn(6))) - (71*signed(dataIn(5))) ,8), 16)    );
                        data_inside_A2(7) <= std_logic_vector(  resize(shift_right((301*signed(dataIn(7))) - (201*signed(dataIn(4))),8), 16)    );
                    end process;

    L_DRIVE_OUTPUTS:block
                    begin
                        dataOut(0)  <= data_inside_A2(0);
                        dataOut(1)  <= data_inside_A2(1);
                        dataOut(2)  <= data_inside_A2(2);
                        dataOut(3)  <= data_inside_A2(3);
                        dataOut(4)  <= data_inside_A2(4);
                        dataOut(5)  <= data_inside_A2(5);
                        dataOut(6)  <= data_inside_A2(6);
                        dataOut(7)  <= data_inside_A2(7);
                    end block;

end architecture rtl;
------------------------------------------------------------------