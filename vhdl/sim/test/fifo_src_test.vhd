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







package fifo_src_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--



    type fifo_src_in_if_t   is record

        wr          :  std_logic;
        rd_from_DUV :  std_logic;
        wdata       :  std_logic_vector(31 downto 0);

    end record;
    --------------------------------------------------------

    constant    fifo_src_num_of_tcs_c    :   integer := 3;     -- Number of testcases

    signal      rtl_in_if           :   fifo_src_in_if_t     ;







    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     fifo_src_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'fifo_src'
    procedure   fifo_src_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_src_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------







end package;






package body fifo_src_test
is

    --------------------------------------------------
    procedure   fifo_src_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_src_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "fifo_src_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (fifo_src_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     fifo_src_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is




        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr            <= '0';
        rtl_in_if.rd_from_DUV   <= '0';
        rtl_in_if.wdata         <= (others  =>  'Z');
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
            when 1  =>  init_check(id_in, "Checking the trig_out output port by writing full the FIFO", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        -----------------------------------
                        
                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            processor_wr(
                                slv(32,i),
                                clk,
                                rtl_in_if.wdata,
                                rtl_in_if.wr
                            );

                        end loop;
                        
                        req_to_check(sv);
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the trig_out output port by reading out after the FIFO after it was written full", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        -----------------------------------
                        
                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            processor_wr(
                                slv(32,i),
                                clk,
                                rtl_in_if.wdata,
                                rtl_in_if.wr
                            );
                        end loop;
                        
                        wait_re(clk);
                        
                        -- Here, the FIFO's depth is 8
                        for i in 0 to 7 loop
                            fifo_rd(
                                clk,
                                rtl_in_if.rd_from_DUV
                            );
                            -- Checking that trig_out is deasserted
                            -- and rdata is 0x00
                            if(i = 0)   then
                                req_to_check(sv);
                            end if;
                        end loop;
                        
                        
                        -- The module should be in 'IDLE' state!
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