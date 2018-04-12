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
    --------------------------------------------------



    ----------- Declared objects for the package ------

    constant    clk_per_c   :   time    := 10 ns;       -- Clock period used across the testbench.

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

    function slv(
        N: natural;
        B: integer
    )   return std_logic_vector;



    type synchronizer_t is protected
        ----------------------------------------
        -- Used from 'tc' process
        procedure       init(
            constant id: in integer
        );
        impure function get_passed      return std_logic;
        impure function get_chk_done    return bit;
        impure function get_caught      return bit;
        procedure       set_chk_enabled(
            variable    val:    bit
        );

        ----------------------------------------
        -- Used from 'chk' process
        procedure       set_caught( val: in bit);
        procedure       check_done;
        procedure       set_chk_done(
            variable    val:    bit
        );
        procedure       compare(
            constant    exp :   in  std_logic;
            constant    act :   in  std_logic
        );

        procedure       compare(
            constant    exp :   in  std_logic_vector;
            constant    act :   in  std_logic_vector
        );

        procedure       compare(
            constant    exp :   in  integer;
            constant    act :   in  integer
        );

        procedure       assertion(
            constant    expression: in  boolean
        );

        impure function get_chk_enabled return bit;
        impure function get_tc_id       return integer;

        ----------------------------------------
    end protected synchronizer_t;







end package;



package body tb_utils_pkg is

    type synchronizer_t is protected body

        variable    tc_id           :   integer;

        variable    chk_error_cntr  :   integer :=  0;
        variable    chk_compare_cntr:   integer :=  0;
        variable    chk_assertion_cntr: integer :=  0;

        variable    caught          :   bit     :=  '0';

        variable    chk_done        :   bit;
        variable    chk_enabled     :   bit;
        -----------------------------------------
        -----------------------------------------
        -----------------------------------------

        impure function get_chk_done
            return bit
        is
        begin
            return chk_done;
        end function;
        -----------------------------------------
        procedure       set_chk_enabled(
            variable    val:    bit
        )is
        begin
            chk_enabled := val;
        end procedure;
        -----------------------------------------
        procedure       set_chk_done(
            variable    val:    bit
        )is
        begin
            chk_done := val;
        end procedure;
        -----------------------------------------
        impure function get_caught
            return bit
        is
        begin
            return caught;
        end function;
        -----------------------------------------
        impure function get_chk_enabled
            return bit
        is
        begin
            return chk_enabled;
        end function;
        -----------------------------------------
        impure function get_tc_id
            return integer
        is
        begin
            return tc_id;
        end function;
        -----------------------------------------
        impure function get_passed
            return std_logic
        is
            variable ret:   std_logic;
        begin
            if(chk_error_cntr = 0)  then
                ret :=  '1';
            else
                ret :=  '0';
            end if;

            return ret;
        end function;
        -----------------------------------------
        procedure       init(
            id: in integer
        )is
        begin
            tc_id               :=  id;
            chk_error_cntr      :=  0;
            chk_compare_cntr    :=  0;
            chk_assertion_cntr  :=  0;
            --At initialization, disable checking
            chk_enabled         :=  '0';
        end procedure;
        -----------------------------------------
        procedure   set_caught( val: in bit)
        is
        begin
            caught    := val;
        end procedure;
        -----------------------------------------
        procedure   check_done  is
        begin
            chk_done    := '1';
        end procedure;
        -----------------------------------------
        -----------------------------------------
        -----------------------------------------
        procedure       compare(
            constant    exp :   in  std_logic;
            constant    act :   in  std_logic
        ) is
        begin
            if(exp /= act)  then
                work.tb_log_pkg.perror(
                    CR &
                    CR &
                    "****[ERROR]****"               & CR &
                    "   Comparison  #"& str(chk_compare_cntr),
                    str(exp),
                    str(act)
                );

                chk_error_cntr := chk_error_cntr + 1;
            end if;


            chk_compare_cntr := chk_compare_cntr + 1;
        end procedure;
        -----------------------------------------
        procedure       compare(
            constant    exp :   in  std_logic_vector;
            constant    act :   in  std_logic_vector
        ) is
        begin
            if(exp /= act)  then
                -- Print error to stdout
                work.tb_log_pkg.perror(
                    CR &
                    CR &
                    "****[ERROR]****"               & CR &
                    "   Comparison  #"& str(chk_compare_cntr),
                    str(exp),
                    str(act)
                );

                chk_error_cntr := chk_error_cntr + 1;
            end if;

            -- Increasing comparsion counter
            chk_compare_cntr := chk_compare_cntr + 1;
        end procedure;
        -----------------------------------------
        procedure       compare(
            constant    exp :   in  integer;
            constant    act :   in  integer
        ) is
        begin
            if(exp /= act)  then
                -- Print error to stdout
                work.tb_log_pkg.perror(
                    CR &
                    CR &
                    "****[ERROR]****"               & CR &
                    "   Comparison  #"& str(chk_compare_cntr),
                    str(exp),
                    str(act)
                );

                chk_error_cntr := chk_error_cntr + 1;
            end if;

            -- Increasing comparsion counter
            chk_compare_cntr := chk_compare_cntr + 1;
        end procedure;
        -----------------------------------------
        procedure       assertion(
            constant    expression: in  boolean
        )is
        begin
            if(expression = false)  then
                -- Print error to stdout
                work.tb_log_pkg.perror(
                    CR &
                    CR &
                    "****[ERROR]****"               & CR &
                    "   Assertion   #" & str(chk_assertion_cntr),
                    "True",
                    "False"
            );
            
                chk_assertion_cntr := chk_assertion_cntr + 1;
            end if;
        end procedure;
        -----------------------------------------
    end protected body synchronizer_t;


















    ------------------------------------------------------------------------------
    -- std_logic input
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
    -- integer input
    function slv(
        N:      natural;
        B:      integer
    )   return  std_logic_vector
    is
        variable result: std_logic_vector(N-1 downto 0);
    begin
        
        result :=   std_logic_vector(to_unsigned(B,N));

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