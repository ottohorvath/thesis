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
        
        signal      rtl_out_if      :   in      cntr_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;
        
        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer   
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
        
        signal      rtl_out_if      :   in      cntr_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;
        
        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer   
    )is
        
        variable    errors          :           integer := 0;
        variable    exp_val         :           integer := 0;   -- Num of checks per Test ID
        
        constant    this            :           string  :=  "cntr_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        

        

        wait on put_it;             -- Waiting on the 'tc' process
        
        errors := 0;                -- Initializing error indicator    
        
        print(scope &": Checking ID = "& str(id),   1);
        
        
        
        case (id)   is
            -------------------------------------------------
            when 0  =>  if( rtl_out_if.noc /= slv(w,'0') ) then
                                                -- Exp      --Act
                            perror(scope&".0",  str(slv(w,'0')),   str(rtl_out_if.noc));
                            errors := errors + 1;
                        end if;
            -------------------------------------------------
            -- Fast checking the counter if it is counting properly
            when 1  =>  exp_val := 1;
                        
                        
                        while(exp_val <3) loop
                            if(to_integer(unsigned(rtl_out_if.noc)) /= exp_val)   then
                                                    -- Exp      --Act
                                perror(scope&".0",  str(exp_val),   str(rtl_out_if.noc));
                                errors := errors + 1;
                                
                                exit;
                            end if;
                            
                            exp_val := exp_val + 1;
                            
                            wait on rtl_out_if.noc; -- Wait on change
                            
                        end loop;
                        
                        ----------------------------------
                        got_it  <= not(got_it);
                        wait on put_it;
                        ----------------------------------
                        
                        -- Waiting on the change
                        
                        
                        
                        if(rtl_out_if.noc /= slv(w,'0'))   then
                                                -- Exp      --Act
                            perror(scope&".1",  str(slv(w,'0')),   str(rtl_out_if.noc));
                            errors := errors + 1;
                            
                            
                        end if;
                        
                        
                        
                        
            -------------------------------------------------
            
            
            
            
            
            
            
            
            
            -------------------------------------------------
            when others =>
        end case;
      
        
        
        -------------------------------------
        if( errors /= 0) then
            passed <= '0';  
            wait for 0 ns;
            test_result(id, "failed");
        else
            passed <= '1';
            wait for 0 ns;
            test_result(id, "passed");
        end if;
        -------------------------------------
        
        
       
        
        got_it  <= not(got_it);      -- Signalling back to the 'tc' process
    end procedure;
    --------------------------------------------------
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



end package body;