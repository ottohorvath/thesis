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



package tb_log_pkg  is

    constant    verbose_c       :   boolean := true;

    --------------------------------------------------
    procedure info(
        constant    str: in  string
    );
    --------------------------------------------------
    procedure print(                                    -- String input
        constant    str     :   in  string      ;
        constant    sim_time:   in  integer := 0
    );
    --------------------------------------------------
    procedure banner(
        constant    tc_id: in  integer
    );
    --------------------------------------------------
    procedure test_result(
        constant    id  :   in  integer;
        constant    res :   in  string
    );
    --------------------------------------------------

    procedure welcome_msg(
        constant    tb_name:    in  string
    );

    --------------------------------------------------

    procedure exit_msg;

    --------------------------------------------------

    function str(
        int    :   integer
    )   return      string;

    function str(
        sl      :   std_logic
    )   return      string;

    function str(
        slv     :   std_logic_vector
    )   return      string;




    -- Padding a string with white-spaces
    function padded_string(
        s   :   string;                                         -- Source string
        n   :   positive                                        -- Length of the Padded string
    )   return  string;                                         -- Returning the Padded string



    procedure perror(
        constant    name:   in  string;
        constant    exp:    in  string;
        constant    act:    in  string
    );








end package;


















package body tb_log_pkg is

    ------------------------------------------------------------------------------
    procedure info(
        constant    str :   in  string
    )is
    begin
        if(verbose_c = true) then
            write(output,   to_string(now) &" -- INFO --: "& str & CR);
        end if;
    end procedure;

    ------------------------------------------------------------------------------
    procedure print(
        constant    str     :   in  string  ;
        constant    sim_time:   in  integer := 0
    )is
    begin
        if(sim_time = 1)    then
            write(output,   to_string(now) &": "& str & CR);
        else
            write(output,   str & CR);
        end if;
    end procedure;
    ------------------------------------------------------------------------------
    procedure banner(
        constant    tc_id: in  integer
    )is
    begin

        print( CR &"Testcase "& to_string(tc_id) );
        print("============");

    end procedure;

    ------------------------------------------------------------------------------
    procedure test_result(
        constant    id  :   in  integer;
        constant    res :   in  string
    )is
    begin
        if(res = "passed")   then
            print("");
            print("Testcase "& to_string(id) &" PASSED!");
            print("");
        elsif(res = "failed")   then
            print("");
            print("Testcase "& to_string(id) &" FAILED!");
            print("");
        end if;
    end procedure;

    ------------------------------------------------------------------------------
    procedure welcome_msg(
        constant    tb_name:    in  string
    )is
    begin
        print("");
        print("=====================================================");
        print("              Start of the Simulation       ");
        print("=====================================================");
        print("");
        print("RTL name: '"&tb_name &"'");
        print("");
    end procedure;

    ------------------------------------------------------------------------------
    procedure exit_msg   is
    begin
        print("");
        print("=====================================================");
        print("              End of the Simulation       ");
        print("=====================================================");
        print("");
    end procedure;
    ------------------------------------------------------------------------------
    function str(
        int     :   integer
    )   return      string
    is
    begin

        return to_string(int);

    end function;
    ------------------------------------------------------------------------------
    function str(
        sl     :    std_logic
    )   return      string
    is
    begin

        return "0b" & to_string(sl);

    end function;
    ------------------------------------------------------------------------------
    function str(
        slv    :    std_logic_vector
    )   return      string
    is
    begin

        return "0x" & to_hstring(slv);

    end function;



    --------------------------------------------------
    function padded_string(
        s       :   string;                                     -- Source string
        n       :   positive                                    -- Length of the Padded string
    )   return      string                                      -- Returning the Padded string
    is
        variable    ps  :   string(1 to n) := (others => ' ');  -- Variable for the Padded string
    begin
        if s'length >= n then                                   -- If the Source is longer than the Padded
            ps := s(1 to n);                                    -- Then truncate the Source

        else                                                    -- If the Source is shorter then the Padded
            ps(1 to s'length)   := s;                           -- Begin the Padded with the Source
            ps(s'length+1 to n) := (others => ' ');             -- And append whitespaces to the end

        end if;

        return ps;                                              -- Return the Padded string
    end function;
    --------------------------------------------------




    procedure perror(
        constant    name:   in  string;
        constant    exp:    in  string;
        constant    act:    in  string
    ) is

    begin
        print(name & CR&
                            "       Expected    = "&exp & CR &
                            "       Actual      = "&act & CR    ,1);
    end procedure;




















end package body;