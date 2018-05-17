//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description: ~ Simple environment to demonstrate
//                the developed framework
//
//-------------------------------------------------------------------------



#include<iostream>      //  For Cpp io
#include<iomanip>       //  For Cpp io manipulation
#include<thread>        //  For Cpp multihreading
#include<fstream>       //  For Cpp file operations
#include<string>        //  For Cpp string
#include<cmath>         //  For mathematical operations
#include<stdint.h>      //  For integer types
#include<sys/mman.h>    //  For 'mmap()' and 'munmap()'
#include<fcntl.h>       //  For 'open()'
#include<unistd.h>      //  For 'close()'
#include<sys/time.h>    //  For time measurement



// Show low level memory read/writes in console for debugging purposes
//#define     VERBOSE

// Include the component library
#include"component_library.h"

// Include the golden reference model implemented in SW for DCT-2D
#include"dct_sw.h"

// Page size, which will be mapped
// In fact, this is the span of the memory map
#define PAGE_SIZE       4096

// Physical base address of LW H2F AXI bridge
#define LW_BASE         0xFF200000

// The Avalon-MM Slave components' memory addresses in the FPGA,
// relative to 'LW_BASE'
#define RSTN_GEN_0      0x00000000
#define CLK_GEN_0       0x00000004
#define MODE_SEL_0      0x00000008
#define DCT_2D          0x0000000C
#define FIFO_SNK_0      0x00000010
#define DELTA_TIMER_0   0x00000014
#define RE_DET_0        0x00000018

// Name of the FPGA .RBF configuration file (FPGA image)
// The size of this file is always the same:
// approx. 4.3 MB
const std::string   fpga_cfg    =   "./demo.rbf";



// For testing the accelarator
const int32_t   pixel_block_int[8][8] =
{
    {100,  80, -38,  -31,   17,   -86,  -70, -101},
    {117, -66,  84,   17,   -8,    26,  105,  118},
    { 12, 109,  21, -109, -125,   -61,  -89, -127},
    {-93, -39,  12, -115,  -42,    39,   83,  70 },
    {-90, -78, 106,    7,  -87,    48,    9,  81 },
    {-63, -64, -55,   71,   75,    63,  127,  94 },
    { 87,  29,  65,  111,  -49,   -13, -108, -107},
    {-63,  -7,  64,  -95,    7,  -107,  -15, -26 },
};

// For the golden model written purely in SW
float   pixel_block_float[8][8] =
{
    {100.0,  80.0, -38.0,  -31.0,   17.0,   -86.0,  -70.0, -101.0},
    {117.0, -66.0,  84.0,   17.0,   -8.0,    26.0,  105.0,  118.0},
    { 12.0, 109.0,  21.0, -109.0, -125.0,   -61.0,  -89.0, -127.0},
    {-93.0, -39.0,  12.0, -115.0,  -42.0,    39.0,   83.0,   70.0},
    {-90.0, -78.0, 106.0,    7.0,  -87.0,    48.0,    9.0,   81.0},
    {-63.0, -64.0, -55.0,   71.0,   75.0,    63.0,  127.0,   94.0},
    { 87.0,  29.0,  65.0,  111.0,  -49.0,   -13.0, -108.0, -107.0},
    {-63.0,  -7.0,  64.0,  -95.0,    7.0,  -107.0,  -15.0,  -26.0},
};


int main()
{
    // Store the status of the FPGA-HPS bridges
    uint32_t        fpga_bridges_enabled;


    //==========================================================================
    fpga_bridges_enabled = 0x0;
    // Check bridges if they are enabled
    // NOTE: Macro from 'component_macros.h'
    CHECK_FPGA_BRIDGES(fpga_bridges_enabled)

    // Disable them, if they were enabled
    if(fpga_bridges_enabled == 0x1)
    {
        // NOTE: Macro from 'component_macros.h'
        DISABLE_FPGA_BRIDGES
    }

    // Configure the FPGA with the .RBF file passed in 'fpga_cfg'
    // in 1 MB portions, because FPGA Manager cannot handle
    // larger block sizes
    // NOTE: Macro from 'component_macros.h'
    CONFIGURE_FPGA(fpga_cfg)

    // Enable bridges back
    // NOTE: Macro from 'component_macros.h'
    ENABLE_FPGA_BRIDGES
    //==========================================================================


    // The base virtual address of the FPGA fabric
    void*           fpga_virtual_base;

    // Linux "/dev/mem/"
    int             devmem;

    // Map the memory region, behind which the FPGA resides, to userspace
    // NOTE: Macro from 'component_macros.h'
    MAP_FPGA_TO_USERSPACE(fpga_virtual_base,devmem,LW_BASE,PAGE_SIZE)


    // Define base virtual memory addresses for the HW components
    uint32_t*       rg0_base;
    uint32_t*       cg0_base;
    uint32_t*       ms0_base;

    // DCT-2D needs signed values!
    int32_t*        dct_base;

    uint32_t*       fs0_base;
    uint32_t*       dt0_base;
    uint32_t*       rd0_base;

    //==========================================================================

    // Generate the components' base addresses relative
    // relative to the FPGA's virtual base
    rg0_base    =   (uint32_t*)(fpga_virtual_base + (uint8_t)RSTN_GEN_0     );
    cg0_base    =   (uint32_t*)(fpga_virtual_base + (uint8_t)CLK_GEN_0      );
    ms0_base    =   (uint32_t*)(fpga_virtual_base + (uint8_t)MODE_SEL_0     );

    // Signed pointer!
    dct_base    =   (int32_t* )(fpga_virtual_base + (uint8_t)DCT_2D         );

    fs0_base    =   (uint32_t*)(fpga_virtual_base + (uint8_t)FIFO_SNK_0     );
    dt0_base    =   (uint32_t*)(fpga_virtual_base + (uint8_t)DELTA_TIMER_0  );
    rd0_base    =   (uint32_t*)(fpga_virtual_base + (uint8_t)RE_DET_0       );

    // Construct the objects to handle the HW components
    // And pass also the virtual base addresses to the constructors
    rstn_gen        rg0("Reset generator",  rg0_base);
    clk_gen         cg0("Clock generator",  cg0_base);
    mode_selector   ms0("Mode selector",    ms0_base);
    fifo_snk        fs0("FIFO sink",        fs0_base);
    delta_timer     dt0("Delta timer",      dt0_base);
    re_det          rd0("Rising edge det.", rd0_base);
    //==========================================================================



    //==========================================================================
    const uint32_t      N = 8;
    // Expected DCT-2D values produced by SW reference modell
    float**             expected_dct_values;
    // Actual DCT-2D values created by HW accelarator
    int32_t             actual_dct_values[N][N];


    uint32_t            dt0_initial_value;
    uint32_t            dt0_finish_value;

    struct timeval  start;
    struct timeval  finish;

    // Launch a separate thread for the golden model of DCT-2D
    // The function is given in C++ lambda
    std::thread sw_ref([&]{
        std::cout<<"[SW Ref. Model] Calculating expected values ..."   <<std::endl;

        // Measure thread execution time
        gettimeofday(&start, NULL);
            // Run the SW reference modell
            expected_dct_values     =   dct_2d(pixel_block_float);
        gettimeofday(&finish, NULL);

    });

    // Launch a separate thread for the HW environment of DCT-2D
    // The thread is given in C++ lambda
    std::thread hw_env([&]{
        std::cout<<"[HW Env.] Running test ..." <<std::endl;

        // Check the status of the components in the always-on domain
        // in the beginning
        rg0.info();
        cg0.info();

        // Start clock for the environment
        cg0.start_clock();
        cg0.wait_until_enabled();

        // Reset the environment
        rg0.gen_pulse();
        rg0.wait_until_enabled();

        // Check again the status of the components in the always-on domain
        rg0.info();
        cg0.info();


        ms0.set_normal_mode();
        // Enable risingedge detector
        rd0.enable();
        // Enable delta timer
        dt0.enable();
        // Read out its initial value of delta timer
        dt0_initial_value = dt0.read_data();

        // Check the FIFO Sink component
        // Command FIFO sink to show its status on its primer output
        fs0.show_status();
        fs0.is_full();
        fs0.is_empty();


        // Fill up accelerator with pixel data
        // but do not just start it right after the data transfers
        std::cout<<"[HW Env.] Fill up the HW ..." <<std::endl;
        for(uint32_t row = 0; row < 8; row++)
        {
            for(uint32_t col = 0; col < 8; col++)
            {
//                std::cout<<"[HW] WDATA("<<row<<","<<col<<") = "<<std::dec<<pixel_block_int[row][col] <<std::endl;
                *dct_base   =   pixel_block_int[row][col];
            }
        }

        // Start the accelarator via 'mode_selector'
        ms0.set_test_mode();

        // Set back the mode to normal, this will prevent the accelarator
        // to start again its operation
        ms0.set_normal_mode();


        // Wait here until Rising-edge dectector caught the pulse on 'dct_done'
        while(rd0.has_caught() != true){}


        // Check how long was the accelarator busy
        dt0_finish_value   =   dt0.read_data();

        fs0.is_full();
        fs0.is_empty();

        // Command FIFO Sink to show its status on its primer output
        fs0.show_data();

        std::cout<<"[HW Env.] Read out the HW ..." <<std::endl;
        // Read out FIFO Sink component
        for(uint32_t row = 0; row < 8; row++)
        {
            for(uint32_t col = 0; col < 8; col++)
            {
                // Read by simple pointer dereferencing
                int32_t rdata       =   (int32_t)(*fs0_base);

                // Store them for comparison
                actual_dct_values[row][col]    =   rdata;
//                std::cout<<"[HW] RDATA("<<row<<","<<col<<") = "<<std::dec<<rdata <<std::endl;
            }
        }

        // Check the FIFO Sink component after reading out its data
        fs0.show_status();
        fs0.is_full();
        fs0.is_empty();
    });
    //==========================================================================
    // Wait for all the threads to finish
    sw_ref.join();
    std::cout<<"[SW Ref. Model] Done!" <<std::endl;
    double exec_time    =   ((double) 1e6 * finish.tv_sec  + (double)finish.tv_usec)
                            -((double) 1e6 * start.tv_sec   + (double)start.tv_usec);

    std::cout<<"[SW Ref. Model] Execution time = "<<exec_time <<" [us]"
    <<std::endl;




    hw_env.join();
    std::cout<<"[HW Env.] Done!" <<std::endl;
    std::cout<<"[HW Env.] Test done!"   <<std::endl;

    //==========================================================================
    std::cout<<"[CHECK] Start checking results!"   <<std::endl;

    // Error counter for dct value checking
    uint32_t    err_cntr;

    err_cntr = 0;
    std::cout<<"[CHECK] Start with DCT-2D values ..."   <<std::endl;
    std::cout<<"[CHECK] 1 digit of difference is allowed!"   <<std::endl;
    for(uint32_t row = 0; row < N; row++)
    {
        for(uint32_t col = 0; col < N; col++)
        {
            float       exp =   expected_dct_values[row][col];
            int32_t     act =   actual_dct_values[row][col];
            float       dif =   std::abs(exp-act);

            // Set some arbitrary criteria for the difference
            // One digit difference is accepted
            if(dif  > 1){
                err_cntr++;
            }

            std::cout <<"[CHECK] Expected = " <<            exp
                      <<"\n"
                      <<"        Actual   = "<<std::dec<<   act
                      <<"\n"
                      <<"        Diff.    = "<<             dif
                      <<std::endl;
        }
    }

    // Print based on results
    if(err_cntr == 0x0){
        std::cout<<"[RESULT: DCT-2D] PASSED!"   <<std::endl;
    }else{
        std::cout<<"[RESULT: DCT-2D] FAILED!"   <<std::endl;
    }


    err_cntr = 0x0;

    // Compare the value of deltatimer with a value which has been
    // acquired in RTL simulation
    if(dt0_finish_value != 161){
        err_cntr=0x1;
    }

    std::cout   <<"[CHECK] Collected accelerator busy time must be matched with the value given by the RTL simulation"
                <<"\n"
                <<"        Expected = 161 x clock period (20 ns)"
                <<"\n"
                <<"        Actual   = " <<dt0_finish_value
                <<std::endl;


    // Print based on results
    if(err_cntr == 0x0){
        std::cout<<"[RESULT: Busy-time] PASSED!"   <<std::endl;
    }else{
        std::cout<<"[RESULT: Busy-time] FAILED!"   <<std::endl;
    }


    // Remove FPGA from userspace
    // NOTE: Macro from 'component_macros.h'
    UNMAP_FPGA(fpga_virtual_base,devmem,PAGE_SIZE)

    return 0;
}




