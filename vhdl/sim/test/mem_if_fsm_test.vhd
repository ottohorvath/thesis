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







package mem_if_fsm_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--

    constant    ack_needed_c    :   boolean :=  false;
    constant    dw_c            :   integer :=  32;
    constant    rdstart_c       :   std_logic_vector(63 downto 0) := x"0000000012340000";
    constant    wrstart_c       :   std_logic_vector(63 downto 0) := x"0000000012345678";


    type mem_if_fsm_in_if_t   is record

        wr      :   std_logic;
        wdata   :   std_logic_vector(dw_c-1 downto 0);
        ack     :   std_logic;

    end record;
    --------------------------------------------------------

    constant    mem_if_fsm_num_of_tcs_c    :   integer := 13;     -- Number of testcases

    signal      rtl_in_if           :   mem_if_fsm_in_if_t     ;

    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     mem_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'mem_if_fsm'
    procedure   mem_if_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     mem_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------







end package;






package body mem_if_fsm_test
is

    --------------------------------------------------
    procedure   mem_if_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     mem_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "mem_if_fsm_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (mem_if_fsm_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     mem_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr    <= '0';
        rtl_in_if.ack   <= '0';
        rtl_in_if.wdata <= (others => 'Z');
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
            when 1  =>  init_check(id_in, "Checking write transaction initiation with CORRECT wdata IDLE -> ST_WADDR", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12345678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_WADDR

            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking write transaction initiation with INCORRECT wdata IDLE -> ST_WADDR", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"00005678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should NOT be in ST_WADDR
            -------------------------------------------------
            when 3  =>  init_check(id_in, "Checking ST_WADDR -> ST_WDATA with CORRECT input", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12345678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_WADDR



                        ----------------------------------
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should be in ST_WDATA

            -------------------------------------------------
            when 4  =>  init_check(id_in, "Checking ST_WADDR -> ST_WDATA with INCORRECT input", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12345678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_WADDR



                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should NOT be in ST_WDATA

            -------------------------------------------------
            when 5  =>  init_check(id_in, "Checking ST_WDATA -> INIT_WR with CORRECT input", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12345678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_WADDR



                        ----------------------------------
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should be in ST_WDATA

                        ----------------------------------
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should be in INIT_WR


            -------------------------------------------------
            when 6  =>  init_check(id_in, "Checking ST_WDATA -> INIT_WR with INCORRECT input", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12345678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_WADDR



                        ----------------------------------
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should be in ST_WDATA

                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should NOT be in INIT_WR


            -------------------------------------------------
            when 7  =>  init_check(id_in, "Checking INIT_WR -> IDLE: direct transition ", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12345678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_WADDR



                        ----------------------------------
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should be in ST_WDATA

                        ----------------------------------
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;
                        ----------------------------------

                        req_to_check(sv);

                        -- Should be in INIT_WR

                        wait_re(clk);
                        wait for 1 ps;

                        req_to_check(sv);

                        -- Should be in IDLE
            -------------------------------------------------
            when 8  =>  init_check(id_in, "Checking state transition IDLE -> ST_RADDR with CORRECT wdata", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12340000";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should be in ST_RADDR
            -------------------------------------------------
            when 9  =>  init_check(id_in, "Checking state transition IDLE -> ST_RADDR with INCORRECT wdata ", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"00005678";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        req_to_check(sv);

                        -- Should NOT be in ST_WADDR

            -------------------------------------------------
            when 10  =>  init_check(id_in, "Checking state transition ST_RADDR -> INIT_RD with CORRECT input ", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12340000";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
                        ----------------------------------

                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
                        ----------------------------------



                        req_to_check(sv);

            -------------------------------------------------
            when 11  =>  init_check(id_in, "Checking state transition ST_RADDR -> INIT_RD with no wr input", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12340000";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
                        ----------------------------------

                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
                        ----------------------------------



                        req_to_check(sv);
            -------------------------------------------------
            when 12  =>  init_check(id_in, "Checking state transition INIT_RD -> IDLE", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------

                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= x"12340000";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
                        ----------------------------------

                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <= '0';
                        wait for 1 ps;
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