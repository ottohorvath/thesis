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


#ifndef FIFO_SRC_H
#define FIFO_SRC_H

//Define status words
const uint32_t   FIFO_SRC_FULL = 0x01;

class fifo_src:    public  component_base
{
public:

    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(fifo_src, component_base)
    //==================================



    //==================================
    // Check if it is full
    bool is_full(){

        return (read_data() == FIFO_SRC_FULL)?(true):(false);
    }
    //==================================

};

#endif//FIFO_SRC_H