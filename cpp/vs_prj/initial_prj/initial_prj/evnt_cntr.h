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


#ifndef EVNT_CNTR_H
#define EVNT_CNTR_H



//Define commands words
const uint32_t  EVNT_CNTR_ENABLE  =   0x1;
const uint32_t  EVNT_CNTR_CLEAR   =   0x2;



class evnt_cntr:    public  component_base
{
public:

    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(evnt_cntr, component_base)
    //==================================


    //==================================
    // Enable the detector
    virtual void enable(){

        write_data(EVNT_CNTR_ENABLE);
    }
    //==================================


    //==================================
    // Clear the detector
    virtual void clear(){

        write_data(EVNT_CNTR_CLEAR);
    }
    //==================================

};

#endif//EVNT_CNTR_H