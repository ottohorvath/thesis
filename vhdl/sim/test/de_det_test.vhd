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







package de_det_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--
    
    
    
    type de_det_in_if_t   is record
    
        en  :  std_logic;
        clr :  std_logic;
        sig :  std_logic;
        
    end record;
    --------------------------------------------------------
    
    constant    de_det_num_of_tcs_c    :   integer := 3;     -- Number of testcases
   
    signal      rtl_in_if           :   de_det_in_if_t     ;
    
    
    
    
    
    
    
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     de_det_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);        
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer     
    );
    --------------------------------------------------
    
    --------------------------------------------------
    -- The main test runner for RTL named 'de_det'
    procedure   de_det_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        signal      rtl_in_if       :   out     de_det_in_if_t ;   
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer    
    );
    --------------------------------------------------
    
    
    

    
    
    
end package;






package body de_det_test
is

    --------------------------------------------------
    procedure   de_det_test(    
        constant    rtl_name        :   in      string;    
        constant    super_name      :   in      string;    
            
        signal      rtl_in_if       :   out     de_det_in_if_t ;       
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer    
    )is
        constant    this            :           string  :=  "de_det_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        for id_v in 0 to (de_det_num_of_tcs_c - 1)   loop        
                    
            test(    rtl_name,scope,      id_v        , 
                                        rtl_in_if   ,
                                        clk         ,
                                        rst_req     ,
                                        cd          ,
                                        put_it      ,
                                        get_it      ,
                                        passed      ,
                                        id          );                                
        end loop;

    end procedure;
    --------------------------------------------------
   
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     de_det_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer    
    )is 
        
        
        
        
        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        rtl_in_if.en    <= '0';
        rtl_in_if.clr   <= '0';
        rtl_in_if.sig   <= '0';
        wait for 1 ns;
        
        
        
        id_out      <= id_in;

        
        banner(id_in);              -- Testcase banner
        
        
        case (id_in) is 
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);
                        -----------------------------------
                        
                        -- The module should be in 'IDLE' state!
                        
                        
            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking if the FSM can be enabled to capture signal change on 'sig'", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                                 
                        wait_re(clk);
                        -----------------------------------
                        
                        -- The module should be in 'IDLE' state!
                        
                        
                        -----------------------------------
                        rtl_in_if.en    <= '1';
                        rtl_in_if.clr   <= '0';
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.en    <= '0'; 
                        wait_re(clk);
                        -----------------------------------
                        
                        -- The module should be in 'ENABLED' state!
                        
                        -----------------------------------
                        wait_re(clk);
                        -----------------------------------
                        
                        -- The flop should now be enabled!
                        
                        -----------------------------------
                        rtl_in_if.sig    <= '1';
                        wait_re(clk);          
                        -----------------------------------
                        
                        -- Signal is changed, and this should be seeable on the 'det_out' output
                        
                        
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the clearing of the FSM", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                                             
                        wait_re(clk);
                        -----------------------------------
                        
                        -- The module should be in 'IDLE' state!
                        
                        -----------------------------------
                        rtl_in_if.en    <= '1';
                        rtl_in_if.clr   <= '0';
                        wait_re(clk);
                        -----------------------------------                        
                        rtl_in_if.en    <= '0'; 
                        wait_re(clk);           
                        -----------------------------------
                        
                        -- The module should be in 'ENABLED' state!
                       
                        ---------------------------
                        rtl_in_if.clr    <= '1'; 
                        wait_re(clk);            
                        ---------------------------
                        rtl_in_if.clr    <= '0'; 
                        wait_re(clk);            
                        ---------------------------
                        
                        
                        -- The module should be in 'IDLE' state!
                        
                        
   
            -------------------------------------------------        
            when others =>
        end case;
            
        print(scope &": Stimulus generated ...", 1);
        
        -- Waiting on the 'chk' process       
        put_it  <= not(put_it);    wait on get_it;             
          
             

        
        log_check(id_in,cd, passed);
            
    end procedure;
    --------------------------------------------------
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    


end package body;