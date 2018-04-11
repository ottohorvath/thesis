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







package delta_timer_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--
    
    
    
    type delta_timer_in_if_t   is record
    
        wr              :   std_logic;
        wdata           :   std_logic_vector(1 downto 0);
        signal_from_DUV :   std_logic;
        
    end record;
    --------------------------------------------------------
    
    constant    delta_timer_num_of_tcs_c    :   integer := 3;     -- Number of testcases
   
    signal      rtl_in_if           :   delta_timer_in_if_t     ;
    
    
    
    
    
    
    
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     delta_timer_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1) 
    );
    --------------------------------------------------
    
    --------------------------------------------------
    -- The main test runner for RTL named 'delta_timer'
    procedure   delta_timer_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv               :   inout  synchronizer_t;
        
        signal      rtl_in_if       :   out     delta_timer_in_if_t ;   
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------
    
    
    

    
    
    
end package;






package body delta_timer_test
is

    --------------------------------------------------
    procedure   delta_timer_test(    
        constant    rtl_name        :   in      string;    
        constant    super_name      :   in      string;    
        variable    sync_sv               :   inout  synchronizer_t;
        signal      rtl_in_if       :   out     delta_timer_in_if_t ;       
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "delta_timer_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        for id_v in 0 to (delta_timer_num_of_tcs_c - 1)   loop        
                    
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
        
        signal      rtl_in_if       :   out     delta_timer_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)  
    )is 
        
        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        rtl_in_if.wr                    <= '0';
        rtl_in_if.signal_from_DUV       <= '0';
        rtl_in_if.wdata                 <= (others => 'Z');
        wait for 1 ps;
        
        
        
        banner(id_in);              -- Testcase banner
        
        
        case (id_in) is 
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        sv.init(id_in);
                        
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The module now should be in 'IDLE'
                        req_to_check(sv);
                        
            -------------------------------------------------            
            when 1  =>  init_check(id_in, "Checking basic functionality: enabling and then generating signal events", cd);
                        sv.init(id_in);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The module now should be in 'IDLE'
                        -------------------------------------
                        processor_wr("01",clk,rtl_in_if.wdata,rtl_in_if.wr);
                        
                        -------------------------------------
                        -- Write has been completed
                        -------------------------------------
                        wait_re(clk);
                        -------------------------------------
                        -- The module now should be in 'ENABLED'
                        -------------------------------------
                        
                        -- Generating first a rising edge then a falling one
                        rtl_in_if.signal_from_DUV       <= '0';
                        wait for 1 ps;
                        -------------------------------------
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.signal_from_DUV       <= '1';
                        wait for 1 ps;
                        -------------------------------------
                        wait_re(clk);
                        
                        -------------------------------------
                        -- The module now should be in 'COUNTING'
                        -------------------------------------
                        
                        rtl_in_if.signal_from_DUV       <= '0';
                        wait for 1 ps;
                        -------------------------------------
                        wait_re(clk);
                        -------------------------------------
                        
                        -------------------------------------
                        -- The module now should be in 'DONE'
                        -------------------------------------
                        wait_re(clk);
                        
                        -- The counter should be standing on 1
                        
                        req_to_check(sv);
                        
            -------------------------------------------------            
            when 2  =>  init_check(id_in, "Checking basic functionality: after it is done it can be cleared", cd);
                        sv.init(id_in);
                        
                        
                        processor_wr("10",clk,rtl_in_if.wdata,rtl_in_if.wr);
                        -------------------------------------
                        -- Write has been completed
                        -------------------------------------
                        wait_re(clk);
                        -------------------------------------
                        -- The module now should be in 'IDLE'
                        -------------------------------------
                        
                        -- The counter should be standing on 0
                        
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