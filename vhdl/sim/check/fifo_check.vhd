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



    signal      rtl_out_if  :   fifo_out_if_t    ;


    --------------------------------------------------
    -- The main test runner for RTL named 'wtf'
    procedure   fifo_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_out_if      :   in      fifo_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;

        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer
    );
    --------------------------------------------------





end package;



package body fifo_check
is

    --------------------------------------------------
    -- The main checker for RTL named 'wtf'
    procedure   fifo_check(
        constant    rtl_name        :   in      string;
        constant    super_name      :   in      string;

        signal      rtl_out_if      :   in      fifo_out_if_t    ;
        signal      tb_if           :   in      tb_if_t         ;

        signal      put_it          :   in      std_logic   ;
        signal      got_it          :   out     std_logic   ;
        signal      passed          :   out     std_logic   ;
        signal      id              :   in      integer
    )is

        variable    i               :           integer :=  0;
        variable    ipp             :           integer :=  0;

        
        variable    noc             :           integer :=  0;   -- Num of checks per Test ID

        constant    this            :           string  :=  "fifo_check";
        constant    scope           :           string  :=  super_name &"."& this;
                ---------------------------------------------------------------------------------------------------
        ---------------------------------------------------------------------------------------------------
        variable    errors          :           integer :=  0;
        
        procedure   check(
            constant    exp :   in  std_logic;
            constant    act :   in  std_logic;
            constant    num :   in  integer
        )
        is
        begin
            
            if(exp /= act)  then
                perror(scope&"."&str(num),  str(exp),   str(act) );
                errors := errors + 1;
            end if;
            
        end procedure;
        
        procedure   check(
            constant    exp :   in  std_logic_vector;
            constant    act :   in  std_logic_vector;
            constant    num :   in  integer
        )
        is
        begin
            if(exp /= act)  then
                perror(scope&"."&str(num),  str(exp),   str(act) );
                errors := errors + 1;
                
                
                
            end if;
        end procedure;
        ---------------------------------------------------------------------------------------------------
        ---------------------------------------------------------------------------------------------------
    begin

        passed  <= '0';     

        errors := 0;                -- Initializing error indicator

        case (id)   is
            -------------------------------------------------

            when    0   =>  wait on put_it;             -- Waiting on the 'tc' process

                            
                                -- EXP   -- ACT
                            check('0',  rtl_out_if.full,      0);
                            check('1',  rtl_out_if.empty,     1);
                            
                            
                            -- Signalling back to the 'tc' process
--                            got_it  <= not(got_it);
            -------------------------------------------------
            when    1   =>  wait on put_it;             -- Waiting on the 'tc' process

                                    -- EXP          -- ACT
                            --check(x"00000001",  rtl_out_if.rdata,       0);
                            check('0',          rtl_out_if.full,        1);
                            check('0',          rtl_out_if.empty,       2);
    
    
    
                            -- Signalling back to the 'tc' process
 --                           got_it  <= not(got_it);      
            -------------------------------------------------
            when    2   =>  wait on put_it;             -- Waiting on the 'tc' process

                            
                            
                            
                            


--                            got_it  <= not(got_it);      -- Signalling back to the 'tc' process


            -------------------------------------------------
            when    3   =>  wait on put_it;             -- Waiting on the 'tc' process


                            loop
                                -- Looping until the FIFO is full
                                -- Test process is responsible for read out the
                                -- contents of it

                                ----------------------------------
                                if rtl_out_if.empty = '1'    then

                                    got_it  <=  '1'; 
                                    exit;

                                end if;
                                ----------------------------------
                                got_it  <= '0';
                                wait on put_it;

                            end loop;

                            -----------------------
                            -----------------------
                            wait on put_it;
                            -----------------------
                            -----------------------
                            
                            
                            
                            -- Just checking if the 'full' flag is popped out
                                -- EXP   -- ACT
                            check('1',  rtl_out_if.full,      0);
                            
                            
                            got_it <= not got_it;
                            wait on put_it;
                            -----------------------
                            -----------------------
                            i   := 0;
                            ipp := 1;
                            for i in 0 to DEPTH_C-1 loop

                                    -- EXP                                              -- ACT
                                check(std_logic_vector(to_unsigned(ipp,DWIDTH_C)),  rtl_out_if.rdata,      1);
                            
                                ----------------------------------------------------------
                                got_it  <= not(got_it);     -- Signalling back to the 'tc' process
                                wait on put_it;             -- Waiting on the 'tc' process
                                ----------------------------------------------------------

                                ipp := ipp + 1;
                            end loop;


--                            got_it  <= not(got_it);      -- Signalling back to the 'tc' process
                            
                            




            -------------------------------------------------
            when others =>
        end case;




        -------------------------------------
        if( errors /= 0) then
            passed <= '0';  
            wait for 1 ps;
            test_result(id, "failed");
        else
            passed <= '1';
            wait for 1 ps;
            test_result(id, "passed");
        end if;
        -------------------------------------

        got_it  <= not(got_it);


    end procedure;
    --------------------------------------------------


end package body;