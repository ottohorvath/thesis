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
        rstn_req:   std_logic;
    end record;
    
    
    type p_hs_t     is record
        put_it  :   std_logic;   
        got_it  :   std_logic;   
        passed  :   std_logic;
        id      :   integer  ; 
    end record;
    
    --------------------------------------------------
    
    
    
    ----------- Declared objects for the package ------
    
    constant    clk_per_c   :   time    := 10 ns;       -- Clock period used across the testbench.
    
    signal      tb_if       :   tb_if_t :=(             --
        clk     =>  '1',                                --
        clk_en  =>  '0',                                -- Testbench resouce related signals.
        rstn    =>  '1',                                 --
        rstn_req=>  '0'
    );                                                  --
    
    signal p_handshake      :   p_hs_t  :=(             --
        put_it  =>  '0',                                --
        got_it  =>  '0',                                -- Handshake signals between the two main process
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
        signal      rst_req         :   out     std_logic   --
    );                                                      --
   
    --------------------------------------------------
    procedure   clk_gen(                                    --
        constant    super_name      :   in      string;     --
                                                            -- Clock generating procedure: enabling the 'clk_gen'
        variable    en_in_v         :   in      std_logic;  -- concurrent assignment in '<RTL>_tb'.
        signal      en_o            :   out     std_logic   --
    );
    
    --------------------------------------------------      --
    function slv(    
        N: natural; 
        B: std_logic
    )   return std_logic_vector;                            -- Replacate std_logic-s to slv, like Verilog's replicate {32{1b1}} operator
        
    
    
    
    
    
    
    
    
    
    
    
end package;























package body tb_utils_pkg is

    ------------------------------------------------------------------------------
    function slv(
        N:      natural;
        B:      std_logic
    )   return  std_logic_vector
    is
        variable result: std_logic_vector(1 to N);
    begin
        for i in 1 to N loop
            result(i) := B;
        end loop;
        
        return result;
    end;
    ------------------------------------------------------------------------------
    
    
    
    
    
    
    
    
    
    
    
    
    
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
        
        signal      rst_req     :   out     std_logic
    )is
        constant    this        :           string  :=  "rst_gen";
        constant    scope       :           string  :=  super_name &"."& this;
    begin
    

        rst_req <= '1';
        
        wait for 1 ns;
        
        rst_req <= '0';
        
        wait for 1 ns;
        
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