library ieee                ;
use ieee.numeric_std.all    ;
use ieee.std_logic_1164.all ;

--use work.dct_package.all;
USE WORK.LOEFF_1D_DCT_DATA_TYPE.ALL;
-----------------------------------------------
entity loeff_1D_DCT_tb is
end entity loeff_1D_DCT_tb;
-----------------------------------------------

architecture behav of loeff_1D_DCT_tb is
    constant    clk_period: time:= 20 ns;

    signal  clk_tb      :       std_logic:='1';
    signal  rstn_tb      :      std_logic:='0';
    signal  en_tb       :       std_logic:='0';
    signal  doneDCT_tb  :       std_logic;
    signal  dataIn_tb   :       dctArray;
    signal  dataIn_tb   :       dataInDCT_type;
    signal  dataOut_tb  :       dctArray;
    signal  dataOut_tb  :       dataOutDCT_type;
begin
    L_DUT:  entity work.loeff_1D_DCT(rtl)
        port map(
            clk         =>  clk_tb      ,
            rstn        =>  rstn_tb      ,
            doneDCT     =>  doneDCT_tb  ,
            en          =>  en_tb       ,
            dataInDCT   =>  dataIn_tb   ,
            dataOutDCT  =>  dataOut_tb
        );

    L_TEST_SEQUENCES:   process
    begin
        -----------------------
        wait for 20 ns;
        rstn_tb  <= '1';
        -----------------------

        -----------------------

        dataIn_tb(0) <= X"0012";
        dataIn_tb(1) <= X"0023";
        dataIn_tb(2) <= X"0034";
        dataIn_tb(3) <= X"0045";
        dataIn_tb(4) <= X"0056";
        dataIn_tb(5) <= X"0067";
        dataIn_tb(6) <= X"0078";
        dataIn_tb(7) <= X"0089";
        wait for 20 ns;
        en_tb   <= '1';
        wait for 1 ns;
        wait until rising_edge(clk_tb);
        en_tb   <= '0';
        wait for 1 ns;
        -------------------------


        --------------------------
        wait until rising_edge(doneDCT_tb);
        wait until rising_edge(clk_tb);
        wait;
        --------------------------
    end process;

    L_CLK_GEN:  process
    begin
        wait for clk_period/2;
        clk_tb <= not clk_tb;
    end process;

end architecture behav;