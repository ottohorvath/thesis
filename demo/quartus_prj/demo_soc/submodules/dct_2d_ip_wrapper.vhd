---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Wrapper to ease integration to Quartus environment,
--              ~ Platform Designer can harvest the IFs easier if they are
--                named a certian way
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;




---------------------------------------------------------------------------
entity dct_2d_ip_wrapper  is
    port(
        csi_clk         :   in  std_logic;
        rsi_rstn        :   in  std_logic;
        avs_write       :   in  std_logic;                      -- Avalon-MM slave
        avs_writedata   :   in  std_logic_vector(31 downto 0);  -- Avalon-MM slave
        busy            :   out std_logic;                      -- Conduit
        start_dct       :   in  std_logic;                      -- Conduit
        dct_done        :   out std_logic;                      -- Conduit
        new_output      :   out std_logic;                      -- Conduit
        new_output_data :   out std_logic_vector(31 downto 0)   -- Conduit
    );
end entity;
---------------------------------------------------------------------------





---------------------------------------------------------------------------
architecture rtl  of  dct_2d_ip_wrapper is

    ----------------------------------------------------------------------------
    -- std_logic input
    function slv(
        N:      natural;
        B:      std_logic
    )   return  std_logic_vector
    is
        variable result: std_logic_vector(1 to N);
    begin
        for i in 1 to N loop
            result(i) := B;
        end loop;

        return result;
    end;
    ----------------------------------------------------------------------------

    -- Chop down the lower byte from 'writedata'
    signal  wdata_8_bits                        :std_logic_vector(7 downto 0);

    -- The transformed data coming from the DCT 2D transformator is
    -- an 11 bits wide signed value
    -- The value must be widened to 32 bits with keeping the signed bit
    signal  dct_output_data_extended_to_32_bits :std_logic_vector(31 downto 0);
    signal  dct_output_data                     :std_logic_vector(10 downto 0);



begin
    L_TIE_OFFS: block
                begin
                    wdata_8_bits   <=  avs_writedata(7 downto 0);
                end block;

    L_SIGN_EXT: block
                begin
                    -- Feed the lower 11 bits directly
                    dct_output_data_extended_to_32_bits(10 downto 0)    <=  dct_output_data;

                    -- For the remaining 21 bits, drive the sign bit
                    -- Namely dct_output_data(10)
                    dct_output_data_extended_to_32_bits(31 downto 11)   <=  slv(21, dct_output_data(10));

                    new_output_data <=  dct_output_data_extended_to_32_bits;
                end block;



    --------------------------------------------------------
    L_IP:   entity work.DCT_2D_wrapper(rtl)
                port map(
                    clk             =>  csi_clk     ,
                    rstn            =>  rsi_rstn    ,
                    ---------------------------------
                    start_dct       =>  start_dct   ,
                    ---------------------------------
                    busy            =>  busy        ,
                    ---------------------------------
                    new_input       =>  avs_write   ,
                    new_input_data  =>  wdata_8_bits,   -- 8 bits
                    ---------------------------------
                    new_output      =>  new_output  ,
                    new_output_data =>  dct_output_data, -- 11 bits
                    ---------------------------------
                    dct_done        =>  dct_done
                );
    --------------------------------------------------------

end architecture;
---------------------------------------------------------------------------























