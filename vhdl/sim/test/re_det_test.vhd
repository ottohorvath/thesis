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


use work.tb_tc_pkg.all      ;   -- Includes for the 'tc' process.
----------------------------------------







package re_det_test
is

    -- Typedefs for IF signals for driving the DUT's inputs--
    
    type re_det_in_if_t   is record
    
        wr              :   std_logic;
        wdata           :   std_logic_vector(1 downto 0);
        signal_from_DUV :   std_logic;
        
    end record;
    --------------------------------------------------------
    
    constant    re_det_num_of_tcs_c    :   integer := 4;     -- Number of testcases
   
    signal      rtl_in_if           :   re_det_in_if_t     ;
    
    
    
    
    
    
    
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     re_det_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);        
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer     
    );
    --------------------------------------------------
    
    --------------------------------------------------
    -- The main test runner for RTL named 're_det'
    procedure   re_det_test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        signal      rtl_in_if       :   out     re_det_in_if_t ;   
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer    
    );
    --------------------------------------------------
    
    
    

    
    
    
end package;






package body re_det_test
is

    --------------------------------------------------
    procedure   re_det_test(    
        constant    rtl_name        :   in      string;    
        constant    super_name      :   in      string;    
            
        signal      rtl_in_if       :   out     re_det_in_if_t ;       
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id              :   out     integer    
    )is
        constant    this            :           string  :=  "re_det_test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        for id_v in 0 to (re_det_num_of_tcs_c - 1)   loop        
                    
            test(    rtl_name,scope,      id_v        , 
                                        rtl_in_if   ,
                                        clk         ,
                                        rst_req     ,
                                        cd          ,
                                        put_it      ,
                                        get_it      ,
                                        passed      ,
                                        id          );                                
        end loop;

    end procedure;
    --------------------------------------------------
   
    --------------------------------------------------
    procedure   test(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;
        
        constant    id_in           :   in      integer;
        
        signal      rtl_in_if       :   out     re_det_in_if_t ;
        signal      clk             :   in      std_logic     ;
        signal      rst_req         :   out     std_logic     ;
        
        signal      cd              :   out     check_descriptor_array (0 to check_no_max_c-1);
        
        
        signal      put_it          :   out     std_logic   ;
        signal      get_it          :   in      std_logic   ;
        signal      passed          :   in      std_logic   ;
        signal      id_out          :   out     integer    
    )is 
        
        
        
        
        constant    this            :           string  :=  "test";
        constant    scope           :           string  :=  super_name &"."& this;
    begin
        
        rtl_in_if.wr                    <= '0';
        rtl_in_if.signal_from_DUV       <= '0';
        rtl_in_if.wdata                 <= (others => '0');
        wait for 1 ns;
        
        id_out  <= id_in;

        
        banner(id_in);              -- Testcase banner
        
        
        case (id_in) is 
            -------------------------------------------------
            when 0  =>  init_check(id_in, "Checking the reset values", cd);
                        
                        rst_gen(scope, rst_req);    -- Reseting
                        
                        wait_re(clk);
            -------------------------------------------------
            when 1  =>  init_check(id_in, "Checking the disabled module: it should not be sensitive to signal changes", cd);            
                                    
                        rst_gen(scope, rst_req);    -- Reseting            
                                    
                        wait_re(clk);
                        rtl_in_if.signal_from_DUV   <= '0';
                        
                        wait_re(clk);
                        rtl_in_if.signal_from_DUV   <= '1';
                        
                        wait_re(clk);
                        rtl_in_if.signal_from_DUV   <= '0';
            -------------------------------------------------
            when 2  =>  init_check(id_in, "Checking the enabled module by generating a rising-edge event", cd);            
                                    
                        rst_gen(scope, rst_req);    -- Reseting            
                        ------------------------------------
                        -- Waiting for the next clock edge
                        wait_re(clk);
                        ------------------------------------
                        rtl_in_if.signal_from_DUV   <= '0';
                        rtl_in_if.wr                <= '1';
                        rtl_in_if.wdata             <= B"01";
                        wait_re(clk);
                        ------------------------------------
                        -- Signals are updated
                        rtl_in_if.wr                <= '0';
                        wait_re(clk);
                        ------------------------------------
                        -- The module no should be enabled
                        -- Now it can catch an event
                        rtl_in_if.signal_from_DUV   <= '1';           
                        wait_re(clk);
                        ------------------------------------
                        -- 'signal_from_DUV' is now updated
                        wait_re(clk);
                        ------------------------------------
                        -- The rising-edge detector's output
                        -- should be now '1'
                        wait_re(clk);
                        ------------------------------------
                        -- In this cycle, the module shall signal
                        -- the successful capture on its rdata output
             


            -------------------------------------------------
            when 3  =>  init_check(id_in, "Checking the clear of the module", cd);            
                                    
                        rst_gen(scope, rst_req);    -- Reseting            
                                    
                        wait_re(clk);
                        
                        rtl_in_if.signal_from_DUV   <= '0';
                        rtl_in_if.wr                <= '1';
                        rtl_in_if.wdata             <= B"01";
                        wait_re(clk);
                        
                        rtl_in_if.wr                <= '0';
                        rtl_in_if.signal_from_DUV   <= '0';           
                        wait_re(clk);
                        
                        rtl_in_if.signal_from_DUV   <= '1';

                        
                        rtl_in_if.wr                <= '1';
                        rtl_in_if.wdata             <= B"10";
                        wait_re(clk);
                        rtl_in_if.wr                <= '0';

            
                        
            -------------------------------------------------        
            when others =>
        end case;
            
        print(scope &": Stimulus generated ...", 1);
            
        put_it  <= not(put_it);     -- Signaled to 'chk' process    
        wait on get_it;             -- Waiting on the 'chk' process    
             

        
        log_check(id_in,cd, passed);
            
    end procedure;
    --------------------------------------------------
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    


end package body;