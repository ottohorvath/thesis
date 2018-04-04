---------------------------------------------------------------------------
--
-- Author: Otto Horvath           
--                                
---------------------------------------------------------------------------
--
-- Description: ~ Wrapper for Sink-FIFO component
--              
--              ~ The Read side is read by the processor  
--                
--              ~ The Write side is written by the DUV              
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity fifo_snk is
    generic (
        DEPTH       :       integer range 8 to 512  :=  8           ;-- Depth of the FIFO
        DWIDTH      :       integer                 :=  32           -- Data width
    );
    port (
        clk             :       in  std_logic                           ;
        rstn            :       in  std_logic                           ;-- Async. active LOW reset
        
        trig_out        :       out std_logic                           ;

        rd              :       in  std_logic                           ;-- Read side
        rdata           :       out std_logic_vector(DWIDTH-1 downto 0) ;--
        wr              :       in  std_logic                           ;
        wdata           :       in  std_logic_vector(1  downto 0)       ;
        
        full_to_DUV     :       out std_logic                           ;-- 
        wr_from_DUV     :       in  std_logic                           ;-- Write side
        wdata_from_DUV  :       in  std_logic_vector(DWIDTH-1 downto 0)  --
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of fifo_snk is

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
    
    
    
    ------------------------------------------------------------------------------
    -- conf_reg = B"01" : Showing the FIFO's 'empty' signal in the LSB: { DWIDTH-1{1b0}, empty}}
    -- conf_reg = B"10" : Showing the FIFO's 'rdata' vector
    -- conf_reg = others: Showing zeros 
    signal  conf_reg    :   std_logic_vector(1 downto 0)        ;
    
    signal  fifo_rd     :   std_logic                           ;
    signal  fifo_empty  :   std_logic                           ;
    signal  fifo_rdata  :   std_logic_vector(DWIDTH-1 downto 0) ;
    ------------------------------------------------------------------------------
begin
    
    L_TRIG:     trig_out    <= fifo_empty;
    -------------------------------------------------------
    L_FIFO_RD:  fifo_rd     <= rd;
    -------------------------------------------------------
    L_CFG_REG:  process (clk, rstn) is
                begin
                    if(rstn = '0')      then
                        conf_reg    <= B"00";
                        
                    elsif(rising_edge(clk)) then
                        
                        if(wr = '1')    then
                            conf_reg    <= wdata;
                        end if;
                        
                    end if;
                end process;
    -------------------------------------------------------
    L_RDATA_MUX:block
                begin
                    
                    rdata   <=  slv(DWIDTH-1,'0') & fifo_empty when conf_reg = B"01"  else  -- Showing the FIFO-s empty signal
                                fifo_rdata                     when conf_reg = B"10"  else  -- Showing FIFO rdata
                                slv(DWIDTH,'0');                                            -- Otherwise, DWIDTH{1b0}} 
    
                end block;
    -------------------------------------------------------
    L_GEN_FIFO: entity work.fifo(rtl)
                    generic map(
                        DEPTH       =>  DEPTH           ,
                        DWIDTH      =>  DWIDTH
                    )    
                    port map(    
                        clk         =>  clk             ,
                        rstn        =>  rstn            ,
                        empty       =>  fifo_empty      ,
                        rd          =>  fifo_rd         ,
                        rdata       =>  fifo_rdata      ,
                        full        =>  full_to_DUV     ,
                        wr          =>  wr_from_DUV     ,
                        wdata       =>  wdata_from_DUV  
                    );
    -------------------------------------------------------
    
    
    
    
end architecture;