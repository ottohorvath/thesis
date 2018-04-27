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


//Define command words
const uint32_t   FIFO_RD_IF_CMD_EN              =   0x01;
const uint32_t   FIFO_RD_IF_CMD_CLR             =   0x02;


class fifo_rd_if:    public  simple_component
{
public:
    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(fifo_rd_if, simple_component)
    //==================================


    //==================================
    // Enable the module
    virtual void enable(){

        // Write the command
        write_data(FIFO_RD_IF_CMD_EN);

        // Waiting for the component to be updated
        while( read_data() != FIFO_RD_IF_ENABLED ){}

        // Update status field
        set_enabled(0x1);
    }
    //==================================


    //==================================
    // Send back the module to idle
    virtual void clear(){

        // Write the command
        write_data(FIFO_RD_IF_CMD_CLR);

        // Waiting for the component to be updated
        while( read_data() != FIFO_RD_IF_IDLE ){}

        // Update status field
        set_enabled(0x0);
    }
    //==================================



    //==================================
    // Poll the control register until it is enabled
    virtual void wait_until_enabled(){

        // Waiting for the component to be enabled
        while( read_data() != FIFO_RD_IF_ENABLED ){}
    }
    //==================================


    //==================================
    // Poll the control register until it is enabled
    virtual void wait_until_cleared(){
        
        // Waiting for the component to be cleared
        while( read_data() != FIFO_RD_IF_IDLE ){}
    }
    //=================================


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