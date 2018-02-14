---------------------------------------------------------------------------
--
-- Author: Otto Horvath           
--                                
---------------------------------------------------------------------------
--
-- Description: ~ This module is responsible for providing reset signal for
--                the whole verification environment.
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;





---------------------------------------------------------------------------
entity rstn_gen is
    port(
        clk         :   in  std_logic;
        rstn        :   in  std_logic;
        
        wr          :   in  std_logic;
        wdata       :   in  std_logic_vector(1  downto  0);
        rdata       :   out std_logic;
        
        rstn_to_DUV  :   out std_logic
    );
end entity rstn_gen;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of rstn_gen is

    signal din          :       std_logic_vector(1  downto  0); 
    signal din_mux      :       std_logic_vector(1  downto  0);
    
    signal write_reg    :       std_logic;                      -- One cycle delay for the 'wr' input
    
    signal nxt_rst_reg  :       std_logic;
    signal rst_reg      :       std_logic;                      
    
    signal re_det_reg   :       std_logic;                      -- The flop for rise-edge detection
    signal re_det_out   :       std_logic;                      -- Output of the rise-edge detector
    
    signal status       :       std_logic;
    
    
begin
    
    --------------------------------------------------------
    -- Feeding the 'wr' input to a flop 
    L_WRITE_FLOPPING_P:    process(clk,rstn)   is
    begin
        if(rstn='0')    then
            write_reg   <= '0';
            
            assert(write_reg = '0') report "Reset value error: 'write_reg'" severity failure;
            
        elsif(rising_edge(clk)) then
            write_reg   <= wr;
            
        end if;
    end process; 
    --------------------------------------------------------
    
    
    --------------------------------------------------------
    -- Implementing the wr interface
    L_WR_IF_BK: block
    begin
    
        L_WR_IF_P: process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                din <= B"00";
                
                assert(din = B"00") report "Reset value error: 'din'" severity failure;
                
            elsif(rising_edge(clk))   then
                din <= din_mux;
                
            end if;
        end process;
        
        --------------------------------------------------
        -- The mux on the input
        din_mux <=  wdata    when (wr = '1')  else
                    din;
    end block;
    --------------------------------------------------------
    
    
    --------------------------------------------------------
    -- Implementing the active LOW reset pulse generating logic
    L_RSTN_GEN_BK: block
    begin
        rstn_to_DUV <= rst_reg;                               -- Driving the output
        

        L_RSTN_GEN_P:   process(clk, rstn)   is
        begin
            if(rstn = '0')  then
                rst_reg     <= '1';                          -- Reset to 1 !!!
                
                assert(rst_reg = '1') report "Reset value error: 'rst_reg'" severity failure;
                
            elsif(rising_edge(clk))   then
                rst_reg     <= nxt_rst_reg;
                
            end if;
        end process;
        
        
        nxt_rst_reg <= not (din(0) and write_reg);
    end block;
    --------------------------------------------------------
    
    
    
    
    --------------------------------------------------------
    -- Implementing the read interface
    L_RD_IF_BK: block
    begin
        rdata    <=  status;
    end block;
    --------------------------------------------------------
    
    
    
    
    
    
    
    --------------------------------------------------------
    -- Implementing the status 
    
    L_STATUS_BK:   block
    begin
        re_det_out  <= (re_det_reg and not(rst_reg));
        
        --------------------------------------------------
        -- The flop for rise-edge detection
        L_STATUS_RE_DET_P:  process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                re_det_reg  <= '1';                          -- Reset to 1 !!!
                
                assert(re_det_reg = '1') report "Reset value error: 're_det_reg'" severity failure;
                
            elsif(rising_edge(clk)) then
                re_det_reg  <= rst_reg; 
                
            end if;
        end process;
        
        L_STATUS_SC_FF: entity work.sc_ff(rtl)    
                --generic map(    
                --    
                --)    
                port map(    
                    clk     => clk         ,    
                    rstn    => rstn        ,    
                    set     => re_det_out  ,                    -- Driving with output of the rise-edge detector
                    clr     => din(1)      ,    
                    q       => status    
                );
    end block;
    --------------------------------------------------------
    
end architecture rtl;
---------------------------------------------------------------------------