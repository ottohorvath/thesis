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


#ifndef MODE_SELECTOR_H
#define MODE_SELECTOR_H

class mode_selector:    public  simple_component
{

public:

    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(mode_selector, simple_component)
    //==================================


    //==================================
    // Set test mode
    void set_test_mode(){
        std::cout<<"["<< get_name()<<"] Test mode ..."<<std::endl;
        enable();
    }
    //==================================


    //==================================
    // Set normal mode
    void set_normal_mode(){
        std::cout<<"["<< get_name()<<"] Normal mode ..."<<std::endl;
        clear();
    }
    //==================================
};

#endif//MODE_SELECTOR_H