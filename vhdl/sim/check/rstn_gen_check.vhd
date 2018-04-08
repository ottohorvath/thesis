----------------------------------------------------------------------------------------
-- Author: Otto Horvath           
----------------------------------------------------------------------------------------
-- Description: ~ 
--                
--
----------------------------------------------------------------------------------------
library ieee				;
library std                 ;
-----------------------------
use std.env.all             ;
use std.textio.all          ;
use ieee.numeric_std.all	;
use ieee.std_logic_1164.all	;
-----------------------------


------ Packages from "../tbench_pkg/" ----
use work.tb_log_pkg.all     ;
use work.tb_utils_pkg.all   ;
use work.tb_report_pkg.all  ;


use work.tb_chk_pkg.all     ;   -- Includes for the 'chk' process.
----------------------------------------







package rstn_gen_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    type rstn_gen_out_if_t   is record
    
        rdata       :   std_logic;
        rstn_to_DUV :   std_logic;
        trig_out    :   std_logic;
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   rstn_gen_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   rstn_gen_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      rstn_gen_out_if_t;
        signal      tb_if           :   in      tb_if_t           
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body rstn_gen_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   rstn_gen_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      rstn_gen_out_if_t;
        signal      tb_if           :   in      tb_if_t          
    )is

        constant    this            :           string  :=  "rstn_gen_check";
        constant    scope           :           string  :=  super_name &"."& this;
        ---------------------------------------------------

    begin

        
        wait_for_next_check(sv);
        
--       case (sv.get_tc_id)   is
--           -------------------------------------------------
--           when 0  =>  
--                       wait for 1 ps;
--                           -- EXP   -- ACT
--                       check('0',  rtl_out_if.rdata        ,   0);
--                       check('1',  rtl_out_if.rstn_to_DUV  ,   1);
--           -------------------------------------------------
--           when 1  =>  wait_re(tb_if.clk);
--                       wait for 1 ps;
--                       
--                           -- EXP   -- ACT
--                       check('0',  rtl_out_if.rstn_to_DUV,   0);
--                       
--                       
--                       wait_re(tb_if.clk);
--                       wait for 1 ps;
--                       
--                           -- EXP   -- ACT
--                       check('1',  rtl_out_if.trig_out,   1);
--                       
--                       wait_re(tb_if.clk);
--                       wait for 1 ps;
--                       
--                           -- EXP   -- ACT
--                       check('1',  rtl_out_if.rdata,   2);
--
--
--           -------------------------------------------------            
--           when 2  =>  --wait_re(tb_if.clk);
--                       --wait for 1 ps;
--                       
--                           -- EXP   -- ACT
--                       check('1',  rtl_out_if.rdata,   0);
--                       
--                       wait_re(tb_if.clk);
--                       wait for 1 ps;
--                       
--                           -- EXP   -- ACT
--                       check('0',  rtl_out_if.rdata,   1);
--                       
--           -------------------------------------------------     
--           when others =>
--       end case;
      

    end procedure;
    --------------------------------------------------
end package body;