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


use work.tb_chk_pkg.all     ;   -- Includes for the 'chk' process.
----------------------------------------

package re_evnt_cntr_check
is
    ------- Typedefs for output RTL IF signals -------------------
    type re_evnt_cntr_out_if_t   is record
        trig_out:   std_logic;
        rdata   :   std_logic_vector(6 downto 0);
    end record;
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named
    procedure   re_evnt_cntr_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------
end package;

package body re_evnt_cntr_check
is

    --------------------------------------------------
    -- The main checker for RTL named
    procedure   re_evnt_cntr_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is
        constant    this            :           string  :=  "re_evnt_cntr_check";
        constant    scope           :           string  :=  super_name &"."& this;


        alias   sv     is
        <<variable  .re_evnt_cntr_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .re_evnt_cntr_tb.rtl_out_if :   re_evnt_cntr_out_if_t >>;

        alias   tb_if   is
        <<signal    .re_evnt_cntr_tb.tb_if      :   tb_if_t>>;
    begin


        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>        -- EXP   -- ACT
                        sv.compare('0',         rtl_out_if.trig_out);
                        sv.compare(slv(7,'0'),  rtl_out_if.rdata);

                        check_done(sv);
            -------------------------------------------------
            when 1  =>
                        wait_re(tb_if.clk);

                        -- EXP   -- ACT
                        sv.compare('0',         rtl_out_if.trig_out);
                        sv.compare(slv(7,3),  rtl_out_if.rdata);
                        check_done(sv);
                        -----------------------------------
            -------------------------------------------------
            when others =>
        end case;

    end procedure;
    --------------------------------------------------
end package body;
