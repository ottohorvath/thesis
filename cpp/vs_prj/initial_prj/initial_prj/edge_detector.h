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


#ifndef EDGE_DETECTOR_H
#define EDGE_DETECTOR_H



//Define commands words
const uint32_t  EDGE_DECTOR_ENABLE  =   0x1;
const uint32_t  EDGE_DECTOR_CLEAR   =   0x2;

//Define status words
const uint32_t  EDGE_DECTOR_CAUGHT   =   0x1;


class edge_detector:    public  component_base
{
public:
    
    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(edge_detector, component_base)
    //==================================


    //==================================
    // Enable the detector
    virtual void enable(){

        write_data(EDGE_DECTOR_ENABLE);
    }
    //==================================


    //==================================
    // Clear the detector
    virtual void clear(){
    
        write_data(EDGE_DECTOR_CLEAR);
    }
    //==================================

    //==================================
    // Checks if it has detected the event
    virtual bool has_caught(){
    
        return(read_data()== EDGE_DECTOR_CAUGHT)?(true):(false);
    }
    //==================================

};

#endif//EDGE_DETECTOR_H