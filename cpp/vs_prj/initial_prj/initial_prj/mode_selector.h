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
        enable();
        std::cout << get_name()<<": Test mode has been set!" <<std::endl;
    }
    //==================================


    //==================================
    // Set normal mode
    void set_normal_mode(){
        clear();
        std::cout << get_name()<<": Normal mode has been set!" <<std::endl;
    }
    //==================================
};

#endif//MODE_SELECTOR_H