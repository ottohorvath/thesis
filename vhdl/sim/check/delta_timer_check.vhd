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







package delta_timer_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    constant    cntr_width_test        :   integer := 32;
    
    alias w is cntr_width_test;         -- Using other refrence name to ease source code readability
    
    type delta_timer_out_if_t   is record
    
        rdata   :   std_logic_vector(w-1 downto 0);
        
        
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   delta_timer_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   delta_timer_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      delta_timer_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body delta_timer_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   delta_timer_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      delta_timer_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         
    )is
        
        constant    this            :           string  :=  "delta_timer_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
    wait_for_next_check(sv);
        
--        case (sv.get_tc_id)   is
--            -------------------------------------------------
--            when 0 | 2  =>  if( rtl_out_if.rdata /= slv(w,'0') ) then
--                                                -- Exp      --Act
--                            perror(scope&".0",  str(slv(w,'0')),   str(rtl_out_if.rdata));
--                            errors := errors + 1;
--                            
--                        end if;
--            -------------------------------------------------
--            when 1  =>  if( rtl_out_if.rdata /= X"00000001" ) then
--                                                -- Exp      --Act
--                            perror(scope&".0",  str(X"00000001"),   str(rtl_out_if.rdata));
--                            errors := errors + 1;
--                            
--                        end if;
--            -------------------------------------------------
--                        
--                        
--            
--                        
--            when others =>
--        end case;
      
    end procedure;
    --------------------------------------------------
    

end package body;