//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description: ~ Golden model for DCT-2D accelerator written purely in SW
//
//
//-------------------------------------------------------------------------

//  Simple and naive 1D-DCT algorithm
//  =================================
//  ~ N         :   order of the transformation / number of values in input
//  ~ x         :   pointer to data to be transformed / input data vector
float*     dct_1d(
//    uint32_t    N,
    float      x[8]
)
{
    const uint32_t    N = 8;
    // Argument of cosine function in DCT-1D
    float       cos_arg;
    // DCT result
    float*      X;


    // pi
    const float PI  = 3.14159265;
    // Normalizing factors in DCT-1D
    const float W_0 =   (float)(    1/ std::sqrt(   (float)(N) )    );
    const float W_k =   (float)(    std::sqrt( 2 /( float(N) )) );


    // Allocate memory space to the result
    X  =   new float[N];
    //==========================================================================
    // Implement the mathematical definition of 1D-DCT
    for(uint32_t k = 0; k < N; k++)
    {
        X[k] = 0.0;
        // Code the mathematical sum
        for(uint32_t n = 0; n < N; n++)
        {
            cos_arg =   (float)( k * PI * (2*n+1) / (2*N) );

            X[k]    +=  ( std::cos(cos_arg) * x[n]);
        }
        // Normalize the result
        X[k] *= (k == 0) ? (W_0):(W_k);
    }
    //==========================================================================

    // Return pointer to the result vector
    return  X;
}


// Simple N-by-N matrix transposer
// ===============================
// (pretty slow)
float**    transpose_matrix(
//    uint32_t    N,
    float**     A
)
{
    const uint32_t    N = 8;
    // Transpose of A
    float**  A_T;

    A_T = new float*[N];
    for(uint32_t row=0; row<N; row++)
        A_T[row] = new float[N];

    //==========================================================================
    for(uint32_t row = 0; row < N; row ++)
    {
        for(uint32_t col = 0; col < N; col ++)
        {
            // Implementing the transposing operation
            A_T[row][col] = A[col][row];
        }
    }
    //==========================================================================
    return  A_T;
}


// Simple DCT-2D via DCT-1Ds and transposing
// ========================================

float**     dct_2d(
//    uint32_t    N,
    float     pixel_block[8][8]
)
{
    const uint32_t    N = 8;

    float**     transformed_pixel_block;

    transformed_pixel_block =   new float*[N];
    for(uint32_t row=0; row<N; row++)
        transformed_pixel_block[row] = new float[N];

    //==========================================================================
    for(uint32_t row = 0; row < N; row ++)
    {
        for(uint32_t col = 0; col < N; col ++)
        {
            // Initialize output matrix
            transformed_pixel_block[row][col] = 0.0;
        }
    }
    //==========================================================================

    //==========================================================================
    // Do DCT-1D for the rows
    for(uint32_t row = 0; row < N; row ++)
    {
        transformed_pixel_block[row]    =   dct_1d( (pixel_block[row]) );
    }
    //==========================================================================

    //==========================================================================
    // Transpose the intermediate matrix
    transformed_pixel_block =   transpose_matrix( transformed_pixel_block);
    //==========================================================================


    //==========================================================================
    // Do DCT-1D on the rows of the TRANSPOSED intermediate matrix
    for(uint32_t row = 0; row < N; row ++)
    {
        transformed_pixel_block[row]    =   dct_1d(transformed_pixel_block[row]);
    }
    //==========================================================================

    //==========================================================================
    // Transpose the intermediate matrix
    transformed_pixel_block =   transpose_matrix( transformed_pixel_block);
    //==========================================================================


    return  transformed_pixel_block;
}




