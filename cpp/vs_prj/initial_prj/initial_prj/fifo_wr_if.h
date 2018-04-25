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


class fifo_wr_if:    public  simple_component
{
public:



    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(fifo_wr_if, simple_component)
    //==================================


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
    bool is_rdata_present(){

        return (read_data() == FIFO_WR_IF_RCVD_DATA)?(true):(false);
    }
    //==================================



    //==================================
    // Send the module to 'SHOW_DATA' state
    void show_data(){

        // Write in the related command
        write_data(CMD_SHOW_DATA);
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