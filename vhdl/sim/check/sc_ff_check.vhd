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







package sc_ff_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    type sc_ff_out_if_t   is record
        q       :   std_logic;
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   sc_ff_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   sc_ff_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      sc_ff_out_if_t;
        signal      tb_if           :   in      tb_if_t       
        
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body sc_ff_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   sc_ff_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      sc_ff_out_if_t;
        signal      tb_if           :   in      tb_if_t       
    )is
        
        constant    this            :           string  :=  "sc_ff_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        wait_for_next_check(sv);
        
        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>  
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.q);
                        
                        check_done(sv);
            -------------------------------------------------
            when 1  =>  
                            -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.q);
                        
                        check_done(sv);
            -------------------------------------------------
            when 2  =>      -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.q);
                        
                        check_done(sv);
            -------------------------------------------------
            when 3  =>      -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.q);
                        
                        check_done(sv);
            -------------------------------------------------
            when others =>
        end case;
      
    end procedure;
    --------------------------------------------------
    
end package body;