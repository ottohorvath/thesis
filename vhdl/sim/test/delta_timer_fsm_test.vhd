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







package delta_timer_fsm_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--



    type delta_timer_fsm_in_if_t   is record

        en_fsm       :   std_logic;
        clr_fsm      :   std_logic;
        chg_caught    :   std_logic;

    end record;
    --------------------------------------------------------

    constant    delta_timer_fsm_num_of_tcs_c    :   integer := 8;     -- Number of testcases

    signal      rtl_in_if           :   delta_timer_fsm_in_if_t     ;







    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);

        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer
    );
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named 'delta_timer_fsm'
    procedure   delta_timer_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;


        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);

        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer
    );
    --------------------------------------------------







end package;






package body delta_timer_fsm_test
is

    --------------------------------------------------
    procedure   delta_timer_fsm_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);



        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer
    )is
        constant    this            :           string  :=  "delta_timer_fsm_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (delta_timer_fsm_num_of_tcs_c - 1)   loop

            test(    rtl_name,scope,      id_v        ,
                                        rtl_in_if   ,
                                        clk         ,
                                        rst_req     ,
                                        cd          ,
                                        put_it      ,
                                        got_it      ,
                                        passed      ,
                                        id          );
        end loop;

    end procedure;
    --------------------------------------------------

    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     delta_timer_fsm_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);


        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer
    )is




        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.en_fsm      <= '0';
        rtl_in_if.clr_fsm     <= '0';
        rtl_in_if.chg_caught   <= '0';
        wait for 1 ns;


        id_out      <= id_in;


        banner(id_in);              -- Testcase banner


        case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!


            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking the enable of the FSM", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        --------------------------
                        rtl_in_if.en_fsm    <= '1'; -- Enabling the FSM
                        rtl_in_if.clr_fsm   <= '0'; -- The clearing is disabled now
                        wait_re(clk);
                        --------------------------
                        rtl_in_if.en_fsm    <= '0'; -- Enabling the FSM
                        wait_re(clk);               -- The approriate output is changed by now
                        --------------------------

                        -- The FSM should be in 'ENABLED' state now!



            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the clearing of the FSM after reset: control outputs of the clearings should not change", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!

                        ---------------------------
                        rtl_in_if.en_fsm    <= '0';
                        rtl_in_if.clr_fsm   <= '1'; -- The clearing is enabled now
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.clr_fsm   <= '0';
                        wait_re(clk);               -- The approriate output would be changed by now
                        ---------------------------

                        -- The FSM should be in 'IDLE' state now!

            -------------------------------------------------
            when 3  =>  init_check(id_in, "Checking after reset if a HIGH pulse on the 'chg_caught' does not toggle the FSM outputs", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!

                        ---------------------------
                        rtl_in_if.chg_caught   <= '1';   -- Signal from dual edge detector
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.chg_caught   <= '0';   -- Signal from dual edge detector
                        wait_re(clk);                   -- The approriate output is changed by now
                        ---------------------------
                        
                        -- The FSM should be in the same state!
                        
                        
            -------------------------------------------------
            when 4  =>  init_check(id_in, "Checking if the FSM can be sent back to IDLE when it is enabled", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------

                        rtl_in_if.en_fsm      <= '1';
                        rtl_in_if.clr_fsm     <= '0';
                        wait_re(clk);
                        ---------------------------
                        print(scope &": Stimulus generated ...", 1);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait_re(clk);                 -- The approriate output is changed by now
                        ---------------------------

                        -- The FSM should be in 'ENABLED' state now!

                        ---------------------------
                        put_it  <= not(put_it);       -- Let this first event be caught by the checker process
                        wait on got_it;               --
                        ---------------------------

                        ---------------------------
                        rtl_in_if.clr_fsm    <= '1';
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.clr_fsm    <= '0';
                        wait_re(clk);

                        -- The FSM should be in 'IDLE' state now!

            -------------------------------------------------
            when 5  =>  init_check(id_in, "Checking after the FSM is enabled that it can capture 'chg_caught' pulse", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------
                        
                        -- The FSM should be in 'IDLE' state now!
                        
                        
                        ---------------------------
                        rtl_in_if.en_fsm      <= '1';
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait_re(clk);                 -- The approriate output would be changed by now
                        ---------------------------

                        -- The FSM should be in 'ENABLED' state now!

                        print(scope &": Stimulus generated ...", 1);

                        ---------------------------


                        put_it  <= not(put_it);       -- Let this first stage be caught by the checker process
                        wait on got_it;               --
                        ---------------------------

                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.chg_caught    <= '0';
                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'COUNTING' state now!



            -------------------------------------------------
            when 6  =>  init_check(id_in, "Checking the 'show_cntr' control output with two 'chg_caught' pulses and also clearing after", cd);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------
                        
                        -- The FSM should be in 'IDLE' state now!
                        
                        
                        ---------------------------
                        rtl_in_if.en_fsm      <= '1';
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait_re(clk);                 -- The approriate output is changed by now
                        ---------------------------
                        
                        -- The FSM should be in 'ENABLED' state now!

                        
                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';  --
                        wait_re(clk);                   -- Generating pulse from dual edge detector
                        ---------------------------                            
                        rtl_in_if.chg_caught    <= '0';  --
                        wait_re(clk);
                        ---------------------------

                        -- The FSM should be in 'COUNTING' state now!
                        
                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';  --
                        wait_re(clk);                   -- Generating pulse from dual edge detector
                        --------------------------- 
                        rtl_in_if.chg_caught    <= '0';
                        wait_re(clk);
                        ---------------------------
                        
                        -- The FSM should be in 'DONE' state now!
                        
                        
                        ---------------------------
                        put_it  <= not(put_it);
                        wait on got_it;
                        ---------------------------

                        ---------------------------
                        rtl_in_if.clr_fsm   <= '1';
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.clr_fsm   <= '0';
                        wait_re(clk);
                        ---------------------------
                        
                        -- The FSM should be in 'IDLE' state now!
                        
                        

            -------------------------------------------------
            when 7  =>  init_check(id_in, "Checking if the FSM can be sent to IDLE while it is waiting for one more pulse from the detector", cd);
    
                        rst_gen(scope, rst_req); -- Reseting
    
                        wait_re(clk);
                        ---------------------------
                        
                        -- The FSM should be in 'IDLE' state now!
                        
                        
                        ---------------------------
                        rtl_in_if.en_fsm      <= '1';
                        rtl_in_if.clr_fsm      <= '1';
                        wait_re(clk);
                        ---------------------------
                        rtl_in_if.en_fsm      <= '0';
                        wait_re(clk);                 -- The approriate output is changed by now
                        ---------------------------
                        
                        
                        -- The FSM should be in 'ENABLED' state now!
                        
                        ---------------------------
                        rtl_in_if.chg_caught    <= '1';  --
                        wait_re(clk);                   -- Generating pulse from dual edge detector
                        ---------------------------
                        rtl_in_if.chg_caught    <= '0';  
                        wait_re(clk);
                        ---------------------------

                        
                        -- The FSM should be in 'COUNTING' state now!
                        
                        
                        ---------------------------
                        rtl_in_if.clr_fsm   <= '1';  --
                        wait_re(clk);                --
                        ---------------------------  -- Generating clear during the counter is enabled
                        rtl_in_if.clr_fsm   <= '0';  
                        wait_re(clk);                
                        ---------------------------
                        
                        -- The FSM should be in 'IDLE' state now!
                        
                        
            -------------------------------------------------
            when others =>
        end case;

        print(scope &": Stimulus generated ...", 1);

        ---------------------------
        put_it  <= not(put_it);     -- Signaling to 'chk' process
        wait on got_it;             -- Waiting on the 'chk' process
        ---------------------------

        log_check(id_in,cd, passed);

    end procedure;
    --------------------------------------------------




















end package body;