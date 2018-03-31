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
    //==================================
    // Component name
    std::string     name;
    // Base memory address
    uint32_t        base_addr;
    // Relative memory address
    uint32_t        relative_addr;
    // Component enabled flag
    uint32_t        enabled;
    //==================================

    //==================================
    GETTER( std::string,     name)
    GETTER( uint32_t,        base_addr)
    GETTER( uint32_t,        relative_addr)
    GETTER( uint32_t,        enabled)
    //==================================


    // Basic status printer
    INFO(name, base_addr,   relative_addr, enabled)

public:
    //==================================
    // Constructor
    component_base(
        std::string     _name           ,     
        uint32_t        _base_addr      ,
        uint32_t        _relative_addr
    ):
        name            (_name      ), 
        base_addr       (_base_addr ),
        relative_addr   (_relative_addr)
    {}
    //==================================
};


#endif//COMPONENT_BASE_H