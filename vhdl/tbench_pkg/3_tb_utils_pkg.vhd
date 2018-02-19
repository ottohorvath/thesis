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


------ Packages from "../packages/" ----
use work.tb_log_pkg.all                 ;
use work.tb_report_pkg.all              ;
----------------------------------------





package tb_utils_pkg is
    
    
    
    
    -------Typedefs for IF signals -------------------
    
    type tb_if_t    is record
        clk     :   std_logic;                          --
        clk_en  :   std_logic;                          -- Reset and clock grouped together.
        rstn    :   std_logic;                          --
    end record;
    
    
    type p_hs_t     is record
        put_it  :   std_logic;   
        get_it  :   std_logic;   
        passed  :   std_logic;
        id      :   integer  ; 
    end record;
    
    --------------------------------------------------
    
    
    
    ----------- Declared objects for the package ------
    
    constant    clk_per_c   :   time    := 10 ns;       -- Clock period used across the testbench.
    
    signal      tb_if       :   tb_if_t :=(             --
        clk     =>  '1',                                --
        clk_en  =>  '0',                                -- Testbench resouce related signals.
        rstn    =>  '1'                                 --
    );                                                  --
    
    signal p_handshake      :   p_hs_t  :=(             --
        put_it  =>  '0',                                --
        get_it  =>  '0',                                -- Handshake signals between the two main process
        passed  =>  '0',
        id      =>   0                                  --
    );                                                  --
    ---------------------------------------------------
    
    

    
    ----------------------------------------------------
    procedure wait_re(                                --
        signal  clk     :   in  std_logic             -- 
    );                                                --
                                                      --
    ---------------------------------------------------- Redefinition of waiting for rising/falling-edge
    procedure wait_fe(                                -- for improving code readability.
        signal  clk     :   in  std_logic             --
    );                                                --
                                                      --
    ----------------------------------------------------    
    procedure   rst_gen(                                    --
        constant    super_name      :   in      string;     --
                                                            -- Reset generating procedure.
        signal      rst_out         :   out     std_logic   --
    );                                                      --
   
    --------------------------------------------------
    procedure   clk_gen(                                    --
        constant    super_name      :   in      string;     --
                                                            -- Clock generating procedure: enabling the 'clk_gen'
        variable    en_in_v         :   in      std_logic;  -- concurrent assignment in '<RTL>_tb'.
        signal      en_o            :   out     std_logic   --
    );
    
    
end package;























package body tb_utils_pkg is


    
    
    
    ------------------------------------------------------------------------------
    procedure wait_re(
        signal  clk:    in  std_logic
    )is
    begin
    
        wait until rising_edge(clk); 
        
    end procedure;
    ------------------------------------------------------------------------------


    ------------------------------------------------------------------------------
    procedure wait_fe(
        signal  clk:    in  std_logic
    )is
    begin
    
        wait until falling_edge(clk); 
        
    end procedure;
    ------------------------------------------------------------------------------

    
    
    
    ------------------------------------------------------------------------------
    procedure   rst_gen(
        constant    super_name  :   in      string;
        
        signal      rst_out     :   out     std_logic
    )is
        constant    this        :           string  :=  "rst_gen";
        constant    scope       :           string  :=  super_name &"."& this;
    begin
    
        wait for    1 ns;
        rst_out     <=  '0';
        print(scope &": Reset is asserted.", 1);
        
        wait for    1 ns;
        rst_out     <=  '1';
        print(scope &": Reset is de-asserted.", 1);
        
    end procedure;
    ------------------------------------------------------------------------------
    



    ------------------------------------------------------------------------------
    procedure clk_gen(
        constant    super_name  :   in      string;
        
        variable    en_in_v     :   in      std_logic;
        signal      en_o        :   out     std_logic    
    )is
        constant    this        :           string  :=  "clk_gen";
        constant    scope       :           string  :=  super_name &"."& this;
    begin
    
        if (en_in_v = '1')   then
            en_o    <= '1';
            print(scope &": Clock is ON!", 1);
        else
            en_o    <= '0';
            print(scope &": Clock is OFF!", 1);
        end if;
        
    end procedure;
    ------------------------------------------------------------------------------
    
    
end package body;