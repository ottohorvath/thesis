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




---------------------------------------------------------------------------------------------------------
entity DCT_2D_wrapper is
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        -- Start of 2D-DCT
        start_dct       :   in  std_logic;
        -- Doing the 2D-DCT transformation
        busy            :   out std_logic;
        -- New input is valid
        new_input       :   in  std_logic;
        -- The serially received and yet to be transformed pixels, 8 bits wide
        new_input_data  :   in  std_logic_vector(inputDataWidth-1 downto 0);
        -- New transformed output is valid
        new_output      :   out std_logic;
        -- The transformed pixels which are serially emitted, 11 bits wide
        new_output_data :   out std_logic_vector(outputDataWidth-1 downto 0);
        -- 2D-DCT is done
        dct_done        :   out std_logic
    );
end entity;
---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
architecture rtl of DCT_2D_wrapper is


    signal  dct_done_w          :   std_logic;

    -- The serially shifted IN pixels to be transformed
    -- ================================================
    signal  recieved_pixels     :   inputPixelBlock ;

    -- The serially shifted OUT transformed pixels
    -- ===========================================
    signal  transmitted_pixels  :   outputPixelBlock;


    -- Input pixel data counters
    -- =========================
    signal  input_pixel_data_x_cntr     :   std_logic_vector(2 downto 0);
    signal  input_pixel_data_y_cntr     :   std_logic_vector(2 downto 0);

    -- Control signals for them
    -- ========================
    signal  inc_input_pixel_data_x_cntr :   std_logic;
    signal  inc_input_pixel_data_y_cntr :   std_logic;

    -- Output pixel data counters
    -- ===========================
    signal  output_pixel_data_x_cntr    :   std_logic_vector(2 downto 0);
    signal  output_pixel_data_y_cntr    :   std_logic_vector(2 downto 0);

    -- Control signals for them
    -- ========================
    signal  inc_output_pixel_data_x_cntr :   std_logic;
    signal  clr_output_pixel_data_x_cntr :   std_logic;
    signal  inc_output_pixel_data_y_cntr :   std_logic;
    signal  clr_output_pixel_data_y_cntr :   std_logic;



    -- FSM on the output serializing side
    type output_fsm_state_t is(
        IDLE,
        EMITTING
    );

    signal  nxt_state   :   output_fsm_state_t;
    signal  cur_state   :   output_fsm_state_t;

    -- FSM control signal
    signal  fsm_new_output  :   std_logic;




begin
    ---------------------------------------------------------------------------------------------
    L_INPUT_MUXING:     block
                        begin
                            --------------------------------------------------------------------
                            L_REG_LAYER:    process(clk,rstn)    is
                                            begin
                                                if(rstn = '0')  then
                                                    recieved_pixels <=  (others =>(others =>(others => '0')));

                                                elsif(rising_edge(clk)) then
                                                    if(new_input = '1') then
                                                        -- Store it at (y,x) in the regbank, when it is valid
                                                        recieved_pixels(to_integer(unsigned(input_pixel_data_y_cntr)), to_integer(unsigned(input_pixel_data_x_cntr) ))  <= new_input_data;
                                                    end if;
                                                end if;
                                            end process;
                            --------------------------------------------------------------------
                            -- -- Also step the pixel X cntr, when new input has been written in
                            L_INC_X_CNTR:   inc_input_pixel_data_x_cntr <=  '1' when (new_input = '1')  else '0';
                            --------------------------------------------------------------------
                        end block;
    ---------------------------------------------------------------------------------------------
    L_OUTPUT:   block
                begin
                    -- Drive the FSM signal to indicate validity of data
                    new_output      <=  fsm_new_output;
                    -- Drive the data pointed out by the counters
                    new_output_data <=  transmitted_pixels(to_integer(unsigned(output_pixel_data_y_cntr)), to_integer(unsigned(output_pixel_data_x_cntr)));
                    --------------------------------------------------------------------
                    L_FSM_STATE:    process(clk,rstn)   is
                                    begin
                                        if(rstn = '0')  then
                                            cur_state   <= IDLE;
                                        elsif(rising_edge(clk)) then
                                            cur_state   <=  nxt_state;
                                        end if;
                                    end process;
                    --------------------------------------------------------------------
                    L_FSM_NXT:  process(cur_state,
                                        dct_done_w,
                                        output_pixel_data_y_cntr,
                                        output_pixel_data_x_cntr
                                ) is
                                begin
                                    nxt_state   <=  cur_state;
                                    case(cur_state) is
                                        ------------------------------------------------
                                        when IDLE       =>  if(dct_done_w = '1')    then
                                                                nxt_state   <= EMITTING;
                                                            end if;
                                        ------------------------------------------------
                                        when EMITTING   =>  if( output_pixel_data_y_cntr = b"111" and
                                                                output_pixel_data_x_cntr = b"111")
                                                            then
                                                                nxt_state   <= IDLE;
                                                            end if;
                                        ------------------------------------------------
                                        when others =>  nxt_state   <=  IDLE;
                                        ------------------------------------------------
                                    end case;
                                end process;
                    --------------------------------------------------------------------
                    L_FSM_CNTRL:    block
                                    begin
                                        -- Generate valid when it is emitting data
                                        fsm_new_output              <=  '1' when (cur_state = EMITTING) else
                                                                        '0';
                                        -- Step counters when it is emitting data
                                        inc_output_pixel_data_x_cntr<=  '1' when (cur_state = EMITTING) else
                                                                        '0';
                                        -- Send back the counters in IDLE
                                        clr_output_pixel_data_x_cntr<=  '1' when (cur_state = IDLE) else
                                                                        '0';
                                        clr_output_pixel_data_y_cntr<=  '1' when (cur_state = IDLE) else
                                                                        '0';
                                    end block;
                end block;
    ---------------------------------------------------------------------------------------------



    ---------------------------------------------------------------------------------------------
    L_INPUT_PIXEL_CNTRS :   block
                            begin
                                ------------------------------------------
                                L_X :   process(clk,rstn)   is
                                        begin
                                            if(rstn = '0')  then
                                                input_pixel_data_x_cntr <=  (others =>'0');

                                            elsif(rising_edge(clk)) then
                                                if(inc_input_pixel_data_x_cntr = '1')    then
                                                    input_pixel_data_x_cntr <=  std_logic_vector(unsigned(input_pixel_data_x_cntr) + 1);
                                                end if;
                                                -- Send back when there was a starting pulse
                                                if(start_dct = '1')    then
                                                    input_pixel_data_x_cntr <=  (others =>'0');
                                                end if;
                                            end if;
                                        end process;
                                ------------------------------------------
                                L_Y :   process(clk,rstn)   is
                                        begin
                                            if(rstn = '0')  then
                                                input_pixel_data_y_cntr <=  (others =>'0');

                                            elsif(rising_edge(clk)) then
                                                if(inc_input_pixel_data_y_cntr = '1')    then
                                                    input_pixel_data_y_cntr <=  std_logic_vector(unsigned(input_pixel_data_y_cntr) + 1);
                                                end if;
                                                -- Send back when there was a starting pulse
                                                if(start_dct = '1') then
                                                    input_pixel_data_y_cntr <=  (others =>'0');
                                                end if;
                                            end if;
                                        end process;
                                ------------------------------------------
                                -- Increase pixel Y cntr when X was 3'b111 and was also a new input has been written in
                                L_Y_INC :   inc_input_pixel_data_y_cntr <=  '1' when    (new_input = '1' and
                                                                                         input_pixel_data_x_cntr = b"111")
                                                                                        else '0';
                            end block;
    ---------------------------------------------------------------------------------------------

    ---------------------------------------------------------------------------------------------
    L_OUTPUT_PIXEL_CNTRS :  block
                            begin
                                ------------------------------------------
                                L_X :   process(clk,rstn)   is
                                        begin
                                            if(rstn = '0')  then
                                                output_pixel_data_x_cntr <=  (others =>'0');

                                            elsif(rising_edge(clk)) then
                                                if(inc_output_pixel_data_x_cntr = '1')    then
                                                    output_pixel_data_x_cntr <=  std_logic_vector(unsigned(output_pixel_data_x_cntr) + 1);
                                                end if;

                                                if(clr_output_pixel_data_x_cntr = '1')    then
                                                    output_pixel_data_x_cntr <=  (others =>'0');
                                                end if;
                                            end if;
                                        end process;
                                ------------------------------------------
                                L_Y :   process(clk,rstn)   is
                                        begin
                                            if(rstn = '0')  then
                                                output_pixel_data_y_cntr <=  (others =>'0');

                                            elsif(rising_edge(clk)) then
                                                if(inc_output_pixel_data_y_cntr = '1')    then
                                                    output_pixel_data_y_cntr <=  std_logic_vector(unsigned(output_pixel_data_y_cntr) + 1);
                                                end if;

                                                if(clr_output_pixel_data_y_cntr = '1')    then
                                                    output_pixel_data_y_cntr <=  (others =>'0');
                                                end if;
                                            end if;
                                        end process;
                                ------------------------------------------
                                -- Increase pixel Y cntr when X was 3'b111 and was also a new output has been sent out
                                L_Y_INC :   inc_output_pixel_data_y_cntr    <=  '1' when    (fsm_new_output = '1' and
                                                                                             output_pixel_data_x_cntr = b"111")
                                                                                    else '0';
                            end block;
    ---------------------------------------------------------------------------------------------


    L_DRIVE_DONE:   dct_done    <=  dct_done_w;

    ------------------------------------------
    L_2D_DCT_CORE:  entity work.DCT_2D(rtl)
                        port map(
                            clk             =>  clk                 ,
                            rstn            =>  rstn                ,
                            start_dct       =>  start_dct           ,
                            busy            =>  busy                ,
                            pixel_block_in  =>  recieved_pixels     ,
                            pixel_block_out =>  transmitted_pixels  ,
                            dct_done        =>  dct_done_w
                        );
    ------------------------------------------
end architecture;
---------------------------------------------------------------------------------------------------------