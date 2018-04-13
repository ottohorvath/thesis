---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Wrapper for Source-FIFO component
--
--              ~ The Read side is read by the DUV
--
--              ~ The Write side is written by the processor
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity fifo_src is
    generic (
        DEPTH       :       integer range 8 to 512  :=  8           ;-- Depth of the FIFO
        DW          :       integer                 :=  32           -- Data width
    );
    port (
        clk             :       in  std_logic                           ;
        rstn            :       in  std_logic                           ;-- Async. active LOW reset
        trig_out        :       out std_logic                           ;
        -- coverage off t
        rdata           :       out std_logic_vector(DW-1 downto 0) ;--
        -- coverage on
        wr              :       in  std_logic                           ;
        -- coverage off t
        wdata           :       in  std_logic_vector(DW-1  downto 0);
        -- coverage on
        empty_to_DUV    :       out std_logic                           ;--
        rd_from_DUV     :       in  std_logic                           ;-- Write side
        -- coverage off t
        rdata_to_DUV    :       out std_logic_vector(DW-1 downto 0)  --
        -- coverage on
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of fifo_src is

    function slv(
        N: natural;
        B: std_logic
    )   return std_logic_vector  -- Replacate std_logic-s to slv, like Verilog's replicate {32{1b1}} operator
    is
        variable result: std_logic_vector(1 to N);
    begin
        for i in 1 to N loop
            result(i) := B;
        end loop;

        return result;
    end;


    signal  full_int    :   std_logic   ;   -- Feeding 'full' to processor on 'rdata' LSB

begin

    L_TRIG:     trig_out    <= full_int;

    ------------------------------------------------------
    L_RDATA:    rdata   <= slv(DW-1, '0') & full_int;

    -------------------------------------------------------
    L_GEN_FIFO: entity work.fifo(rtl)
                    generic map(
                        DEPTH       =>  DEPTH           ,
                        DW      =>  DW
                    )
                    port map(
                        clk         =>  clk             ,
                        rstn        =>  rstn            ,
                        empty       =>  empty_to_DUV    ,
                        rd          =>  rd_from_DUV     ,
                        rdata       =>  rdata_to_DUV    ,
                        full        =>  full_int        ,
                        wr          =>  wr              ,
                        wdata       =>  wdata
                    );
    -------------------------------------------------------




end architecture;