
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
---------------------------------
use     work.dct_package.all    ;
---------------------------------


------------------------------------------------------------------
entity loeff_1D_DCT is
    port(
        clk             :   in      std_logic;
        rstn            :   in      std_logic;
        doneDCT         :   out     std_logic;
        en              :   in      std_logic;
        dataInDCT       :   in      dctArray;
        dataOutDCT      :   out     dctArray
    );
end entity loeff_1D_DCT;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of loeff_1D_DCT is

    signal data_from_INPUT_to_A1    : dctArray  ;
    signal data_from_A1_to_A2       : dctArray  ;
    signal data_from_A2_to_A3       : dctArray  ;
    signal data_from_A3_to_A4       : dctArray  ;
    signal data_from_from_A4        : dctArray  ;

    signal done_dct                 : std_logic ;
    signal reg1                     : dctArray  ;
    signal reg2                     : dctArray  ;
    signal reg3                     : dctArray  ;
    signal reg4                     : dctArray  ;
    signal reg5                     : dctArray  ;


    signal pipeline_cntr           : std_logic_vector(2 downto 0);
    signal cntr_clr                : std_logic;
    signal cntr_en                 : std_logic;

    type fsm_state_t is(
        IDLE,
        BUSY,
        DONE
    );

    signal  nxt_state   :   fsm_state_t;
    signal  cur_state   :   fsm_state_t;

begin
    --------------------------------------------
    L_CNTR: block
            begin
                process(clk,rstn) is
                begin
                    if(rstn = '0')  then
                        pipeline_cntr   <= (others =>'0');
                    elsif(rising_edge(clk)) then
                        if(cntr_clr = '1') then
                            pipeline_cntr   <= (others =>'0');
                        end if;
                        if(cntr_en = '1') then
                            pipeline_cntr   <=  std_logic_vector(unsigned(pipeline_cntr) + 1);
                        end if;
                    end if;
                end process;
            end block;


    ---------------------------------------------------------------------
    L_REG_LAYERS:   process(clk)
                    begin
                        if(rising_edge(clk)) then
                            reg1    <= data_from_INPUT_to_A1;
                            reg2    <= data_from_A1_to_A2;
                            reg3    <= data_from_A2_to_A3;
                            reg4    <= data_from_A3_to_A4;
                            reg5    <= data_from_from_A4;

                            if(en = '1')    then
                                data_from_INPUT_to_A1   <= dataInDCT;
                            end if;
                        end if;
                    end process;
    ---------------------------------------------------------------------

    ---------------------------------------------------------------------
    L_FSM_NXT:  process(cur_state,
                        en,
                        pipeline_cntr
                ) is
                begin
                    nxt_state   <=  cur_state;
                    case(cur_state) is
                        ------------------------------------------------
                        when IDLE       =>  if(en = '1')
                                            then
                                                nxt_state   <=  BUSY;
                                            end if;
                        ------------------------------------------------
                        when BUSY       =>  if(pipeline_cntr = b"100")
                                            then
                                                nxt_state   <=  DONE;
                                            end if;
                        ------------------------------------------------
                        when DONE       =>
                                            nxt_state   <=  IDLE;
                        ------------------------------------------------
                        when others =>  nxt_state   <=  IDLE;
                        ------------------------------------------------
                    end case;
                end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    L_FSM_CNTRL:    block
                    begin
                        cntr_clr    <=  '1' when(pipeline_cntr = b"100") else
                                        '0';
                        cntr_en     <=  '1' when(cur_state = BUSY and pipeline_cntr /= b"100") else
                                        '0';
                        done_dct    <=  '1' when(cur_state = done) else
                                        '0';
                    end block;
    --------------------------------------------------------------------

    ----------------------------------------
    L_FSM_STATE:    process(clk,rstn)  is
                    begin
                        if(rstn = '0')  then
                            cur_state   <= IDLE;
                        elsif(rising_edge(clk)) then
                            cur_state   <= nxt_state;
                        end if;
                    end process;
    ----------------------------------------



    --------------------------------------------
    L_A1:   entity work.loeff_A1(rtl)
                port map(
                    dataIn  =>  reg1,
                    dataOut =>  data_from_A1_to_A2
                );
    --------------------------------------------

    --------------------------------------------
    L_A2:   entity work.loeff_A2(rtl)
                port map(
                    dataIn  =>  reg2,
                    dataOut =>  data_from_A2_to_A3
                );
    --------------------------------------------


    --------------------------------------------
    L_A3:   entity work.loeff_A3(rtl)
                port map(
                    dataIn  =>  reg3,
                    dataOut =>  data_from_A3_to_A4
                );
    --------------------------------------------

    --------------------------------------------
    L_A4:   entity work.loeff_A4(rtl)
                port map(
                    dataIn  =>  reg4,
                    dataOut =>  data_from_from_A4
                );
    --------------------------------------------

    ---------------------------------------------------------------------
    L_DATAOUT_ASSIGNMENT:   dataOutDCT              <= reg5;
    L_DONE_ASSIGNMENT   :   doneDCT                 <= done_dct;






end architecture rtl;
------------------------------------------------------------------