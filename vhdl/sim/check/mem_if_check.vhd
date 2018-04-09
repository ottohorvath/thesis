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







package mem_if_check
is
    ------- Typedefs for output RTL IF signals -------------------

    constant    ch_dw_c            :   integer :=  32;
    constant    ch_aw_c            :   integer :=  32;

    constant    ch_rdstart_c       :   std_logic_vector(31 downto 0) := x"12340000";
    constant    ch_wrstart_c       :   std_logic_vector(31 downto 0) := x"12345678";


    type mem_if_out_if_t   is record
        rdata           :   std_logic_vector(ch_dw_c-1 downto 0);
        wdata_to_DUV    :   std_logic_vector(ch_dw_c-1 downto 0);
        addr_to_DUV     :   std_logic_vector(ch_aw_c-1 downto 0);
        rstrb_to_DUV    :   std_logic;
        wstrb_to_DUV    :   std_logic;

    end record;
    --------------------------------------------------



    signal      rtl_out_if  :   mem_if_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   mem_if_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      mem_if_out_if_t;
        signal      tb_if           :   in      tb_if_t

    );
    --------------------------------------------------





end package;



package body mem_if_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   mem_if_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        variable    sv              :   inout   synchronizer_t;

        signal      rtl_out_if      :   in      mem_if_out_if_t;
        signal      tb_if           :   in      tb_if_t
    )is

        constant    this            :           string  :=  "mem_if_check";
        constant    scope           :           string  :=  super_name &"."& this;
    begin

        wait_for_next_check(sv);

        case (sv.get_tc_id)   is
            -------------------------------------------------
            when 0  =>
                            -- EXP   -- ACT
                        sv.compare('0',             rtl_out_if.rstrb_to_DUV   );
                        sv.compare('0',             rtl_out_if.wstrb_to_DUV   );
                        sv.compare(slv(ch_dw_c,'0'),   rtl_out_if.rdata       );

                        check_done(sv);

            -------------------------------------------------
            when 1  =>
                            -- EXP   -- ACT
                        sv.compare('0',             rtl_out_if.rstrb_to_DUV   );
                        sv.compare('1',             rtl_out_if.wstrb_to_DUV   );

                        sv.compare(x"0000ffff",     rtl_out_if.wdata_to_DUV    );
                        sv.compare(x"aaaabbbb",     rtl_out_if.addr_to_DUV     );


                        check_done(sv);
            -------------------------------------------------
            when 2  =>
                            -- EXP   -- ACT
                        sv.compare('1',             rtl_out_if.rstrb_to_DUV   );
                        sv.compare('0',             rtl_out_if.wstrb_to_DUV   );

                        
                        sv.compare(x"aaaabbbb",     rtl_out_if.addr_to_DUV     );


                        check_done(sv);
                        ------------------------------------
                        wait_for_next_check(sv);

                        sv.compare('0',             rtl_out_if.rstrb_to_DUV   );
                        sv.compare('0',             rtl_out_if.wstrb_to_DUV   );
                        
                        
                        sv.compare(x"aaaabbbb",     rtl_out_if.addr_to_DUV     );
                        
                        check_done(sv);
                        ------------------------------------
                        wait_for_next_check(sv);
                        
                        sv.compare('0',             rtl_out_if.rstrb_to_DUV   );
                        sv.compare('0',             rtl_out_if.wstrb_to_DUV   );
                        
                        
                        sv.compare(x"aaaabbbb",     rtl_out_if.addr_to_DUV     );
                        sv.compare(x"0000aaa2",     rtl_out_if.rdata     );
                        
                        check_done(sv);
                        
                            
                        
                        
            -------------------------------------------------
           when others =>
        end case;

    end procedure;
    --------------------------------------------------

end package body;