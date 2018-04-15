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







package config_reg_if_fsm_check
is
    ------- Typedefs for output RTL IF signals -------------------

    type config_reg_if_fsm_out_if_t   is record
        rstrb       :   std_logic;
        wstrb       :   std_logic;
        cs          :   std_logic;
        addr_en     :   std_logic;
        wdata_en    :   std_logic;
        rdata_en    :   std_logic;
    end record;
    --------------------------------------------------


    --------------------------------------------------
    -- The main test runner for RTL named ' '
    procedure   config_reg_if_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------





end package;



package body config_reg_if_fsm_check
is

    --------------------------------------------------
    -- The main checker for RTL named ' '
    procedure   config_reg_if_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is

        constant    this            :           string  :=  "config_reg_if_fsm_check";
        constant    scope           :           string  :=  super_name &"."& this;

        alias   sv     is
        <<variable  .config_reg_if_fsm_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .config_reg_if_fsm_tb.rtl_out_if :   config_reg_if_fsm_out_if_t >>;

        alias   tb_if   is
        <<signal    .config_reg_if_fsm_tb.tb_if      :   tb_if_t>>;
    begin



        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>        -- EXP                -- ACT
                        --sv.compare('1',         rtl_out_if.trig_out     );
                        --sv.compare(slv(32,'0'), rtl_out_if.rdata        );
                        --sv.compare('0',         rtl_out_if.full_to_DUV  );
                        check_done(sv);
            -------------------------------------------------

            -------------------------------------------------
            when others =>
        end case;

    end procedure;
    --------------------------------------------------
end package body;
