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
use work.all;
-----------------------------


------ Packages from "../tbench_pkg/" ----
use work.tb_log_pkg.all     ;
use work.tb_utils_pkg.all   ;
use work.tb_report_pkg.all  ;


use work.tb_chk_pkg.all     ;   -- Includes for the 'chk' process.
----------------------------------------







package reset_synchronizer_check
is
    ------- Typedefs for output RTL IF signals -------------------

    constant    ch_dw_c            :   integer :=  32;
    constant    ch_aw_c            :   integer :=  32;

    constant    ch_rdstart_c       :   std_logic_vector(31 downto 0) := x"12340000";
    constant    ch_wrstart_c       :   std_logic_vector(31 downto 0) := x"12345678";


    type reset_synchronizer_out_if_t   is record
        synced_rst  :   std_logic;
    end record;
    --------------------------------------------------



    signal      rtl_out_if  :   reset_synchronizer_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   reset_synchronizer_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      reset_synchronizer_out_if_t;
        signal      tb_if           :   in      tb_if_t

    );
    --------------------------------------------------





end package;



package body reset_synchronizer_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   reset_synchronizer_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      reset_synchronizer_out_if_t;
        signal      tb_if           :   in      tb_if_t
    )is

        constant    this            :           string  :=  "reset_synchronizer_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        wait_for_next_check(sv);

        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>  
                        sv.compare('0', rtl_out_if.synced_rst);
                        
                        wait_re(tb_if.clk);
                        wait for 1 ps;
                        -------------------------------
                        sv.compare('0', rtl_out_if.synced_rst);
                        
                        wait_re(tb_if.clk);
                        wait for 1 ps;
                        -------------------------------
                        sv.compare('1', rtl_out_if.synced_rst);
                        
                        check_done(sv);
                        
            -------------------------------------------------
           when others =>
        end case;

    end procedure;
    --------------------------------------------------

end package body;