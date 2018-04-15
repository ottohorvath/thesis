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







package fifo_snk_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--



    type fifo_snk_in_if_t   is record
        wr_from_DUV     :  std_logic;
        wdata_from_DUV  :  std_logic_vector(31 downto 0);
        wr              :  std_logic;
        wdata           :  std_logic_vector(1 downto 0);
        rd              :  std_logic;
    end record;
    --------------------------------------------------------

    constant    fifo_snk_num_of_tcs_c    :   integer := 5;     -- Number of testcases

    signal      rtl_in_if           :   fifo_snk_in_if_t     ;



    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     fifo_snk_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'fifo_snk'
    procedure   fifo_snk_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_snk_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------







end package;






package body fifo_snk_test
is

    --------------------------------------------------
    procedure   fifo_snk_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_snk_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "fifo_snk_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (fifo_snk_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     fifo_snk_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is




        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr_from_DUV      <=  '0';
        rtl_in_if.wdata_from_DUV   <=  (others=>'X');
        rtl_in_if.wr               <=  '0';
        rtl_in_if.wdata            <=  (others=>'X');
        rtl_in_if.rd               <=  '0';
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
            when 1  =>  init_check(id_in,
                        "Checking the fifo states"&
                        " by writing 0x01 into it, after reset", cd);
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
                        wait for 1 ps;
                        req_to_check(sv);

            -------------------------------------------------
            when 2  =>  init_check(id_in,
                        "Checking the fifo states after reset,by writing"&
                        " 0x01 into it, then write full", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        -- Write into the register to show its status on processor side
                        processor_wr(
                            b"01",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;

                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            processor_wr(
                                slv(32,i),
                                clk,
                                rtl_in_if.wdata_from_DUV,
                                rtl_in_if.wr_from_DUV
                            );
                        end loop;

                        wait for 1 ps;


                        req_to_check(sv);
            -------------------------------------------------
            when 3  =>  init_check(id_in,
                        "Checking the fifo states after reset,by NOT writing"&
                        " 0x01 into it, then write full."&
                        " 'rdata' should be zero!", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        -- Write into the register to show its status on processor side
                        --processor_wr(
                        --    b"01",
                        --    clk,
                        --    rtl_in_if.wdata,
                        --    rtl_in_if.wr
                        --);
                        --wait for 1 ps;

                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            processor_wr(
                                slv(32,i),
                                clk,
                                rtl_in_if.wdata_from_DUV,
                                rtl_in_if.wr_from_DUV
                            );
                        end loop;

                        wait for 1 ps;


                        req_to_check(sv);
            -------------------------------------------------
            when 4  =>  init_check(id_in,
                        "Checking the fifo data on processor side"&
                        " by writing fifo full then set the module's register to show data"&
                        " on processor side. After it, just read everything out."&
                        " And finally check the fifo's status by writing 0x01 into it.", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------

                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            processor_wr(
                                slv(32,i),
                                clk,
                                rtl_in_if.wdata_from_DUV,
                                rtl_in_if.wr_from_DUV
                            );
                        end loop;

                        -- Write into the register to show its fifo data on processor side
                        processor_wr(
                            b"10",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;


                        req_to_check(sv);

                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            fifo_rd(
                                clk,
                                rtl_in_if.rd
                            );
                        end loop;
                        wait for 1 ps;

                        req_to_check(sv);

                        processor_wr(
                            b"01",
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;

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