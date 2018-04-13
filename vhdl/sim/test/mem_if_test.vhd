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







package mem_if_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--

    constant    tc_ack_needed_c    :   boolean :=  false;
    constant    tc_dw_c            :   integer :=  32;
    constant    tc_aw_c            :   integer :=  32;

    constant    tc_rdstart_c       :   std_logic_vector(31 downto 0) := x"12340000";
    constant    tc_wrstart_c       :   std_logic_vector(31 downto 0) := x"12345678";


    type mem_if_in_if_t   is record

        wr              :   std_logic;
        wdata           :   std_logic_vector(tc_dw_c-1 downto 0);
        ack             :   std_logic;
        rd              :   std_logic;
        rdata_from_DUV  :   std_logic_vector(tc_dw_c-1 downto 0);

    end record;
    --------------------------------------------------------

    constant    mem_if_num_of_tcs_c     :   integer := 3;     -- Number of testcases

    signal      rtl_in_if               :   mem_if_in_if_t     ;







    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     mem_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'mem_if'
    procedure   mem_if_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     mem_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    );
    --------------------------------------------------







end package;






package body mem_if_test
is

    --------------------------------------------------
    procedure   mem_if_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     mem_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "mem_if_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (mem_if_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     mem_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr                    <= '0';
        rtl_in_if.ack                   <= '0';
        rtl_in_if.wdata                 <= (others => 'Z');
        rtl_in_if.rdata_from_DUV        <= (others => 'Z');
        rtl_in_if.rd                    <= '0';

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
            when 1  =>  init_check(id_in, "Checking one simple memory write without ack", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        -- Initiating write transfer
                        rtl_in_if.wdata <=  tc_wrstart_c;
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        -- Address
                        rtl_in_if.wdata <=  x"aaaabbbb";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        -- Payload
                        rtl_in_if.wdata <=  x"0000ffff";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;

                        req_to_check(sv);

            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking one simple memory read without ack", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        -- Initiating read transfer
                        rtl_in_if.wdata <=  tc_rdstart_c;
                        rtl_in_if.wr    <=  '1';
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        -- Address
                        rtl_in_if.wdata <=  x"aaaabbbb";
                        wait for 1 ps;
                        ----------------------------------
                        wait_re(clk);
                        ----------------------------------
                        rtl_in_if.wr    <=  '0';
                        wait for 1 ps;

                        req_to_check(sv);
                        -----------------------------------


                        wait_re(clk);

                        rtl_in_if.rdata_from_DUV    <= x"0000aaa2";
                        wait for 1 ps;

                        req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.rd    <=  '1';
                        wait for 1 ps;
                        -----------------------------------

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