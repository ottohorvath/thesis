import os
import subprocess
import sys


#==============================================================
#
# ***NOTE***:  Only VHDL and QuestaSim support is implemented!
# ===========
#
#
#=============================================================


#===========================================================================================================
# Global variables

# Used file extension
file_ext            =   ".vhd"                  # VHDL file extension

# 'vsim' args
rtl_ver             =   "-93"                   # VHDL version for RTL compilation
tb_ver              =   "-2008"                 # VHDL version for TB compilation
sim_resolution      =   "ps"                    # Simulation resolution time unit

# RTLs
rtl_src_dir         =   "../../logical/"        # Rel. path to the RTL source files

# Testbenches
tbench_src_dir      =   "../tbench/"            # Rel. path to testbenches
tbench_suffix       =   "_tb"                   # Suffix of the testbench files For example: <RTL>_tb.vhd
tbench_pkg_src_dir  =   "../tbench_pkg/"         # Rel. path to testbench utils

# Tests
test_src_dir        =   "../test/"              # Rel. path to testcases related packages
test_suffix         =   "_test"                 # Suffix of the testcase package files. For example: <RTL>_test.vhd

# Checks
check_src_dir       =   "../check/"             # Rel. path to packages containing the checks of the appropriate testcase
check_suffix        =   "_check"                # Suffix of the check package files. For example: <RTL>_check.vhd

# Misc
comp_output_dir     =   "../work/"              # Rel. path to the output dir. of the compilation
log_dir             =   "../logs/"              # Rel. path to the directory of the generated log files
rgr_log_dir         =   log_dir + "rgr/"        # Rel. path to the directory of the generated log files in regression
gui_log_dir         =   log_dir + "gui/"        # Rel. path to the directory of the generated log files in GUI mode
cli_log_dir         =   log_dir + "cli/"        # Rel. path to the directory of the generated log files in CLI
comp_log            =   "vcom_log.log"          # Name of the log with compilation results
ccov_dir            =   "../coverage/"          # Rel. path to where the result of CCov will be placed
#===========================================================================================================




def print_welcome_msg():
    """
    Description:    ~ This function is just printing a welcome message on the console
                      and the name of the python file in the first sentence.

    Arguments:      ~ No arguments.

    Returning:      ~ No return value.
    """

    # Welcome message
    print("""

===========================================================================================================

    You are running '""" + os.path.basename(sys.argv[0]) + """'!

        The script is responsible for running the regression or simulating one self-checking testbench.

        To run regression, type the following:
            -all <ENTER>

        To run a testbench, issue the following:
            -sim=<VHDL RTL entity name> [-gui] <ENTER>

===========================================================================================================

    """)


def print_exit_msg():
    """
    Description:    ~ This function is just printing a message on the console
                      and and the results of the regression. Also waits on the user to input something.

    Arguments:      ~ No arguments.

    Returning:      ~ No return value.
    """
    # Concluding message.
    print("""

===========================================================================================================

    The regression has been finished!

        =>  Compilation log is here '"""+ rgr_log_dir + comp_log +"""'

        =>  Simulation logs and HTML report are under '"""+ rgr_log_dir +"""<tb_name>_log.log & <rtl_name>.html'

        =>  Codecoverage logs are under '"""+ ccov_dir +"""<tb_name>_ccov/index.html'

===========================================================================================================

Press ENTER to finish ...
    """)

    #Leaving some time for reading the concluding text.
    input()


def is_rtl_src_present(rtl_src_dir, rtl_name):
    """
    Description:    ~ This function is checking the presence of the RTL source file for the
                      entity named 'rtl_name'.

    Arguments:      ~ rtl_name:         String containing the entity name.
                    ~ rtl_src_dir:      String containing the relative path to the RTL source files.

    Returning:      ~ 1 upon success, namely the corresponding RTL source 'rtl_name+file_ext' is present.
                    ~ 0 otherwise.
    """

    if not rtl_name:                        # If 'rtl_name' is omitted
        return 0                            # Then return with error


    rtl_files   = os.listdir(rtl_src_dir)   # Gathering files from here


    rtl_found   = 0                         #
    rtl_file    = rtl_name + file_ext       #
                                            # Iterating over the RTL source files.
    if rtl_file in rtl_files:               #
        rtl_found = 1                       #


    return rtl_found                        # Result of the search.


def is_tbench_src_present(tbench_src_dir, rtl_name, tbench_suffix):
    """
    Description:    ~ This function is checking the presence of the testbench source file for the
                      entity named 'rtl_name'.

    Arguments:      ~ rtl_name:             String containing the entity name.
                    ~ tbench_src_dir:       String containing the relative path to the testbench source files.
                    ~ tbench_suffix:        String containing an arbitrary suffix for checking.

    Returning:      ~ 1 upon success, namely the corresponding testbench source 'rtl_name+tbench_suffix+file_ext' is present.
                    ~ 0 otherwise.
    """

    if not rtl_name:                                        # If 'rtl_name' is omitted
        return 0                                            # Then return with error


    tbench_files    = os.listdir(tbench_src_dir)            # Gathering files from here.

                                                            #
    tbench_found    = 0                                     #
    tbench_file     = rtl_name + tbench_suffix + file_ext   # Iterating over the test files.
                                                            #
    if tbench_file in tbench_files:                         #
        tbench_found = 1                                    #


    return tbench_found                                     # Result of the search.


def is_test_src_present(test_src_dir, rtl_name, test_suffix):
    """
    Description:    ~ This function is checking the presence of the corresponding testcase source file.
                      The source file should be named like so:
                        'rtl_name+test_suffix+file_ext'

    Arguments:      ~ rtl_name:         String containing the entity name.
                    ~ tests_dir:        String containing the relative path to the test files.
                    ~ test_suffix:      String containing an arbitrary suffix for checking.

    Returning:      ~ 1 upon success, namely the corresponding testcase package file 'rtl_name+suffix+file_ext' is present.
                    ~ 0 otherwise.
    """


    if not rtl_name:                                # If 'rtl_name' is omitted
        return 0                                    # Then return with error


    test_files  = os.listdir(test_src_dir)          # Gathering files from here.

                                                    #
    test_found  = 0                                 #
    test_file   = rtl_name + test_suffix + file_ext # Iterating over the test files.
                                                    #
    if test_file in test_files:                     #
        test_found = 1                              #


    return test_found                               # Result of the search.


def is_check_src_present(check_src_dir, rtl_name, check_suffix):
    """
    Description:    ~ This function is checking the presence of the corresponding checker file.
                      The source file should be named like so:
                        'rtl_name+check_suffix+file_ext'

    Arguments:      ~ rtl_name:         String containing the entity name.
                    ~ check_src_dir:    String containing the relative path to the check files.
                    ~ check_suffix:     String containing an arbitrary suffix for checking.


    Returning:      ~ 1 upon success, namely the corresponding check package file 'rtl_name+check_suffix+file_ext' is present.
                    ~ 0 otherwise.
    """

    if not rtl_name:                                        # If 'rtl_name' is omitted
        return 0                                            # Then return with error



    check_files     = os.listdir(check_src_dir)             # Gathering files from here.


    check_found     = 0                                     #
    check_file      = rtl_name + check_suffix + file_ext    #
                                                            # Iterating over the check package files.
    if check_file in check_files:                           #
        check_found = 1                                     #


    return check_found                                      # Result of the search.


def create_lib_and_map(dest_dir):

    if os.path.exists(dest_dir):                                # Remove destination folder first
        os.system("rm -rf "+ dest_dir)                          #


    subprocess.call("vlib       " + dest_dir , shell = False)   # Create library
    subprocess.call("vmap  work " + dest_dir , shell = False)   # And map 'work' to it


def compile_tb_packages(pkg_src_dir, log_file):

    # Just the packages
    subprocess.call("vcom -just p   " + tb_ver + "  -work work " + pkg_src_dir + "*" + file_ext , shell = False, stdout = log_file)

    subprocess.call("echo "" ",shell = False, stdout=log_file)   # New line, make the log breezy

    # Then the corresponding bodies
    subprocess.call("vcom -just pb  " + tb_ver + "  -work work " + pkg_src_dir + "*" + file_ext , shell = False, stdout = log_file)

    subprocess.call("echo "" ",shell = False, stdout=log_file)   # New line, make the log breezy


def compile_rtl_files(src_dir, log_file):

    # First the entities
    subprocess.call("vcom -just e   " + rtl_ver +" -lint   -work work " + src_dir + "*" + file_ext, shell = False, stdout = log_file)

    subprocess.call("echo "" ",shell = False, stdout=log_file)   # New line, make the log breezy

    # Then the architectures
    subprocess.call("vcom -just a   " + rtl_ver +" -lint   -work work " + src_dir + "*" + file_ext, shell = False, stdout = log_file)

    subprocess.call("echo "" ",shell = False, stdout=log_file)   # New line, make the log breezy


def compile_one_tb_src(tb_src_dir, name, log_file):

    # Compile one testbench related source file
    subprocess.call("vcom      "+ tb_ver +" -work work  " + tb_src_dir + name + file_ext, shell = False, stdout=log_file)

    subprocess.call("echo "" ",shell = False, stdout=log_file)   # New line, make the log breezy


def compile_tb_files(tb_src_dir, log_file):

    # Compile one testbench related source file
    subprocess.call("vcom      "+ tb_ver +" -work work  " + tb_src_dir + "*" + file_ext, shell = False, stdout=log_file)

    subprocess.call("echo "" ",shell = False, stdout=log_file)   # New line, make the log breezy


def vopt_for_sim(tb_name, rtl_name):

    subprocess.call('vopt '+ tb_name +' -o '+ tb_name +'_opt'       +   # Optimizing the testbench, visiblity here in CLI is not needed
                    ' -G RTL_NAME_G=\"'+ rtl_name+'\"'              +   # RTL name in string
                    ' -G CLI_G=1'                                   +   # Command line interface is used
                    ' -G GUI_G=0'                                   +   # GUI is not used
                    ' -G RGR_G=0'                                       # For one simulation, the regression indicator parameter is set to zero
                    , shell = False,)


def vopt_for_sim_gui(tb_name, rtl_name):

    subprocess.call('vopt +acc '+ tb_name +' -o '+ tb_name +'_opt '  +   # In case of GUI, full visiblity might be useful for debugging purposes, that's why +acc is added
                    ' -G RTL_NAME_G=\"'+ rtl_name+'\"'              +   # RTL name in string
                    ' -G CLI_G=0'                                   +   # Command line interface is used
                    ' -G GUI_G=1'                                   +   # GUI is used
                    ' -G RGR_G=0'                                       # For one simulation, the regression indicator parameter is set to zero
                    , shell = False,)


def vsim_for_sim(tb_name, log_file):

    subprocess.call('vsim -batch -t 1'+sim_resolution               +   # Starting Questa in CLI and setting the simulation time resolution
                    ' -do "run -all; quit;"'                        +   # Run until it is not finished
                    ' -default_radix hexadecimal'                   +   # Setting default radix
                    ' -logfile "'+log_file+tb_name+'_log.log"'      +   # Specifing the simulation log files
                    ' work.'+tb_name+'_opt'                             # Load in the optimized testbench
                    , shell = False)


def vsim_for_sim_gui(tb_name, log_file):

    subprocess.call('vsim -t 1'+sim_resolution                                  +   # Starting Questa in GUI and setting the simulation time resolution
                    ' -do "set NoQuitOnFinish 1; log -r /*;'                    +   # Recursively log all signals for easier Waveform debugging
                    ' add wave -position insertpoint sim:/cntr_tb/sync_sv;'     +   # Add shared variable to waveform before simulation is started to be able to see its content
                    ' add wave -position insertpoint sim:/'+tb_name+'/L_DUT/*;' +   # Open up and add DUT signals to the waveform
                    ' run -all;"'                                               +   
                    ' -default_radix hexadecimal'                               +   # Setting default radix
                    ' -logfile "'+log_file+tb_name+'_log.log"'                  +   # Specifing the simulation log files
                    ' work.'+tb_name+'_opt '                                        # Load in the optimized testbench
                    , shell = False)


def run_sim(rtl_name):
    """
    Description:    ~ This function runs one self-checking testbench in CLI.

    Arguments:      ~ The name of the RTL file/entity which will be simulated.

    Returning:      ~ None, creating log files
    """


    create_lib_and_map(comp_output_dir)                             # Create a library and map it to Questa

    if not os.path.exists(cli_log_dir):                             # Check if there is an existing directory
        os.mkdir(cli_log_dir)                                       # Otherwise, make one

    vcom_log = open(cli_log_dir + rtl_name + "_" + comp_log ,'w')   # Logging into separate compilation log file

    compile_tb_packages(tbench_pkg_src_dir, vcom_log)               # Compiling TB framework related packages
    compile_tb_packages(test_src_dir,       vcom_log)               # Packages containing tests
    compile_tb_packages(check_src_dir,      vcom_log)               # Packages containing checks

    compile_rtl_files(rtl_src_dir,  vcom_log)                       # Compile all the RTLs

    tbench_name = rtl_name + tbench_suffix                          # Testbench is named <RTL>_tb
    compile_one_tb_src(tbench_src_dir,tbench_name, vcom_log)        # Compile <RTL>_tb

    vopt_for_sim(tbench_name, rtl_name)                             # Optimizing the testbench and passing values to the toplevel generics

    vsim_for_sim(tbench_name, cli_log_dir)                          # Run simulation


def run_sim_gui(rtl_name):
    """
    Description:    ~ This function runs one self-checking testbench in GUI (QuestaSim).

    Arguments:      ~ The name of the RTL file/entity which will be simulated.

    Returning:      ~ None, creating log files
    """


    create_lib_and_map(comp_output_dir)                             # Create a library and map it to Questa

    if not os.path.exists(gui_log_dir):                             # Check if there is an existing directory
        os.mkdir(gui_log_dir)                                       # Otherwise, make one

    vcom_log = open(gui_log_dir + rtl_name + "_" + comp_log ,'w')   # Logging into separate compilation log file

    compile_tb_packages(tbench_pkg_src_dir, vcom_log)               # Compiling TB framework related packages
    compile_tb_packages(test_src_dir,       vcom_log)               # Packages containing tests
    compile_tb_packages(check_src_dir,      vcom_log)               # Packages containing checks

    compile_rtl_files(rtl_src_dir,  vcom_log)                       # Compile all the RTLs

    tbench_name = rtl_name + tbench_suffix                          # Testbench is named <RTL>_tb
    compile_one_tb_src(tbench_src_dir,tbench_name, vcom_log)        # Compile <RTL>_tb

    vopt_for_sim_gui(tbench_name, rtl_name)                         # Optimizing the testbench and passing values to the toplevel generics

    vsim_for_sim_gui(tbench_name, gui_log_dir)                      # Run simulation


def run_rgr():
    """
    Description:    ~ This function is responsible to run all the Self-checking testbenches for the RTL files.

                      It iterates over the appropriate folder which are given by global variables, and collects all the source files.
                      Then, it compiles all of them into one folder, pointed by 'comp_output_dir'.
                      After that, the corresponding SC-TB files, from 'tb_src_dir', will be simulated by Questa.
                      Moreover, Code coverage will be collected.

                      Finally, reports will be generated about the collected results.

    Arguments:      ~ None, using global variables.

    Returning:      ~ None, creating log files.

    """

    create_lib_and_map(comp_output_dir)                             # Create a library and map it to Questa

    if not os.path.exists(rgr_log_dir):                             # Check if there is an existing directory
        os.mkdir(rgr_log_dir)                                       # Otherwise, make one

    vcom_log = open(rgr_log_dir + comp_log ,'w')                    # Logging into separate compilation log file


    compile_tb_packages(tbench_pkg_src_dir, vcom_log)               # Compiling TB framework related packages
    compile_tb_packages(test_src_dir,       vcom_log)               # Packages containing tests
    compile_tb_packages(check_src_dir,      vcom_log)               # Packages containing checks

    compile_rtl_files(rtl_src_dir,  vcom_log)                       # Compile all the RTLs

    compile_tb_files(tbench_src_dir,vcom_log)                       # Compile all the testbenches





    tb_files    =       os.listdir(tbench_src_dir)


    tb_names    =   [x.split('.')[0] for x in tb_files]             # Removing the 'file_ext' file extensions from the 'tb_files' list.



    print("""

===========================================================================================================
    Running the Self-Checking testbenches
===========================================================================================================

    """)


    if not os.path.exists(ccov_dir):                 # Same for codecoverage directory
        os.mkdir(ccov_dir)                           #




    # Iterating over the testbenches
    for tb_name in tb_names:

        subprocess.call('vopt '+tb_name+' -o '+tb_name+'_opt'           +
                        ' -G RTL_NAME_G=\"'+ tb_name.split('_tb')[0] +'\"'+   # Removing the '_tb' postfix to get the rtl name from tb name
                        ' -G CLI_G=0'                                   +
                        ' -G GUI_G=0'                                   +
                        ' -G RGR_G=1'                                   +
                        ' +cover=sbecft+/'+tb_name+'/L_DUT'                 # Setup code-coverage in QuestaSim
                        ,shell = False)


        if not os.path.exists(ccov_dir+tb_name+ '_ccov/'):                 # Same for codecoverage directory
            os.mkdir(ccov_dir+tb_name+ '_ccov/')                           #
                                                                            #


        print("\n")



        subprocess.call('vsim -batch -t 1'+ sim_resolution                                          +
                        ' -coverage '                                                               +
                        ' -do "coverage save -onexit ' +ccov_dir+tb_name+ '_ccov/'+tb_name+'.ucdb;' +
                        ' run -all; quit"'                                                          +
                        ' -default_radix hexadecimal'                                               +
                        ' -logfile "'+ rgr_log_dir + tb_name +'_log.log"'                               +
                        ' work.'+tb_name+'_opt'
                        ,shell = False)

        print("""
===========================================================================================================
        """)


    print("""

===========================================================================================================
    Generating Code Coverage reports
===========================================================================================================

    """)

    for tb_name in tb_names:

        subprocess.call('vcover report -html -htmldir '+ccov_dir+tb_name+'_ccov'       +
                        ' -source -details -code bcefst'                                +
                        ' -threshL 50 -threshH 90'                                      +
                        ' '+ccov_dir+tb_name+'_ccov/'+tb_name+'.ucdb'
                        , shell = False)

        print("\n")



def parse_stdin():

    rgr         = 0     # Regression
    sim         = 0     # One testbench simulation with CLI
    sim_gui     = 0     # One testbench simulation with GUI

    rtl_name    = ""    # RTL module name in case of one simulation
    cmd         = []

    print("Type a command line and press ENTER ...")


    while True:

        cin = input()           # Getting info from stdin.


        cin = cin.split()       # Splitting at whitespaces.

        #------------------ Checking the input ------------------------
        rgr_needed = 0
        sim_needed = 0
        gui_needed = 0
        for arg in cin:

            if arg == "-all"    and rgr_needed == 0:
                rgr_needed  = 1

            if arg.startswith("-sim=")  and sim_needed == 0:
                sim_needed  = 1
                rtl_name    = arg.replace("-sim=","")

            if arg == "-gui"   and gui_needed == 0:
                gui_needed  = 1
        #------------------ Updating the command indicators -----------
        if rgr_needed == 1 and sim_needed == 0:
            cmd     = cin
            rgr     = 1
            break

        elif rgr_needed == 0 and sim_needed == 1 and gui_needed == 0:
            cmd     = cin
            sim     = 1
            break

        elif rgr_needed == 0 and sim_needed == 1 and gui_needed == 1:
            cmd     = cin
            sim_gui = 1
            break

        else:
            print("***ERROR***: The command " +str(cin)+ " is not understandable! Try again!")




    return rgr, sim, sim_gui, rtl_name, cmd     # Return the result of the parsing


def check_src_files(rgr, sim, sim_gui, rtl_name):


    file_errors = 0                                     # rtl/test/check source file related errors


    if rgr == 0 and sim == 1 or sim_gui == 1:           # If only one simulation is needed
        print("")

        # Checking the RTL source file's presence
        if is_rtl_src_present(rtl_src_dir, rtl_name) == 0:
            print("RTL file '" + rtl_name + file_ext + "' has not been found in '" + rtl_src_dir + "' !")
            file_errors += 1

        # Checking the testbench source file's presence
        if is_tbench_src_present(tbench_src_dir, rtl_name, tbench_suffix) == 0:
            print("Testbench file '"+rtl_name+tbench_suffix+file_ext+ "' has not been found in '" + tbench_src_dir + "' !")
            file_errors += 1

        # Checking the corresponding test file's presence
        if is_test_src_present(test_src_dir, rtl_name, test_suffix) == 0:
            print("Package file '" + rtl_name + test_suffix + file_ext + "', describing the tests, has not been found in '" + test_src_dir + "' !")
            file_errors += 1

        # Checking the corresponding check file's presence
        if is_check_src_present(check_src_dir, rtl_name,  check_suffix) == 0:
            print("Package file '" + rtl_name + check_suffix + file_ext + "', describing the checks, has not been found in '" + check_src_dir + "' !")
            file_errors += 1

        #print("\nPress ENTER to finish ...")    # General script ending message




    return file_errors


def main():
    """
    Description:    ~ This function is main code of the script. First, it parses the input command
                      given by the user in stdin. Can be either regression on all the available RTL-s or one self-
                      checking TB on one RTL in CLI or one simulation in Questa GUI.

                      In regression, it does not check if the source files are present. All the related errors will
                      be collected in the log files.

    Arguments:      ~ None, using global variables.

    Returning:      ~ 0, when all the source files are present in the directories for the desired entity.
                    ~ 1, when it cannot find RTL/TB source files.
    """


    print_welcome_msg()                                         # Welcome message.

    rgr, sim, sim_gui, rtl_name, cmd = parse_stdin()            # Parsing STDIN

    file_errors = check_src_files(rgr, sim, sim_gui, rtl_name)  # Checking source files for CLI and GUI usage


    if file_errors == 0:                                        # If the files are present
        if sim == 1:                                            # If GUI is not needed
            run_sim(rtl_name)

        if sim_gui == 1:                                        # If GUI should open up
            run_sim_gui(rtl_name)






    # Regression assumes all the source files are in their appropriate places
    if rgr == 1 and sim == 0 and sim_gui == 0:                 # If regression is needed
        run_rgr()
        print_exit_msg()

































#--------- Main ----------------
if __name__ == "__main__":

    main()

#-------------------------------