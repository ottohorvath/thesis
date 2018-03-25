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
use work.tb_log_pkg.all                 ;
use work.tb_report_pkg.all              ;
----------------------------------------
   
package tb_sync_pkg is   
    
    
    
    
    
    type    shared_sync is  protected 
        -------------------------------
        impure function can_i_check_it  return  integer;
        -------------------------------
        impure function can_i_drive_it  return  integer;
        -------------------------------
        procedure       checking_it;
        -------------------------------
        procedure       driving_it;
        -------------------------------
        procedure       checking_done;
        -------------------------------
        procedure       driving_done;
        -------------------------------
        procedure       start_checking;
        -------------------------------
        procedure       set_clk_event(
            constant    arg:    integer
        );
        -------------------------------
        procedure       wait_on_clk;
    end protected;
    
    
    

    
    
    
end package;



package body tb_sync_pkg is   
    
    
    type    shared_sync is  protected body
        
        -- Checker is doing its work
        variable    checking_res    :   integer:=   0;
        -- Tester is driving stimuli
        variable    driving_stim    :   integer:=   0;
        
        --
        variable    fe_on_reset     :   integer:=   0;
        
        -- Rising edge event on clock
        variable    clk_event       :   integer:=   0;
       
        -------------------------------
        impure  function can_i_check_it
            return  integer
        is
            variable    tmp:    integer:=   0;
        begin
            if(driving_stim = 1)   then
                tmp:=   0;
            else
                tmp:=   1;
            end if;
            
            return tmp;
        end function;
        -------------------------------
        impure function can_i_drive_it
            return  integer
        is
            variable    tmp:    integer:=   0;
        begin
            if(checking_res = 1)   then            
                tmp:=   0;            
            else            
                tmp:=   1;            
            end if;            
                    
            return tmp;        
        end function;
        -------------------------------
        procedure   checking_it    is
        begin
            checking_res:=  1;
        end procedure;
        -------------------------------
        procedure   driving_it    is
        begin
            driving_stim:=  1;
        end procedure;
        -------------------------------
        procedure   checking_done    is
        begin
            checking_res:=  0;
        end procedure;
        -------------------------------
        procedure   driving_done    is
        begin
            driving_stim:=  0;
        end procedure;
        -------------------------------
        procedure   start_checking  is
        begin
            
            loop
                if(driving_stim =   0)then
                    exit;
                end if;
            end loop;
            
        end procedure;
        -------------------------------
        procedure   set_clk_event   (
            constant    arg:    integer
        )
        is
        begin
            clk_event:= arg;
        end procedure;
        -------------------------------
        procedure   wait_on_clk is
        begin
            
            loop
                if(clk_event = 1)   then
                    exit;
                end if;
            end loop;
        end procedure;
    end protected body;
    
    

    
    
end package body;