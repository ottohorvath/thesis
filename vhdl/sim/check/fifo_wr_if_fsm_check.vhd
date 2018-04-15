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







package fifo_wr_if_fsm_check
is
    ------- Typedefs for output RTL IF signals -------------------

    type fifo_wr_if_fsm_out_if_t   is record
        show_data_fsm   :   std_logic;
        rdata_reg_en    :   std_logic;
        full            :   std_logic;
        rcvd_data_fsm   :   std_logic;
        enabled_fsm     :   std_logic;
    end record;
    --------------------------------------------------


    --------------------------------------------------
    -- The main test runner for RTL named ' '
    procedure   fifo_wr_if_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------





end package;



package body fifo_wr_if_fsm_check
is

    --------------------------------------------------
    -- The main checker for RTL named ' '
    procedure   fifo_wr_if_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is

        constant    this            :           string  :=  "fifo_wr_if_fsm_check";
        constant    scope           :           string  :=  super_name &"."& this;

        alias   sv     is
        <<variable  .fifo_wr_if_fsm_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .fifo_wr_if_fsm_tb.rtl_out_if :   fifo_wr_if_fsm_out_if_t >>;

        alias   tb_if   is
        <<signal    .fifo_wr_if_fsm_tb.tb_if      :   tb_if_t>>;
    begin



        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0|6|7|8  =>        -- EXP                -- ACT
                        sv.compare('0',         rtl_out_if.show_data_fsm     );
                        sv.compare('0',         rtl_out_if.rdata_reg_en      );
                        sv.compare('1',         rtl_out_if.full              );
                        sv.compare('0',         rtl_out_if.rcvd_data_fsm     );
                        sv.compare('0',         rtl_out_if.enabled_fsm       );
                        check_done(sv);
            -------------------------------------------------
            when 1|2|5 =>        -- EXP                -- ACT
                        sv.compare('0',         rtl_out_if.show_data_fsm     );
                        sv.compare('0',         rtl_out_if.rdata_reg_en      );
                        sv.compare('0',         rtl_out_if.full              );
                        sv.compare('0',         rtl_out_if.rcvd_data_fsm     );
                        sv.compare('1',         rtl_out_if.enabled_fsm       );
                        check_done(sv);
            -------------------------------------------------
            when 3  =>        -- EXP                -- ACT
                        sv.compare('0',         rtl_out_if.show_data_fsm     );
                        sv.compare('0',         rtl_out_if.rdata_reg_en      );
                        sv.compare('1',         rtl_out_if.full              );
                        sv.compare('1',         rtl_out_if.rcvd_data_fsm     );
                        sv.compare('1',         rtl_out_if.enabled_fsm       );
                        check_done(sv);
            -------------------------------------------------
            when 4  =>        -- EXP                -- ACT
                        sv.compare('1',         rtl_out_if.show_data_fsm     );
                        sv.compare('0',         rtl_out_if.rdata_reg_en      );
                        sv.compare('1',         rtl_out_if.full              );
                        sv.compare('0',         rtl_out_if.rcvd_data_fsm     );
                        sv.compare('1',         rtl_out_if.enabled_fsm       );
                        check_done(sv);
            -------------------------------------------------
            -------------------------------------------------
            when others =>
        end case;

    end procedure;
    --------------------------------------------------
end package body;
