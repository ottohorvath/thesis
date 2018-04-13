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




use work.all;


package fifo_test
is



    -- Typedefs for IF signals for driving the DUT's inputs--

    constant    DEPTH_C     :   integer :=  8;
    constant    DWIDTH_C    :   integer :=  32;

    type fifo_in_if_t   is record

        wr      :   std_logic;
        wdata   :   std_logic_vector(DWIDTH_C-1 downto 0);
        rd      :   std_logic;

    end record;
    --------------------------------------------------------

    constant    fifo_num_of_tcs_c   :   integer     := 3;     -- Number of testcases

    signal      rtl_in_if           :   fifo_in_if_t     ;



    --------------------------------------------------
    -- The main test runner for RTL named 'fifo'
    procedure   fifo_test(

        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------



    --------------------------------------------------
    procedure   test(

        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     fifo_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)--;
    );
    --------------------------------------------------
end package;






package body fifo_test
is

    --------------------------------------------------
    procedure   fifo_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;


        signal      rtl_in_if       :   out     fifo_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "fifo_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (fifo_num_of_tcs_c - 1)   loop

            wait_re(clk);

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
        variable    sv              :   inout   synchronizer_t;

        constant    id_in           :   in      integer;


        signal      rtl_in_if       :   out     fifo_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        variable    i               :           integer :=  0;
        variable    ipp             :           integer :=  0;


        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr                    <= '0';
        rtl_in_if.rd                    <= '0';
        rtl_in_if.wdata                 <= (others => 'Z');
        wait for 1 ps;

        banner(id_in);              -- Testcase banner




        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking reset values", cd);
                        sv.init(id_in);


                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------------
                        req_to_check(sv);

            -------------------------------------------------
            when 1  =>  init_check(id_in, "Writing the FIFO full and checking the full and rdata outputs", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------------
                        -- The FIFO's depth is 8
                        for i in 0 to 7 loop
                            fifo_wr(
                                slv(32,i+1),
                                clk,
                                rtl_in_if.wdata,
                                rtl_in_if.wr
                            );
                        end loop;

                        req_to_check(sv);
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Writing the FIFO full and then reading out until it gets emptied", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------------
                        -- The FIFO's depth is 8
                        for i in 0 to 7 loop
                            fifo_wr(
                                slv(32,i+1),
                                clk,
                                rtl_in_if.wdata,
                                rtl_in_if.wr
                            );
                        end loop;

                        for i in 0 to 7 loop

                            req_to_check(sv);

                            fifo_rd(
                                clk,
                                rtl_in_if.rd
                            );
                        end loop;



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