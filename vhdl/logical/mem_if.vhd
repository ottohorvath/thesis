-------------------------------------------------------------------------
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
entity mem_if is
    generic(
        ACK_NEEDED          :       boolean :=  false   ;                                       -- DUV-side acknowledge input for different memories 
                
        P_DATA_W            :       natural :=  32      ;                                       -- Proc.-side IF data width
        RD_START            :       std_logic_vector(31 downto 0):=     X"FFFF0000";            -- Read transaction indicator
        WR_START            :       std_logic_vector(31 downto 0):=     X"0000FFFF";            -- Write transaction indicator
            
        D_DATA_W            :       natural :=  32      ;                                       -- DUV-side IF data width
        D_ADDR_W            :       natural :=  32                                              -- DUV-side IF address width
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
        data_to_DUV         :   out std_logic_vector(D_DATA_W-1   downto 0);-- Simple memory read/write IF
        addr_to_DUV         :   out std_logic_vector(D_ADDR_W-1   downto 0);-- 
        data_from_DUV       :   in  std_logic_vector(D_DATA_W-1   downto 0);-- 
        -----------------------------------------------------------------
        ack_from_DUV        :   in  std_logic                               -- Ack. input, when ACK_NEEDED is set to TRUE
    );
end entity mem_if;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of mem_if is
    
    signal  addr_reg        :   std_logic_vector(D_ADDR_W-1   downto 0);    -- Address storing register for read trans.
    signal  addr_reg_en     :   std_logic;                                  -- The enable input for it.
    
    signal  wr_data_reg     :   std_logic_vector(D_DATA_W-1   downto 0);    -- Data storing register for write trans.
    signal  wr_data_reg_en  :   std_logic;                                  -- The enable input for it.
    
    signal  rd_data_reg     :   std_logic_vector(D_DATA_W-1   downto 0);    -- Data from the memory
    signal  rd_data_reg_en  :   std_logic;                                  -- The enable input for it.
    
    signal  read_q          :   std_logic;                                  -- For storing two consecutive (read = 1) events.
    signal  read_q_xor      :   std_logic;                                  -- For toggling the read_q flop.
    
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
    -- 	Instantiating the 'mem_if_fsm' FSM.
    L_FSM:
        entity work.mem_if_fsm(rtl)
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
---------------------------------------------------------------------------



















