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

-----------------------------------------------
entity DCT_2D_tb is
end entity DCT_2D_tb;
-----------------------------------------------

architecture bhv of DCT_2D_tb is
    constant    period      :           time            := 10 ns;
    signal      dataIn_tb   :           inputPixelBlock := (others =>   (others =>  (others => '0')))   ;
    signal      dataOut_tb  :           outputPixelBlock:= (others =>   (others =>  (others => '0')))   ;
    signal      clk_tb      :           std_logic       := '1';
    signal      rstn_tb     :           std_logic       := '0';
    signal      start_dct_tb:           std_logic       := '0';
    signal      dct_done_tb :           std_logic       := '0';

begin
    L_DUT:  entity work.DCT_2D(rtl)
                port map(
                    clk             =>  clk_tb      ,
                    rstn            =>  rstn_tb     ,
                    start_dct       =>  start_dct_tb,
                    busy            =>  open        ,
                    pixel_block_in  =>  dataIn_tb   ,
                    pixel_block_out =>  dataOut_tb  ,
                    dct_done        =>  dct_done_tb
                );

    L_TEST_SEQUENCES:   process
    begin
        wait for 1 ns;
        rstn_tb <= '1';
        wait for 1 ns;

        wait until rising_edge(clk_tb);

        dataIn_tb(0,0)  <= b"01100100"; dataIn_tb(2,0)  <= b"00001100"; dataIn_tb(4,0)  <= b"10100110"; dataIn_tb(6,0)  <= b"01010111";
        dataIn_tb(0,1)  <= b"01010000"; dataIn_tb(2,1)  <= b"01101101"; dataIn_tb(4,1)  <= b"10110010"; dataIn_tb(6,1)  <= b"00011101";
        dataIn_tb(0,2)  <= b"11011010"; dataIn_tb(2,2)  <= b"00010101"; dataIn_tb(4,2)  <= b"01101010"; dataIn_tb(6,2)  <= b"01000001";
        dataIn_tb(0,3)  <= b"11100001"; dataIn_tb(2,3)  <= b"10010011"; dataIn_tb(4,3)  <= b"00000111"; dataIn_tb(6,3)  <= b"01101111";
        dataIn_tb(0,4)  <= b"00010001"; dataIn_tb(2,4)  <= b"10000011"; dataIn_tb(4,4)  <= b"10101001"; dataIn_tb(6,4)  <= b"11001111";
        dataIn_tb(0,5)  <= b"10101010"; dataIn_tb(2,5)  <= b"11000011"; dataIn_tb(4,5)  <= b"00110000"; dataIn_tb(6,5)  <= b"11110011";
        dataIn_tb(0,6)  <= b"10111010"; dataIn_tb(2,6)  <= b"10100111"; dataIn_tb(4,6)  <= b"00001001"; dataIn_tb(6,6)  <= b"10010100";
        dataIn_tb(0,7)  <= b"10011011"; dataIn_tb(2,7)  <= b"10000001"; dataIn_tb(4,7)  <= b"01010001"; dataIn_tb(6,7)  <= b"10010101";

        dataIn_tb(1,0)  <= b"01110101"; dataIn_tb(3,0)  <= b"10100011"; dataIn_tb(5,0)  <= b"11000001"; dataIn_tb(7,0)  <= b"11000001";
        dataIn_tb(1,1)  <= b"10111110"; dataIn_tb(3,1)  <= b"11011001"; dataIn_tb(5,1)  <= b"11000000"; dataIn_tb(7,1)  <= b"11111001";
        dataIn_tb(1,2)  <= b"01010100"; dataIn_tb(3,2)  <= b"00001100"; dataIn_tb(5,2)  <= b"11001001"; dataIn_tb(7,2)  <= b"01000000";
        dataIn_tb(1,3)  <= b"00010001"; dataIn_tb(3,3)  <= b"10001101"; dataIn_tb(5,3)  <= b"01000111"; dataIn_tb(7,3)  <= b"10100001";
        dataIn_tb(1,4)  <= b"11111000"; dataIn_tb(3,4)  <= b"11010110"; dataIn_tb(5,4)  <= b"01001011"; dataIn_tb(7,4)  <= b"00000111";
        dataIn_tb(1,5)  <= b"00011010"; dataIn_tb(3,5)  <= b"00100111"; dataIn_tb(5,5)  <= b"00111111"; dataIn_tb(7,5)  <= b"10010101";
        dataIn_tb(1,6)  <= b"01101001"; dataIn_tb(3,6)  <= b"01010011"; dataIn_tb(5,6)  <= b"01111111"; dataIn_tb(7,6)  <= b"11110001";
        dataIn_tb(1,7)  <= b"01110110"; dataIn_tb(3,7)  <= b"01000110"; dataIn_tb(5,7)  <= b"01011110"; dataIn_tb(7,7)  <= b"11100110";

        wait for 1 ns;


        wait until rising_edge(clk_tb);
        wait for 1 ns;
        start_dct_tb <= '1';

        wait until rising_edge(clk_tb);
        start_dct_tb <= '0';
        wait for 1 ns;

        wait;
    end process;

    L_CLK_GEN:  process
    begin
        wait for period/2;
        clk_tb <= not clk_tb ;
    end process;

end architecture bhv;