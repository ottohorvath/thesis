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


#ifndef SIMPLE_COMPONENT_H
#define SIMPLE_COMPONENT_H


//Define instruction words
const uint32_t   CMD_EN          =   0x01;
const uint32_t   CMD_CLR         =   0x02;


//Define status words
const uint32_t   STATUS_EN       =   0x01;
const uint32_t   STATUS_CLR      =   0x00;


class simple_component:    public  component_base
{

public:


    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(simple_component, component_base)
    //==================================


    //==================================
    // Enable the module by writing CMD_EN in
    virtual void enable(){

        // Write the command
        write_data(CMD_EN);

        // Waiting for the component to be updated
        while( read_data() != STATUS_EN ){}

        // Update status field
        set_enabled(0x1);
    }
    //==================================



    //==================================
    // Clear the module by writing CMD_CLR in
    virtual void clear(){

        // Write the command
        write_data(CMD_CLR);

        // Waiting for the component to be updated
        while( read_data() != STATUS_CLR ){}

        // Updated status field
        set_enabled(0x0);
    }
    //==================================


    //==================================
    // Poll the control register until it is enabled
    virtual void wait_until_enabled(){

        // Waiting for the component to be enabled
        while( read_data() != STATUS_EN ){}
    }
    //==================================



    //==================================
    // Poll the control register until it is enabled
    virtual void wait_until_cleared(){

        // Waiting for the component to be cleared
        while( read_data() != STATUS_CLR ){}
    }
    //==================================

};

#endif//SIMPLE_COMPONENT_H