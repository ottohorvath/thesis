//-------------------------------------------------------------------------
//
// Author: Otto Horvath
//
//-------------------------------------------------------------------------
//
// Description:
//
//  ~ Includes macros
//
//  ~ Container header file: stores all the class
//
//
//-------------------------------------------------------------------------


#ifndef COMPONENT_LIBRARY_H
#define COMPONENT_LIBRARY_H

    //==========================
    #include"component_macros.h"
    //==========================
    #include"component_base.h"
    #include"simple_component.h"
    #include"interface_component.h"
    #include"edge_detector.h"
    #include"evnt_cntr.h"
    //==========================
    #include"mode_selector.h"
    #include"clk_gen.h"
    #include"rstn_gen.h"
    #include"mem_if.h"
    #include"config_reg_if.h"
    #include"fifo_rd_if.h"
    #include"fifo_wr_if.h"
    #include"fifo_src.h"
    #include"fifo_snk.h"
    #include"re_det.h"
    #include"fe_det.h"
    #include"chg_det.h"
    #include"re_evnt_cntr.h"
    #include"fe_evnt_cntr.h"
    #include"delta_timer.h"


#endif//COMPONENT_LIBRARY_H