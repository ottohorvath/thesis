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







package fifo_check
is



    ------- Typedefs for output RTL IF signals -------------------


    constant    DEPTH_C     :   integer :=  8;
    constant    DWIDTH_C    :   integer :=  32;

    type fifo_out_if_t   is record

        empty   :   std_logic;
        rdata   :   std_logic_vector(DWIDTH_C-1 downto 0);
        full    :   std_logic;
    end record;
    --------------------------------------------------

    --------------------------------------------------
    -- The main test runner for RTL named ' '
    procedure   fifo_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------

end package;



package body fifo_check
is

    --------------------------------------------------
    -- The main checker for RTL named ' '
    procedure   fifo_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is
        variable    i               :           integer :=  0;
        variable    ipp             :           integer :=  0;

        constant    this            :           string  :=  "fifo_check";
        constant    scope           :           string  :=  super_name &"."& this;

        alias   sv     is
        <<variable  .fifo_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_o   is
        <<signal    .fifo_tb.rtl_out_if :   fifo_out_if_t >>;

        alias   tb_if   is
        <<signal    .fifo_tb.tb_if      :   tb_if_t>>;
    begin


        wait_for_next_check(sv);

        case (sv.get_tc_id)   is
            -------------------------------------------------

            when    0   =>
                                -- EXP   -- ACT
                            sv.compare('0',     rtl_o.full);
                            sv.compare('1',     rtl_o.empty);
                            sv.assertion(Is_X(rtl_o.rdata));

                            check_done(sv);
            -------------------------------------------------
            when    1   =>
                                    -- EXP          -- ACT
                            sv.compare(slv(32,1),   rtl_o.rdata);
                            sv.compare('1',         rtl_o.full);
                            sv.compare('0',         rtl_o.empty);

                            check_done(sv);
            -------------------------------------------------
            when    2   =>
                            for i in 0 to 7 loop
                                        -- EXP          -- ACT
                                sv.compare(slv(32,i+1),    rtl_o.rdata);

                                if( i = 0)  then

                                    sv.compare('1',          rtl_o.full);
                                    sv.compare('0',          rtl_o.empty);
                                else
                                    sv.compare('0',          rtl_o.full);
                                    sv.compare('0',          rtl_o.empty);
                                end if;
                                check_done(sv);

                                wait_for_next_check(sv);
                            end loop;

                            sv.compare(slv(32,1),    rtl_o.rdata);
                            sv.compare('0',          rtl_o.full);
                            sv.compare('1',          rtl_o.empty);

                            check_done(sv);

            -------------------------------------------------
            when others =>
        end case;



    end procedure;
    --------------------------------------------------


end package body;