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
entity confreg_if_fsm is
    generic(
        ACK_NEEDED          :       boolean :=  false   ;
    
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
        cs                  :   out std_logic;
        
        addr_reg_en         :   out std_logic; 
        wr_data_reg_en      :   out std_logic; 
        rd_data_reg_en      :   out std_logic 
    );
end entity confreg_if_fsm;
---------------------------------------------------------------------------

architecture    rtl of confreg_if_fsm   is
    
    type    state_t    is(
        IDLE            ,
        
        ST_RD_ADDR      ,   --
        INIT_RD_TRANS   ,   --
        EXTD_RD_TRANS   ,   --  States related to a read transaction.
        WAIT_FOR_RD_ACK ,   --
        CAPTURE_RD_DATA ,   --  
        
        ST_WR_ADDR      ,   -- 
        ST_WR_DATA      ,   -- 
        INIT_WR_TRANS   ,   --  States related to a write transaction.
        GEN_WR_TRANS    ,   --
        EXTD_WR_TRANS   ,   --
        WAIT_FOR_WR_ACK     --

        
    );
    signal  curr_state           :   state_t;
    signal  next_state           :   state_t;
    
begin

    -----------------------------------------------------------------
    -- Modeling the output and the next-state logic.
    -- With two-process FSM description, so it is expected from the synthesizer to generate non-buffered (non-registered) outputs.
    
    L_LOGIC:
        process(curr_state, writedata, write, ack_from_DUV)   is
        begin
            
            addr_reg_en     <=  '0' ;                                --
            wr_data_reg_en  <=  '0' ;                                --
            rd_data_reg_en  <=  '0' ;                                --
            rd_strobe       <=  '0' ;                                -- Default assignments (otherwise these would model latches)
            wr_strobe       <=  '0' ;                                --
            cs              <=  '0' ;                                --
            next_state      <=  curr_state;                                --
            
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
                -- Waiting for the address from the processor.
                when    ST_RD_ADDR    =>
                
                    if(write = '1') then
                        addr_reg_en <= '1';                          -- Storing the address into a flop.
                        next_state  <= INIT_RD_TRANS;

                    end if;
                    
                -----------------------------------------------------
                -- Asserting the select signal. The address has one cycle to reach the DUV config register IF's input.
                -- It is expected from the DUV to provide the data in the next state, when the ACK_NEEDED is FALSE.
                when    INIT_RD_TRANS    =>
                    
                    cs  <= '1';
                    if(ACK_NEEDED)  then                             -- Synthesis parameter!
                        next_state  <= WAIT_FOR_RD_ACK;              -- When the beginning of the transfer is bound to an ack.
                    else
                        next_state  <= CAPTURE_RD_DATA;              -- When it is not (for example: they are in the same clock domain).
                    end if;
                -----------------------------------------------------
                -- The state for extending the transaction. It will be synthesised when the ACK_NEEDED is set to TRUE.
                when    WAIT_FOR_RD_ACK =>
                    
                    cs  <= '1';
                    if(ack_from_DUV = '1')  then
                        next_state  <= CAPTURE_RD_DATA;

                    end if;
                
                -----------------------------------------------------
                -- The DUV put out the data. This logic will acknowledge back to the DUV to signal the successfull data exchange.
                when CAPTURE_RD_DATA   =>
                    
                    cs              <= '1';                          -- Extending the selecting signal.
                    rd_strobe       <= '1';                          -- Ack-ing to the DUV.
                    rd_data_reg_en  <= '1';
                    
                    if(ACK_NEEDED)  then                             -- Synthesis paramter!
                        next_state  <= EXTD_RD_TRANS;                 
                    else
                        next_state  <= IDLE;                         -- The transfer is finished.
                    end if;

                -----------------------------------------------------
                when EXTD_RD_TRANS   =>
                
                    cs              <= '1';
                    rd_strobe       <= '1';
                    
                    if(ack_from_DUV = '1')  then
                        rd_data_reg_en  <= '1';                       -- The read DATA will be captured.
                        next_state  <= IDLE;
                    else
                        next_state  <= EXTD_RD_TRANS;
                    end if;
                    
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
                        next_state      <= INIT_WR_TRANS;
                    else
                        next_state      <= ST_WR_DATA;
                    end if;
                    
                -----------------------------------------------------
                -- Asserting the select signal. 
                when    INIT_WR_TRANS    =>
                    
                    cs  <= '1';
                    if(ACK_NEEDED)  then                             -- Synthesis parameter!
                        next_state  <= WAIT_FOR_WR_ACK;              -- When the beginning of the transfer is bound to an ack.
                    else
                        next_state  <= GEN_WR_TRANS;                 -- When it is not
                    end if;
                -----------------------------------------------------
                -- The state for extending the transaction. It will be synthesised when the ACK_NEEDED is set to TRUE.
                when    WAIT_FOR_WR_ACK =>
                    
                    cs  <= '1';
                    if(ack_from_DUV = '1')  then
                        next_state  <=  GEN_WR_TRANS;

                    end if;
                    
                -----------------------------------------------------
                -- Generating the transfer.
                when    GEN_WR_TRANS    =>
                    
                    cs          <= '1';                             -- Extending the selecting signal.
                    wr_strobe   <= '1';                             -- Signaling a valid pulse to the DUV.
                    
                    if(ACK_NEEDED) then                             -- Synthesis parameter!
                        next_state  <= EXTD_WR_TRANS;
                    else
                        next_state  <= IDLE;                        -- Finishing the write transfer.
                    end if;
                    
                -----------------------------------------------------
                -- Extending the transfer until the acknowledgement is not arrived.
                when EXTD_WR_TRANS   =>
                    
                    cs          <= '1';
                    wr_strobe   <= '1';
                    
                    if(ack_from_DUV = '1')  then
                        next_state  <= IDLE;                        -- Finishing the write transfer.
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
    -- Modeling the state-register.
    
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