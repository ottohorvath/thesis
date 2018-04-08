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







package delta_timer_fsm_check
is
    ------- Typedefs for output RTL IF signals -------------------





    type delta_timer_fsm_out_if_t   is record

        show_cntr   :   std_logic;
        cntr_clr    :   std_logic;
        cntr_en     :   std_logic;
        det_clr     :   std_logic;
        det_en      :   std_logic;

    end record;
    --------------------------------------------------



    signal      rtl_out_if  :   delta_timer_fsm_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   delta_timer_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      delta_timer_fsm_out_if_t    ;
        signal      tb_if           :   in      tb_if_t
    );
    --------------------------------------------------





end package;



package body delta_timer_fsm_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   delta_timer_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      delta_timer_fsm_out_if_t    ;
        signal      tb_if           :   in      tb_if_t
    )is

        constant    this            :           string  :=  "delta_timer_fsm_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            -- The check is the same for all three cases
            when 0 | 2 | 3 =>
                                        -- EXP          -- ACT
                                sv.compare('0',         rtl_out_if.show_cntr );
                                sv.compare('1',         rtl_out_if.cntr_clr);
                                sv.compare('0',         rtl_out_if.cntr_en);
                                sv.compare('1',         rtl_out_if.det_clr);
                                sv.compare('0',         rtl_out_if.det_en);

                                check_done(sv);

            -------------------------------------------------
            -- Checking the output signals related to ENABLED state
            when 1  =>
                                        -- EXP          -- ACT
                                sv.compare('1',         rtl_out_if.det_en);

                                check_done(sv);

            -------------------------------------------------
            when 4  =>
                                        -- EXP          -- ACT
                                sv.compare('1',         rtl_out_if.det_en);

                                check_done(sv);
                                ---------------------------

                                wait_for_next_check(sv);

                                ---------------------------

                                        -- EXP          -- ACT
                                sv.compare('0',         rtl_out_if.det_en);

                                check_done(sv);
            -------------------------------------------------
            when 5  =>
                                        -- EXP          -- ACT
                                sv.compare('1',         rtl_out_if.det_en);

                                check_done(sv);
                                ---------------------------

                                wait_for_next_check(sv);

                                ---------------------------
                                        -- EXP          -- ACT
                                sv.compare('1',         rtl_out_if.cntr_en);
                                sv.compare('1',         rtl_out_if.det_en);

                                check_done(sv);

             -------------------------------------------------
             when 6  =>
                                        -- EXP          -- ACT
                                sv.compare('1',         rtl_out_if.show_cntr);

                                check_done(sv);
                                ---------------------------

                                wait_for_next_check(sv);

                                ---------------------------

                                        -- EXP          -- ACT
                                sv.compare('0',         rtl_out_if.show_cntr);

                                check_done(sv);

            -------------------------------------------------
            when 7  =>
                                        -- EXP          -- ACT
                                sv.compare('0',         rtl_out_if.cntr_en);
                                sv.compare('0',         rtl_out_if.det_en);

                                check_done(sv);
            -------------------------------------------------
            when others =>
        end case;


    end procedure;
    --------------------------------------------------

end package body;