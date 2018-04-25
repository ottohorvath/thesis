//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description:
//          
//  ~ 
//                  
//
//-------------------------------------------------------------------------


#ifndef FIFO_SNK_H
#define FIFO_SNK_H

//Define command words
const uint32_t   FIFO_SNK_STATUS_CMD    = 0x01;
const uint32_t   FIFO_SNK_DATA_CMD      = 0x02;

//Define status word
//[0] - empty
//[1] - full
const uint32_t   FIFO_SNK_EMPTY = 0x01;
const uint32_t   FIFO_SNK_FULL  = 0x02;

class fifo_snk:    public  component_base
{
public:
    
    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(fifo_snk, component_base)
    //==================================



    //==================================
    // Check if it is full
    // The method assumes that the module
    // previously has been set to show its status
    bool is_full(){
        
        return (read_data() == FIFO_SNK_FULL)?(true):(false);
    }
    //==================================


    //==================================
    // Check if it is empty
    // The method assumes that the module
    // previously has been set to show its status
    bool is_empty(){
        
        return (read_data() == FIFO_SNK_EMPTY)?(true):(false);
    }
    //==================================


    //==================================
    // Command to show its status
    void show_status(){

        write_data(FIFO_SNK_STATUS_CMD);
    }
    //==================================

    //==================================
    // Command to show its data
    void show_data(){

        write_data(FIFO_SNK_DATA_CMD);
    }
    //==================================








};

#endif//FIFO_SRC_H