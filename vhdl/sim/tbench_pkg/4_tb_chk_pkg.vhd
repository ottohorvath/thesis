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
----------------------------------------


package tb_chk_pkg
is
    
    
    --------------- Generic run procedure ------------
    procedure   chk
        generic(
            type        rtl_out_if_t;                                       -- The corresponding DUT RTL IF type
            constant    new_run_name        :       string;                 -- The name of the instance 'run' procedure

            constant    called_chk_name     :       string;                 -- The name of the 'called_process' in string
            
            procedure   called_chk
            (                                                               -- Procedure responsible for running one check which is indexed by 'id'
                constant    rtl_name        :   in  string;
                constant    super_name      :   in  string;

                signal      rtl_out_if      :   in  rtl_out_if_t;       -- Watching DUT's output ports
                signal      tb_if           :   in  tb_if_t     ;
                
                signal      put_it          :   in  std_logic   ;   
                signal      got_it          :   out std_logic   ;
                signal      passed          :   out std_logic   ;
                signal      id              :   in  integer   
            )
        )
    (       
        constant    rtl_name    :   in      string;
        constant    super_name  :   in      string;
        
        signal      rtl_out_if  :   in      rtl_out_if_t;
        signal      tb_if       :   in      tb_if_t     ;
        
        signal      put_it      :   in      std_logic   ;
        signal      got_it      :   out     std_logic   ;
        signal      passed      :   out     std_logic   ;
        signal      id          :   in      integer   
    );
    --------------------------------------------------
    
    

    
    
    
    
    
    
    

end package;


package body tb_chk_pkg
is
    ------------------------------------------------------------------------------
    procedure   chk
        generic(
            type        rtl_out_if_t;                                  
            constant    new_run_name        :       string;            
    
            constant    called_chk_name     :       string;           
            
            procedure   called_chk
            (                                                          
                constant    rtl_name        :   in  string;
                constant    super_name      :   in  string;
    
                signal      rtl_out_if      :   in  rtl_out_if_t;
                signal      tb_if           :   in  tb_if_t     ; 
                
                signal      put_it          :   in  std_logic   ;
                signal      got_it          :   out std_logic   ;
                signal      passed          :   out std_logic   ;
                signal      id              :   in  integer   
                
            )
        )
    (       
        constant    rtl_name    :   in      string;
        constant    super_name  :   in      string;
        
        signal      rtl_out_if  :   in      rtl_out_if_t;
        signal      tb_if       :   in      tb_if_t     ;
        
        signal      put_it      :   in      std_logic   ;
        signal      got_it      :   out     std_logic   ;
        signal      passed      :   out     std_logic   ;
        signal      id          :   in      integer   
        
    )is
        constant    this        :           string  :=  new_run_name;
        constant    scope       :           string  :=  super_name &"."& new_run_name;
    begin
        
        -- Run 'called_chk' generic procedure: the actual resolved procedure name will be like this: <RTL>_check
        called_chk(rtl_name,scope,          rtl_out_if  ,
                                            tb_if       , 
                                            put_it      ,
                                            got_it      ,
                                            passed      ,
                                            id          );
        
    end procedure;
    ------------------------------------------------------------------------------
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

end package body;