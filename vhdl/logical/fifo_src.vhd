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
        DWIDTH      :       integer                 :=  32           -- Data width
    );
    port (
        clk             :       in  std_logic                           ;
        rstn            :       in  std_logic                           ;-- Async. active LOW reset

        rdata           :       out std_logic_vector(DWIDTH-1 downto 0) ;--
        wr              :       in  std_logic                           ;
        wdata           :       in  std_logic_vector(DWIDTH-1  downto 0);
        
        empty_to_DUV    :       out std_logic                           ;-- 
        rd_from_DUV     :       in  std_logic                           ;-- Write side
        rdata_to_DUV    :       out std_logic_vector(DWIDTH-1 downto 0)  --
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

    ------------------------------------------------------
    L_RDATA:    rdata   <= slv(DWIDTH-1, '0') & full_int;

    -------------------------------------------------------
    L_GEN_FIFO: entity work.fifo(rtl)
                    generic map(
                        DEPTH       =>  DEPTH           ,
                        DWIDTH      =>  DWIDTH  
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