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
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout  synchronizer_t;

        signal      rtl_out_if      :   in      fifo_out_if_t    ;
        signal      tb_if           :   in      tb_if_t
    );
    --------------------------------------------------





end package;



package body fifo_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   fifo_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      fifo_out_if_t    ;
        signal      tb_if           :   in      tb_if_t
    )is

        variable    i               :           integer :=  0;
        variable    ipp             :           integer :=  0;

        constant    this            :           string  :=  "fifo_check";
        constant    scope           :           string  :=  super_name &"."& this;
                ---------------------------------------------------------------------------------------------------
        ---------------------------------------------------------------------------------------------------

    begin


        wait_for_next_check(sv);

        case (sv.get_tc_id)   is
            -------------------------------------------------

            when    0   =>
                                -- EXP   -- ACT
                            sv.compare('0',  rtl_out_if.full);
                            sv.compare('1',  rtl_out_if.empty);

                            check_done(sv);


            -------------------------------------------------
            when    1   =>
                                    -- EXP          -- ACT
                            sv.compare(x"00000001",  rtl_out_if.rdata);
                            sv.compare('0',          rtl_out_if.full);
                            sv.compare('1',          rtl_out_if.empty);

                            check_done(sv);





          -------------------------------------------------
          when    2   =>


                        loop
                            -- Looping until the FIFO is full
                            -- Test process is responsible for read out the
                            -- contents of it

                            ----------------------------------
                            if(rtl_out_if.empty = '1')then
                                sv.set_caught('1');
                                check_done(sv);
                                exit;

                            end if;
                            ----------------------------------

                            wait_for_next_check(sv);

                        end loop;

                        wait_for_next_check(sv);

                        sv.set_caught('0');


                        -- Just checking if the 'full' flag is popped out
                        sv.compare('1', rtl_out_if.full);
                        check_done(sv);

                        -----------------------
                        -----------------------
                        i   := 0;
                        ipp := 1;
                        for i in 0 to DEPTH_C-1 loop

                            wait_for_next_check(sv);

                            sv.compare(std_logic_vector(to_unsigned(ipp,DWIDTH_C)), rtl_out_if.rdata);
                            check_done(sv);

                            ipp := ipp + 1;

                        end loop;
            -------------------------------------------------
            when others =>
        end case;



    end procedure;
    --------------------------------------------------


end package body;