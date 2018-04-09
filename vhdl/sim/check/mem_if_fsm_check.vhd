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







package mem_if_fsm_check
is
    ------- Typedefs for output RTL IF signals -------------------

    type mem_if_fsm_out_if_t   is record
        rstrb       :   std_logic;
        wstrb       :   std_logic;
        addr_en     :   std_logic;
        wdata_en    :   std_logic;
        rdata_en    :   std_logic;
    end record;
    --------------------------------------------------



    signal      rtl_out_if  :   mem_if_fsm_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   mem_if_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      mem_if_fsm_out_if_t;
        signal      tb_if           :   in      tb_if_t

    );
    --------------------------------------------------





end package;



package body mem_if_fsm_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   mem_if_fsm_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      mem_if_fsm_out_if_t;
        signal      tb_if           :   in      tb_if_t
    )is

        constant    this            :           string  :=  "mem_if_fsm_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        wait_for_next_check(sv);

        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
            -------------------------------------------------
            when 1  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
            -------------------------------------------------
            when 2  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
            -------------------------------------------------
            when 3  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
                        ---------------------------------

                        wait_for_next_check(sv);


                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('1',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);

            -------------------------------------------------
            when 4  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
                        ---------------------------------

                        wait_for_next_check(sv);


                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);
            -------------------------------------------------
            when 5  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
                        ---------------------------------

                        wait_for_next_check(sv);


                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('1',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);
                        ---------------------------------
                        wait_for_next_check(sv);

                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('1',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);

            -------------------------------------------------
            when 6  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
                        ---------------------------------

                        wait_for_next_check(sv);


                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('1',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);
                        ---------------------------------
                        wait_for_next_check(sv);

                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('1',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);

            -------------------------------------------------
            when 7  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
                        ---------------------------------

                        wait_for_next_check(sv);


                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('1',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);
                        ---------------------------------
                        wait_for_next_check(sv);

                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('1',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);
                        ---------------------------------
                        wait_for_next_check(sv);

                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);
            -------------------------------------------------
            when 8  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
            -------------------------------------------------
            when 9  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);
            -------------------------------------------------
            when 10  =>
                            -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);

            -------------------------------------------------
            when 11  =>
                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('1',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);


                        check_done(sv);


            -------------------------------------------------
            when 12  =>
                            -- EXP   -- ACT
                        sv.compare('1',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        wait_re(tb_if.clk);
                        wait for 1 ps;

                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('1',  rtl_out_if.rdata_en);

                        wait_re(tb_if.clk);
                        wait for 1 ps;


                            -- EXP   -- ACT
                        sv.compare('0',  rtl_out_if.rstrb   );
                        sv.compare('0',  rtl_out_if.wstrb   );
                        sv.compare('0',  rtl_out_if.addr_en );
                        sv.compare('0',  rtl_out_if.wdata_en);
                        sv.compare('0',  rtl_out_if.rdata_en);

                        check_done(sv);



            -------------------------------------------------
           when others =>
        end case;

    end procedure;
    --------------------------------------------------

end package body;