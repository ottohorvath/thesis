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
        std::cout << get_name()<<": Reset pulse has been generated!" <<std::endl;
    }
    //==================================


    //==================================
    // Clear the control register
    void clear_register(){
        clear();
        std::cout << get_name()<<": Cleared!" <<std::endl;
    }
    //==================================
};

#endif//RSTN_GEN_H