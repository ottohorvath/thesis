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

library ieee                ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all    ;
-----------------------------------------------







package dct_package
is
    -- The resultant bit widths of matrix products in Loeffler's algorithm
    constant innerDataWidth :   integer := 16   ;
    -- Input data width (pixel bit depth)
    constant inputDataWidth :   integer := 8    ;
    
    -- Transformed pixel in fixed point format
    constant outputDataWidth:   integer := 11   ;
    
    -- M by N matrix
    constant M              :   integer := 8    ;
    constant N              :   integer := 8    ;


    -- The type of data which arrives to 1D-DCT
    -- 8 long array of 16 bits
    type dctArray is
        array (inputDataWidth-1 downto 0) of
            std_logic_vector(innerDataWidth-1   downto 0);


    --- a 2D-DCT atmeneti adatainak tarolasara
    --- DEFAULT: _____________8x8 db 16 bites adat____________
    ----------------------------------------------------------------------------------
    type dctMatrixArray is
        array (M-1 downto 0,N-1 downto 0) of
            std_logic_vector(innerDataWidth-1 downto 0);
    ----------------------------------------------------------------------------------

    --- a bemeno pixelblokk tipusa
    --- DEFAULT: _____________8x8 db 8 bites adat_____________
    ----------------------------------------------------------------------------------
    type inputPixelBlock is
        array(M-1 downto 0,N-1 downto 0) of   -- egy MxN-es pixelblokk
            std_logic_vector(inputDataWidth-1   downto 0);                  --
    -----------------------------------------------------------------------------------


    --- a kimeneti, transzformalt pixelblokk tipusa
    --- DEFAULT: _____________8x8 db 11 bites adat____________
    -----------------------------------------------------------------------------------
    type outputPixelBlock is
        array(M-1 downto 0,N-1 downto 0) of   -- az MxN-es trafozott pixelblokk
            std_logic_vector(outputDataWidth-1  downto 0);                  --
    -----------------------------------------------------------------------------------


    --- a 2D-DCT vezerlo allapotgep allapotainak megadasa
    --- idle: varakozik a start_dct jelre, ha megerkezett ez, akkor bemasolja a bemenetet egy regiszterbankba
    --- h*  : az adott pixelmatrix soran megy vegig, horizontalisan
    --- v*  : az adott pixelmatrix oszlopan megy, vertikalisan
    -----------------------------------------------------------------------------------
    type    state_t is(
        idle,
        h0  , h0en, h0done,
        h1  , h1en, h1done,
        h2  , h2en, h2done,
        h3  , h3en, h3done,
        h4  , h4en, h4done,
        h5  , h5en, h5done,
        h6  , h6en, h6done,
        h7  , h7en, h7done,
        v0  , v0en, v0done,
        v1  , v1en, v1done,
        v2  , v2en, v2done,
        v3  , v3en, v3done,
        v4  , v4en, v4done,
        v5  , v5en, v5done,
        v6  , v6en, v6done,
        v7  , v7en, v7done,
        data_to_output,
        output_ready
    );
    -----------------------------------------------------------------------------------


    ------------------------------------------------
    function    shift_left_by_2_and_extend_to_16_bits(
        data_in :   in  std_logic_vector
    )   return          std_logic_vector;

    ------------------------------------------------
    -- Drive one row from  'src' pixel matrix to the transformator matrix
    procedure   drive_one_row_to_transformator(
        constant    row_idx :   in  integer         ;
        signal      src     :   in  inputPixelBlock ;
        signal      dst     :   out dctArray
    );

    ------------------------------------------------
    -- Store 'src' input pixel matrix to register bank
    procedure   store_pixel_data_to_reg_bank(
        signal  src     :   in  inputPixelBlock;
        signal  dst     :   out inputPixelBlock
    );


    ------------------------------------------------
    -- Drive the transformed outputs from register bank
    procedure   drive_transformed_pixels_to_output(
        signal  src :   in  outputPixelBlock;
        signal  dst :   out outputPixelBlock
    );

    ------------------------------------------------
    -- Drive the result of 1D-DCT ROW transforming back to register bank
    procedure   drive_row_data_from_1d_dct_back_to_regbank(
        constant    row_idx :   in  integer     ;
        signal      src     :   in  dctArray    ;
        signal      dst     :   out dctMatrixArray
    );

    ------------------------------------------------
    procedure   drive_one_column_from_regbank_to_1d_dct(
        constant    col_idx :   in  integer         ;
        signal      src     :   in  dctMatrixArray  ;
        signal      dst     :   out dctArray
    );

    ------------------------------------------------
    -- Drive the result of 1D-DCT COLUMN transforming back to register bank
    procedure   drive_col_data_from_1d_dct_back_to_regbank(
        constant    col_idx :   in  integer;
        signal      src     :   in  dctArray;
        signal      dst     :   out dctMatrixArray
    );


    ------------------------------------------------
    procedure   drive_regbank_to_output_reg_layer(
        signal  src :   in  dctMatrixArray  ;
        signal  dst :   out outputPixelBlock
    );


end package;
-----------------------------------------------



package body dct_package
is

    ------------------------------------------------
    function    shift_left_by_2_and_extend_to_16_bits(
        data_in :   in  std_logic_vector
    )   return          std_logic_vector
    is
        variable  tmp:    std_logic_vector(innerDataWidth-1 downto 0);
    begin
        tmp := std_logic_vector(resize(signed(shift_left(signed(resize(unsigned(data_in),inputDataWidth+2)),2)), innerDataWidth));
        -----------
        return tmp;
        -----------
    end function;
    ------------------------------------------------

    ------------------------------------------------
    -- Drive one row from  'src' pixel matrix to the transformator matrix
    procedure   drive_one_row_to_transformator(
        constant    row_idx :   in  integer         ;
        signal      src     :   in  inputPixelBlock ;
        signal      dst     :   out dctArray
    )
    is
    begin
        dst(0)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,0)  );
        dst(1)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,1)  );
        dst(2)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,2)  );
        dst(3)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,3)  );
        dst(4)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,4)  );
        dst(5)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,5)  );
        dst(6)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,6)  );
        dst(7)  <=  shift_left_by_2_and_extend_to_16_bits(  src(row_idx,7)  );
    end procedure;
    ------------------------------------------------

    ------------------------------------------------
    -- Store 'src' input pixel matrix to register bank
    procedure   store_pixel_data_to_reg_bank(
        signal  src     :   in  inputPixelBlock;
        signal  dst     :   out inputPixelBlock
    )
    is
    begin
        -------------------------------
        for ii in 0 to M-1  loop
            -------------------------------
            for jj in 0 to N-1  loop
                dst(ii,jj)   <= src(ii,jj);
            end loop;
            -------------------------------
        end loop;
    end procedure;
    ------------------------------------------------


    ------------------------------------------------
    -- Drive the transformed outputs from register bank
    procedure   drive_transformed_pixels_to_output(
        signal  src :   in  outputPixelBlock;
        signal  dst :   out outputPixelBlock
    )
    is
    begin
        -------------------------------
        for ii in 0 to M-1  loop
            -------------------------------
            for jj in 0 to N-1  loop
                dst(ii,jj) <= src(ii,jj);
            end loop;
            -------------------------------
        end loop;
        -------------------------------
    end procedure;
    ------------------------------------------------

    ------------------------------------------------
    -- Drive the result of 1D-DCT ROW transforming back to register bank
    procedure   drive_row_data_from_1d_dct_back_to_regbank(
        constant    row_idx :   in  integer     ;
        signal      src     :   in  dctArray    ;
        signal      dst     :   out dctMatrixArray
    )
    is
    begin
        dst(row_idx,0)   <=  std_logic_vector(signed( src(0) )  );
        dst(row_idx,1)   <=  std_logic_vector(signed( src(1) )  );
        dst(row_idx,2)   <=  std_logic_vector(signed( src(2) )  );
        dst(row_idx,3)   <=  std_logic_vector(signed( src(3) )  );
        dst(row_idx,4)   <=  std_logic_vector(signed( src(4) )  );
        dst(row_idx,5)   <=  std_logic_vector(signed( src(5) )  );
        dst(row_idx,6)   <=  std_logic_vector(signed( src(6) )  );
        dst(row_idx,7)   <=  std_logic_vector(signed( src(7) )  );
    end procedure;
    ------------------------------------------------

    ------------------------------------------------
    procedure   drive_one_column_from_regbank_to_1d_dct(
        constant    col_idx :   in  integer         ;
        signal      src     :   in  dctMatrixArray  ;
        signal      dst     :   out dctArray
    )
    is
    begin
        dst(0)  <= src(0,col_idx);
        dst(1)  <= src(1,col_idx);
        dst(2)  <= src(2,col_idx);
        dst(3)  <= src(3,col_idx);
        dst(4)  <= src(4,col_idx);
        dst(5)  <= src(5,col_idx);
        dst(6)  <= src(6,col_idx);
        dst(7)  <= src(7,col_idx);
    end procedure;
    ------------------------------------------------

    ------------------------------------------------
    -- Drive the result of 1D-DCT COLUMN transforming back to register bank
    procedure   drive_col_data_from_1d_dct_back_to_regbank(
        constant    col_idx :   in  integer;
        signal      src     :   in  dctArray;
        signal      dst     :   out dctMatrixArray
    )
    is
    begin
        -- Firstn divide the result by 8 (shift right by 3)
        -- and then round it up by adding MSB part of the fraction (i.e. b"10" in case of 2 bits)
        dst(0,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(0)), 3) + 2) ,2));
        dst(1,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(1)), 3) + 2) ,2));
        dst(2,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(2)), 3) + 2) ,2));
        dst(3,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(3)), 3) + 2) ,2));
        dst(4,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(4)), 3) + 2) ,2));
        dst(5,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(5)), 3) + 2) ,2));
        dst(6,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(6)), 3) + 2) ,2));
        dst(7,col_idx)  <= std_logic_vector(shift_right( (shift_right(signed(src(7)), 3) + 2) ,2));
    end procedure;
    ------------------------------------------------


    ------------------------------------------------
    procedure   drive_regbank_to_output_reg_layer(
        signal  src :   in  dctMatrixArray  ;
        signal  dst :   out outputPixelBlock
    )
    is
    begin
        -------------------------------
        for ii in 0 to M-1  loop
            -------------------------------
            for jj in 0 to N-1 loop
                dst(ii,jj) <= std_logic_vector(resize(signed(src(ii,jj)),outputDataWidth));
            end loop;
            -------------------------------
        end loop;
        -------------------------------
    end procedure;
    ------------------------------------------------

end package body;
