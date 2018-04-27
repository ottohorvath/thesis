#include"stdafx.h"
//=================
#include<iostream>
#include<string>
#include<stdint.h>


#define DEBUG
#define DEBUG_RDATA 0x01

//Include the component library
#include"component_library.h"



int main()
{

    delta_timer e("re_evnt_cntr",0x1,0x2);

    e.clear();
    e.enable();
    return 0;
}




