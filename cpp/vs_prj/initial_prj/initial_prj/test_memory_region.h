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


#ifndef TEST_MEMORY_REGION_H
#define TEST_MEMORY_REGION_H


class test_memory_region
{
public:
    
    // Memory location
    uint32_t*   address;

    // Constructor
    test_memory_region(){
        address = new uint32_t;
    }


};

#endif//TEST_MEMORY_REGION_H