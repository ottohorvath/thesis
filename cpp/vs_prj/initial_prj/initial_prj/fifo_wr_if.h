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


#ifndef FIFO_WR_IF_H
#define FIFO_WR_IF_H

//Define status words
const uint32_t   FIFO_WR_IF_IDLE        =   0x02;
const uint32_t   FIFO_WR_IF_ENABLED     =   0x01;
const uint32_t   FIFO_WR_IF_RCVD_DATA   =   0x07;

//Define command words
const uint32_t   FIFO_WR_IF_CMD_EN              =   0x01;
const uint32_t   FIFO_WR_IF_CMD_CLR             =   0x02;
const uint32_t   FIFO_WR_IF_CMD_SHOW_DATA       =   0x04;


class fifo_wr_if:    public  simple_component
{
public:



    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(fifo_wr_if, simple_component)
    //==================================


    //==================================
    // Enable the module
    virtual void enable(){
        // Write the command
        write_data(FIFO_WR_IF_CMD_EN);

        // Waiting for the component to be updated
        while( read_data() != FIFO_WR_IF_ENABLED ){}

        // Update status field
        set_enabled(0x1);

        // Info
        std::cout <<"["<< get_name()  <<"] Enabled!" <<std::endl;
    }
    //==================================


    //==================================
    // Send back the module to idle
    virtual void clear(){
        // Write the command
        write_data(FIFO_WR_IF_CMD_CLR);

        // Waiting for the component to be updated
        while( read_data() != FIFO_WR_IF_IDLE ){}

        // Update status field
        set_enabled(0x0);

        // Info
        std::cout <<"["<< get_name()  <<"] Cleared!" <<std::endl;
    }
    //==================================


    //==================================
    // Poll the control register until it is enabled
    virtual void wait_until_enabled(){

        // Info
        std::cout <<"["<< get_name()  <<"] Waiting to be enabled ..." <<std::endl;

        // Waiting for the component to be enabled
        while( read_data() != FIFO_WR_IF_ENABLED ){}
    }
    //==================================


   //==================================
    // Poll the control register until it is enabled
    virtual void wait_until_cleared(){

        // Info
        std::cout <<"["<< get_name()  <<"] Waiting to be cleared ..." <<std::endl;

        // Waiting for the component to be cleared
        while( read_data() != FIFO_WR_IF_IDLE ){}
    }
    //=================================


    //==================================
    // Check if it is in IDLE state
    bool is_idle(){

        return (read_data() == FIFO_WR_IF_IDLE)?(true):(false);
    }
    //==================================



    //==================================
    // Check if it is in 'ENABLED' state
    bool is_enabled(){

        return (read_data() == FIFO_WR_IF_ENABLED)?(true):(false);
    }
    //==================================



    //==================================
    // Check if it is in 'RCVD_DATA' state
    bool is_rcvd_data(){

        return (read_data() == FIFO_WR_IF_RCVD_DATA)?(true):(false);
    }
    //==================================



    //==================================
    // Send the module to 'SHOW_DATA' state
    void show_data(){

        // Write in the related command
        write_data(FIFO_WR_IF_CMD_SHOW_DATA);
    }
    //==================================



    //==================================
    // Reading data out from module
    // This method assumes that the
    // module in 'SHOW_DATA' state
    uint32_t read_out(){

        return read_data();
    }
    //==================================



};

#endif//FIFO_WR_IF_H