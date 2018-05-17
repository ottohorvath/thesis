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
entity fifo_snk_wrapper is
    generic (
        DEPTH           :       integer range 8 to 512  :=  8;
        DW              :       integer                 :=  32
    );
    port (
        csi_clk         :       in  std_logic;
        rsi_rstn        :       in  std_logic;
        trig_out        :       out std_logic;                          -- Conduit
        avs_read        :       in  std_logic;                          -- Avalon-MM slave
        avs_readdata    :       out std_logic_vector(DW-1 downto 0);    -- Avalon-MM slave
        avs_write       :       in  std_logic;                          -- Avalon-MM slave
        avs_writedata   :       in  std_logic_vector(DW-1  downto 0);   -- Avalon-MM slave
        full_to_DUV     :       out std_logic;                          -- Conduit
        wr_from_DUV     :       in  std_logic;                          -- Conduit
        wdata_from_DUV  :       in  std_logic_vector(DW-1 downto 0)     -- Conduit
    );
end entity;
--------------------------------------------------------------------------------
architecture rtl of fifo_snk_wrapper is
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

begin



    -------------------------------------------------------
    L_IP:   entity work.fifo_snk(rtl)
                generic map(
                    DEPTH           =>  DEPTH   ,
                    DW              =>  DW
                )
                port map(
                    clk             =>  csi_clk         ,
                    rstn            =>  rsi_rstn        ,
                    trig_out        =>  trig_out        ,
                    rd              =>  avs_read        ,
                    rdata           =>  avs_readdata    ,
                    wr              =>  avs_write       ,
                    wdata           =>  avs_writedata(1 downto 0),
                    full_to_DUV     =>  full_to_DUV     ,
                    wr_from_DUV     =>  wr_from_DUV     ,
                    wdata_from_DUV  =>  wdata_from_DUV
                );
    -------------------------------------------------------




end architecture;