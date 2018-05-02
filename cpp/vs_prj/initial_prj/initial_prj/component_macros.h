//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description:
//
//  ~ Contains some basic macros for the classes
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



#define INFO(var1,var2,var3)                                                        \
public:     virtual void    info(){                                                 \
                std::cout   <<"Component Name = "   <<var1  <<std::endl             \
                            <<"Base addr = 0x" <<std::hex  <<var2  <<std::endl      \
                            <<"Enabled   = 0x" <<std::hex  <<var3  <<std::endl;     \
                }
#define BASIC_CONSTRUCTOR(derived_class_name, super_class_name) \
    derived_class_name(                                         \
        std::string _name           ,                           \
        uint32_t    _base_addr                                  \
    ):                                                          \
        super_class_name(                                       \
            _name           ,                                   \
            _base_addr                                          \
        )                                                       \
    {}




#define MAP_FPGA_TO_USERSPACE(fpga_void_ptr,devmem,base,span)                               \
devmem          =   open("/dev/mem", O_RDWR|O_SYNC);                                        \
fpga_void_ptr   =   mmap(NULL,  span, (PROT_READ|PROT_WRITE), MAP_SHARED, devmem, base);    \
if (fpga_void_ptr== MAP_FAILED)                                                             \
{                                                                                           \
    std::cout<<"Error during mapping '##base' to userspace ..."<<std::endl;                 \
    return 1;                                                                               \
}


#define UNMAP_FPGA(fpga_void_ptr,devmem,span)           \
if(munmap(fpga_void_ptr, span)!=0)                      \
{                                                       \
    std::cout<<"Error during unmapping ..."<<std::endl; \
    close(devmem);                                      \
    return  1;                                          \
}                                                       \
close(devmem);

