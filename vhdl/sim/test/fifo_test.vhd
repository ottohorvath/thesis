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

    constant    fifo_num_of_tcs_c   :   integer     := 4;     -- Number of testcases

    signal      rtl_in_if           :   fifo_in_if_t     ;







    --------------------------------------------------
    procedure   test(

        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        constant    id_in           :   in      integer;

        signal      rtl_in_if       :   out     fifo_in_if_t ;
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
    -- The main test runner for RTL named 'fifo'
    procedure   fifo_test(

        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_in_if       :   out     fifo_in_if_t ;
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






package body fifo_test
is

    --------------------------------------------------
    procedure   fifo_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_in_if       :   out     fifo_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);



        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer
    )is
        constant    this            :           string  :=  "fifo_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        for id_v in 0 to (fifo_num_of_tcs_c - 1)   loop
            
            wait_re(clk);

            test(rtl_name,scope,        id_v        ,
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

        signal      rtl_in_if       :   out     fifo_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;

        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);


        signal      put_it          :   out     std_logic   ;
        signal      got_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer
    )is

        variable    i               :           integer :=  0;
        variable    ipp             :           integer :=  0;


        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        rtl_in_if.wr                    <= '0';
        rtl_in_if.rd                    <= '0';
        rtl_in_if.wdata                 <= (others => '0');
        wait for 1 ns;



        id_out  <= id_in;


        banner(id_in);              -- Testcase banner


         case (id_in) is
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking reset values", cd);

                        --wait_re(clk);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        wait_re(clk);
                        wait for 1 ps;
                        
                        
                        
                        
                        put_it  <= not(put_it);     -- Signaled to 'chk' process
                        wait on got_it;             -- Waiting on the 'chk' process
                        
                        
            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking if one can write into it and then can read out the written data, also having a look at the appropriate FIFO status indicators", cd);

                        wait_re(clk);

                        rst_gen(scope, rst_req); -- Reseting
                        
                        wait_re(clk);

                        ---------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <=  x"00000001";
                        wait for 1 ps;
                        wait_re(clk);
                        ---------------------------------
                        rtl_in_if.wr    <= '0';
                        rtl_in_if.rd    <= '1';
                        wait for 1 ps;
                        wait_re(clk);
                        rtl_in_if.rd    <= '0';
                        wait for 1 ps;
                        ---------------------------------
                        
                        put_it  <= not(put_it);     -- Signaled to 'chk' process
                        wait on got_it;             -- Waiting on the 'chk' process
                        
                        
                        
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the read data on read interface without asserting the 'rd' signal, after writing into the FIFO", cd);


                        wait_re(clk);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);

                        ---------------------------------
                        rtl_in_if.wr    <= '1';
                        rtl_in_if.wdata <=  x"00000002";
                        wait for 1 ps;
                        wait_re(clk);
                        ---------------------------------
                        rtl_in_if.rd    <= '0';
                        wait for 1 ps;
                        wait_re(clk);
                        wait for 1 ps;
                        
                        
                        
                        put_it  <= not(put_it);     -- Signaled to 'chk' process
                        wait on got_it;             -- Waiting on the 'chk' process
                        
                        
                        
           -------------------------------------------------
            when 3  =>  init_check(id_in, "Writing the FIFO full and reading everything out. Checking if the rdata is the same as the wdata written in", cd);

                        wait_re(clk);

                        rst_gen(scope, rst_req); -- Reseting

                        wait_re(clk);
                        ---------------------------------


                        -- Reading out every content from the FIFO

                        loop
                            ----------------------------------
                            rtl_in_if.rd    <= '1';
                                wait for 1 ps;
                            wait_re(clk);
                                wait for 1 ps;
                            ----------------------------------
                            rtl_in_if.rd    <= '0';
                                wait for 1 ps;
                            ----------------------------------
                            put_it  <= not put_it;
                            ----------------------------------
                            ----------------------------------
                            ----------------------------------
                            wait on got_it;
                            
                            if(got_it = '1')    then
                                exit;
                            end if;

                        end loop;

                        -- When that is completed, just write Full

                        i   := 0;
                        ipp := 1;
                        for i in 0 to DEPTH_C-1 loop

                            ----------------------------------
                            rtl_in_if.wr    <= '1';
                            rtl_in_if.wdata <=  std_logic_vector(to_unsigned(ipp , DWIDTH_C) ) ;
                            wait for 1 ps;
                            wait_re(clk);
                            ----------------------------------
                            wait for 1 ps;
                            rtl_in_if.wr    <= '0';

                            ----------------------------------
                            ipp :=  ipp+1;
                        end loop;


                        -- Just send the full FIFO for checking
                        put_it  <= not put_it;
                        wait on got_it;

                        -- Then read out everything
                        i   := 0;
                        for i in 0 to DEPTH_C-1 loop
                            ----------------------------------
                            rtl_in_if.rd    <= '1';
                            wait for 1 ps;
                            wait_re(clk);
                            wait for 1 ps;
                            ----------------------------------
                            rtl_in_if.rd    <= '0';
                            wait for 1 ps;
                            ----------------------------------

                            put_it  <= not(put_it);
                            wait on got_it;

                            ----------------------------------

                        end loop;
                        
                        
                        put_it  <= not(put_it);     -- Signaled to 'chk' process
                        wait on got_it;             -- Waiting on the 'chk' process
                        
                        
                        



            -------------------------------------------------
            when others =>
        end case;

        print(scope &": Stimulus FINISHED ...", 1);

        log_check(id_in,cd, passed);
        

    end procedure;
    --------------------------------------------------


















end package body;