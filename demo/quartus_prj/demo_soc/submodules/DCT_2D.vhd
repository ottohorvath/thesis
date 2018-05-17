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


-- 2D-DCT module with FSM:
--  ~ First, it goes through on rows and then on columns
--  ~ 'goes' means here doing 1D-DCT transformation
------------------------------------------------------------------
entity DCT_2D is
    port(
        clk             :   in  std_logic           ;
        rstn            :   in  std_logic           ;
        -- Start 2D-DCT
        start_dct       :   in  std_logic           ;
        -- Doing the transformation
        busy            :   out std_logic           ;
        -- 8x8 pixel block as input
        pixel_block_in  :   in  inputPixelBlock     ;
        -- Transformed 8x8 pixel block as output
        pixel_block_out :   out outputPixelBlock    ;
        -- Done signal
        dct_done        :   out std_logic
    );
end entity DCT_2D;
------------------------------------------------------------------



------------------------------------------------------------------
architecture rtl of DCT_2D is
    signal dct_1d_en            :   std_logic;
    signal dct_1d_done          :   std_logic;

    signal state                :   state_t;

    -- Data input to 1D-DCT
    -- ====================
    signal data_to_DCT          :   dctArray;

    -- Data output to 1D-DCT
    -- =====================
    signal data_from_DCT        :   dctArray;

    -- Register bank for the 8x8 input pixel block
    -- 8x8 @ 8 bits
    -- =============
    signal input_data_reg       :   inputPixelBlock ;
    -- Register bank for the 8x8 transformed output pixel block
    -- 8x8 @ 11 bits
    -- =============
    signal output_data_reg      :   outputPixelBlock;

    -- Intermediate register bank for row and column operations
    -- ========================================================
    signal reg_bank             :   dctMatrixArray  ;


begin
    ---------------------------------------------------------------------------------
    L_BUSY: block
            begin
                busy        <=  '1' when(state /= idle and state /= output_ready) else
                                '0';
                dct_done    <=  '1' when(state = output_ready) else
                                '0';
            end block;
    ---------------------------------------------------------------------------------


    ---------------------------------------------------------------------------------
    L_FSM:  process(clk,rstn)
    begin
        if(rstn = '0')
        then
            dct_1d_en           <=  '0'   ;
            state               <=  idle  ;
            input_data_reg      <=  (others =>  (others =>  (others => '0')));
            output_data_reg     <=  (others =>  (others =>  (others => '0')));
            reg_bank            <=  (others =>  (others =>  (others => '0')));
        elsif(rising_edge(clk))
        then
            case state  is
                -----------------------------------------------------------------------------
                when idle =>

                    -------------------------------------------------------------
                    -- Store the inputs to the register bank
                    if(start_dct = '1') then
                        store_pixel_data_to_reg_bank(pixel_block_in,input_data_reg);
                        state <= h0;
                    end if;
                -----------------------------------------------------------------------------
                when h0 =>
                     -- Drive the first row to the 1D-DCT transformator
                    drive_one_row_to_transformator(0,input_data_reg,data_to_DCT);
                    state <= h0en;
                -----------------------------------------------------------------------------
                when h0en =>
                    -- Enable the 1D-DCT transformator
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                    -- Disable and stop the 1D-DCT transformator
                        dct_1d_en   <= '0';
                        state       <= h0done  ;
                    end if;
                -----------------------------------------------------------------------------
                when h0done =>
                    drive_row_data_from_1d_dct_back_to_regbank(0,data_from_DCT,reg_bank);

                    state       <= h1;
                -----------------------------------------------------------------------------
                when h1 =>
                    drive_one_row_to_transformator(1,input_data_reg,data_to_DCT);
                    state <= h1en;
                -------------------------------------------------------------------------------
                when h1en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state   <=  h1done;
                    end if;
                -------------------------------------------------------------------------------
                when h1done =>
                    drive_row_data_from_1d_dct_back_to_regbank(1,data_from_DCT,reg_bank);

                    state       <=  h2;
                ------------------------------------------------------------------------------
                when h2 =>
                    drive_one_row_to_transformator(2,input_data_reg,data_to_DCT);
                    state <= h2en;
                ----------------------------------------------------------------------------------
                when h2en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state   <=  h2done;
                    end if;
                ----------------------------------------------------------------------------------
                when h2done =>
                    drive_row_data_from_1d_dct_back_to_regbank(2,data_from_DCT,reg_bank);

                    state       <= h3;
                ------------------------------------------------------------------------------
                when h3 =>
                    drive_one_row_to_transformator(3,input_data_reg,data_to_DCT);
                    state <= h3en;
                ----------------------------------------------------------------------------------
                when h3en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state   <=  h3done;
                    end if;
                ----------------------------------------------------------------------------------
                when h3done =>
                    drive_row_data_from_1d_dct_back_to_regbank(3,data_from_DCT,reg_bank);

                    state       <= h4;
                ----------------------------------------------------------------------------------
                when h4 =>
                    drive_one_row_to_transformator(4,input_data_reg,data_to_DCT);
                    state <= h4en;
                ----------------------------------------------------------------------------------
                when h4en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state   <=  h4done  ;
                    end if;
                ----------------------------------------------------------------------------------
                when h4done =>
                    drive_row_data_from_1d_dct_back_to_regbank(4,data_from_DCT,reg_bank);

                    state       <= h5;
                ----------------------------------------------------------------------------------
                when h5 =>
                    drive_one_row_to_transformator(5,input_data_reg,data_to_DCT);
                    state <= h5en;
                ----------------------------------------------------------------------------------
                when h5en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  h5done;
                    end if;
                ----------------------------------------------------------------------------------
                when h5done =>
                    drive_row_data_from_1d_dct_back_to_regbank(5,data_from_DCT,reg_bank);

                    state       <= h6;
                ----------------------------------------------------------------------------------
                when h6 =>
                    drive_one_row_to_transformator(6,input_data_reg,data_to_DCT);
                    state <= h6en;
                ----------------------------------------------------------------------------------
                when h6en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  h6done;
                    end if;
                ----------------------------------------------------------------------------------
                when h6done =>
                    drive_row_data_from_1d_dct_back_to_regbank(6,data_from_DCT,reg_bank);

                    state       <= h7;
                ----------------------------------------------------------------------------------
                when h7 =>
                    drive_one_row_to_transformator(7,input_data_reg,data_to_DCT);
                    state <= h7en;
                ----------------------------------------------------------------------------------
                when h7en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  h7done;
                    end if;
                ----------------------------------------------------------------------------------
                when h7done =>
                    drive_row_data_from_1d_dct_back_to_regbank(7,data_from_DCT,reg_bank);

                    state       <= v0;
                ----------------------------------------------------------------------------------
                when v0 =>
                    drive_one_column_from_regbank_to_1d_dct(0,reg_bank,data_to_DCT);
                    state <= v0en;
                ------------------------------------------------------------------------------------
                when v0en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state   <=  v0done;
                    end if;
                ------------------------------------------------------------------------------------
                when v0done =>
                    drive_col_data_from_1d_dct_back_to_regbank(0,data_from_DCT, reg_bank);

                    state       <= v1;
                ------------------------------------------------------------------------------
                when v1 =>
                    drive_one_column_from_regbank_to_1d_dct(1,reg_bank,data_to_DCT);
                    state <= v1en;
                ------------------------------------------------------------------------------------
                when v1en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state   <=  v1done  ;
                    end if;
                ------------------------------------------------------------------------------------
                when v1done =>
                    drive_col_data_from_1d_dct_back_to_regbank(1,data_from_DCT, reg_bank);

                    state       <= v2;
                ------------------------------------------------------------------------------
                when v2 =>
                    drive_one_column_from_regbank_to_1d_dct(2,reg_bank,data_to_DCT);
                    state <= v2en;
                ------------------------------------------------------------------------------------
                when v2en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  v2done  ;
                    end if;
                ------------------------------------------------------------------------------------
                when v2done =>
                    drive_col_data_from_1d_dct_back_to_regbank(2,data_from_DCT, reg_bank);

                    state       <= v3;
                ------------------------------------------------------------------------------
                when v3 =>
                    drive_one_column_from_regbank_to_1d_dct(3,reg_bank,data_to_DCT);
                    state <= v3en;
                ------------------------------------------------------------------------------------
                when v3en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  v3done  ;
                    end if;
                ------------------------------------------------------------------------------------
                when v3done =>
                    drive_col_data_from_1d_dct_back_to_regbank(3,data_from_DCT, reg_bank);

                    state       <= v4;
                ------------------------------------------------------------------------------
                when v4 =>
                    drive_one_column_from_regbank_to_1d_dct(4,reg_bank,data_to_DCT);
                    state <= v4en;
                ------------------------------------------------------------------------------------
                when v4en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  v4done  ;
                    end if;
                ------------------------------------------------------------------------------------
                when v4done =>
                    drive_col_data_from_1d_dct_back_to_regbank(4,data_from_DCT, reg_bank);

                    state       <= v5;
                ------------------------------------------------------------------------------
                when v5 =>
                    drive_one_column_from_regbank_to_1d_dct(5,reg_bank,data_to_DCT);
                    state <= v5en;
                ------------------------------------------------------------------------------------
                when v5en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  v5done  ;
                    end if;
                ------------------------------------------------------------------------------------
                when v5done =>
                    drive_col_data_from_1d_dct_back_to_regbank(5,data_from_DCT, reg_bank);

                    state       <= v6;
                ------------------------------------------------------------------------------
                when v6 =>
                    drive_one_column_from_regbank_to_1d_dct(6,reg_bank,data_to_DCT);
                    state <= v6en;
                ------------------------------------------------------------------------------------
                when v6en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  v6done;
                    end if;
                ------------------------------------------------------------------------------------
                when v6done =>
                    drive_col_data_from_1d_dct_back_to_regbank(6,data_from_DCT, reg_bank);

                    state       <= v7;
                ------------------------------------------------------------------------------
                when v7 =>
                    drive_one_column_from_regbank_to_1d_dct(7,reg_bank,data_to_DCT);
                    state <= v7en;
                ------------------------------------------------------------------------------------
                when v7en =>
                    dct_1d_en   <= '1';
                    if(dct_1d_done = '1')
                    then
                        dct_1d_en   <= '0';
                        state       <=  v7done;
                    end if;
                ------------------------------------------------------------------------------------
                when v7done =>
                    drive_col_data_from_1d_dct_back_to_regbank(7,data_from_DCT, reg_bank);

                    state       <= data_to_output;
                ------------------------------------------------------------------------------
                -- Drive register bank to output register layer
                when data_to_output =>
                    state <= output_ready;
                    drive_regbank_to_output_reg_layer(reg_bank,output_data_reg);
                ------------------------------------------------------------------------------
                -- The data can be taken from output
                when output_ready =>

                    state       <= idle;
                ------------------------------------------------------------------------------
                when others =>
                    state       <= idle;
                ------------------------------------------------------------------------------
            end case;
        end if;
    end process;



    -------------------------------
    L_ROW:  for ii in 0 to M-1  generate
        -------------------------------
        L_COL:  for jj in 0 to N-1  generate
                    pixel_block_out(ii,jj) <= output_data_reg(ii,jj);
                end generate;
        -------------------------------
            end generate;
    -------------------------------




    -------------------------------------------------------
    -- Instance of 1D-DCT
    L_1D_DCT:   entity work.loeff_1D_DCT(rtl)
                    port map(
                        clk         => clk          ,
                        rstn        => rstn         ,
                        doneDCT     => dct_1d_done  ,
                        en          => dct_1d_en    ,
                        dataInDCT   => data_to_DCT  ,
                        dataOutDCT  => data_from_DCT
                    );
    -----------------------------------------------------

end architecture rtl;
------------------------------------------------------------------