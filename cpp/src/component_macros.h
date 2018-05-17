//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description:
//
//  ~ Contains some basic macros for the classes and the cpp environment
//
//
//-------------------------------------------------------------------------

#define FIELD_WITH_ACCESSORS(type, var)                             \
private:    type var;                                               \
public:     virtual type    get_##var()          {return var;}      \
public:     virtual void    set_##var(type var) {this->var = var;}


#define GETTER(type, var)   \
public:     virtual type    get_##var()          {return var;}


#define SETTER(type, var)   \
public:     virtual void    set_##var(type var) {this->var = var;}



#define INFO(var1,var2,var3)                                                                \
public:     virtual void    info(){                                                         \
                std::cout   <<"[INFO] Component name = "   <<var1  <<std::endl              \
                            <<"[INFO] Base addr      = " <<std::hex  <<var2  <<std::endl    \
                            <<"[INFO] Enabled        = " <<std::hex  <<var3  <<std::endl;   \
                }


#define BASIC_CONSTRUCTOR(derived_class_name, super_class_name) \
    derived_class_name(                                         \
        std::string     _name,                                  \
        uint32_t*       _base_addr                              \
    ):                                                          \
        super_class_name(                                       \
            _name,                                              \
            _base_addr                                          \
        )                                                       \
    {}


#define CHECK_FPGA_BRIDGES(bridges_enabled) \
std::cout<<"[FPGA Configuration] Checking the status of the bridges between HPS and FPGA ..."<<std::endl; \
std::fstream    F2H     ;               \
std::fstream    H2F     ;               \
std::fstream    LW_H2F  ;               \
                                        \
F2H.open("/sys/class/fpga-bridge/fpga2hps/enable"       ,std::fstream::in | std::fstream::out | std::fstream::binary); \
H2F.open("/sys/class/fpga-bridge/hps2fpga/enable"       ,std::fstream::in | std::fstream::out | std::fstream::binary); \
LW_H2F.open("/sys/class/fpga-bridge/lwhps2fpga/enable"  ,std::fstream::in | std::fstream::out | std::fstream::binary); \
                                        \
std::string     status_F2H   ;          \
std::string     status_H2F   ;          \
std::string     status_LW_H2F;          \
                                        \
std::getline(F2H   ,status_F2H   );     \
std::getline(H2F   ,status_H2F   );     \
std::getline(LW_H2F,status_LW_H2F);     \
                                        \
if(status_F2H == "1"){                  \
    bridges_enabled = 0x1;              \
}                                       \
                                        \
if(status_H2F == "1"){                  \
    bridges_enabled = 0x1;              \
}                                       \
                                        \
if(status_LW_H2F == "1"){               \
    bridges_enabled = 0x1;              \
}                                       \
                                        \
F2H.close();                            \
H2F.close();                            \
LW_H2F.close();



#define DISABLE_FPGA_BRIDGES \
std::cout<<"[FPGA Configuration] Disabling the bridges!"<<std::endl;    \
                                                                        \
F2H.open("/sys/class/fpga-bridge/fpga2hps/enable"       ,std::fstream::in | std::fstream::out | std::fstream::binary); \
H2F.open("/sys/class/fpga-bridge/hps2fpga/enable"       ,std::fstream::in | std::fstream::out | std::fstream::binary); \
LW_H2F.open("/sys/class/fpga-bridge/lwhps2fpga/enable"  ,std::fstream::in | std::fstream::out | std::fstream::binary); \
                                        \
F2H     <<  0x0;                        \
H2F     <<  0x0;                        \
LW_H2F  <<  0x0;                        \
                                        \
F2H.close();                            \
H2F.close();                            \
LW_H2F.close();






#define ENABLE_FPGA_BRIDGES \
std::cout<<"[FPGA Configuration] Enabling the bridges!"<<std::endl;     \
                                                                        \
F2H.open("/sys/class/fpga-bridge/fpga2hps/enable"       ,std::fstream::in | std::fstream::out | std::fstream::binary); \
H2F.open("/sys/class/fpga-bridge/hps2fpga/enable"       ,std::fstream::in | std::fstream::out | std::fstream::binary); \
LW_H2F.open("/sys/class/fpga-bridge/lwhps2fpga/enable"  ,std::fstream::in | std::fstream::out | std::fstream::binary); \
                                        \
F2H     <<  0x1;                        \
H2F     <<  0x1;                        \
LW_H2F  <<  0x1;                        \
                                        \
F2H.close();                            \
H2F.close();                            \
LW_H2F.close();



#define CONFIGURE_FPGA(fpga_cfg) \
std::fstream    FPGA_DEV;                                                                                               \
std::fstream    FPGA_STATUS;                                                                                            \
std::fstream    FPGA_CFG;                                                                                               \
FPGA_DEV.open("/dev/fpga0"                      , std::fstream::out | std::fstream::binary | std::fstream::trunc);      \
FPGA_CFG.open(fpga_cfg                          , std::fstream::in  | std::fstream::binary);                            \
FPGA_STATUS.open("/sys/class/fpga/fpga0/status" , std::fstream::in  );                                                  \
                                                                                                                        \
std::cout<<"[FPGA Configuration] Configuring FPGA with '"<<fpga_cfg<<"'!"<<std::endl;                                   \
                                                                                                                        \
std::string     CUR_FPGA_STATUS;                                                                                        \
std::getline(   FPGA_STATUS,    CUR_FPGA_STATUS   );                                                                    \
                                                                                                                        \
if(CUR_FPGA_STATUS == "configuration phase")                                                                            \
{                                                                                                                       \
    char*           cfg_block[5];                                                                                       \
    size_t          block_size  =   1024*1024;                                                                          \
                                                                                                                        \
    cfg_block[0]    =   new char [block_size];                                                                          \
    cfg_block[1]    =   new char [block_size];                                                                          \
    cfg_block[2]    =   new char [block_size];                                                                          \
    cfg_block[3]    =   new char [block_size];                                                                          \
    cfg_block[4]    =   new char [block_size];                                                                          \
                                                                                                                        \
    FPGA_CFG.read(cfg_block[0], block_size);                                                                            \
    FPGA_CFG.read(cfg_block[1], block_size);                                                                            \
    FPGA_CFG.read(cfg_block[2], block_size);                                                                            \
    FPGA_CFG.read(cfg_block[3], block_size);                                                                            \
    FPGA_CFG.read(cfg_block[4], block_size);                                                                            \
                                                                                                                        \
    FPGA_CFG.close();                                                                                                   \
                                                                                                                        \
    FPGA_DEV.write(cfg_block[0], block_size);                                                                           \
    FPGA_DEV.write(cfg_block[1], block_size);                                                                           \
    FPGA_DEV.write(cfg_block[2], block_size);                                                                           \
    FPGA_DEV.write(cfg_block[3], block_size);                                                                           \
    FPGA_DEV.write(cfg_block[4], block_size);                                                                           \
                                                                                                                        \
    FPGA_DEV.close();                                                                                                   \
    FPGA_STATUS.close();                                                                                                \
                                                                                                                        \
    delete[]    cfg_block[0];                                                                                           \
    delete[]    cfg_block[1];                                                                                           \
    delete[]    cfg_block[2];                                                                                           \
    delete[]    cfg_block[3];                                                                                           \
    delete[]    cfg_block[4];                                                                                           \
                                                                                                                        \
                                                                                                                        \
    while(CUR_FPGA_STATUS != "user mode"){                                                                              \
        FPGA_STATUS.open("/sys/class/fpga/fpga0/status" , std::fstream::in  );                                          \
        std::getline(   FPGA_STATUS,    CUR_FPGA_STATUS   );                                                            \
        FPGA_STATUS.close();                                                                                            \
    }                                                                                                                   \
    std::cout<<"[FPGA Configuration] FPGA is now in '"<<CUR_FPGA_STATUS<<"'. Configuration DONE!"<<std::endl;           \
                                                                                                                        \
    FPGA_STATUS.close();                                                                                                \
}else                                                                                                                   \
{                                                                                                                       \
    std::cout<<"[FPGA Configuration] FPGA is in '"<<CUR_FPGA_STATUS<<"'. Configuration FAILED!"<<std::endl;             \
    FPGA_DEV.close();                                                                                                   \
    FPGA_STATUS.close();                                                                                                \
    FPGA_CFG.close();                                                                                                   \
    return 1;                                                                                                           \
}





#define MAP_FPGA_TO_USERSPACE(fpga_void_ptr,devmem,base,span)                               \
std::cout<<"[FPGA Map] Mapping FPGA to userspace!"<<std::endl;                              \
devmem          =   open("/dev/mem", O_RDWR|O_SYNC);                                        \
fpga_void_ptr   =   mmap(NULL,  span, (PROT_READ|PROT_WRITE), MAP_SHARED, devmem, base);    \
if (fpga_void_ptr== MAP_FAILED)                                                             \
{                                                                                           \
    std::cout<<"Error during mapping '##base' to userspace ..."<<std::endl;                 \
    return 1;                                                                               \
}


#define UNMAP_FPGA(fpga_void_ptr,devmem,span)           \
std::cout<<"[FPGA Unmap] Removing FPGA from userspace!"<<std::endl;     \
if(munmap(fpga_void_ptr, span)!=0)                      \
{                                                       \
    std::cout<<"Error during unmapping ..."<<std::endl; \
    close(devmem);                                      \
    return  1;                                          \
}                                                       \
close(devmem);

