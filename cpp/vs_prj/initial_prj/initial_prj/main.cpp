#include"stdafx.h"
//=================
#include<iostream>      //  For Cpp io
#include<string>        //  For Cpp string
#include<stdint.h>      //  For integer types
#include<sys/mman.h>    //  For 'mmap()' and 'munmap()'
#include<fcntl.h>       //  For 'open()'
#include<unistd.h>      //  For 'close()'





//Include the component library
#include"component_library.h"


// Page size, which will be mapped
// In fact, this is the span of the memory map
#define PAGE_SIZE 4096
// Physical base address of LW H2F AXI bridge
#define LW_BASE 0xFF200000
// The Avalon-MM Slave component’s memory address in the FPGA,
// relative to ’LW_BASE’
#define RSTN_GEN_0      0x00000030
#define DELTA_TIMER_1   0x00000020
#define DELTA_TIMER_0   0x00000010
#define CLK_GEN_0       0x00000000


int main()
{
    void*       fpga_virtual_base;
    int         devmem;

    uint32_t*   rg0;
    uint32_t*   cg0;
    uint32_t*   dt1;
    uint32_t*   dt0;


    MAP_FPGA_TO_USERSPACE(fpga_virtual_base,devmem,LW_BASE,PAGE_SIZE)

    rg0 = (uint32_t*)(fpga_virtual_base + (uint8_t)RSTN_GEN_0    );
    dt1 = (uint32_t*)(fpga_virtual_base + (uint8_t)DELTA_TIMER_1 );
    dt0 = (uint32_t*)(fpga_virtual_base + (uint8_t)DELTA_TIMER_0 );
    cg0 = (uint32_t*)(fpga_virtual_base + (uint8_t)CLK_GEN_0     );









    UNMAP_FPGA(fpga_virtual_base,devmem,PAGE_SIZE)
    return 0;
}




