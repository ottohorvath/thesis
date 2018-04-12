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







package delta_timer_check
is
    ------- Typedefs for output RTL IF signals -------------------

    constant    cntr_width_test        :   integer := 32;

    alias w is cntr_width_test;         -- Using other refrence name to ease source code readability

    type delta_timer_out_if_t   is record

        rdata   :   std_logic_vector(w-1 downto 0);
    end record;
    --------------------------------------------------
    --------------------------------------------------
    -- The main test runner for RTL named
    procedure   delta_timer_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------
end package;



package body delta_timer_check
is

    --------------------------------------------------
    -- The main checker for RTL named 
    procedure   delta_timer_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is

        constant    this            :           string  :=  "delta_timer_check";
        constant    scope           :           string  :=  super_name &"."& this;



        alias   sv     is
        <<variable  .delta_timer_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .delta_timer_tb.rtl_out_if :   delta_timer_out_if_t >>;

        alias   tb_if   is
        <<signal    .delta_timer_tb.tb_if      :   tb_if_t>>;
    begin

        wait_for_next_check(sv);

        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0 | 2  =>
                                    -- EXP          -- ACT
                            sv.compare(slv(w,'0'),  rtl_out_if.rdata);

                            check_done(sv);
            -------------------------------------------------
            when 1  =>
                                    -- EXP          -- ACT
                            sv.compare(x"00000001",  rtl_out_if.rdata);

                            check_done(sv);
            -------------------------------------------------

            when others =>
        end case;

    end procedure;
    --------------------------------------------------


end package body;