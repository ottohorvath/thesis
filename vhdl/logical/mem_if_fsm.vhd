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
entity mem_if_fsm is
    generic(
        ACK_NEEDED          :       boolean :=  false   ;                                       -- DUV-side acknowledge input for different memories 
        
        P_DATA_W            :       natural :=  32      ;                                       -- Proc.-side IF data width
        RD_START            :       std_logic_vector(31 downto 0):=     X"FFFF0000";            -- Read transaction indicator
        WR_START            :       std_logic_vector(31 downto 0):=     X"0000FFFF"             -- Write transaction indicator   
    );
    port(
        clk                 :   in  std_logic;
        rstn                :   in  std_logic;
        
        write               :   in  std_logic;
        writedata           :   in  std_logic_vector(P_DATA_W-1 downto 0);
        
        ack_from_DUV        :   in  std_logic;
        
        rd_strobe           :   out std_logic;      
        wr_strobe           :   out std_logic;      
        
        addr_reg_en         :   out std_logic; 
        wr_data_reg_en      :   out std_logic; 
        rd_data_reg_en      :   out std_logic 
    );
end entity mem_if_fsm;
---------------------------------------------------------------------------

architecture    rtl of mem_if_fsm   is
    
    type    state_t    is(
        IDLE            ,
        
        ST_RD_ADDR      ,   --
        GEN_RD_TRANS    ,   --
        WAIT_FOR_RD_ACK ,   -- States related to a read transaction
        WAIT_FOR_RD_DATA,   --
        CAPTURE_RD_DATA ,   --
        
        ST_WR_ADDR      ,   -- 
        ST_WR_DATA      ,   -- 
        GEN_WR_TRANS    ,   -- States related to a write transaction
        WAIT_FOR_WR_ACK     -- 
        
    );
    signal  curr_state           :   state_t;
    signal  next_state           :   state_t;
    
begin

    -----------------------------------------------------------------
    L_LOGIC:
        process(curr_state, writedata, write, ack_from_DUV)   is
        begin
            
            addr_reg_en     <=  '0' ;                                --
            wr_data_reg_en  <=  '0' ;                                --
            rd_data_reg_en  <=  '0' ;                                --
            rd_strobe       <=  '0' ;                                -- Default assignments (otherwise these would model latches)
            wr_strobe       <=  '0' ;                                --
            next_state      <=  IDLE;                                --
            
            case(curr_state)    is
                -----------------------------------------------------
                -- Setting the control signals to their default values.
                when    IDLE   =>

                    if(write = '1' and writedata = RD_START)    then -- If the processor wants to READ something.
                        next_state  <= ST_RD_ADDR;
                    end if;
                    if(write = '1' and writedata = WR_START)    then -- If the processor wants to WRITE something.
                        next_state  <= ST_WR_ADDR;
                    end if;
                    
                -----------------------------------------------------
                -- Waiting for the address, from which it will be read the data out.
                when    ST_RD_ADDR    =>
                
                    if(write = '1') then
                        addr_reg_en <= '1';
                        next_state  <= GEN_RD_TRANS;
                    end if;
                    
                -----------------------------------------------------
                -- Asserting the read strobe signal to the mem. Initiating a read transaction.
                when    GEN_RD_TRANS    =>
                
                    rd_strobe   <= '1';
                    
                    if(ACK_NEEDED)  then                             -- If the ack. input is needed in the design. Additional state will be synthesized.
                        next_state  <= WAIT_FOR_RD_ACK;
                    else
                        next_state  <= WAIT_FOR_RD_DATA;             -- Otherwise, just synthesize a small FSM.            
                    end if;
                    
                -----------------------------------------------------
                -- This state is only available, when the ACK_NEEDED parameter is set to TRUE.
                when    WAIT_FOR_RD_ACK    =>
                    
                    if(ack_from_DUV = '1')    then                         -- Waiting, until the acknowledgement from the mem. is not arrived.
                        next_state  <= CAPTURE_RD_DATA;
                    end if;
                    
                -----------------------------------------------------
                -- This state is only available, when the ACK_NEEDED parameter is set to FALSE. 
                when WAIT_FOR_RD_DATA   =>
                    
                    next_state      <= CAPTURE_RD_DATA;              -- One clock-cycle delay, giving some time for the memory to output its data.
                    
                -----------------------------------------------------
                -- This state implements a one-cycle delay, which is required for the memory.
                when    CAPTURE_RD_DATA    =>
                
                    rd_data_reg_en  <= '1';                          -- The read DATA will be captured.
                    next_state      <= IDLE;
                
                -----------------------------------------------------
                -- Waiting for the address.
                when    ST_WR_ADDR  =>
                    
                    if(write = '1') then
                        addr_reg_en <= '1';                          -- The write ADDRESS will be stored.
                        next_state  <= ST_WR_DATA;
                    end if;
                    
                -----------------------------------------------------
                -- Waiting for the data.
                when    ST_WR_DATA  =>
                
                    if(write = '1') then
                        wr_data_reg_en  <= '1';                      -- The write DATA will be stored.
                        next_state      <= GEN_WR_TRANS;
                    end if;
                    
                -----------------------------------------------------
                -- Asserting the write strobe signal. Initiating a write transaction.
                when    GEN_WR_TRANS    =>
                    
                    wr_strobe   <= '1';                              -- Signaling the memory to write the data which has been placed on the write bus.
                    
                    if(ACK_NEEDED)  then
                        next_state      <= WAIT_FOR_WR_ACK;          -- Will wait for its response.
                    else
                        next_state      <= IDLE;                     -- Otherwise, the transaction can be finished.
                    end if;
                -----------------------------------------------------
                -- Waiting for the acknowledgement.
                when    WAIT_FOR_WR_ACK    =>
                
                    if(ack_from_DUV = '1')  then                     -- Waiting for the response.
                        wr_strobe       <= '0'  ;
                        next_state      <= IDLE ;
                    end if;
                
                -----------------------------------------------------
                -- When the FSM reached an undefined state.
                when others =>	
                
                    report "?" severity failure;
                    next_state  <=  IDLE;                            -- Then it is better to reset itself.   
                    
                -----------------------------------------------------
            end case;
        end process;
    -----------------------------------------------------------------
    
    
    
    ------------------------------------------
    L_STATE:
        process(clk,rstn)   is
        begin
            if(rstn = '0')  then
                curr_state  <= IDLE;
                
            elsif(rising_edge(clk)) then
                curr_state  <= next_state;
                
            end if;
        end process;
    ------------------------------------------
end architecture rtl;