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



#define INFO(var1,var2,var3,var4)                                                   \
public:     virtual void    info(){                                                 \
                std::cout   <<"Component Name = "   <<var1  <<std::endl             \
                            <<"Base addr = 0x" <<std::hex  <<var2  <<std::endl      \
                            <<"Rel. addr = 0x" <<std::hex  <<var3  <<std::endl      \
                            <<"Enabled   = 0x" <<std::hex  <<var4  <<std::endl;     \
                }
#define BASIC_CONSTRUCTOR(derived_class_name, super_class_name) \
    derived_class_name(                                         \
        std::string _name           ,                           \
        uint32_t    _base_addr      ,                           \
        uint32_t    _relative_addr                              \
    ):                                                          \
        super_class_name(                                       \
            _name           ,                                   \
            _base_addr      ,                                   \
            _relative_addr                                      \
        )                                                       \
    {}