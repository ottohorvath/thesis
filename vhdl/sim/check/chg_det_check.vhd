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







package chg_det_check
is
    ------- Typedefs for output RTL IF signals -------------------





    type chg_det_out_if_t   is record

        det_out :   std_logic;

    end record;
    --------------------------------------------------



    signal      rtl_out_if  :   chg_det_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   chg_det_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      chg_det_out_if_t;
        signal      tb_if           :   in      tb_if_t
    );
    --------------------------------------------------





end package;



package body chg_det_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   chg_det_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      chg_det_out_if_t;
        signal      tb_if           :   in      tb_if_t
    )is

        constant    this            :           string  :=  "chg_det_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin



        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>        -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.det_out);

                        check_done(sv);
            -------------------------------------------------
            when 1  =>        -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.det_out);

                        check_done(sv);

            -------------------------------------------------
            when 2  =>        -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.det_out);

                        check_done(sv);
            -------------------------------------------------
            when others =>
        end case;

    end procedure;
    --------------------------------------------------
end package body;
