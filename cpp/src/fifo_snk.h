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
        std::cout<<"["<< get_name()<<"] Checking full ..."<<std::endl;
        
        if(read_data() == FIFO_SNK_FULL)
        {
            std::cout<<"["<< get_name()<<"] Full!"<<std::endl;
            return  (true);
        }else
        {
            std::cout<<"["<< get_name()<<"] Not full!"<<std::endl;
            return  (false);
        }
    }
    //==================================


    //==================================
    // Check if it is empty
    // The method assumes that the module
    // previously has been set to show its status
    bool is_empty(){
        std::cout<<"["<< get_name()<<"] Checking empty ..."<<std::endl;

        if(read_data() == FIFO_SNK_EMPTY)
        {
            std::cout<<"["<< get_name()<<"] Empty!"<<std::endl;
            return  (true);
        }else
        {
            std::cout<<"["<< get_name()<<"] Not empty!"<<std::endl;
            return  (false);
        }
    }
    //==================================


    //==================================
    // Command to show its status
    void show_status(){
        std::cout<<"["<< get_name()<<"] Showing status ..."<<std::endl;
        write_data(FIFO_SNK_STATUS_CMD);
    }
    //==================================

    //==================================
    // Command to show its data
    void show_data(){
        std::cout<<"["<< get_name()<<"] Showing data ..."<<std::endl;
        write_data(FIFO_SNK_DATA_CMD);
    }
    //==================================


};

#endif//FIFO_SRC_H