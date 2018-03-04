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







package clk_gen_check
is
    ------- Typedefs for output RTL IF signals -------------------
    
    type clk_gen_out_if_t   is record
    
        rdata   :   std_logic;
        clk_out :   std_logic;
        
    end record;
    --------------------------------------------------
    
    
    
    signal      rtl_out_if  :   clk_gen_out_if_t    ;
    
    
    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   clk_gen_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        signal      rtl_out_if      :   in      clk_gen_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;
        
        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer   
    );
    --------------------------------------------------
    
    
    
    
    
end package;



package body clk_gen_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   clk_gen_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        signal      rtl_out_if      :   in      clk_gen_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;
        
        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer   
    )is
        
        variable    errors          :           integer := 0;
        variable    noc             :           integer := 0;   -- Num of checks per Test ID
        
        constant    this            :           string  :=  "clk_gen_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        

        wait on put_it;             -- Waiting on the 'tc' process
        
        errors := 0;                -- Initializing error indicator    
        
        print(scope &": Checking ID = "& str(id),   1);
        
        
        
        case (id)   is
            -------------------------------------------------
            when 0  =>  if( rtl_out_if.rdata /= '0' ) then
                                                -- Exp      --Act
                            perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));
                            errors := errors + 1;
                            
                        end if;
                        
                        if( rtl_out_if.clk_out /= '0')  then
                                                -- Exp      --Act
                            perror(scope&".1", str('0'),    str(rtl_out_if.clk_out));
                            errors := errors + 1;
                            
                        end if;

            -------------------------------------------------
            when 1 =>   if( rtl_out_if.rdata /= '0' ) then
                                                    -- Exp      --Act
                            perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));
                            errors := errors + 1;
                            
                        end if;
                        
                        wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                        
                        if( rtl_out_if.rdata /= '1' ) then
                                                -- Exp      --Act
                            perror(scope&".1",  str('1'),   str(rtl_out_if.rdata));
                            errors := errors + 1;
                            
                        end if;
                        
            -------------------------------------------------
            when 2 =>   wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
            
                        if (rtl_out_if.clk_out /= '0')  then
                            perror(scope&".0",  str('0'),   str(rtl_out_if.clk_out));
                            errors := errors + 1;
                        end if;
                        
                        wait_fe(tb_if.clk);
                        
                        
            
                        if (rtl_out_if.clk_out /= '1')  then
                            perror(scope&".1",  str('1'),   str(rtl_out_if.clk_out));
                            errors := errors + 1;
                        end if;
            -------------------------------------------------
            when 3 =>   wait_re(tb_if.clk);
                        
                        if (rtl_out_if.rdata /= '1')  then              --
                            perror(scope&".0",  str('1'),   str(rtl_out_if.rdata));  -- Rdata should be 1 (enabled)
                            errors := errors + 1;                       --
                        end if;                                         --
                        
                        wait_re(tb_if.clk);
                                                                        --
                                                                        --
                        if (rtl_out_if.rdata /= '0')  then               -- Rdata should be 0 (cleared)
                            perror(scope&".1",  str('0'),   str(rtl_out_if.rdata));  --
                            errors := errors + 1;                       --
                        end if;                                         --
            -------------------------------------------------
            when 4 =>   wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                        
                        
                        if (rtl_out_if.clk_out /= '0')  then            --
                            perror(scope&".0",  str('0'),   str(rtl_out_if.clk_out));  -- Clock out should be
                            errors := errors + 1;                       --
                        end if;                                         --
                        
                                                                        
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