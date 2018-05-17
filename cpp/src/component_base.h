//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description:
//
//  ~ Virtual base class for the component classes
//
//
//-------------------------------------------------------------------------

#ifndef COMPONENT_BASE_H
#define COMPONENT_BASE_H

class   component_base
{
public:
    //==================================
    // Component name
    std::string     name;
    // Base memory address
    uint32_t*       base_addr;
    // Component enabled flag
    uint32_t        enabled;
    //==================================

    //==================================
    GETTER( std::string,     name)
    GETTER( uint32_t*,       base_addr)
    GETTER( uint32_t,        enabled)
    SETTER( uint32_t,        enabled)
    //==================================


    // Basic status printer
    INFO(name, base_addr, enabled)

public:
    //==================================
    // Constructor
    component_base(
        std::string     _name           ,
        uint32_t*        _base_addr
    ):
        name            (_name      )   ,
        base_addr       (_base_addr )   ,
        enabled         (0x00000000 )
    {}
    //==================================


#ifdef DEBUG
    //==================================
    virtual void write_data(
        const uint32_t&  write_data
    ){

        std::cout   <<"["<< get_name()  <<"] Write data = 0x"<< std::hex<<write_data<<std::endl;
    }
    //==================================


    //==================================
    virtual uint32_t read_data(){
        uint32_t    read_data;

        read_data = DEBUG_RDATA;

        std::cout   <<"["<< get_name()  <<"] Read data = 0x"<<std::hex <<read_data<<std::endl;
        return read_data;
    }
    //==================================

#else
    //==================================
    // Get the value of 'rdata' output port
    virtual uint32_t read_data(){
        uint32_t read_data;

        // Read out
        read_data = *base_addr;
        #ifdef  VERBOSE
            std::cout<<"["<< get_name()<<"] Read data = 0x"
            <<std::hex <<read_data<<std::endl;
        #endif
        return read_data;
    }
    //==================================


    //==================================
    // Simple write to component
    virtual void write_data(
        const uint32_t&  write_data
    ){
        #ifdef VERBOSE
            std::cout<<"["<< get_name()<<"] Write data = 0x"
            << std::hex<<write_data<<std::endl;
        #endif
        // Write in
        *base_addr   =   write_data;
    }

#endif
};

#endif//COMPONENT_BASE_H