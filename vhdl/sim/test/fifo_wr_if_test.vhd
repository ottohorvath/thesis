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


package fifo_wr_if_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--

    type fifo_wr_if_in_if_t   is record
        trig_in         :   std_logic;
        wr              :   std_logic;
        wdata           :   std_logic_vector(2 downto 0);
        wr_from_DUV     :   std_logic;
        wdata_from_DUV  :   std_logic_vector(31 downto 0);
    end record;
    --------------------------------------------------------

    constant    fifo_wr_if_num_of_tcs_c    :   integer := 3;     -- Number of testcases

    signal      rtl_in_if           :   fifo_wr_if_in_if_t     ;


    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     fifo_wr_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'fifo_wr_if'
    procedure   fifo_wr_if_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_wr_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------


end package;



package body fifo_wr_if_test
is

    --------------------------------------------------
    procedure   fifo_wr_if_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     fifo_wr_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "fifo_wr_if_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (fifo_wr_if_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     fifo_wr_if_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.trig_in         <=  '0';
        rtl_in_if.wr              <=  '0';
        rtl_in_if.wdata           <=  (others => '0');
        rtl_in_if.wr_from_DUV     <=  '0';
        rtl_in_if.wdata_from_DUV  <=  (others => '0');
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
            when 1  =>  init_check(id_in,   "Checking the module after it is enabled"&
                                            " with one write data from FIFO IF."&
                                            " At the end, clearing it.", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        -- Enable the module
                        processor_wr(
                            slv(3,1),
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        req_to_check(sv);

                        wait_re(clk);

                        -----------------------------------
                        -- Writing in some arbitrary data
                        -- on fifo write IF
                        fifo_wr(
                            slv(32,241),
                            clk,
                            rtl_in_if.wdata_from_DUV,
                            rtl_in_if.wr_from_DUV
                        );
                        wait for 1 ps;
                        req_to_check(sv);

                        wait_re(clk);

                        -----------------------------------
                        -- Should be in RCVD_DATA state
                        -- Write in 0x04 to show data from DUV
                        processor_wr(
                            slv(3,4),
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        req_to_check(sv);
                        
                        wait_re(clk);
                        
                        -----------------------------------
                        -- Clear the module by writing 0x01 to it
                        -- i.e. send back to idle
                        processor_wr(
                            slv(3,1),
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 2  =>  init_check(id_in,   "Checking the basic functionality WITH trig_in:"&
                                            " enable the module with it, then write in one fifo data,"&
                                            " and finally clear it.", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        -- Enable the module with trig_in input port
                        rtl_in_if.trig_in <='1'; wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.trig_in <='0'; wait for 1 ps;
                        wait for 1 ps;
                        req_to_check(sv);
                        
                        wait_re(clk);
                        
                        -----------------------------------
                        -- Writing in some arbitrary data
                        -- on fifo write IF
                        fifo_wr(
                            slv(32,241),
                            clk,
                            rtl_in_if.wdata_from_DUV,
                            rtl_in_if.wr_from_DUV
                        );
                        wait for 1 ps;
                        req_to_check(sv);
                        
                        wait_re(clk);
                        
                        -----------------------------------
                        -- Should be in RCVD_DATA state
                        -- Write in 0x04 to show data from DUV
                        processor_wr(
                            slv(3,4),
                            clk,
                            rtl_in_if.wdata,
                            rtl_in_if.wr
                        );
                        wait for 1 ps;
                        req_to_check(sv);
                        
                        wait_re(clk);
                        
                        -----------------------------------
                        -- Clear the module by writing 0x01 to it
                        -- i.e. send back to idle
                        processor_wr(
                            slv(3,1),
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