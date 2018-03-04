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







package re_det_fsm_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--



    type re_det_fsm_in_if_t   is record

        en_fsm       :   std_logic;
        clr_fsm      :   std_logic;
        sig_from_re_det:   std_logic;

    end record;
    --------------------------------------------------------

    constant    re_det_fsm_num_of_tcs_c    :   integer := 5;     -- Number of testcases

    signal      rtl_in_if           :   re_det_fsm_in_if_t     ;







    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     re_det_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);

        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer
    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 're_det_fsm'
    procedure   re_det_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_in_if       :   out     re_det_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;


        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);

        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer
    );
    --------------------------------------------------







end package;






package body re_det_fsm_test
is

    --------------------------------------------------
    procedure   re_det_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_in_if       :   out     re_det_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);



        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer
    )is
        constant    this            :           string  :=  "re_det_fsm_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (re_det_fsm_num_of_tcs_c - 1)   loop

            test(    rtl_name,scope,      id_v        ,
                                        rtl_in_if   ,
                                        clk         ,
                                        rst_req     ,
                                        cd          ,
                                        put_it      ,
                                        got_it      ,
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

        signal      rtl_in_if       :   out     re_det_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);


        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer
    )is




        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.en_fsm            <= '0';
        rtl_in_if.clr_fsm           <= '0';
        rtl_in_if.sig_from_re_det   <= '0';
        wait for 1 ns;


        id_out      <= id_in;


        banner(id_in);              -- Testcase banner


        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!
            -------------------------------------------------            
            when 1 =>   init_check(id_in, "Checking if it can capture the rising-edge event after it has been enabled", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'IDLE' state now!
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'ENABLED' state now!
                        -------------------------------------
                        rtl_in_if.sig_from_re_det   <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.sig_from_re_det   <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'CAPTURED' state now!
            -------------------------------------------------            
            when 2 =>   init_check(id_in, "Checking if it can be sent back to idle when it is enabled", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'IDLE' state now!
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'ENABLED' state now!
                        -------------------------------------
                        rtl_in_if.clr_fsm            <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.clr_fsm            <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'IDLE' state now!
                        -------------------------------------
                        rtl_in_if.sig_from_re_det   <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.sig_from_re_det   <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'IDLE' state now!
                        -------------------------------------
            -------------------------------------------------
            when 3 =>   init_check(id_in, "Checking if if it is not triggered for falling-edge after it has been enabled", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'IDLE' state now!
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '1';
                        
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '0';
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'ENABLED' state now!
                        -------------------------------------
            -------------------------------------------------            
            when 4 =>   init_check(id_in, "Checking if if it can be sent back to IDLE when it captured an event", cd);
                        
                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'IDLE' state now!
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.en_fsm            <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'ENABLED' state now!
                        -------------------------------------
                        rtl_in_if.sig_from_re_det   <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.sig_from_re_det   <= '0';
                        wait_re(clk);
                        -------------------------------------
                        -- The FSM should be in 'CAPTURED' state now!
                        -------------------------------------
                        rtl_in_if.clr_fsm            <= '1';
                        wait_re(clk);
                        -------------------------------------
                        rtl_in_if.clr_fsm            <= '0';
                        wait_re(clk);
                        -------------------------------------
            
                        
                        
                        
                        
            -------------------------------------------------
            when others =>
        end case;

        print(scope &": Stimulus generated ...", 1);

        ---------------------------
        put_it  <= not(put_it);     -- Signaling to 'chk' process
        wait on got_it;             -- Waiting on the 'chk' process
        ---------------------------

        log_check(id_in,cd, passed);

    end procedure;
    --------------------------------------------------




















end package body;