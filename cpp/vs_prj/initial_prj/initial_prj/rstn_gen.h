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


#ifndef RSTN_GEN_H
#define RSTN_GEN_H

class rstn_gen:    public  simple_component
{

public:

    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(rstn_gen, simple_component)
    //==================================


    //==================================
    // Generate reset pulse
    void gen_pulse(){

        enable();
    }
    //==================================


    //==================================
    // Clear the control register
    void clear_register(){

        clear();
    }
    //==================================
};

#endif//RSTN_GEN_H