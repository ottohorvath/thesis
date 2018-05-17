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
entity rstn_gen_wrapper is
    generic(
        REG_LAYER       :       boolean     :=  false  -- For timing closure purposes
    );
    port(
        csi_clk         :   in  std_logic;                      -- Clock Input
        rsi_rstn        :   in  std_logic;                      -- Reset Input
        avs_write       :   in  std_logic;                      -- Avalon-MM Slave
        avs_writedata   :   in  std_logic_vector(31 downto  0); -- Avalon-MM Slave
        avs_readdata    :   out std_logic_vector(31 downto  0); -- Avalon-MM Slave
        trig_out        :   out std_logic;                      -- Conduit
        rso_rstn_to_DUV :   out std_logic                       -- Reset Output
    );
end entity rstn_gen_wrapper;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of rstn_gen_wrapper is
    ------------------------------------------------------------------------------
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
    ------------------------------------------------------------------------------





    signal  wdata_to_IP     :   std_logic_vector(1 downto 0);
    signal  rdata_from_IP   :   std_logic;

begin

    L_AVS:  block
            begin
                wdata_to_IP     <=  avs_writedata(1 downto 0);      -- Just the lower 2 bits
                avs_readdata    <=  slv(31,'0') & rdata_from_IP;    -- Just LSB
            end block;


    L_IP:   entity work.rstn_gen(rtl)
                generic map(
                    REG_LAYER   =>  REG_LAYER
                )
                port map(
                    clk         =>  csi_clk         ,
                    rstn        =>  rsi_rstn        ,
                    wr          =>  avs_write       ,
                    wdata       =>  wdata_to_IP     ,
                    rdata       =>  rdata_from_IP   ,
                    trig_out    =>  trig_out        ,
                    rstn_to_DUV =>  rso_rstn_to_DUV
                );
    --------------------------------------------------------





end architecture rtl;
---------------------------------------------------------------------------