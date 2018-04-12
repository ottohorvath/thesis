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







package cntr_check
is
    ------- Typedefs for output RTL IF signals -------------------


    constant    cntr_width_test        :   integer := 32;

    alias w is cntr_width_test;         -- Using other refrence name to ease source code readability


    type cntr_out_if_t   is record

        noc:   std_logic_vector(w-1 downto 0);

    end record;
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named
    procedure   cntr_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------





end package;



package body cntr_check
is

    --------------------------------------------------
    -- The main checker for RTL named
    procedure   cntr_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is

        variable    exp_val         :           integer;

        constant    this            :           string  :=  "cntr_check";
        constant    scope           :           string  :=  super_name &"."& this;


        alias   sv     is
        <<variable  .fifo_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .fifo_tb.rtl_out_if :   cntr_out_if_t >>;

        alias   tb_if   is
        <<signal    .fifo_tb.tb_if      :   tb_if_t>>;

    begin



        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>              -- EXP   -- ACT
                        sv.compare(slv(w,'0'),  rtl_out_if.noc);

                        check_done(sv);
            -------------------------------------------------
            -- Fast checking the counter if it is counting properly
            when 1  =>

                        exp_val := 1;
                        while(exp_val <3) loop
                                        -- EXP  -- ACT
                            sv.compare(exp_val, to_integer(unsigned(rtl_out_if.noc)) );

                            exp_val := exp_val + 1;
                            wait_re(tb_if.clk);

                        end loop;
                        check_done(sv);

                        wait_for_next_check(sv);

                                    -- EXP   -- ACT
                        sv.compare(slv(w,'0'),  rtl_out_if.noc);

                        check_done(sv);
            -------------------------------------------------
            when others =>
        end case;


    end procedure;
    --------------------------------------------------

end package body;