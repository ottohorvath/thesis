library ieee				;
library std                 ;
-----------------------------
use std.env.all             ;
use std.textio.all          ;
use ieee.numeric_std.all	;
use ieee.std_logic_1164.all	;
-----------------------------



------ Packages from "../packages/" ----
use work.tb_log_pkg.all ;
----------------------------------------


---------------------------------------------------------------------------------------------------------
package tb_report_pkg
is


    ----------- Declared objects for the package ------
    
    constant    check_no_max_c    :   integer     := 256;
    constant    logs_dir_c        :   string      := "../logs/rgr/";        -- Rel. path to the generated logs' directory
    
    
    constant    max_char_num_c   :   integer      := 256;
	---------------------------------------------------



   
    -- Typedefs -----------------------------------------------------------------------------------------
    
    type    boolean_array_t is 
        array (0 to check_no_max_c-1) of boolean;
    
    type check_descriptor_t is record                                   -- Struct for the checks:
        valid   : boolean           ;                                   --      ~ Is it enabled?        
        name    : string (1 to max_char_num_c);                        --      ~ The name of it
        dsrp    : string (1 to max_char_num_c);                        --      ~ Small description
        done    : boolean           ;                                   --      ~ Has it finished the checking?
        failed  : boolean           ;                                   --      ~ Has it failed?
    end record;                                  
    
    type check_descriptor_array is
        array (natural range <>) of check_descriptor_t;                --  An array from the structs
        
        
        

    signal  check_descriptor:  check_descriptor_array (0 to check_no_max_c-1) :=(
        (others =>
            (
                valid   =>  false   ,
                name    =>  padded_string(" ",max_char_num_c),
                dsrp    =>  padded_string(" ",max_char_num_c),
                done    =>  false   ,
                failed  =>  false   
            )
        )
    );    -- Check descriptor structure
    -----------------------------------------------------------------------------------------------------

    

    
    
    
    
    
    
    -- Generating a simple HTML-report file from the check descriptors and the ID.
	procedure gen_rgr_report_html(
        constant    super_name          :   in  string      ;   -- Scope of the caller procedure   
    
        constant    report_needed       :   in  integer     ;   -- These values are coming from 'tb_top' generics.
		constant    rtl_name            :   in	string      ;   --

		signal      check_descriptors   :	in  check_descriptor_array (0 to check_no_max_c-1)
	);
	
    
    

    
    
    
    procedure init_check(
        constant    id          :   in  integer ;
        constant    description :   in  string  ;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1)
    );
    
    procedure failed_check(
        constant    id          :   in  integer;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1)
    );
    
    
    
    procedure passed_check(
        constant    id          :   in  integer;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1)
    );
    
    
    procedure log_check(
        constant    id          :   in  integer;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1);
        constant    passed      :   in  std_logic
    );
    
    
    
    
    
    
    
    
end package;
---------------------------------------------------------------------------------------------------------






---------------------------------------------------------------------------------------------------------
package body tb_report_pkg
is

    

    
    
    
    
    --------------------------------------------------
    procedure init_check(
        constant    id          :   in      integer;
        constant    description :   in      string;
        signal      cd          :   out     check_descriptor_array (0 to check_no_max_c-1)
    )is
    begin
        
        cd(id).valid    <=  true;
        cd(id).name     <=  padded_string(str(id),max_char_num_c);
        cd(id).dsrp     <=  padded_string(description,max_char_num_c);
        
    end procedure;
    --------------------------------------------------
    
    
    
    
    
    
    --------------------------------------------------
    procedure failed_check(
        constant    id          :   in  integer;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1)
    )is
    begin
        
        cd(id).failed <= true;
        cd(id).done   <= true;
        
    end procedure;
    --------------------------------------------------
    
    
    
    
    --------------------------------------------------
    procedure passed_check(
        constant    id          :   in  integer;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1)
    )is
    begin
        
        cd(id).failed <= false;
        cd(id).done   <= true;
        
    end procedure;
    --------------------------------------------------
    
    procedure log_check(
        constant    id          :   in  integer;
        signal      cd          :   out check_descriptor_array (0 to check_no_max_c-1);
        constant    passed      :   in  std_logic
    )is
    begin
        
        if(passed = '1')    then
            passed_check(id, cd);
        else
            failed_check(id,cd);
        end if;
        
    end procedure;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
   --------------------------------------------------
    procedure gen_rgr_report_html (
        constant    super_name          :       in  string  ;
        constant    report_needed       :       in  integer ;
        constant    rtl_name            :       in	string  ;
        
		signal      check_descriptors   :	    in  check_descriptor_array (0 to check_no_max_c-1)
    )is
        constant    this                        :   string  :=  "gen_rgr_report_html";
        constant    scope                       :   string  :=  super_name &"."& this;
        
        
		variable    checks_done                 :	natural := 0;
		variable    checks_failed               :   natural := 0;
		variable    checks_skipped              :   natural := 0;
        
        file        regression_report_html_file :   text;
        variable    fopen_status                :   file_open_status;
        variable    line_buffer                 :   line;
    begin
        
        wait for 1 ns;          -- Waiting some time because of the behaviour of the signals ...
        
        -- If report is needed
        if (report_needed /= 0) then
        
        
            -- Opening HTML file for collecting the results
            file_open(
                fopen_status,
                regression_report_html_file,
                logs_dir_c & rtl_name & ".html",
                write_mode
            );
            
            -- If the file couldn't be opened
            if (fopen_status /= open_ok)    then
--                write(output,"***ERROR***: The '"& logs_dir_c & rtl_name & ".html" & "' could not be opened." & CR);
                print(scope &": ***ERROR***: The '"& logs_dir_c & rtl_name & ".html' could not be opened.");
                stop;
            end if;
            
            print(scope &": Processing the check descriptor ...");
            
            -- Process check descriptors
            for i in 0 to check_no_max_c-1 loop
                if ( check_descriptors(i).valid = true ) then
                    
                    if ( check_descriptors(i).done = true ) then
                        checks_done := checks_done + 1;
                    else
                        checks_skipped := checks_skipped + 1;
                    end if;
                    
                    if ( check_descriptors(i).failed = true ) then 
                        checks_failed := checks_failed + 1; 
                    end if;
                    
                end if;
            end loop;
            
            print(scope &": Generating HTML report ...");
            
            -- Generate HTML output with regression test results
            write(line_buffer, 
            string'(" <!DOCTYPE html><html lang=""en-US""><style type=""text/css"">.fail {color: #ff0000;}.pass {color: #86c500;}.skip {color: #00c3ff}.skip_blue {color: #00c3ff}table#tests {font-size:1.2em;font-family: 'Roboto';border-collapse: collapse;border-spacing: 0;/*width: 100%;*/}table#summary {font-size:1.4em;font-family: 'Roboto';border-collapse: collapse;border-spacing: 0;font-weight: bold;vertical-align: left;}#tests td,#tests th {text-align: left;border: 2px solid black;}#summary th, #summary td {width: 100px;text-align: left;}#tests tr:hover {background-color: #dddddd}td.bigger {padding: 5px 10px 5px 10px;font-size:1.5em;}.container{float:left}#piechart{float:left}</style><title>Test results for "));
            writeline(regression_report_html_file, line_buffer);
            
            write(line_buffer, rtl_name);
            writeline(regression_report_html_file, line_buffer);
            
            write(line_buffer, string'("</title><body><h1>Test results for "));
            writeline(regression_report_html_file, line_buffer);
            
            write(line_buffer, rtl_name);
            writeline(regression_report_html_file, line_buffer);
            
            write(line_buffer, string'("</h1><div id=""piechart""></div><script type=""text/javascript"" src=""https://www.gstatic.com/charts/loader.js""></script><script type=""text/javascript"">google.charts.load('current', {'packages':['corechart']});google.charts.setOnLoadCallback(drawChart);"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'("function drawChart() {var data = google.visualization.arrayToDataTable([['Check', 'Num'],['Failed',"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_failed);
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'(",],['Passed',"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_done - checks_failed);
            writeline(regression_report_html_file, line_buffer);
            
            write(line_buffer, string'("],['Skipped',"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_skipped);
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'("],]);var options = {'title':'', 'width':550, 'height':400,is3D: true, colors:['#ff0000','#86c500','#00b6ff'], fontSize:[16]};var chart = new google.visualization.PieChart(document.getElementById('piechart'));chart.draw(data, options);}</script>"));
            writeline(regression_report_html_file, line_buffer);
            
            
            
            
            
            
            -- Table generating --
            
            
            write(line_buffer, string'("<div class=""container""><table id=""summary""><tr><th>Total tests</th><th>Done</th><th class=""skip_blue"">Skipped</th><th class=""pass"">Passed</th><th class=""fail"">Failed</th></tr><tr><td class=""bigger"">"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_done + checks_skipped);
            writeline(regression_report_html_file, line_buffer);
            
            
            
            write(line_buffer, string'("</td><td class=""bigger"">"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_done);
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'("</td><td class=""bigger skip_blue"">"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_skipped);
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'("</td><td class=""bigger pass"">"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_done - checks_failed);
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'("</td><td class=""bigger fail"">"));
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, checks_failed);
            writeline(regression_report_html_file, line_buffer);
            
            
            write(line_buffer, string'("</td></tr><table id=""tests""><tr><th>Check ID</th><th>Description</th></tr>"));
            writeline(regression_report_html_file, line_buffer);
            
            for i in 0 to check_no_max_c-1 loop
                if ( check_descriptors(i).valid = true ) then
                    if ( check_descriptors(i).failed = true ) then
                        write(line_buffer, string'("<tr class=""fail""><td>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, check_descriptors(i).name);
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, string'("</td><td>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, check_descriptors(i).dsrp);
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, string'("</td></tr>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                    elsif ( check_descriptors(i).done = false ) then
                        write(line_buffer, string'("<tr class=""skip_blue""><td>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, check_descriptors(i).name);
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, string'("</td><td>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, check_descriptors(i).dsrp);
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, string'("</td></tr>"));
                        writeline(regression_report_html_file, line_buffer);
                    else
                        write(line_buffer, string'("<tr class=""pass""><td>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, check_descriptors(i).name);
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, string'("</td><td>"));
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, check_descriptors(i).dsrp);
                        writeline(regression_report_html_file, line_buffer);
                        
                        
                        write(line_buffer, string'("</td></tr>"));
                        writeline(regression_report_html_file, line_buffer);
                    end if;
                    
                end if;
            end loop;
            
            write(line_buffer, string'("</table></div></body></html>"));
            writeline(regression_report_html_file, line_buffer);
            
            
            print(scope &": Done!");
            
            
            
            file_close(regression_report_html_file);    -- Closing the HTML file
		
        end if;
        
        
    end procedure;
    
end package body ;


