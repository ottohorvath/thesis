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
----------------------------------------


package tb_chk_pkg
is


    --------------- Generic run procedure ------------
    procedure   chk
        generic(
            type        rtl_out_if_t;                                       -- The corresponding DUT RTL IF type
            constant    new_run_name        :       string;                 -- The name of the instance 'run' procedure

            constant    called_chk_name     :       string;                 -- The name of the 'called_process' in string

            procedure   called_chk
            (   -- Procedure responsible for running one check which is indexed by 'id'

                constant    rtl_name        :   in  string;
                constant    super_name      :   in  string;
                variable    sync_sv         :   inout  synchronizer_t;

                signal      rtl_out_if      :   in  rtl_out_if_t;       -- Watching DUT's output ports
                signal      tb_if           :   in  tb_if_t
            )
        )
    (

        constant    rtl_name    :   in      string;
        constant    super_name  :   in      string;
        variable    sync_sv     :   inout  synchronizer_t;

        signal      rtl_out_if  :   in      rtl_out_if_t;
        signal      tb_if       :   in      tb_if_t
    );
    --------------------------------------------------




    procedure wait_for_next_check(
        variable    sync_sv :   inout  synchronizer_t
    );

    procedure check_done(
        variable    sync_sv :   inout  synchronizer_t
    );





end package;


package body tb_chk_pkg
is
    ------------------------------------------------------------------------------
    procedure   chk
        generic(
            type        rtl_out_if_t;
            constant    new_run_name        :       string;

            constant    called_chk_name     :       string;

            procedure   called_chk
            (
                constant    rtl_name        :   in  string;
                constant    super_name      :   in  string;
                variable    sync_sv         :   inout  synchronizer_t;

                signal      rtl_out_if      :   in  rtl_out_if_t;
                signal      tb_if           :   in  tb_if_t
            )
        )
    (
        constant    rtl_name    :   in      string;
        constant    super_name  :   in      string;
        variable    sync_sv         :   inout  synchronizer_t;

        signal      rtl_out_if  :   in      rtl_out_if_t;
        signal      tb_if       :   in      tb_if_t
    )is
        constant    this        :           string  :=  new_run_name;
        constant    scope       :           string  :=  super_name &"."& new_run_name;

    begin

        -- Run 'called_chk' generic procedure: the actual resolved procedure name will be like this: <RTL>_check
        called_chk( rtl_name,scope,sync_sv,      rtl_out_if  ,
                                            tb_if       );

    end procedure;
    ------------------------------------------------------------------------------


    procedure wait_for_next_check(
        variable    sync_sv :   inout  synchronizer_t
    )   is
        variable    zero :   bit :=  '0';
    begin

        -- Before start looping, just set the status
        sync_sv.set_chk_done(zero);

        -- Wait for 'req_to_check' call from 'tc' process
        loop
            if(sync_sv.get_chk_enabled = '1' )    then
                exit;
            else
                wait for 1 ps;
            end if;
        end loop;
    end procedure;


    procedure check_done(
        variable    sync_sv :   inout  synchronizer_t
    )   is
        variable    one :   bit :=  '1';
    begin
        -- Before start looping, just set the status
        sync_sv.set_chk_done(one);

        wait for 1 ps;

    end procedure;













end package body;