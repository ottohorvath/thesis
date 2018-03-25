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
use work.tb_sync_pkg.all    ;


use work.tb_chk_pkg.all     ;   -- Includes for the 'chk' process.
----------------------------------------







package fifo_check
is

    

    ------- Typedefs for output RTL IF signals -------------------


    constant    DEPTH_C     :   integer :=  8;
    constant    DWIDTH_C    :   integer :=  32;

    type fifo_out_if_t   is record

        empty   :   std_logic;
        rdata   :   std_logic_vector(DWIDTH_C-1 downto 0);
        full    :   std_logic;
    end record;
    --------------------------------------------------



    signal      rtl_out_if  :   fifo_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   fifo_check(
        variable    sv              :   inout   shared_sync;
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_out_if      :   in      fifo_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;

        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer
    );
    --------------------------------------------------





end package;



package body fifo_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   fifo_check(
        variable    sv              :   inout   shared_sync;
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_out_if      :   in      fifo_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;

        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer
    )is

        variable    i               :           integer :=  0;
        variable    ipp             :           integer :=  0;

        variable    errors          :           integer :=  0;
        variable    noc             :           integer :=  0;   -- Num of checks per Test ID

        constant    this            :           string  :=  "fifo_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin



        wait on put_it;             -- Waiting on the 'tc' process

        errors := 0;                -- Initializing error indicator

        print(scope &": Checking ID = "& str(id),   1);



        case (id)   is
            -------------------------------------------------
            when    0   =>  if(
                                rtl_out_if.rdata    /=  x"00000000" and
                                rtl_out_if.full     /=  '0'         and
                                rtl_out_if.empty    /=  '1'
                            )   then
                                                   -- Exp      --Act
                                perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));
                                errors := errors + 1;
                            end if;
            -------------------------------------------------
            when    1   =>  if(
                                rtl_out_if.rdata /=  x"00000001"
                            ) then
                                                    -- Exp      --Act
                                perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));
                                errors := errors + 1;
                            end if;
            -------------------------------------------------
            when    2   =>  if(
                                rtl_out_if.rdata /=  x"00000002"
                            ) then
                                                    -- Exp      --Act
                                perror(scope&".0",  str('0'),   str(rtl_out_if.rdata));
                                errors := errors + 1;
                            end if;
            -------------------------------------------------
            when    3   =>  
                            
                            sv.start_checking;
                            
                            sv.checking_it;
                            
                            print(scope &": Checking DONE!",1);
                            sv.checking_done;
                            

            
--                            loop
--                                -- Looping until the FIFO is full
--                                -- Test process is responsible for read out the
--                                -- contents of it
--
--                                if rtl_out_if.full = '0'    then
--                                    got_it  <= not got_it;
--                                    exit;
--                                else
--                                    wait for 1 ps;
--                                end if;
--
--                            end loop;
--                            
--                            print(scope &": WAIT",1);
--                            wait;
--                            -----------------------
--
--                            wait on put_it;
--                            i   := 0;
--                            ipp := 1;
--                            for i in 0 to DEPTH_C-1 loop
--                                if(
--                                    rtl_out_if.rdata /=  std_logic_vector(to_unsigned(ipp , DWIDTH_C) )
--                                ) then
--                                                              -- Exp      --Act
--                                    perror(scope&"."&str(ipp),  str(ipp),   str(rtl_out_if.rdata));
--                                    errors := errors + 1;
--                                end if;
--                                ----------------------------------------------------------
--                                got_it  <= not(got_it);     -- Signalling back to the 'tc' process
--                                wait on put_it;             -- Waiting on the 'tc' process
--                                ----------------------------------------------------------
--
--                                ipp := ipp + 1;
--                            end loop;


            -------------------------------------------------
            when others =>
        end case;



        -------------------------------------
        if( errors /= 0) then
            passed <= '0';
            wait for 0 ns;
            test_result(id, "failed");
        else
            passed <= '1';
            wait for 0 ns;
            test_result(id, "passed");
        end if;
        -------------------------------------




        got_it  <= not(got_it);      -- Signalling back to the 'tc' process
    end procedure;
    --------------------------------------------------



















end package body;