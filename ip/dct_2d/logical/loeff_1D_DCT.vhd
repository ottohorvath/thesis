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
entity loeff_1D_DCT is
    port(
        clk             :   in      std_logic;
        rstn            :   in      std_logic;
        doneDCT         :   out     std_logic;
        en              :   in      std_logic;
        dataInDCT       :   in      dctArray;
        dataOutDCT      :   out     dctArray
    );
end entity loeff_1D_DCT;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of loeff_1D_DCT is

    signal data_from_INPUT_to_A1    : dctArray  ;
    signal data_from_A1_to_A2       : dctArray  ;
    signal data_from_A2_to_A3       : dctArray  ;
    signal data_from_A3_to_A4       : dctArray  ;
    signal data_from_from_A4        : dctArray  ;

    signal done_dct                 : std_logic ;
    signal reg1                     : dctArray  ;
    signal reg2                     : dctArray  ;
    signal reg3                     : dctArray  ;
    signal reg4                     : dctArray  ;
    signal reg5                     : dctArray  ;
    signal pipeline_cntr            : std_logic_vector(2 downto 0);

begin


    ---------------------------------------------------------------------
    L_SEQUENTIAL:   process(clk,rstn)
                    begin
                        if(rstn ='0') then
                            done_dct        <=  '0'                     ;
                            reg1            <= (others =>(others =>'0'));
                            reg2            <= (others =>(others =>'0'));
                            reg3            <= (others =>(others =>'0'));
                            reg4            <= (others =>(others =>'0'));
                            reg5            <= (others =>(others =>'0'));
                            pipeline_cntr   <= (others => '0')          ;
                        elsif(rising_edge(clk)) then

                            done_dct <= '0';

                            if(en = '1') then
                                -- Pipeline stage 1.
                                reg1    <= data_from_INPUT_to_A1;
                                -- Pipeline stage 2.
                                reg2    <= data_from_A1_to_A2;
                                -- Pipeline stage 3.
                                reg3    <= data_from_A2_to_A3;
                                -- Pipeline stage 4.
                                reg4    <= data_from_A3_to_A4;
                                -- Pipeline stage 5.
                                reg5    <= data_from_from_A4;
                                -- Pipeline counter increasing
                                pipeline_cntr <= std_logic_vector(unsigned(pipeline_cntr) + 1);
                            end if;

                            -- Generate done
                            if(pipeline_cntr = b"101")  then
                                done_dct        <= '1';
                                pipeline_cntr   <= b"000";
                            end if;
                        end if;
                    end process;
    ---------------------------------------------------------------------

    --------------------------------------------
    L_A1:   entity work.loeff_A1(rtl)
                port map(
                    dataIn  =>  reg1,
                    dataOut =>  data_from_A1_to_A2
                );
    --------------------------------------------

    --------------------------------------------
    L_A2:   entity work.loeff_A2(rtl)
                port map(
                    dataIn  =>  reg2,
                    dataOut =>  data_from_A2_to_A3
                );
    --------------------------------------------


    --------------------------------------------
    L_A3:   entity work.loeff_A3(rtl)
                port map(
                    dataIn  =>  reg3,
                    dataOut =>  data_from_A3_to_A4
                );
    --------------------------------------------

    --------------------------------------------
    L_A4:   entity work.loeff_A4(rtl)
                port map(
                    dataIn  =>  reg4,
                    dataOut =>  data_from_from_A4
                );
    --------------------------------------------

    ---------------------------------------------------------------------
    L_DATAIN_ASSIGNMENT :   data_from_INPUT_to_A1   <= dataInDCT;
    L_DATAOUT_ASSIGNMENT:   dataOutDCT              <= reg5;
    L_DONE_ASSIGNMENT   :   doneDCT                 <= done_dct;
    ---------------------------------------------------------------------

end architecture rtl;
------------------------------------------------------------------