#include"stdafx.h"
//=================
#include<iostream>
#include<string>
#include<stdint.h>

#include"component_library.h"






int main()
{

    mode_selector   ms("Mode Selector",0x34,0x05);
    ms.info();
    std::cout   <<ms.get_name() <<std::endl;
    return 0;
}




