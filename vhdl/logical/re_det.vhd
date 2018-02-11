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
entity re_det is
    --generic(
    --
    --);
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        write           :   in  std_logic;
        writedata       :   in  std_logic_vector(1  downto  0);
        read            :   in  std_logic;
        readdata        :   out std_logic;
        signal_from_DUV :   in  std_logic
    );
end entity re_det;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of re_det is
    
    signal din_mux  :   std_logic_vector(1  downto  0);
    signal din      :   std_logic_vector(1  downto  0);
    
    signal dout_mux :   std_logic;
    signal dout     :   std_logic;
    
    signal sig      :   std_logic;
    signal re_reg   :   std_logic;
    signal det_out  :   std_logic;
    
begin

    --------------------------------------------------------
    -- Implementing the write interface
    L_WR_IF:    block
    begin
        process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                din <= B"00";
                
            elsif(rising_edge(clk)) then
                din <= din_mux;
                
            end if;
        end process;
    
        din_mux <=  writedata when (write = '1')    else
                    din;
    end block;
    --------------------------------------------------------
    
    --------------------------------------------------------
    -- Implementing the read interface
    L_RD_IF:    block
    begin
        
        ---------------------------------------------------
        -- Instantiating the 're_det_fsm' module     
        
        L_FSM:    entity work.re_det_fsm(rtl)
                        port map(
                            clk             =>  clk             ,
                            rstn            =>  rstn            ,
                            en              =>  din(0)          ,
                            clr             =>  din(1)          ,
                            sig_from_re_det =>  det_out ,
                            re_caught       =>  dout            
                        );
        
        
        dout_mux <= dout    when    (read = '1')    else
                    '0';
        readdata <= dout_mux;
    end block;
    --------------------------------------------------------
    
    --------------------------------------------------------
    L_RE_DET_P:    process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                re_reg <= '1';
                
            elsif(rising_edge(clk)) then
            
                if(din(0) = '1' )   then
                    re_reg  <= sig;
                end if;
                
            end if;
        end process;
    
    L_RE_SIG:
        sig     <= signal_from_DUV;
    
    L_RE_DET_OUT:
        det_out <=  sig and not(re_reg) when (din(0) = '1')  else
                    '0';
    --------------------------------------------------------
    
end architecture rtl;


































