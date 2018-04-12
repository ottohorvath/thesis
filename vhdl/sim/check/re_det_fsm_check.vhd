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







package re_det_fsm_check
is
    ------- Typedefs for output RTL IF signals -------------------





    type re_det_fsm_out_if_t   is record

        re_caught   :   std_logic;

    end record;
    --------------------------------------------------
    --------------------------------------------------
    -- The main test runner for RTL named
    procedure   re_det_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------





end package;



package body re_det_fsm_check
is

    --------------------------------------------------
    -- The main checker for RTL named 
    procedure   re_det_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is

        constant    this            :           string  :=  "re_det_fsm_check";
        constant    scope           :           string  :=  super_name &"."& this;

        alias   sv     is
        <<variable  .fifo_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .fifo_tb.rtl_out_if :   re_det_fsm_out_if_t >>;

        alias   tb_if   is
        <<signal    .fifo_tb.tb_if      :   tb_if_t>>;

    begin

        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0 | 2 | 3 | 4  =>
                                            -- EXP   -- ACT
                                    sv.compare('0',  rtl_out_if.re_caught);

                                    check_done(sv);
            -------------------------------------------------
            when 1  =>
                                            -- EXP   -- ACT
                                    sv.compare('1',  rtl_out_if.re_caught);

                                    check_done(sv);
            -------------------------------------------------
            when others =>
        end case;


    end procedure;
    --------------------------------------------------


end package body;