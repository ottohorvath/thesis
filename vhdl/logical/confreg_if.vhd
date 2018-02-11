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
entity confreg_if is
    generic(
        ACK_NEEDED          :       boolean :=  false   ;
        
        P_DATA_W            :       natural :=  32      ;                           
        RD_START            :       std_logic_vector(31 downto 0):=     X"FFFF0000";
        WR_START            :       std_logic_vector(31 downto 0):=     X"0000FFFF";
            
        D_DATA_W            :       natural :=  32      ;                           
        D_ADDR_W            :       natural :=  32                                  
    );
    port(
        clk                 :   in  std_logic;
        rstn                :   in  std_logic;
        -----------------------------------------------------------------
        write               :   in  std_logic;                              --              
        writedata           :   in  std_logic_vector(P_DATA_W-1   downto 0);-- 
        read                :   in  std_logic;                              -- MMIO Slave IF
        readdata            :   out std_logic_vector(P_DATA_W-1   downto 0);-- 
        -----------------------------------------------------------------   
        write_strobe_to_DUV :   out std_logic;                              --                     
        read_strobe_to_DUV  :   out std_logic;                              -- 
        data_to_DUV         :   out std_logic_vector(D_DATA_W-1   downto 0);-- Simple config register IF
        addr_to_DUV         :   out std_logic_vector(D_ADDR_W-1   downto 0);-- 
        data_from_DUV       :   in  std_logic_vector(D_DATA_W-1   downto 0);-- 
        cs_to_DUV           :   out std_logic                              ;--   
        -----------------------------------------------------------------
        ack_from_DUV        :   in  std_logic                               -- Ack. input, when ACK_NEEDED is set to TRUE
    );
end entity confreg_if;
---------------------------------------------------------------------------

architecture rtl of confreg_if is
    
    signal  addr_reg        :   std_logic_vector(D_ADDR_W-1   downto 0);
    signal  addr_reg_en     :   std_logic;                              
    
    signal  wr_data_reg     :   std_logic_vector(D_DATA_W-1   downto 0);
    signal  wr_data_reg_en  :   std_logic;                              
    
    signal  rd_data_reg     :   std_logic_vector(D_DATA_W-1   downto 0);
    signal  rd_data_reg_en  :   std_logic;                              
    
    signal  read_q          :   std_logic;                              
    signal  read_q_xor      :   std_logic;                              
    
begin
    
    -----------------------------------------------------
    L_RD_IF:
        process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                read_q  <= '0';
                
            elsif(rising_edge(clk)) then
                read_q  <= read_q_xor;
                
            end if;
        end process;
    
        read_q_xor  <=  read xor read_q;                   -- Toggling the read_q flop. Basically, a controllable inverter. 
                
        readdata    <=  std_logic_vector(resize( signed(rd_data_reg), P_DATA_W )) when (read_q = '1') else
                        (others => '0');
    -----------------------------------------------------



    -----------------------------------------------------
    L_ADDR_REG:
        process(clk,rstn)   is
        begin
            if(rstn = '0')  then
                addr_reg    <= (others => '0');
                
            elsif(rising_edge(clk)) then
            
                if(addr_reg_en = '1')   then
                    addr_reg    <= std_logic_vector(resize( signed(writedata),  D_DATA_W));
                end if;
                
            end if;
        end process;
    -----------------------------------------------------   


    -----------------------------------------------------
    L_WR_DATA_REG:
        process(clk,rstn)   is
        begin
            if(rstn = '0')  then
                wr_data_reg    <= (others => '0');
                
            elsif(rising_edge(clk)) then
                
                if(wr_data_reg_en = '1')   then
                    wr_data_reg    <= std_logic_vector(resize( signed(writedata),  D_DATA_W));
                end if;
                
            end if;
        end process;
    -----------------------------------------------------    

    -----------------------------------------------------
    L_RD_DATA_REG:
        process(clk,rstn)   is
        begin
            if(rstn = '0')  then
                rd_data_reg    <= (others => '0');
                
            elsif(rising_edge(clk)) then
            
                if(rd_data_reg_en = '1')    then
                    rd_data_reg    <= data_from_DUV;
                end if;
                
            end if;
        end process;
    -----------------------------------------------------    
    


    -----------------------------------------------------
    -- 	Instantiating the 'confreg_if_fsm' FSM.
    L_FSM:
        entity work.confreg_if_fsm(rtl)
            generic map(
                ACK_NEEDED      => ACK_NEEDED   ,
                P_DATA_W        => P_DATA_W     ,
                RD_START        => RD_START     ,
                WR_START        => WR_START
            )
            port map(
                clk             => clk                  ,
                rstn            => rstn                 ,
                write           => write                ,
                writedata       => writedata            ,
                ack_from_DUV    => ack_from_DUV         ,
                rd_strobe       => read_strobe_to_DUV   ,
                wr_strobe       => write_strobe_to_DUV  ,
                cs              => cs_to_DUV            ,
                addr_reg_en     => addr_reg_en          ,
                wr_data_reg_en  => wr_data_reg_en       ,
                rd_data_reg_en  => rd_data_reg_en   
            );
    -----------------------------------------------------

    
    
    
    
    
    
    
    
    
    
    -----------------------------------------------------
    L_OUTPUT_ASSIGNMENTS:
        data_to_DUV <=  wr_data_reg ;
        addr_to_DUV <=  addr_reg    ;
    -----------------------------------------------------    
 
end architecture rtl;

