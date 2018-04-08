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







package cntr_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    
    constant    cntr_width_test        :   integer := 32;
    
    alias w is cntr_width_test;         -- Using other refrence name to ease source code readability
    
    
    type cntr_out_if_t   is record
    
        noc:   std_logic_vector(w-1 downto 0);
        
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   cntr_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   cntr_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      cntr_out_if_t;
        signal      tb_if           :   in      tb_if_t       
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body cntr_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   cntr_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;
        
        signal      rtl_out_if      :   in      cntr_out_if_t;
        signal      tb_if           :   in      tb_if_t      
    )is
        
        
        constant    this            :           string  :=  "cntr_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        

        
        wait_for_next_check(sv);
        
        
--        case (sv.get_tc_id)   is
--            -------------------------------------------------
--            when 0  =>  if( rtl_out_if.noc /= slv(w,'0') ) then
--                                                -- Exp      --Act
--                            perror(scope&".0",  str(slv(w,'0')),   str(rtl_out_if.noc));
--                            errors := errors + 1;
--                        end if;
--            -------------------------------------------------
--            -- Fast checking the counter if it is counting properly
--            when 1  =>  exp_val := 1;
--                        
--                        
--                        while(exp_val <3) loop
--                            if(to_integer(unsigned(rtl_out_if.noc)) /= exp_val)   then
--                                                    -- Exp      --Act
--                                perror(scope&".0",  str(exp_val),   str(rtl_out_if.noc));
--                                errors := errors + 1;
--                                
--                                exit;
--                            end if;
--                            
--                            exp_val := exp_val + 1;
--                            
--                            wait on rtl_out_if.noc; -- Wait on change
--                            
--                        end loop;
--                        
--                        ----------------------------------
--                        got_it  <= not(got_it);
--                        wait on put_it;
--                        ----------------------------------
--                        
--                        -- Waiting on the change
--                        
--                        
--                        
--                        if(rtl_out_if.noc /= slv(w,'0'))   then
--                                                -- Exp      --Act
--                            perror(scope&".1",  str(slv(w,'0')),   str(rtl_out_if.noc));
--                            errors := errors + 1;
--                            
--                            
--                        end if;
--                        
--                        
--                        
--                        
--            -------------------------------------------------
--            
--            
--            
--            
--            
--            
--            
--            
--            
--            -------------------------------------------------
--            when others =>
--        end case;
      
        
    end procedure;
    --------------------------------------------------

end package body;