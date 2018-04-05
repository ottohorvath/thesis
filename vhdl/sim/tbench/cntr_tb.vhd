-------------------------------------------------------------------------------------------------
-- Author: Otto Horvath           
-------------------------------------------------------------------------------------------------
-- Description: ~ 
--                
--
-----------------------------------------------------------------------------------------------
library ieee				;
library std                 ;
library work                ;
-----------------------------
use std.env.all             ;
use std.textio.all          ;
use ieee.numeric_std.all	;
use ieee.std_logic_1164.all	;
-----------------------------



------ Packages from "../tb_framework_pkg/" ----

use work.tb_utils_pkg.all       ;
use work.tb_log_pkg.all         ;
use work.tb_report_pkg.all      ;

use work.tb_tc_pkg.all          ;   -- Includes for the 'tc' process.
use work.tb_chk_pkg.all         ;   -- Includes for the 'chk' process.
----------------------------------------




use work.cntr_test.all   ;
use work.cntr_check.all  ;




-----------------------------------------------------------------------------------------------
entity cntr_tb is
    -- These generics are initialized by the Python script at elaboration time.
    generic(
    
        constant    RTL_NAME_G  :           string;         -- RTL name
        
        constant    CLI_G       :           integer := 0;   --
        constant    GUI_G       :           integer := 0;   -- Simulation type indicators.
        constant    RGR_G       :           integer := 0    --
    );
end entity;
-----------------------------------------------------------------------------------------------


architecture bhv of cntr_tb is
    
    constant    clk_enabled_c:  std_logic:= '1';            -- Clock is enabled by default.
    
    
    
    --------- Initializing the generic parameters  ----------
    procedure run_test is new tc
        generic map(
            new_run_name        =>  "run_test"      ,       -- constant string
            
            rtl_in_if_t         =>  cntr_in_if_t     ,       -- type
            called_tc           =>  cntr_test        ,       -- procedure
            called_tc_name      =>  "cntr_test"              -- constant string
        );
    -----------------------------------------------------------------------------------
    
    --------- Initializing the generic parameters  ----------
    procedure run_check is new chk
        generic map(
            new_run_name        =>  "run_check"     ,       -- constant string
            
            rtl_out_if_t        =>  cntr_out_if_t    ,       -- type
            called_chk          =>  cntr_check       ,       -- procedure
            called_chk_name     =>  "cntr_check"             -- constant string
        );
    -----------------------------------------------------------------------------------
begin


    -----------------------------------------------------------------------------------------
    tc:     process is 
                constant    this                :   string      :=  "process_tc";
                
                variable    clock_enable_v      :   std_logic   :=  clk_enabled_c;          -- Clock enable, enabled by default
            begin
                ------------------------------------------------------
                setup(RTL_NAME_G,this,              clock_enable_v  ,                       -- 
                                                    tb_if.clk_en                            -- Setup the testbench.
                                                                    );                      --
                ------------------------------------------------------
                run_test(RTL_NAME_G,this,           rtl_in_if           ,                   --
                                                    tb_if.clk           ,
                                                    tb_if.rstn_req      ,
                                                    check_descriptor    ,-- Run the testcases for the chosen RTL
                                                    p_handshake.put_it  ,                   --
                                                    p_handshake.got_it  ,                   --
                                                    p_handshake.passed  ,                   --
                                                    p_handshake.id      );                  --
                ------------------------------------------------------
                report_and_exit(RTL_NAME_G,this,    RGR_G           , 
                                                    check_descriptor);                      -- Generate report based on results and exit.
                ------------------------------------------------------
            end process;      
    -----------------------------------------------------------------------------------------        
    
    
    -----------------------------------------------------------------------------------------        
    chk:    process is
                constant    this            :   string      :=  "process_chk";
            begin
                ------------------------------------------------------
                run_check(RTL_NAME_G,this,          rtl_out_if          ,                       --
                                                    tb_if               ,                       -- 
                                                    p_handshake.put_it  ,                       --
                                                    p_handshake.got_it  ,                       --
                                                    p_handshake.passed  ,                       -- Run the checks for the tests
                                                    p_handshake.id      );                      --
                ------------------------------------------------------
            end process;
    -----------------------------------------------------------------------------------------
    
    
    
    
    
    -----------------------------------------------------------------------------------------
    rst_gen:    process is
                    constant    this            :   string      :=  "process_rst_gen";
                begin
                    
                    wait on tb_if.rstn_req;
                    
                    if(tb_if.rstn_req = '1')    then
                        tb_if.rstn     <=  '0'; print(this &": Reset is asserted.", 1);
                    else
                        tb_if.rstn     <=  '1'; print(this &": Reset is de-asserted.", 1);
                    end if;
                    
                end process;
    -----------------------------------------------------------------------------------------
    
    
    
    -----------------------------------------------------------------------------------------
    cntr:    tb_if.clk  <=  not tb_if.clk  after (clk_per_c/2) when (tb_if.clk_en = '1') else '1';
    -----------------------------------------------------------------------------------------
    L_DUT:  entity work.cntr(rtl)
                generic map(
                    CW   => w
                )
                port map(
                    clk             =>  tb_if.clk           ,
                    rstn            =>  tb_if.rstn          ,
                    
                    en              =>  rtl_in_if.en        ,      
                    clr             =>  rtl_in_if.clr       ,  
                   
                    cntr_out        =>  rtl_out_if.noc
                );
    -----------------------------------------------------------------------------------------
    
end architecture;





