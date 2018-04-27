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


#ifndef INTERFACE_COMPONENT_H
#define INTERFACE_COMPONENT_H


class interface_component:    public  component_base
{

public:

    //==================================
    // Constructor
    BASIC_CONSTRUCTOR(interface_component, component_base)
    //==================================


    //==================================
    // Start a read transaction
    virtual void start_read_txn(
        const uint32_t&  read_indicator,
        const uint32_t&  raddr
    ){
        
        // First write in the 'read_indicator'
        write_data(read_indicator);

        // Then the 'raddr'
        write_data(raddr);
    }
    //==================================


    //==================================
    // Start a write transaction
    virtual void    start_write_txn(
        const uint32_t&  write_indicator  ,
        const uint32_t&  waddr            ,
        const uint32_t&  wdata
    ){
        
        // First write in the 'write_indicator'
        write_data(write_indicator);

        // Then the 'waddr'
        write_data(waddr);

        // Finally 'wdata'
        write_data(wdata);
    }
    //==================================


};

#endif//INTERFACE_COMPONENT_H