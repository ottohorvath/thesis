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


package config_reg_if_fsm_test
is


    --constant    ack_needed_c    :   boolean :=  true;
    constant    ack_needed_c    :   boolean :=  false;
    constant    dw_c            :   integer :=  32;
    constant    rdstart_c       :   std_logic_vector(63 downto 0) := x"0000000012340000";
    constant    wrstart_c       :   std_logic_vector(63 downto 0) := x"0000000012345678";




    -- Typedefs for IF signals for driving the DUT's inputs--

    type config_reg_if_fsm_in_if_t   is record
        wr              :   std_logic;
        wdata           :   std_logic_vector(31 downto 0);
        ack_from_DUV    :   std_logic;
    end record;
    --------------------------------------------------------

    -- When ack_needed = true, there are 13 testcases
    --constant    config_reg_if_fsm_num_of_tcs_c    :   integer := 16;     -- Number of testcases
    -- By default, there is only 10 of them
    constant    config_reg_if_fsm_num_of_tcs_c    :   integer := 10;     -- Number of testcases

    signal      rtl_in_if           :   config_reg_if_fsm_in_if_t     ;


    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     config_reg_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'config_reg_if_fsm'
    procedure   config_reg_if_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     config_reg_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)

    );
    --------------------------------------------------


end package;



package body config_reg_if_fsm_test
is

    --------------------------------------------------
    procedure   config_reg_if_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_in_if       :   out     config_reg_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this            :           string  :=  "config_reg_if_fsm_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (config_reg_if_fsm_num_of_tcs_c - 1)   loop

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

        signal      rtl_in_if       :   out     config_reg_if_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is

        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr              <=  '0';
        rtl_in_if.wdata           <=  (others=> 'X');
        rtl_in_if.ack_from_DUV    <=  '0';
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
            when 1  =>  init_check(id_in, "Checking IDLE->ST_WADDR state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                        wait_re(clk);
                        wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking ST_WADDR->ST_WDATA state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';

                        wait_re(clk);
                        wait for 1 ps;
                        req_to_check(sv);
                        -----------------------------------
            -------------------------------------------------
            when 3  =>  init_check(id_in, "Checking ST_WDATA->INIT_WR state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';

                        wait_re(clk);
                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        -----------------------------------
                        wait for 1 ps;
                        req_to_check(sv);
                        -------------------------------------------------
            -------------------------------------------------
            when 4  =>  init_check(id_in, "Checking INIT_WR->GEN_WR state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';

                        wait_re(clk);
                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        -----------------------------------
                        --req_to_check(sv);

                        wait_re(clk);
                        wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 5  =>  init_check(id_in, "Checking GEN_WR->IDLE state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';

                        wait_re(clk);
                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        -----------------------------------
                        --req_to_check(sv);

                        wait_re(clk);
                        wait for 1 ps;
                        --req_to_check(sv);
                        wait_re(clk);
                        wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 6  =>  init_check(id_in, "Checking IDLE->ST_RADDR state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12340000";wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                        wait_re(clk);
                        wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 7  =>  init_check(id_in, "Checking ST_RADDR->INIT_RD state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12340000";     wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X'); wait for 1 ps;

                        wait_re(clk);
                        --wait for 1 ps;
                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1'; wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0'; wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 8  =>  init_check(id_in, "Checking INIT_RD->CAPT_RDATA state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12340000";     wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X'); wait for 1 ps;

                        wait_re(clk);
                        --wait for 1 ps;
                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';wait for 1 ps;
                        --req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);   wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 9  =>  init_check(id_in, "Checking CAPT_RDATA->IDLE state transition", cd);
                        sv.init(id_in);

                        rst_gen(scope, rst_req); -- Reseting
                        wait_re(clk);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <= X"12340000";     wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.wdata <= (others => 'X'); wait for 1 ps;

                        wait_re(clk);
                        --wait for 1 ps;
                        --req_to_check(sv);
                        -----------------------------------
                        rtl_in_if.wr    <= '1';wait for 1 ps;

                        wait_re(clk);
                        rtl_in_if.wr    <= '0';wait for 1 ps;
                        --req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);   wait for 1 ps;
                        --req_to_check(sv);
                        -----------------------------------
                        wait_re(clk);   wait for 1 ps;
                        req_to_check(sv);
            -------------------------------------------------
            when 10  =>
                        if(ack_needed_c = true) then

                            init_check(id_in, "Checking INIT_RD->WAIT_RACK state transition", cd);
                            sv.init(id_in);

                            rst_gen(scope, rst_req); -- Reseting
                            wait_re(clk);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <= X"12340000";     wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            rtl_in_if.wdata <= (others => 'X'); wait for 1 ps;

                            wait_re(clk);
                            --wait for 1 ps;
                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';wait for 1 ps;
                            --req_to_check(sv);
                            -----------------------------------
                            wait_re(clk);   wait for 1 ps;
                            req_to_check(sv);
                        end if;
            -------------------------------------------------
            when 11  =>
                        if(ack_needed_c = true) then

                            init_check(id_in, "Checking WAIT_RACK->EXTD_RD state transition", cd);
                            sv.init(id_in);

                            rst_gen(scope, rst_req); -- Reseting
                            wait_re(clk);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <= X"12340000";     wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            rtl_in_if.wdata <= (others => 'X'); wait for 1 ps;

                            wait_re(clk);
                            --wait for 1 ps;
                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';wait for 1 ps;
                            --req_to_check(sv);
                            -----------------------------------
                            wait_re(clk);   wait for 1 ps;
                            --req_to_check(sv);
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;

                            rtl_in_if.ack_from_DUV    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.ack_from_DUV    <= '0';wait for 1 ps;
                            req_to_check(sv);
                        end if;
           -------------------------------------------------
            when 12  =>
                        if(ack_needed_c = true) then

                            init_check(id_in, "Checking EXTD_RD->CAPT_RDATA state transition", cd);
                            sv.init(id_in);

                            rst_gen(scope, rst_req); -- Reseting
                            wait_re(clk);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <= X"12340000";     wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            rtl_in_if.wdata <= (others => 'X'); wait for 1 ps;

                            wait_re(clk);
                            --wait for 1 ps;
                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';wait for 1 ps;
                            --req_to_check(sv);
                            -----------------------------------
                            wait_re(clk);   wait for 1 ps;
                            --req_to_check(sv);
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;

                            rtl_in_if.ack_from_DUV    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.ack_from_DUV    <= '0';wait for 1 ps;
                            --req_to_check(sv);
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;

                            rtl_in_if.ack_from_DUV    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.ack_from_DUV    <= '0';wait for 1 ps;


                            req_to_check(sv);
                        end if;
            -------------------------------------------------
            when 13  => if(ack_needed_c = true) then
                            init_check(id_in, "Checking INIT_WR->WAIT_WACK state transition", cd);
                            sv.init(id_in);

                            rst_gen(scope, rst_req); -- Reseting
                            wait_re(clk);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            wait_re(clk);
                            rtl_in_if.wr    <= '0';

                            wait_re(clk);
                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            -----------------------------------
                            --req_to_check(sv);

                            wait_re(clk);
                            wait for 1 ps;
                            req_to_check(sv);



                        end if;
            -------------------------------------------------
            -------------------------------------------------
            when 14  => if(ack_needed_c = true) then
                            init_check(id_in, "Checking WAIT_WACK->EXTD_WR state transition", cd);
                            sv.init(id_in);

                            rst_gen(scope, rst_req); -- Reseting
                            wait_re(clk);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            wait_re(clk);
                            rtl_in_if.wr    <= '0';

                            wait_re(clk);
                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            -----------------------------------
                            --req_to_check(sv);

                            wait_re(clk);
                            wait for 1 ps;
                            --req_to_check(sv);

                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;

                            rtl_in_if.ack_from_DUV    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.ack_from_DUV    <= '0';wait for 1 ps;


                            req_to_check(sv);


                        end if;
            -------------------------------------------------
            -------------------------------------------------
            when 15  => if(ack_needed_c = true) then
                            init_check(id_in, "Checking EXTD_WR->IDLE state transition", cd);
                            sv.init(id_in);

                            rst_gen(scope, rst_req); -- Reseting
                            wait_re(clk);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <= X"12345678";wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            rtl_in_if.wdata <= (others => 'X');wait for 1 ps;

                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            wait_re(clk);
                            rtl_in_if.wr    <= '0';

                            wait_re(clk);
                            --req_to_check(sv);
                            -----------------------------------
                            rtl_in_if.wr    <= '1';
                            wait_re(clk);
                            rtl_in_if.wr    <= '0';
                            -----------------------------------
                            --req_to_check(sv);

                            wait_re(clk);
                            wait for 1 ps;
                            --req_to_check(sv);

                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;

                            rtl_in_if.ack_from_DUV    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.ack_from_DUV    <= '0';wait for 1 ps;


                            --req_to_check(sv);

                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;
                            wait_re(clk);   wait for 1 ps;

                            rtl_in_if.ack_from_DUV    <= '1';wait for 1 ps;

                            wait_re(clk);
                            rtl_in_if.ack_from_DUV    <= '0';wait for 1 ps;
                            
                            req_to_check(sv);
                        end if;
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