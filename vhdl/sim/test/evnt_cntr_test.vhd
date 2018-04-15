----------------------------------------------------------------------------------------
-- Author: Otto Horvath
----------------------------------------------------------------------------------------
-- Description: ~
--
--
----------------------------------------------------------------------------------------
library ieee                ;
library std                 ;
-----------------------------
use std.env.all             ;
use std.textio.all          ;
use ieee.numeric_std.all    ;
use ieee.std_logic_1164.all ;
-----------------------------


------ Packages from "../tbench_pkg/" ----
use work.tb_log_pkg.all     ;
use work.tb_utils_pkg.all   ;
use work.tb_report_pkg.all  ;


use work.tb_tc_pkg.all      ;   -- Includes for the 'tc' process.
----------------------------------------







package evnt_cntr_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--



    type evnt_cntr_in_if_t   is record

        wr              :   std_logic;
        wdata           :   std_logic_vector(1 downto 0);
        trig_in         :   std_logic;
        signal_from_DUV :   std_logic_vector(7 downto 0);

    end record;
    --------------------------------------------------------

    constant    evnt_cntr_num_of_tcs_c    :   integer := 2;     -- Number of testcases

    signal      rtl_in_if           :   evnt_cntr_in_if_t     ;

    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     evnt_cntr_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'evnt_cntr'
    procedure   evnt_cntr_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     evnt_cntr_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

end package;






package body evnt_cntr_test
is

    --------------------------------------------------
    procedure   evnt_cntr_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     evnt_cntr_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "evnt_cntr_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (evnt_cntr_num_of_tcs_c - 1)   loop

            test(rtl_name,scope,sync_sv,id_v        ,
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

        signal      rtl_in_if       :   out     evnt_cntr_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is




        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr              <=    '0';
        rtl_in_if.wdata           <=    (others =>  '0');
        rtl_in_if.trig_in         <=    '0';
        rtl_in_if.signal_from_DUV <=    (others=>    '0');
        wait for 1 ps;


        banner(id_in);              -- Testcase banner


        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        -----------------------------------

                        -- The module should be in 'IDLE' state!
                        req_to_check(sv);
            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking the counter inside and the trigger output, with changing values on signal_from_DUV, and at the end clear the module", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        -----------------------------------
                        processor_wr(
                            b"01",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );


                        rtl_in_if.signal_from_DUV   <=  x"ff";
                        wait for 1 ps;
                        wait_re(clk);

                        req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);
                        req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.signal_from_DUV   <=  x"aa";
                        wait for 1 ps;
                        wait_re(clk);
                        req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);
                        req_to_check(sv);
                        -----------------------------------

                        
                        wait_re(clk);
                        processor_wr(
                            b"10",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait_re(clk);
                        wait for 1 ps;
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