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







package clk_gen_check
is
    ------- Typedefs for output RTL IF signals -------------------

    type clk_gen_out_if_t   is record
        rdata   :   std_logic;
        clk_out :   std_logic;
    end record;
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named
    procedure   clk_gen_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------





end package;



package body clk_gen_check
is

    --------------------------------------------------
    -- The main checker for RTL named ' '
    procedure   clk_gen_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is
        constant    this            :           string  :=  "clk_gen_check";
        constant    scope           :           string  :=  super_name &"."& this;

        alias   sv     is
        <<variable  .clk_gen_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .clk_gen_tb.rtl_out_if :   clk_gen_out_if_t >>;

        alias   tb_if   is
        <<signal    .clk_gen_tb.tb_if      :   tb_if_t>>;

    begin

        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>      -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rdata);
                        sv.compare('0',  rtl_out_if.clk_out);

                        check_done(sv);
            -------------------------------------------------
            when 1 =>            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rdata);

                        wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                                -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.rdata);

                        check_done(sv);
            -------------------------------------------------
            when 2 =>   wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                                -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.clk_out);

                        wait_fe(tb_if.clk);
                                -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.clk_out);

                        check_done(sv);
            -------------------------------------------------
            when 3 =>   wait_re(tb_if.clk);
                                -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.rdata);

                        wait_re(tb_if.clk);
                                -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rdata);

                        check_done(sv);
            -------------------------------------------------
            when 4 =>   wait_re(tb_if.clk);
                        wait_re(tb_if.clk);
                                -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.clk_out);

                        check_done(sv);
            -------------------------------------------------
            when others =>
        end case;

    end procedure;
    --------------------------------------------------

end package body;