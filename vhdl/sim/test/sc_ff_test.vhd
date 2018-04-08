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


use work.tb_tc_pkg.all      ;   -- Includes for the 'tc' process.
----------------------------------------







package sc_ff_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--
    
    type sc_ff_in_if_t   is record
    
        set     :   std_logic;
        clr     :   std_logic;
        
    end record;
    --------------------------------------------------------
    
    constant    sc_ff_num_of_tcs_c    :   integer := 4;     -- Number of testcases
   
    signal      rtl_in_if           :   sc_ff_in_if_t     ;
    
    
    
    
    
    
    
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     sc_ff_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1) 
    );
    --------------------------------------------------
    
    --------------------------------------------------
    -- The main test runner for RTL named 'sc_ff'
    procedure   sc_ff_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;
        
        signal      rtl_in_if       :   out     sc_ff_in_if_t ;   
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)   
    );
    --------------------------------------------------
    
    
    

    
    
    
end package;






package body sc_ff_test
is

    --------------------------------------------------
    procedure   sc_ff_test(    
        constant    rtl_name        :   in      string;    
        constant    super_name      :   in      string;    
        variable    sync_sv         :   inout  synchronizer_t;
            
        signal      rtl_in_if       :   out     sc_ff_in_if_t ;       
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1) 
    )is
        constant    this            :           string  :=  "sc_ff_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        for id_v in 0 to (sc_ff_num_of_tcs_c - 1)   loop        
                    
            test(rtl_name,scope,sync_sv,        id_v        , 
                                                rtl_in_if   ,
                                                clk         ,
                                                rst_req     ,
                                                cd          );                                
        end loop;

    end procedure;
    --------------------------------------------------
   
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     sc_ff_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is 
        
        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        rtl_in_if.set   <= '0';
        rtl_in_if.clr   <= '0';
        wait for 1 ps;   
        
        banner(id_in);              -- Testcase banner
        
        
        case (id_in) is 
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        sv.init(id_in);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        
                        
                        req_to_check(sv);
                        
                        
            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking the 'set' control input", cd);
                        sv.init(id_in);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.clr   <= '0'; 
                        rtl_in_if.set   <= '1'; --  Setting
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.set   <= '0'; 
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        
                        
                        req_to_check(sv);
                        
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the 'clr' control input", cd);
                        sv.init(id_in);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.clr   <= '0'; 
                        rtl_in_if.set   <= '1'; --  Setting
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.clr   <= '1'; --  Clearing
                        rtl_in_if.set   <= '0'; 
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.clr   <= '0';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        
                        
                        req_to_check(sv);
                        
                        
            -------------------------------------------------
            when 3  =>  init_check(id_in, "Checking when both control inputs are HIGH: output should remain unchanged", cd);
                        sv.init(id_in);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.clr   <= '0'; 
                        rtl_in_if.set   <= '1'; --  Setting
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.clr   <= '1'; --  Both controls are high: the module is enabled, but should not be cleared
                        rtl_in_if.set   <= '1'; --  
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        wait_re(clk);           -- The output should be '1'
                        ----------------------------------
                        
                        
                        req_to_check(sv);
                        
                        
            -------------------------------------------------        
            when others =>
        end case;
            
        ------------------------------
        print(scope &": Testcase FINISHED ...", 1);
        ------------------------------
        if( sv.get_passed = '1') then
            test_result(sv.get_tc_id, "passed");
        else
            test_result(sv.get_tc_id, "failed");
        end if;
        ------------------------------
        log_check(id_in,cd, sv.get_passed);
        
    end procedure;
    --------------------------------------------------
    
end package body;