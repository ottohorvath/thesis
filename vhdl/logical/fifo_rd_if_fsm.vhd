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
entity fifo_rd_if_fsm is
    generic(
        DW          :       integer :=  32  -- Data width
    );
    port(
        clk         :   in  std_logic;
        rstn        :   in  std_logic;
        wr          :   in  std_logic;
        wdata       :   in  std_logic_vector(DW-1 downto 0);
        fifo_rd     :   in  std_logic;
        trig_in_fsm :   in  std_logic;
        wdata_reg_en:   out std_logic;
        empty       :   out std_logic;
        got_read_out:   out std_logic;
        enabled_fsm :   out std_logic
    );
end entity fifo_rd_if_fsm;
---------------------------------------------------------------------------

architecture    rtl of fifo_rd_if_fsm   is

    type    state_t is(
        IDLE                ,
        ENABLED             ,
        RDATA_PRESENT       ,
        RDATA_GOT_READ_OUT
    );
    signal  cur_state   :   state_t;
    signal  nxt_state   :   state_t;

begin

    L_FSM:  block
    begin

        ----------------------------------------------------------------------
        L_NEXT_STATE:   process(cur_state,wr,wdata,fifo_rd) is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                -----------------------------------------------------
                -- Another component can also enable the module via 'trig_in_fsm'
                when IDLE           =>      if( (wdata(1 downto 0) = b"01" and wr = '1') or
                                                (trig_in_fsm = '1')
                                            ) then
                                                nxt_state   <= ENABLED;
                                            end if;
                -----------------------------------------------------
                -- Clearing has prioprity
                when ENABLED        =>      if( wdata(1 downto 0) = b"10"    and wr = '1')  then
                                                nxt_state   <= IDLE;
                                            elsif( wr = '1') then
                                                nxt_state   <= RDATA_PRESENT;
                                            end if;
                -----------------------------------------------------
                -- Clearing has prioprity
                when RDATA_PRESENT  =>      if( wdata(1 downto 0) = b"10"    and wr = '1')  then
                                                nxt_state   <= IDLE;
                                            elsif(fifo_rd = '1')  then
                                                nxt_state   <= RDATA_GOT_READ_OUT;
                                            end if;
                -----------------------------------------------------
                -- Clearing has prioprity
                -- Could be useful to be able to send back to enabled immediately
                when RDATA_GOT_READ_OUT =>  if(wdata(1 downto 0) = b"10"    and wr = '1') then
                                                nxt_state   <= IDLE;
                                            elsif(wdata(1 downto 0) = b"01"    and wr = '1')    then
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

        wdata_reg_en    <=  '1' when( cur_state = ENABLED
                                    ) else '0';
        -------------------------------------------------------------
        empty           <=  '1' when( cur_state = IDLE      or
                                      cur_state = ENABLED   or
                                      cur_state = RDATA_GOT_READ_OUT
                                    ) else '0';
        -------------------------------------------------------------
        got_read_out    <=  '1' when( cur_state = RDATA_GOT_READ_OUT
                                    ) else '0';
        -------------------------------------------------------------
        enabled_fsm     <=  '1' when( cur_state /= IDLE
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