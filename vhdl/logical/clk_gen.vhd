---------------------------------------------------------------------------
--
-- Author: Otto Horvath           
--                                
---------------------------------------------------------------------------
--
-- Description: ~ This module is responsible for providing clock signal for
--                the whole verification environment.
--
--              ~ The clock can be enabled and disabled as well.
--               
--              ~ One can choose from one clock-gating architecture: 
--                 + flop-based.
--
---------------------------------------------------------------------------
--
-- Note:        ~ The gated clock output 'clk_out' has to be added to the FPGA's
--                clock routing/distributing network in the synthesizer !!!
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;




---------------------------------------------------------------------------
entity clk_gen  is
    port(
        clk     :   in  std_logic;
        rstn    :   in  std_logic;
    
        wr      :   in  std_logic;                      --                                  
        wdata   :   in  std_logic_vector(1  downto  0); -- Processor IF
        rdata   :   out std_logic;                      --
        
        clk_out :   out std_logic                       -- The gated output clock
    );
end entity clk_gen;
---------------------------------------------------------------------------





---------------------------------------------------------------------------
architecture rtl  of  clk_gen is

    signal int_din      :   std_logic_vector(1  downto  0); -- Register for storing wdata
    signal int_din_mux  :   std_logic_vector(1  downto  0); -- Mux on the 'int_din' register's input
    
    
    signal int_status   :   std_logic;                      -- Control and int_status register
    
    signal int_cg      :   std_logic;                       -- The flop which will gate the 'clk_out'
    
    signal int_n_clk    :   std_logic;                      -- The inverted 'clk'
    
begin
    
    --------------------------------------------------------
    L_WR_IF_BK: block
    begin
    
        process( clk, rstn )   is
        begin
            if(rstn = '0')  then
                int_din <= B"00";
                
            elsif(rising_edge(clk)) then
                int_din <= int_din_mux;
                
            end if;
        end process;
        
        int_din_mux <= wdata    when (wr = '1')  else
                   int_din;
    end block;
    --------------------------------------------------------
    
    --------------------------------------------------------
    L_RD_IF_BK: block
    begin
   
        rdata    <= int_status;
        
    end block;
    --------------------------------------------------------
    
    --------------------------------------------------------
    L_CK_GATING_BK: block
    begin
    
        int_n_clk   <= not clk;
        
        process( int_n_clk, rstn )   is
        begin
            if(rstn = '0')  then
                int_cg <= '0';
                
            elsif(rising_edge(int_n_clk))   then
                int_cg <= int_status;
                
            end if;
        end process;
        
        clk_out  <= int_cg and clk;                         -- Gating clock and flop output
        
    end block;
    --------------------------------------------------------
    
    
    --------------------------------------------------------
    -- Instantiate the 'sc_ff' to control the clock gen. logic
    
    L_SC_FF:
        entity work.sc_ff(rtl)
            port map(
                clk     => clk          ,
                rstn    => rstn         ,
                set     => int_din(0)   ,
                clr     => int_din(1)   ,
                q       => int_status
            );
    --------------------------------------------------------
    
    
    
    
end architecture rtl;
---------------------------------------------------------------------------























