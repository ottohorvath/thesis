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
entity chg_det_wrapper is
    port(
        csi_clk             :   in  std_logic;  --  Clock Source Input
        rsi_rstn            :   in  std_logic;  --  Reset Source Input
        en                  :   in  std_logic;  --  Conduit
        clr                 :   in  std_logic;  --  Conduit
        sig                 :   in  std_logic;  --  Conduit
        detout              :   out std_logic   --  Conduit
    );
end entity;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of chg_det_wrapper is

begin
    ---------------------------------------------------------------
    L_IP:   entity work.chg_det(rtl)
                port map(
                    clk     =>  csi_clk ,
                    rstn    =>  rsi_rstn,
                    en      =>  en      ,
                    clr     =>  clr     ,
                    sig     =>  sig     ,
                    det_out =>  detout
                );
    ---------------------------------------------------------------------
end architecture rtl;

