---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Generic synchronizer for de-asserting async. reset
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity reset_synchronizer is
    generic(
        ACTIVE_LOW  :   boolean :=  true;
        SYNC_LVL    :   integer :=  2
    );
    port(
        clk         :   in  std_logic;
        raw_rst     :   in  std_logic;
        synced_rst  :   out std_logic
    );
end entity reset_synchronizer;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of reset_synchronizer is

    -- Wires between the intermediate flops.
    -- Only interesting if SYNC_LVL is bigger than 2.
    -- ==============================================
    signal  intermediate_wire:  std_logic_vector(SYNC_LVL-2 downto 0);

    -- Constant input logic to the sync. chain
    -- based on active LOW/HIGH reset getting synchronized
    -- ======================================
    signal  const_logic_value:  std_logic;

begin

    ----------------------------------------------------------
    L_CONST_1   :   if(ACTIVE_LOW = true)   generate
                        const_logic_value   <=  '1';
                    end generate;
    ----------------------------------------------------------
    L_CONST_0   :   if(ACTIVE_LOW = false)   generate
                        const_logic_value   <=  '0';
                    end generate;
    ----------------------------------------------------------
    L_FIRST:    entity  work.flop(rtl)
                    generic map(
                        ACTIVE_LOW  =>  ACTIVE_LOW
                    )
                    port map(
                        clk   =>  clk       ,
                        rst   =>  raw_rst   ,
                        d     =>  const_logic_value  ,
                        q     =>  intermediate_wire(0)
                    );
    ----------------------------------------------------------
    L_LAST :    entity  work.flop(rtl)
                    generic map(
                        ACTIVE_LOW  =>  ACTIVE_LOW
                    )
                    port map(
                        clk   =>  clk       ,
                        rst   =>  raw_rst   ,
                        d     =>  intermediate_wire(SYNC_LVL-2),
                        q     =>  synced_rst
                    );
    ----------------------------------------------------------
    L_INTER:    for ii in 1 to SYNC_LVL-2 generate
                    ------------------------------------
                    L_IF:   if(SYNC_LVL > 2)  generate
                        --------------------------------
                        L_U:    entity work.flop(rtl)
                                    generic map(
                                        ACTIVE_LOW  =>  ACTIVE_LOW
                                    )
                                    port map(
                                        clk =>  clk     ,
                                        rst =>  raw_rst ,
                                        d   =>  intermediate_wire(ii-1),
                                        q   =>  intermediate_wire(ii)
                                    );
                       --------------------------------
                            end generate;
                    ------------------------------------
                end generate;
    ----------------------------------------------------------

end architecture rtl;
---------------------------------------------------------------------------