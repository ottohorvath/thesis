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
        wdata       :   in  std_logic_vector(DW-1 downto 0);
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

        ST_RD_ADDR      ,   --
        INIT_RD_TRANS   ,   --
        EXTD_RD_TRANS   ,   --  States related to a read transaction.
        WAIT_FOR_RD_ACK ,   --
        CAPTURE_RD_DATA ,   --

        ST_WR_ADDR      ,   --
        ST_WR_DATA      ,   --
        INIT_WR_TRANS   ,   --  States related to a wr transaction.
        GEN_WR_TRANS    ,   --
        EXTD_WR_TRANS   ,   --
        WAIT_FOR_WR_ACK     --
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
                                            nxt_state   <=  ST_RD_ADDR;         -- Read indicator
                                        end if;
                                        if(wr = '1' and wdata = std_logic_vector(resize(signed(WR_START), DW)) ) then
                                            nxt_state   <=  ST_WR_ADDR;         -- Write indicator
                                        end if;
                --=============================================================
                --=============================================================
                when ST_RD_ADDR     =>  if(wr = '1')    then                 --
                                            nxt_state   <= INIT_RD_TRANS;    --
                                        end if;                              --
                -----------------------------------------------------        --
                when INIT_RD_TRANS  =>  if(ACK_NEEDED)  then                 --
                                            nxt_state   <= WAIT_FOR_RD_ACK;  -- Read related states
                                        else                                 --
                                            nxt_state   <= CAPTURE_RD_DATA;  --
                                        end if;                              --
                -----------------------------------------------------        --
                when WAIT_FOR_RD_ACK=>  if(ack_from_DUV = '1')  then         --
                                            nxt_state   <= EXTD_RD_TRANS;    --
                                        end if;                              --
                -----------------------------------------------------        --
                when EXTD_RD_TRANS  =>  if(ack_from_DUV = '1')  then         --
                                            nxt_state   <= IDLE;             --
                                        end if;                              --
                -----------------------------------------------------        --
                when CAPTURE_RD_DATA=>  nxt_state   <= IDLE;                  --
                --=============================================================
                --=============================================================
                when ST_WR_ADDR     =>  if(wr = '1')    then                 --
                                            nxt_state   <=  ST_WR_DATA;      --
                                        end if;                              --
                -----------------------------------------------------        --
                when ST_WR_DATA     =>  if(wr = '1')    then                 --
                                            nxt_state   <=  INIT_WR_TRANS;   --
                                        end if;                              --
                -----------------------------------------------------        --
                when INIT_WR_TRANS  =>  if(ACK_NEEDED)  then                 --
                                            nxt_state   <=  WAIT_FOR_WR_ACK; --
                                        else                                 -- Write related states
                                            nxt_state   <=  GEN_WR_TRANS;    --
                                        end if;                              --
                -----------------------------------------------------        --
                when WAIT_FOR_WR_ACK=>  if(ack_from_DUV = '1')  then         --
                                            nxt_state   <=  GEN_WR_TRANS;    --
                                        end if;                              --
                -----------------------------------------------------        --
                when GEN_WR_TRANS   =>  if(ACK_NEEDED)  then                 --
                                            nxt_state   <= EXTD_WR_TRANS;    --
                                        else                                 --
                                            nxt_state   <= IDLE;             --
                                        end if;                              --
                -----------------------------------------------------        --
                when EXTD_WR_TRANS  =>  if(ack_from_DUV = '1')  then         --
                                            nxt_state   <= IDLE;             --
                                        end if;                              --
                --=============================================================
                --=============================================================

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
            cs      <=  '1' when( cur_state = INIT_RD_TRANS   or
                                  cur_state = CAPTURE_RD_DATA or
                                  
                                  cur_state = INIT_WR_TRANS   or
                                  cur_state = GEN_WR_TRANS
                                ) else '0';
            --------------------------------------------------
            rstrb   <=  '1' when( cur_state = CAPTURE_RD_DATA
                                ) else '0';
            --------------------------------------------------
            wstrb   <=  '1' when( cur_state = GEN_WR_TRANS
                                ) else '0';
            --------------------------------------------------
        end generate;
        
        -- FSM outputs
        L_ACK: if(ACK_NEEDED = true)  generate
            --------------------------------------------------
            cs      <=  '1' when( cur_state = INIT_RD_TRANS   or
                                  cur_state = CAPTURE_RD_DATA or
                                  cur_state = WAIT_FOR_RD_ACK or
                                  cur_state = EXTD_RD_TRANS   or
                                  
                                  cur_state = INIT_WR_TRANS   or
                                  cur_state = GEN_WR_TRANS    or
                                  cur_state = WAIT_FOR_WR_ACK or
                                  cur_state = EXTD_WR_TRANS
                                ) else '0';
            --------------------------------------------------
            rstrb   <=  '1' when( cur_state = CAPTURE_RD_DATA or
                                  cur_state = EXTD_RD_TRANS
                                ) else '0';
            --------------------------------------------------
            wstrb   <=  '1' when( cur_state = GEN_WR_TRANS    or
                                  cur_state = EXTD_WR_TRANS
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