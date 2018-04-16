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


package config_reg_if_test
is


    constant    ack_needed_c    :   boolean :=  false;
    constant    dw_c            :   integer :=  32;
    constant    aw_c            :   integer :=  32;
    constant    rdstart_c       :   std_logic_vector(63 downto 0) := x"0000000012340000";
    constant    wrstart_c       :   std_logic_vector(63 downto 0) := x"0000000012345678";




    -- Typedefs for IF signals for driving the DUT's inputs--

    type config_reg_if_in_if_t   is record
        wr              :   std_logic;
        wdata           :   std_logic_vector(dw_c-1  downto 0);
        rd              :   std_logic;
        rdata_from_DUV  :   std_logic_vector(dw_c-1  downto 0);
        ack_from_DUV    :   std_logic;
    end record;
    --------------------------------------------------------

    constant    config_reg_if_num_of_tcs_c    :   integer := 3;     -- Number of testcases

    signal      rtl_in_if           :   config_reg_if_in_if_t     ;


    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     config_reg_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'config_reg_if'
    procedure   config_reg_if_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     config_reg_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------


end package;



package body config_reg_if_test
is

    --------------------------------------------------
    procedure   config_reg_if_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     config_reg_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "config_reg_if_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (config_reg_if_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     config_reg_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr              <=    '0';
        rtl_in_if.wdata           <=    (others=>'X');
        rtl_in_if.rd              <=    '0';
        rtl_in_if.rdata_from_DUV  <=    (others=>'X');
        rtl_in_if.ack_from_DUV    <=    '0';
        wait for 1 ps;





        banner(id_in);              -- Testcase banner


        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        wait for 1 ps;
                        -----------------------------------

                        req_to_check(sv);
            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking one simple write ", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        --req_to_check(sv);
                        -- Write in write indicator
                        processor_wr(
                            x"12345678",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        -- Write address
                        processor_wr(
                            x"0000000A",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------
                        -- Write data
                        processor_wr(
                            x"00001111",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------

                        wait_re(clk);
                        wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------

                        wait_re(clk);
                        wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking one simple read ", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        wait for 1 ps;
                        req_to_check(sv);
                        -- Write in write indicator
                        processor_wr(
                            x"12340000",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        -- Read address
                        processor_wr(
                            x"0000000B",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        ---- Drive in dummy read data
                        --rtl_in_if.rdata_from_DUV    <=  x"CCCCDDDD";
                        --wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------

                        wait_re(clk);
                        -- Drive in dummy read data
                        rtl_in_if.rdata_from_DUV    <=  x"CCCCDDDD";
                        wait for 1 ps;
                        --wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------

                        wait_re(clk);
                        rtl_in_if.rd  <=    '1';
                        wait for 1 ps;
                        -----------------------------------
                        req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);
                        rtl_in_if.rd  <=    '0';
                        wait for 1 ps;









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