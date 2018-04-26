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
        enable();
        std::cout <<"["<<get_name()<<"] Clock is started!" <<std::endl;
    }
    //==================================



    //==================================
    // Stop the clock
    void stop_clock(){
        clear();
        std::cout <<"["<<get_name()<<"] Clock is stopped!" <<std::endl;
    }
    //==================================
};

#endif//CLK_GEN_H