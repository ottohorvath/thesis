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







package delta_timer_fsm_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--



    type delta_timer_fsm_in_if_t   is record

        en_fsm       :   std_logic;
        clr_fsm      :   std_logic;
        chg_caught    :   std_logic;

    end record;
    --------------------------------------------------------

    constant    delta_timer_fsm_num_of_tcs_c    :   integer := 8;     -- Number of testcases

    signal      rtl_in_if           :   delta_timer_fsm_in_if_t     ;







    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv               :   inout  synchronizer_t;


        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'delta_timer_fsm'
    procedure   delta_timer_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;


        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;


        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------







end package;






package body delta_timer_fsm_test
is

    --------------------------------------------------
    procedure   delta_timer_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;


        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "delta_timer_fsm_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (delta_timer_fsm_num_of_tcs_c - 1)   loop

            test(rtl_name,scope,sync_sv,    id_v        ,
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
        variable    sv               :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is




        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.en_fsm      <= '0';
        rtl_in_if.clr_fsm     <= '0';
        rtl_in_if.chg_caught   <= '0';
        wait for 1 ps;



        banner(id_in);              -- Testcase banner


        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!
                        
                        
                        req_to_check(sv);

            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking the enable of the FSM", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        --------------------------
                        rtl_in_if.en_fsm    <= '1'; -- Enabling the FSM
                        rtl_in_if.clr_fsm   <= '0'; -- The clearing is disabled now
                        wait for 1 ps;
                        --------------------------
                        wait_re(clk);
                        --------------------------
                        rtl_in_if.en_fsm    <= '0'; -- Enabling the FSM
                        wait for 1 ps;
                        --------------------------
                        wait_re(clk);               -- The approriate output is changed by now
                        --------------------------

                        -- The FSM should be in 'ENABLED' state now!

                        req_to_check(sv);

            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the clearing of the FSM after reset: control outputs of the clearings should not change", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!

                        ---------------------------
                        rtl_in_if.en_fsm    <= '0';
                        rtl_in_if.clr_fsm   <= '1'; -- The clearing is enabled now
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.clr_fsm   <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);               -- The approriate output would be changed by now
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!

                        
                        
                        req_to_check(sv);
                        
                        
            -------------------------------------------------
            when 3  =>  init_check(id_in, "Checking after reset if a HIGH pulse on the 'chg_caught' does not toggle the FSM outputs", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!

                        ---------------------------
                        rtl_in_if.chg_caught   <= '1';   -- Signal from dual edge detector
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.chg_caught   <= '0';   -- Signal from dual edge detector
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                   -- The approriate output is changed by now
                        ---------------------------

                        -- The FSM should be in the same state!

                        req_to_check(sv);
                        
                        
            -------------------------------------------------
            when 4  =>  init_check(id_in, "Checking if the FSM can be sent back to IDLE when it is enabled", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        rtl_in_if.en_fsm      <= '1';
                        rtl_in_if.clr_fsm     <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                 -- The approriate output is changed by now
                        ---------------------------

                        -- The FSM should be in 'ENABLED' state now!

                        ---------------------------
                        -- Let this first event be caught by the checker process
                        req_to_check(sv);
                        ---------------------------

                        ---------------------------
                        rtl_in_if.clr_fsm    <= '1';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.clr_fsm    <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!

                        req_to_check(sv);


            -------------------------------------------------
            when 5  =>  init_check(id_in, "Checking after the FSM is enabled that it can capture 'chg_caught' pulse", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!


                        ---------------------------
                        rtl_in_if.en_fsm      <= '1';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                 -- The approriate output would be changed by now
                        ---------------------------

                        -- The FSM should be in 'ENABLED' state now!


                        -- Let this first stage be caught by the checker process
                        req_to_check(sv);
                        ---------------------------

                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.chg_caught    <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'COUNTING' state now!

                        req_to_check(sv);


            -------------------------------------------------
            when 6  =>  init_check(id_in, "Checking the 'show_cntr' control output with two 'chg_caught' pulses and also clearing after", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!


                        ---------------------------
                        rtl_in_if.en_fsm      <= '1';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                 -- The approriate output is changed by now
                        ---------------------------

                        -- The FSM should be in 'ENABLED' state now!


                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';  --
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                   -- Generating pulse from dual edge detector
                        ---------------------------
                        rtl_in_if.chg_caught    <= '0';  --
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'COUNTING' state now!

                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';  --
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                   -- Generating pulse from dual edge detector
                        ---------------------------
                        rtl_in_if.chg_caught    <= '0';
                        wait for 1 ps;

                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'DONE' state now!


                        ---------------------------

                        req_to_check(sv);

                        ---------------------------

                        ---------------------------
                        rtl_in_if.clr_fsm   <= '1';
                        wait for 1 ps;
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.clr_fsm   <= '0';
                        wait for 1 ps;
                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!


                        req_to_check(sv);



            -------------------------------------------------
            when 7  =>  init_check(id_in, "Checking if the FSM can be sent to IDLE while it is waiting for one more pulse from the detector", cd);
                        sv.init(id_in);
                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!


                        ---------------------------
                        rtl_in_if.en_fsm    <= '1';
                        rtl_in_if.clr_fsm   <= '1';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                 -- The approriate output is changed by now
                        ---------------------------


                        -- The FSM should be in 'ENABLED' state now!

                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';  --
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                   -- Generating pulse from dual edge detector
                        ---------------------------
                        rtl_in_if.chg_caught    <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------


                        -- The FSM should be in 'COUNTING' state now!


                        ---------------------------
                        rtl_in_if.clr_fsm   <= '1';  --
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);                --
                        ---------------------------  -- Generating clear during the counter is enabled
                        rtl_in_if.clr_fsm   <= '0';
                        wait for 1 ps;
                        ---------------------------
                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!



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