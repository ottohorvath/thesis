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







package timer_fsm_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    
    
    
    
    type timer_fsm_out_if_t   is record
    
        show_cntr   :   std_logic;
        cntr_clr    :   std_logic;
        cntr_en     :   std_logic;
        det_clr     :   std_logic;
        det_en      :   std_logic;
        
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   timer_fsm_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   timer_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        signal      rtl_out_if      :   in      timer_fsm_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;
        
        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer   
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body timer_fsm_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   timer_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        signal      rtl_out_if      :   in      timer_fsm_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;
        
        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer   
    )is
        
        variable    errors          :           integer := 0;
        variable    noc             :           integer := 0;   -- Num of checks per Test ID
        
        constant    this            :           string  :=  "timer_fsm_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        

        wait on put_it;             -- Waiting on the 'tc' process
        
        errors := 0;                -- Initializing error indicator    
        
        print(scope &": Checking ID = "& str(id),   1);
        
        
        
        case (id)   is
            -------------------------------------------------
            -- The check is the same for all three cases
            when 0 | 2 | 3 =>  
                        if( rtl_out_if.show_cntr /= '0' ) then
                                                -- Exp      --Act
                            perror(scope&".0",  str('0'),   str(rtl_out_if.show_cntr));
                            errors := errors + 1;
                        end if;
                        

                        if( rtl_out_if.cntr_clr /= '1' ) then
                                                -- Exp      --Act
                            perror(scope&".1",  str('1'),   str(rtl_out_if.cntr_clr));
                            errors := errors + 1;
                        end if;
                        
                        if( rtl_out_if.cntr_en /= '0' ) then
                                                -- Exp      --Act
                            perror(scope&".2",  str('0'),   str(rtl_out_if.cntr_en));
                            errors := errors + 1;
                        end if;
                        
                        if( rtl_out_if.det_clr /= '1' ) then
                                                -- Exp      --Act
                            perror(scope&".3",  str('1'),   str(rtl_out_if.det_clr));
                            errors := errors + 1;
                        end if;
                        
                        if( rtl_out_if.det_en /= '0' ) then
                                                -- Exp      --Act
                            perror(scope&".4",  str('0'),   str(rtl_out_if.det_en));
                            errors := errors + 1;
                        end if;        

            -------------------------------------------------
            -- Checking the output signals related to ENABLED state
            when 1  =>  if( rtl_out_if.det_en /= '1' ) then           
                                                -- Exp      --Act     
                            perror(scope&".0",  str('1'),   str(rtl_out_if.det_en));  
                            errors := errors + 1;                   
                        end if;                  
                              
            -------------------------------------------------            
            when 4  =>  
            
                        if( rtl_out_if.det_en /= '1' ) then          
                                                -- Exp      --Act            
                            perror(scope&".0",  str('1'),   str(rtl_out_if.det_en));            
                            errors := errors + 1;            
                        end if;
                        
                        ---------------------------
                        got_it  <= not(got_it);
                        wait on put_it;
                        ---------------------------
                        
                        print(scope &": Checking ID = "& str(id),   1);
                        
                        if( rtl_out_if.det_en /= '0' ) then       
                                                -- Exp      --Act            
                            perror(scope&".1",  str('0'),   str(rtl_out_if.det_en));            
                            errors := errors + 1;            
                        end if;
            -------------------------------------------------            
            when 5  =>  
            
                        if( rtl_out_if.det_en /= '1' ) then        
                                                -- Exp      --Act            
                            perror(scope&".0",  str('1'),   str(rtl_out_if.det_en));            
                            errors := errors + 1;            
                        end if;
                        
                        ---------------------------
                        got_it  <= not(got_it);
                        wait on put_it;
                        ---------------------------
                        
                        print(scope &": Checking ID = "& str(id),   1);
                        
                        
                        if( rtl_out_if.cntr_en /= '1' ) then        
                                                -- Exp      --Act            
                            perror(scope&".1",  str('1'),   str(rtl_out_if.cntr_en));            
                            errors := errors + 1;            
                        end if;
                        
                        if( rtl_out_if.det_en /= '1' ) then       
                                                -- Exp      --Act            
                            perror(scope&".2",  str('1'),   str(rtl_out_if.det_en));            
                            errors := errors + 1;            
                        end if;
              
             -------------------------------------------------               
             when 6  =>             
                        
                        if( rtl_out_if.show_cntr /= '1' ) then                   
                                                -- Exp      --Act                       
                            perror(scope&".0",  str('1'),   str(rtl_out_if.show_cntr));                       
                            errors := errors + 1;                       
                        end if;           
                                   
                        ---------------------------
                        got_it  <= not(got_it); 
                        wait on put_it;
                        ---------------------------
                        
                        
                        
                        if( rtl_out_if.show_cntr /= '0' ) then        
                                                -- Exp      --Act                    
                            perror(scope&".1",  str('1'),   str(rtl_out_if.show_cntr));               
                            errors := errors + 1;                       
                        end if;           
                        
                        
            -------------------------------------------------               
            when 7  =>             
                       
                        if( rtl_out_if.det_en /= '0' ) then        
                                                -- Exp      --Act                    
                            perror(scope&".0",  str('0'),   str(rtl_out_if.det_en));               
                            errors := errors + 1;                       
                        end if;           
                                   
            
                        if( rtl_out_if.cntr_en /= '0' ) then        
                                                -- Exp      --Act                  
                            perror(scope&".1",  str('0'),   str(rtl_out_if.cntr_en));             
                            errors := errors + 1;                       
                        end if;           

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