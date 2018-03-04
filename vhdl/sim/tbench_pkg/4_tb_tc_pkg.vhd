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



package tb_tc_pkg
is

    
    
    
    --------------------------------------------------
    procedure   setup(
        constant    rtl_name        :   in      string;     --
        constant    super_name      :   in      string;     --
                                                            -- Setup phase executing procedure: 
        variable    clk_en_in_v     :   in      std_logic;  --  - welcome message + clock gen. + reset gen.
        signal      clk_en_out      :   out     std_logic  -- 
        
    ); 
    --------------------------------------------------
    
    procedure   report_and_exit(
        constant    rtl_name        :   in      string;     --
        constant    super_name      :   in      string;     -- Report generator and simaulation stopper procedure:
                                                            -- gen. HTML report + exit message + stop. 
        constant    rgr_is_needed   :   in      integer;    --
        signal      chk_descriptor  :   in      check_descriptor_array (0 to check_no_max_c-1)
    );
    
    --------------------------------------------------
    
    
    
    
    
    --------------- Generic run procedure ------------
    procedure   tc
        generic(
            type        rtl_in_if_t;                                    -- The corresponding DUT RTL IF type
            constant    new_run_name        :       string;             -- The name of the instance 'run' procedure

            constant    called_tc_name      :       string;             -- The name of the 'called_process' in string
            
            procedure   called_tc
            (                                                           -- Procedure responsible for running one testcase which is indexed by 'id'
                constant    rtl_name        :   in  string;
                constant    super_name      :   in  string;

                signal      rtl_in_if       :   out rtl_in_if_t ;
                signal      clk             :   in  std_logic     ;
                signal      rst_req         :   out std_logic     ;
                
                signal      cd              :   out check_descriptor_array (0 to check_no_max_c-1);                
                
                signal      put_it          :   out std_logic   ;
                signal      got_it          :   in  std_logic   ;
                signal      passed          :   in  std_logic   ;                
                signal      id              :   out integer        
            )
        )
    (       
        constant    rtl_name    :   in      string;
        constant    super_name  :   in      string;
        
        signal      rtl_in_if   :   out     rtl_in_if_t ;
        signal      clk             :   in  std_logic     ;
        signal      rst_req         :   out std_logic     ;
        
        signal      cd          :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        signal      put_it      :   out     std_logic   ;
        signal      got_it      :   in      std_logic   ;
        signal      passed      :   in      std_logic   ;
        signal      id          :   out     integer    
    );
    --------------------------------------------------
    
    
    ------------------------------------------
    procedure   processor_wr(                        -- Processor write with std_logic data
        constant    din     :   in  std_logic;
        signal      clk     :   in  std_logic;
        signal      wdata   :   out std_logic;
        signal      wr      :   out std_logic
    );
    ------------------------------------------
    
    procedure   processor_wr(                       -- Processor write with slv data
        constant    din     :   in  std_logic_vector;
        signal      clk     :   in  std_logic;
        signal      wdata   :   out std_logic_vector;
        signal      wr      :   out std_logic
    );
    ------------------------------------------
    
    
    
    
    

end package;














package body tb_tc_pkg
is

    
    --------------- Generic run procedure ------------
    procedure tc
        generic(
            type        rtl_in_if_t;                                      
            constant    new_run_name        :       string;            

            constant    called_tc_name      :       string;            
            
            procedure   called_tc
            (                                
                constant    rtl_name        :   in  string;
                constant    super_name      :   in  string;

                signal      rtl_in_if       :   out rtl_in_if_t ;
                signal      clk             :   in  std_logic     ;
                signal      rst_req         :   out std_logic     ;
                signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
                
                signal      put_it          :   out std_logic   ;
                signal      got_it          :   in  std_logic   ;
                signal      passed          :   in  std_logic   ;
                signal      id              :   out integer    
            )
        )
    (
        constant    rtl_name    :   in      string;
        constant    super_name  :   in      string;
        
        signal      rtl_in_if   :   out     rtl_in_if_t ;
        signal      clk             :   in  std_logic     ;
        signal      rst_req         :   out std_logic     ;
        
        
        signal      cd          :   out     check_descriptor_array (0 to check_no_max_c-1);
        
       
        signal      put_it      :   out     std_logic   ;
        signal      got_it      :   in      std_logic   ;
        signal      passed      :   in      std_logic   ;
        signal      id          :   out     integer    
    )is
        constant    this        :           string  :=  new_run_name;
        constant    scope       :           string  :=  super_name &"."& new_run_name;
    begin
    
        -- Run 'called_tc' generic procedure: the actual resolved procedure name will be like this: <RTL>_test
        called_tc(rtl_name,scope,           rtl_in_if   ,
                                            clk         ,
                                            rst_req     ,
                                            cd          ,
                                            put_it      ,
                                            got_it      ,
                                            passed      ,
                                            id          );
    
    end procedure;
    --------------------------------------------------
    
    
    ------------------------------------------------------------------------------
    procedure setup(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        variable    clk_en_in_v     :   in      std_logic;
        signal      clk_en_out      :   out     std_logic
        
    )is
        constant    this            :           string  :=  "setup";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        welcome_msg(rtl_name);                          -- Passing RTL name to welcome message printer proc.
        
        clk_gen(scope,      clk_en_in_v,clk_en_out);    -- Clock generating
        

    end procedure;
    ------------------------------------------------------------------------------
    
    
    ------------------------------------------------------------------------------
    procedure   report_and_exit(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        constant    rgr_is_needed   :   in      integer;
        signal      chk_descriptor  :   in      check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "report_and_exit";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        
        gen_rgr_report_html(            --
            scope           ,           -- 
            rgr_is_needed   ,           --
            rtl_name        ,           -- Generating HTML report.
            chk_descriptor              --
        );                              --
        
        exit_msg;                       -- Ending message.
        
        stop;                           -- Stop simulation, similar to Verilog's $finish() procedure. It ios from std.env package
        
    end procedure;
    ------------------------------------------------------------------------------
    
    
    ------------------------------------------
    procedure   processor_wr(                      
        constant    din     :   in  std_logic;
        signal      clk     :   in  std_logic;
        signal      wdata   :   out std_logic;
        signal      wr      :   out std_logic
    )is
    begin
        
        wait_re(clk);
        ----------------
        wdata   <= din;
        wr      <= '1';
        wait_re(clk);
        ---------------
        wr      <= '0';
        
    end procedure;
    ------------------------------------------
    
    
    ------------------------------------------
    procedure   processor_wr(                      
        constant    din     :   in  std_logic_vector;
        signal      clk     :   in  std_logic;
        signal      wdata   :   out std_logic_vector;
        signal      wr      :   out std_logic
    )is
    begin
        
        wait_re(clk);
        ----------------
        wdata   <= din;
        wr      <= '1';
        wait_re(clk);
        ---------------
        wr      <= '0';
        
    end procedure;
    ------------------------------------------
    
    
    
    
    


end package body;