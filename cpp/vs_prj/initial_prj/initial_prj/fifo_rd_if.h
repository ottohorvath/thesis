//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description:
//          
// 
//                  
//
//-------------------------------------------------------------------------


#ifndef FIFO_RD_IF_H
#define FIFO_RD_IF_H


//Define status words
const uint32_t   FIFO_RD_IF_IDLE                =   0x02;
const uint32_t   FIFO_RD_IF_ENABLED             =   0x03;
const uint32_t   FIFO_RD_IF_RDATA_PRESENT       =   0x01;
const uint32_t   FIFO_RD_IF_RDATA_GOT_READ_OUT  =   0x07;


class fifo_rd_if:    public  simple_component
{
public:
    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(fifo_rd_if, simple_component)
    //==================================


    //==================================
    // Simple write data to FIFO_RD_IF
    void write_in(
        const uint32_t&  wdata
    ){
        // First enable the module
        enable();
        // Then write in the payload
        write_data(wdata);
    }
    //==================================


    //==================================
    // Check if it is in IDLE state
    bool is_idle(){
        
        return (read_data() == FIFO_RD_IF_IDLE)?(true):(false);
    }
    //==================================



    //==================================
    // Check if it is in ENABLED state
    bool is_enabled(){
        
        return (read_data() == FIFO_RD_IF_ENABLED)?(true):(false);
    }
    //==================================


    //==================================
    // Check if it is in RDATA_PRESENT state
    bool is_rdata_present(){
        
        return (read_data() == FIFO_RD_IF_RDATA_PRESENT)?(true):(false);
    }
    //==================================


    //==================================
    // Check if it is in RDATA_PRESENT state
    bool is_rdata_got_read_out(){
        
        return (read_data() == FIFO_RD_IF_RDATA_GOT_READ_OUT)?(true):(false);
    }
    //==================================

};

#endif//FIFO_RD_IF_H