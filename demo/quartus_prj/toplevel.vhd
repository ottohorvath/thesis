---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Toplevel HDL entity of the Demonstration environment
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity toplevel is
    port(
        -- Clock from crystal
        FPGA_CLK1_50            :       in      std_logic;
        -- KEY[0] from board
        KEY_0                   :       in      std_logic;
        -- Signals for the onboard DDR3
        hps_memory_mem_a        :       out     std_logic_vector(12 downto 0);
        hps_memory_mem_ba       :       out     std_logic_vector(2 downto 0);
        hps_memory_mem_ck       :       out     std_logic;
        hps_memory_mem_ck_n     :       out     std_logic;
        hps_memory_mem_cke      :       out     std_logic;
        hps_memory_mem_cs_n     :       out     std_logic;
        hps_memory_mem_ras_n    :       out     std_logic;
        hps_memory_mem_cas_n    :       out     std_logic;
        hps_memory_mem_we_n     :       out     std_logic;
        hps_memory_mem_reset_n  :       out     std_logic;
        hps_memory_mem_dq       :       inout   std_logic_vector(7 downto 0);
        hps_memory_mem_dqs      :       inout   std_logic;
        hps_memory_mem_dqs_n    :       inout   std_logic;
        hps_memory_mem_odt      :       out     std_logic;
        hps_memory_mem_dm       :       out     std_logic;
        hps_memory_oct_rzqin    :       in      std_logic
    );
end entity;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
architecture rtl of toplevel is

    component demo_soc is
        port (
            clk_clk            : in    std_logic;
            memory_mem_a       : out   std_logic_vector(12 downto 0);
            memory_mem_ba      : out   std_logic_vector(2 downto 0);
            memory_mem_ck      : out   std_logic;
            memory_mem_ck_n    : out   std_logic;
            memory_mem_cke     : out   std_logic;
            memory_mem_cs_n    : out   std_logic;
            memory_mem_ras_n   : out   std_logic;
            memory_mem_cas_n   : out   std_logic;
            memory_mem_we_n    : out   std_logic;
            memory_mem_reset_n : out   std_logic;
            memory_mem_dq      : inout std_logic_vector(7 downto 0);
            memory_mem_dqs     : inout std_logic;
            memory_mem_dqs_n   : inout std_logic;
            memory_mem_odt     : out   std_logic;
            memory_mem_dm      : out   std_logic;
            memory_oct_rzqin   : in    std_logic;
            reset_reset_n      : in    std_logic
        );
    end component demo_soc;
begin

    -- Instantiate the system which has been generated in
    -- Platform Designer
    L_DEMO_SOC: component   demo_soc
                port map(
                    clk_clk             =>  FPGA_CLK1_50,
                    memory_mem_a        =>  hps_memory_mem_a      ,
                    memory_mem_ba       =>  hps_memory_mem_ba     ,
                    memory_mem_ck       =>  hps_memory_mem_ck     ,
                    memory_mem_ck_n     =>  hps_memory_mem_ck_n   ,
                    memory_mem_cke      =>  hps_memory_mem_cke    ,
                    memory_mem_cs_n     =>  hps_memory_mem_cs_n   ,
                    memory_mem_ras_n    =>  hps_memory_mem_ras_n  ,
                    memory_mem_cas_n    =>  hps_memory_mem_cas_n  ,
                    memory_mem_we_n     =>  hps_memory_mem_we_n   ,
                    memory_mem_reset_n  =>  hps_memory_mem_reset_n,
                    memory_mem_dq       =>  hps_memory_mem_dq     ,
                    memory_mem_dqs      =>  hps_memory_mem_dqs    ,
                    memory_mem_dqs_n    =>  hps_memory_mem_dqs_n  ,
                    memory_mem_odt      =>  hps_memory_mem_odt    ,
                    memory_mem_dm       =>  hps_memory_mem_dm     ,
                    memory_oct_rzqin    =>  hps_memory_oct_rzqin  ,
                    reset_reset_n       =>  KEY_0
                );

end architecture;
---------------------------------------------------------------------------