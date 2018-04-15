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


package fifo_wr_if_fsm_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--

    type fifo_wr_if_fsm_in_if_t   is record
        trig_in_fsm     :   std_logic;
        wr              :   std_logic;
        wdata           :   std_logic_vector(2 downto 0);
        fifo_wr         :   std_logic;
    end record;
    --------------------------------------------------------

    constant    fifo_wr_if_fsm_num_of_tcs_c    :   integer := 9;     -- Number of testcases

    signal      rtl_in_if           :   fifo_wr_if_fsm_in_if_t     ;


    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     fifo_wr_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'fifo_wr_if_fsm'
    procedure   fifo_wr_if_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_wr_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------


end package;



package body fifo_wr_if_fsm_test
is

    --------------------------------------------------
    procedure   fifo_wr_if_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_wr_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "fifo_wr_if_fsm_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (fifo_wr_if_fsm_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     fifo_wr_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr               <=  '0';
        rtl_in_if.wdata            <=  (others=>'X');
        rtl_in_if.fifo_wr          <=  '0';
        rtl_in_if.trig_in_fsm      <=  '0';
        wait for 1 ps;





        banner(id_in);              -- Testcase banner


        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        req_to_check(sv);
            -------------------------------------------------
            when 1  =>  init_check(id_in,   "Checking IDLE->ENABLED state transtition"&
                                            " WITHOUT trig_in", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wdata <= b"001";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 2  =>  init_check(id_in,   "Checking IDLE->ENABLED state transtition"&
                                            " WITH trig_in", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        rtl_in_if.trig_in_fsm    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.trig_in_fsm    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 3  =>  init_check(id_in,   "Checking ENABLED->RCVD_DATA state transtition"
                                            , cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        rtl_in_if.trig_in_fsm    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.trig_in_fsm    <= '0'  ;   wait for 1 ps;
                        -----------------------------------

                        wait_re(clk);

                        rtl_in_if.fifo_wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.fifo_wr    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 4  =>  init_check(id_in,   "Checking RCVD_DATA->SHOW_DATA state transtition"
                                            , cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        rtl_in_if.trig_in_fsm    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.trig_in_fsm    <= '0'  ;   wait for 1 ps;
                        -----------------------------------

                        wait_re(clk);

                        rtl_in_if.fifo_wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.fifo_wr    <= '0'  ;   wait for 1 ps;

                        wait_re(clk);

                        rtl_in_if.wdata <= b"100";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 5  =>  init_check(id_in,   "Checking SHOW_DATA->ENABLED state transtition"
                                            , cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        rtl_in_if.trig_in_fsm    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.trig_in_fsm    <= '0'  ;   wait for 1 ps;
                        -----------------------------------

                        wait_re(clk);

                        rtl_in_if.fifo_wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.fifo_wr    <= '0'  ;   wait for 1 ps;

                        wait_re(clk);

                        rtl_in_if.wdata <= b"100";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        wait_re(clk);

                        rtl_in_if.wdata <= b"001";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 6  =>  init_check(id_in,   "Checking SHOW_DATA->IDLE state transtition"
                                            , cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        rtl_in_if.trig_in_fsm    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.trig_in_fsm    <= '0'  ;   wait for 1 ps;
                        -----------------------------------

                        wait_re(clk);

                        rtl_in_if.fifo_wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.fifo_wr    <= '0'  ;   wait for 1 ps;

                        wait_re(clk);

                        rtl_in_if.wdata <= b"100";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        wait_re(clk);

                        rtl_in_if.wdata <= b"010";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 7  =>  init_check(id_in,   "Checking ENABLED->IDLE state transtition"
                                            , cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wdata <= b"001";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;



                        -----------------------------------
                        rtl_in_if.wdata <= b"010";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;

                        req_to_check(sv);
            -------------------------------------------------
            when 8  =>  init_check(id_in,   "Checking RCVD_DATA->IDLE state transtition"
                                            , cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        rtl_in_if.wdata <= b"001";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;
                        -----------------------------------

                        wait_re(clk);

                        rtl_in_if.fifo_wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.fifo_wr    <= '0'  ;   wait for 1 ps;

                        -----------------------------------

                        wait_re(clk);


                        rtl_in_if.wdata <= b"010";
                        rtl_in_if.wr    <= '1'  ;   wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.wdata <= b"XXX";
                        rtl_in_if.wr    <= '0'  ;   wait for 1 ps;






                        req_to_check(sv);

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