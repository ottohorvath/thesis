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







package re_det_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    type re_det_out_if_t   is record
    
        rdata       :   std_logic;
        
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   re_det_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   re_det_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      re_det_out_if_t;
        signal      tb_if           :   in      tb_if_t            
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body re_det_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   re_det_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      re_det_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         
    )is
        
        constant    this            :           string  :=  "re_det_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        
        wait_for_next_check(sv);
        
--        case (sv.get_tc_id)   is
--            -------------------------------------------------
--            when 0  =>  if(rtl_out_if.rdata /= '0') then
--                                                 -- Exp      --Act
--                            perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));
--                            errors := errors + 1;
--                            
--                        end if;
--            -------------------------------------------------
--            when 1  =>  wait_re(tb_if.clk);
--            
--                        if(rtl_out_if.rdata /= '0') then            
--                                                 -- Exp      --Act            
--                            perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));            
--                            errors := errors + 1;            
--                                        
--                        end if;            
--            -------------------------------------------------
--            when 2  =>  if(rtl_out_if.rdata /= '1') then            
--                                                 -- Exp      --Act            
--                            perror(scope&".0",  str('1'),   str(rtl_out_if.rdata));            
--                            errors := errors + 1;            
--                                        
--                        end if;               
--            -------------------------------------------------
--            when 3  =>  wait_re(tb_if.clk);
--                        
--            
--                        if(rtl_out_if.rdata /= '1') then            
--                                                 -- Exp      --Act            
--                            perror(scope&".0",  str('1'),   str(rtl_out_if.rdata));            
--                            errors := errors + 1;            
--                                        
--                        end if;  
--                        
--                        
--                        
--                        
--            when others =>
--        end case;
--      
   end procedure;
    --------------------------------------------------

end package body;