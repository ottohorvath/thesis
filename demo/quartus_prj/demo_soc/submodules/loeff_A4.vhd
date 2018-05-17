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
entity loeff_A4 is
    port(
        dataIn  :   in  dctArray;
        dataOut :   out dctArray
    );
end entity loeff_A4;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of loeff_A4 is

    -- Type of inner data,
    -- By default it an array of 8 16 bits signed data
    signal data_inside_A4   :   dctArray;

begin

    L_BUTTERFLY_A4: process(dataIn)
                    begin
                        data_inside_A4(0) <= std_logic_vector( signed(dataIn(0)) );
                        data_inside_A4(1) <= std_logic_vector(  resize(shift_right( 181*(signed(dataIn(7)) + signed(dataIn(4)) ) ,8), 16)   );
                        data_inside_A4(2) <= std_logic_vector( signed(dataIn(2))  );
                        data_inside_A4(3) <= std_logic_vector( signed(dataIn(5))  );
                        data_inside_A4(4) <= std_logic_vector( signed(dataIn(1))  );
                        data_inside_A4(5) <= std_logic_vector( signed(dataIn(6))  );
                        data_inside_A4(6) <= std_logic_vector( signed(dataIn(3))  );
                        data_inside_A4(7) <= std_logic_vector(  resize(shift_right( 181*(signed(dataIn(7)) - signed(dataIn(4)) ) ,8), 16)   );
                    end process;

    L_DRIVE_OUTPUTS:block
                    begin
                        dataOut(0)  <= data_inside_A4(0);
                        dataOut(1)  <= data_inside_A4(1);
                        dataOut(2)  <= data_inside_A4(2);
                        dataOut(3)  <= data_inside_A4(3);
                        dataOut(4)  <= data_inside_A4(4);
                        dataOut(5)  <= data_inside_A4(5);
                        dataOut(6)  <= data_inside_A4(6);
                        dataOut(7)  <= data_inside_A4(7);
                    end block;

end architecture rtl;
------------------------------------------------------------------