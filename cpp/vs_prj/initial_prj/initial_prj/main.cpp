#include"stdafx.h"
//=================
#include<iostream>
#include<string>
#include<stdint.h>


#define DEBUG
#define DEBUG_RDATA 0x04

//Include the component library
#include"component_library.h"



int main()
{

    fifo_wr_if fwi("FIFO write IF",0x1,0x2);


    //fwi.enable();
    fwi.show_data();
    std::cout   <<"Read data out:   0x" <<std::hex  <<fwi.read_out()    <<std::endl;


    std::cout   <<"IDLE:        "       <<fwi.is_idle()     <<std::endl;
    std::cout   <<"ENABLED:     "       <<fwi.is_enabled()  <<std::endl;
    std::cout   <<"RCVD_DATA:   "       <<fwi.is_rcvd_data()<<std::endl;




    return 0;
}




