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
entity fifo_wr_if_fsm is
    generic(
        DW          :       integer :=  32  -- Data width
    );
    port(
        clk         :   in  std_logic;
        rstn        :   in  std_logic;
        trig_in_fsm :   in  std_logic;
        wr          :   in  std_logic;
        wdata       :   in  std_logic_vector(DW-1 downto 0);
        fifo_wr     :   in  std_logic;
        show_data_fsm:   out std_logic;
        rdata_reg_en:   out std_logic;
        full        :   out std_logic;
        rcvd_data_fsm:   out std_logic;
        enabled_fsm :   out std_logic
    );
end entity fifo_wr_if_fsm;
---------------------------------------------------------------------------

architecture    rtl of fifo_wr_if_fsm   is

    type    state_t is(
        IDLE     ,
        ENABLED  ,
        RCVD_DATA,
        SHOW_DATA
    );
    signal  cur_state   :   state_t;
    signal  nxt_state   :   state_t;

begin

    L_FSM:  block
    begin

        ----------------------------------------------------------------------
        L_NEXT_STATE:   process(cur_state,wr,wdata,fifo_wr) is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                -----------------------------------------------------
                when IDLE       =>  if( (wdata(2 downto 0) = b"001" and wr='1') or
                                        (trig_in_fsm = '1')
                                      )  then
                                        nxt_state   <= ENABLED;
                                    end if;
                -----------------------------------------------------
                -- Clearing has prioprity
                when ENABLED    =>  if( wdata(2 downto 0) = b"010" and wr='1' ) then
                                        nxt_state   <= IDLE;
                                    elsif( fifo_wr = '1')           then
                                        nxt_state   <= RCVD_DATA;
                                    end if;
                -----------------------------------------------------
                -- Clearing has prioprity
                when RCVD_DATA  =>  if( wdata(2 downto 0) = b"010" and wr='1' ) then
                                        nxt_state   <= IDLE;
                                    elsif( wdata(2 downto 0) = b"100" and wr='1' ) then
                                        nxt_state   <= SHOW_DATA;
                                    end if;
                -----------------------------------------------------
                -- Clearing has prioprity
                -- Could be useful to be able to send back to enabled immediately
                when SHOW_DATA  =>  if( wdata(2 downto 0) = "010" and wr='1' )   then
                                        nxt_state   <= IDLE;
                                    elsif(wdata(2 downto 0) = b"001" and wr='1') then
                                        nxt_state   <= ENABLED;
                                    end if;
                -----------------------------------------------------
                -- coverage off
                when others =>  nxt_state   <= IDLE;
                -- coverage on
                -----------------------------------------------------
            end case;
        end process;
        ----------------------------------------------------------------------

        -- FSM outputs
        show_data_fsm   <=  '1' when( cur_state = SHOW_DATA
                                    ) else '0';
        -------------------------------------------------------------
        full            <=  '1' when( cur_state = RCVD_DATA or
                                      cur_state = SHOW_DATA
                                    ) else '0';
        -------------------------------------------------------------
        rcvd_data_fsm   <=  '1' when( cur_state = RCVD_DATA
                                    ) else '0';
        -------------------------------------------------------------
        enabled_fsm     <=  '1' when( cur_state /= IDLE
                                    ) else '0';
        -------------------------------------------------------------
        rdata_reg_en    <=  '1' when( (cur_state = ENABLED) and (fifo_wr = '1')
                                    ) else '0';
        
        

        -----------------------------------------------------
        L_STATE:    process(clk,rstn)   is
        begin
            if(rstn = '0')  then
                cur_state  <= IDLE;

            elsif(rising_edge(clk)) then
                cur_state  <= nxt_state;

            end if;
        end process;
        -----------------------------------------------------
    end block;

end architecture;