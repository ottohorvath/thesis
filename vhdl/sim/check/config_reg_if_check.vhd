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







package config_reg_if_check
is

    constant    chk_ack_needed_c    :   boolean :=  false;
    constant    chk_dw_c            :   integer :=  32;
    constant    chk_aw_c            :   integer :=  32;
    constant    chk_rdstart_c       :   std_logic_vector(63 downto 0) := x"0000000012340000";
    constant    chk_wrstart_c       :   std_logic_vector(63 downto 0) := x"0000000012345678";







    ------- Typedefs for output RTL IF signals -------------------

    type config_reg_if_out_if_t   is record
        rdata        :  std_logic_vector(chk_dw_c-1 downto 0);
        wstrb_to_DUV :  std_logic;
        rstrb_to_DUV :  std_logic;
        wdata_to_DUV :  std_logic_vector(chk_dw_c-1 downto 0);
        addr_to_DUV  :  std_logic_vector(chk_aw_c-1 downto 0);
        cs_to_DUV    :  std_logic;
    end record;
    --------------------------------------------------


    --------------------------------------------------
    -- The main test runner for RTL named ' '
    procedure   config_reg_if_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    );
    --------------------------------------------------





end package;



package body config_reg_if_check
is

    --------------------------------------------------
    -- The main checker for RTL named ' '
    procedure   config_reg_if_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string
    )is

        constant    this            :           string  :=  "config_reg_if_check";
        constant    scope           :           string  :=  super_name &"."& this;

        alias   sv     is
        <<variable  .config_reg_if_tb.sync_sv    :   synchronizer_t>>;

        alias   rtl_out_if   is
        <<signal    .config_reg_if_tb.rtl_out_if :   config_reg_if_out_if_t >>;

        alias   tb_if   is
        <<signal    .config_reg_if_tb.tb_if      :   tb_if_t>>;
    begin



        wait_for_next_check(sv);


        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>          -- EXP                      -- ACT
                        sv.compare('0',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.wstrb_to_DUV );
                        --sv.compare(slv(chk_aw_c,'X'),   rtl_out_if.addr_to_DUV  );
                        --sv.compare(slv(chk_dw_c,'X'),   rtl_out_if.wdata_to_DUV  );
                        sv.assertion(Is_X(rtl_out_if.addr_to_DUV));
                        sv.assertion(Is_X(rtl_out_if.wdata_to_DUV));


                        check_done(sv);
            -------------------------------------------------
            when 1  =>          -- EXP                      -- ACT
                        sv.compare('0',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.wstrb_to_DUV );
                        sv.compare(x"0000000A",         rtl_out_if.addr_to_DUV  );
                        --sv.compare(slv(chk_dw_c,'X'),   rtl_out_if.wdata_to_DUV  );
                        sv.assertion(Is_X(rtl_out_if.wdata_to_DUV));
                        check_done(sv);

                        wait_for_next_check(sv);

                                -- EXP                      -- ACT
                        sv.compare('1',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.wstrb_to_DUV );
                        sv.compare(x"0000000A",         rtl_out_if.addr_to_DUV  );
                        sv.compare(x"00001111",         rtl_out_if.wdata_to_DUV  );
                        check_done(sv);

                        wait_for_next_check(sv);

                                -- EXP                      -- ACT
                        sv.compare('1',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('1',                 rtl_out_if.wstrb_to_DUV );
                        sv.compare(x"0000000A",         rtl_out_if.addr_to_DUV  );
                        sv.compare(x"00001111",         rtl_out_if.wdata_to_DUV  );
                        check_done(sv);

                        wait_for_next_check(sv);

                                -- EXP                      -- ACT
                        sv.compare('0',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.wstrb_to_DUV );
                        sv.compare(x"0000000A",         rtl_out_if.addr_to_DUV  );
                        sv.compare(x"00001111",         rtl_out_if.wdata_to_DUV  );
                        check_done(sv);
            -------------------------------------------------
            when 2  =>          -- EXP                      -- ACT
                        sv.compare('0',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.rstrb_to_DUV );
                        sv.compare(slv(chk_dw_c,'0'),   rtl_out_if.rdata  );
                        --sv.compare(slv(chk_dw_c,'X'),   rtl_out_if.wdata_to_DUV  );
                        --sv.assertion(Is_X(rtl_out_if.addr_to_DUV));
                        check_done(sv);

                        wait_for_next_check(sv);
                                -- EXP                      -- ACT
                        sv.compare('1',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.rstrb_to_DUV );
                        sv.compare(slv(chk_dw_c,'0'),   rtl_out_if.rdata  );
                        --sv.compare(slv(chk_dw_c,'X'),   rtl_out_if.wdata_to_DUV  );
                        sv.compare(x"0000000B",       rtl_out_if.addr_to_DUV);
                        check_done(sv);

                        wait_for_next_check(sv);

                                -- EXP                      -- ACT
                        sv.compare('1',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('1',                 rtl_out_if.rstrb_to_DUV );
                        sv.compare(slv(chk_dw_c,'0'),   rtl_out_if.rdata  );
                        --sv.compare(slv(chk_dw_c,'X'),   rtl_out_if.wdata_to_DUV  );
                        sv.compare(x"0000000B",       rtl_out_if.addr_to_DUV);
                        check_done(sv);

                        wait_for_next_check(sv);

                                -- EXP                      -- ACT
                        sv.compare('0',                 rtl_out_if.cs_to_DUV    );
                        sv.compare('0',                 rtl_out_if.rstrb_to_DUV );
                        sv.compare(x"CCCCDDDD",         rtl_out_if.rdata  );
                        --sv.compare(slv(chk_dw_c,'X'),   rtl_out_if.wdata_to_DUV  );
                        sv.compare(x"0000000B",       rtl_out_if.addr_to_DUV);
                        check_done(sv);


            -------------------------------------------------

            -------------------------------------------------
            when others =>
        end case;

    end procedure;
    --------------------------------------------------
end package body;
