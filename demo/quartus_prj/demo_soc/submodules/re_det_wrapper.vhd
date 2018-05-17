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
entity re_det_wrapper is
    generic(
        REG_LAYER       :       boolean     :=  false  -- For timing closure purposes
    );
    port(
        csi_clk             :   in  std_logic;
        rsi_rstn            :   in  std_logic;
        avs_write           :   in  std_logic;                      -- Avalon-MM slave
        avs_writedata       :   in  std_logic_vector(31 downto  0); -- Avalon-MM slave
        avs_readdata        :   out std_logic_vector(31 downto 0);  -- Avalon-MM slave
        trig_out            :   out std_logic;                      -- Conduit
        signal_from_DUV     :   in  std_logic                       -- Conduit
    );
end entity;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of re_det_wrapper is

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

    -- Tie-offs to 4 bytes
    -- ===================
    signal  wdata_32_bits   :   std_logic_vector(31 downto 0);
    signal  rdata_32_bits   :   std_logic_vector(31 downto 0);


begin

    ---------------------------------------------------------------------
    L_TIE_OFFS: block
                begin
                    wdata_32_bits   <=  avs_writedata;
                    avs_readdata    <=  rdata_32_bits;
                    -----------------------------------
                    -- Tie the unused bits to zero
                    rdata_32_bits(31 downto 1)  <= slv(31,'0');
                end block;
    ---------------------------------------------------------------------



    ---------------------------------------------------------------------
    L_IP:   entity work.re_det(rtl)
                generic map(
                    REG_LAYER       =>  REG_LAYER
                )
                port map(
                    clk             =>  csi_clk ,
                    rstn            =>  rsi_rstn,
                    wr              =>  avs_write,
                    wdata           =>  wdata_32_bits(1 downto 0),
                    rdata           =>  rdata_32_bits(0),
                    trig_out        =>  trig_out,
                    signal_from_DUV =>  signal_from_DUV
                );
    ---------------------------------------------------------------------
end architecture rtl;
