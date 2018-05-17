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


#ifndef CLK_GEN_H
#define CLK_GEN_H

class clk_gen:    public  simple_component
{

public:

    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(clk_gen, simple_component)
    //==================================



    //==================================
    // Start generating the clock
    void start_clock(){
        std::cout<<"["<< get_name()<<"] Starting clock for the environment ..."<<std::endl;
        enable();
    }
    //==================================



    //==================================
    // Stop the clock
    void stop_clock(){
        std::cout<<"["<< get_name()<<"] Stopping clock ..."<<std::endl;
        clear();
    }
    //==================================
};

#endif//CLK_GEN_H