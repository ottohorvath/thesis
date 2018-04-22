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
entity config_reg_if_fsm is
    generic(
        ACK_NEEDED  :       boolean :=  false   ;               -- Synthesis parameter
        DW          :       integer :=  32      ;               -- Proc.-side IF data width
        RD_START    :       std_logic_vector(63 downto 0);      -- Read transaction indicator
        WR_START    :       std_logic_vector(63 downto 0)       -- wr transaction indicator
    );
    port(
        clk         :   in  std_logic;
        rstn        :   in  std_logic;
        wr          :   in  std_logic;
        -- coverage off t
        wdata       :   in  std_logic_vector(DW-1 downto 0);
        -- coverage on
        ack_from_DUV:   in  std_logic;
        rstrb       :   out std_logic;
        wstrb       :   out std_logic;
        cs          :   out std_logic;
        addr_en     :   out std_logic;
        wdata_en    :   out std_logic;
        rdata_en    :   out std_logic
    );
end entity config_reg_if_fsm;
---------------------------------------------------------------------------

architecture    rtl of config_reg_if_fsm   is

    type    state_t    is(
        IDLE            ,

        ST_RADDR      ,   --
        INIT_RD   ,   --
        EXTD_RD   ,   --  States related to a read transaction.
        WAIT_RACK ,   --
        CAPT_RDATA ,   --

        ST_WADDR      ,   --
        ST_WDATA      ,   --
        INIT_WR   ,   --  States related to a wr transaction.
        GEN_WR    ,   --
        EXTD_WR   ,   --
        WAIT_WACK     --
    );
    signal  cur_state           :   state_t;
    signal  nxt_state           :   state_t;

begin

    L_FSM:  block
    begin

        ----------------------------------------------------------------------
        L_NEXT_STATE:   process(cur_state,wr,wdata,ack_from_DUV) is
        begin

            nxt_state   <= cur_state;

            case(cur_state) is
                -----------------------------------------------------
                when IDLE           =>  if(wr = '1' and wdata = std_logic_vector(resize(signed(RD_START), DW)) ) then
                                            nxt_state   <=  ST_RADDR;         -- Read indicator
                                        end if;
                                        if(wr = '1' and wdata = std_logic_vector(resize(signed(WR_START), DW)) ) then
                                            nxt_state   <=  ST_WADDR;         -- Write indicator
                                        end if;
                --===================================================



                --===================================================--
                when ST_RADDR   =>  if(wr = '1')    then             --
                                        nxt_state   <= INIT_RD;      --
                                    end if;                          --
                -------------------------------------------------------
                when INIT_RD    =>  if(ACK_NEEDED)  then             --
                                        nxt_state   <= WAIT_RACK;    --
                                    else                             --
                                        nxt_state   <= CAPT_RDATA;   --
                                    end if;                          -- Read-related signals
                -------------------------------------------------------
                when WAIT_RACK  =>  if(ack_from_DUV = '1')  then     --
                                        nxt_state   <= EXTD_RD;      --
                                    end if;                          --
                -------------------------------------------------------
                when EXTD_RD    =>  if(ack_from_DUV = '1')  then     --
                                        nxt_state   <= IDLE;   --
                                    end if;                          --
                -------------------------------------------------------
                when CAPT_RDATA =>  nxt_state       <= IDLE;         --
                --===================================================--


                --===================================================--
                when ST_WADDR   =>  if(wr = '1')    then             --
                                        nxt_state   <=  ST_WDATA;    --
                                    end if;                          --
                -------------------------------------------------------
                when ST_WDATA   =>  if(wr = '1')    then             --
                                        nxt_state   <=  INIT_WR;     --
                                    end if;                          --
                -------------------------------------------------------
                when INIT_WR    =>  if(ACK_NEEDED)  then             --
                                        nxt_state   <=  WAIT_WACK;   --
                                    else                             --
                                        nxt_state   <=  GEN_WR;      --
                                    end if;                          -- Write-related signals
                -------------------------------------------------------
                when WAIT_WACK  =>  if(ack_from_DUV = '1')  then     --
                                        nxt_state   <=  EXTD_WR;     --
                                    end if;                          --
                -------------------------------------------------------
                when GEN_WR     =>  nxt_state   <= IDLE;             --
                -------------------------------------------------------
                when EXTD_WR    =>  if(ack_from_DUV = '1')  then     --
                                        nxt_state   <= IDLE;         --
                                    end if;                          --
                --===================================================--



                --===================================================

                -----------------------------------------------------
                -- coverage off
                when others =>  nxt_state   <= IDLE;
                -- coverage on
                -----------------------------------------------------
            end case;
        end process;
        ----------------------------------------------------------------------



        -- FSM outputs
        L_NO_ACK: if(ACK_NEEDED = false)  generate
            --------------------------------------------------
            cs      <=  '1' when( cur_state = INIT_RD       or
                                  cur_state = CAPT_RDATA    or

                                  cur_state = INIT_WR       or
                                  cur_state = GEN_WR
                                ) else '0';
            --------------------------------------------------
            rstrb   <=  '1' when( cur_state = CAPT_RDATA
                                ) else '0';
            --------------------------------------------------
            wstrb   <=  '1' when( cur_state = GEN_WR
                                ) else '0';
            --------------------------------------------------
            addr_en <=  '1' when( cur_state = ST_RADDR      or
                                  cur_state = ST_WADDR
                                ) else '0';
            --------------------------------------------------
            wdata_en<=  '1' when( cur_state = ST_WDATA
                                ) else '0';
            --------------------------------------------------
            rdata_en<=  '1' when( cur_state = CAPT_RDATA
                                ) else '0';
            --------------------------------------------------
        end generate;

        -- FSM outputs
        L_ACK: if(ACK_NEEDED = true)  generate
            --------------------------------------------------
            cs      <=  '1' when( cur_state = INIT_RD       or
                                  cur_state = CAPT_RDATA    or
                                  cur_state = WAIT_RACK     or
                                  cur_state = EXTD_RD       or

                                  cur_state = INIT_WR       or
                                  cur_state = GEN_WR        or
                                  cur_state = WAIT_WACK     or
                                  cur_state = EXTD_WR
                                ) else '0';
            --------------------------------------------------
            rstrb   <=  '1' when( cur_state = CAPT_RDATA    or
                                  cur_state = EXTD_RD
                                ) else '0';
            --------------------------------------------------
            wstrb   <=  '1' when( cur_state = GEN_WR        or
                                  cur_state = EXTD_WR
                                ) else '0';
            --------------------------------------------------
            addr_en <=  '1' when( cur_state = ST_RADDR      or
                                  cur_state = ST_WADDR
                                ) else '0';
            --------------------------------------------------
            wdata_en<=  '1' when( cur_state = ST_WDATA
                                ) else '0';
            --------------------------------------------------
            rdata_en<=  '1' when( cur_state = CAPT_RDATA    or
                                  (cur_state = EXTD_RD and ack_from_DUV = '1')
                                ) else '0';
            --------------------------------------------------
        end generate;


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