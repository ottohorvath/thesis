---------------------------------------------------------------------------
--
-- Author: Otto Horvath           
--                                
---------------------------------------------------------------------------
--
-- Description: ~ 
--                
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;




---------------------------------------------------------------------------
entity fe_det is
    --generic(
    --
    --);
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        
        wr              :   in  std_logic;
        wdata           :   in  std_logic_vector(1  downto  0);
        rdata           :   out std_logic;
        
        signal_from_DUV :   in  std_logic
    );
end entity fe_det;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of fe_det is
    
    signal din_mux  :   std_logic_vector(1  downto  0);
    signal din      :   std_logic_vector(1  downto  0);
    
    signal dout     :   std_logic;
    
    signal sig      :   std_logic;
    signal fe_reg   :   std_logic;
    signal det_out  :   std_logic;
    
begin

    --------------------------------------------------------
    -- Implementing the wr interface
    L_WR_IF: block
    begin
    
        L_WR_IF_P:  process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                din <= B"00";
                
                assert(din = B"00") report "Reset value error: 'din'" severity failure;
                
            elsif(rising_edge(clk)) then
                din <= din_mux;
                
            end if;
        end process;
    
        din_mux <=  wdata when (wr = '1')    else
                    din;
    end block;
    --------------------------------------------------------
    
    --------------------------------------------------------
    -- Implementing the read interface
    L_RD_IF: block
    begin
        
        ---------------------------------------------------
        -- Instantiating the 'fe_det_fsm'     
        
        L_FSM:    entity work.fe_det_fsm(rtl)
            port map(
                clk             =>  clk     ,
                rstn            =>  rstn    ,
                en              =>  din(0)  ,
                clr             =>  din(1)  ,
                sig_from_fe_det =>  det_out,
                fe_caught       =>  dout
            );
        
        
        rdata <= dout;
    end block;
    --------------------------------------------------------
    
    
    
    
 
    
    --------------------------------------------------------
    L_FE_DET_P: process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                fe_reg <= '0';
                
                assert(fe_reg = '0') report "Reset value error: 'fe_reg'" severity failure;
                
            elsif(rising_edge(clk)) then
            
                if(din(0) = '1' )   then
                    fe_reg  <= sig;
                end if;
                
            end if;
        end process;
    
    L_FE_SIG:
        sig     <= signal_from_DUV;
    
    L_FE_DET_OUT:
        det_out <=  not(sig) and fe_reg when (din(0) = '1')  else
                    '0';
    --------------------------------------------------------
    
end architecture rtl;


































