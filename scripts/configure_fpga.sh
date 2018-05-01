#!/bin/sh

#===============================================================================
# Description:
#   ~ Generic FPGA configurator script
#   ~ Loads an RBF file, which has been generated from SRAM Object file,
#     to the FPGA
#===============================================================================
# Usage:
#   $> ./configure_fpga.sh <path to an .rbf file>
#===============================================================================


BRIDGES_ENABLED="0"
#===============================================================================
#===============================================================================


# Check bridges if they are enabled
# ==================================
check_bridges()
{
    echo "[INFO] Checking the status of the bridges between HPS an FPGA ..."

    F2H=`cat /sys/class/fpga-bridge/fpga2hps/enable`
    H2F=`cat /sys/class/fpga-bridge/hps2fpga/enable`
    LW_H2F=`cat /sys/class/fpga-bridge/lwhps2fpga/enable`

    if [[ "${F2H}" -eq "1" ]]; then
        BRIDGES_ENABLED="1"
    fi

    if [[ "${H2F}" -eq "1" ]]; then
        BRIDGES_ENABLED="1"
    fi

    if [[ "${LW_H2F}" -eq "1" ]]; then
        BRIDGES_ENABLED="1"
    fi
}

# Disable bridges
# ===============
disable_bridges()
{
    echo "[INFO] Disabling the bridges!"
    echo 0 > /sys/class/fpga-bridge/fpga2hps/enable
    echo 0 > /sys/class/fpga-bridge/hps2fpga/enable
    echo 0 > /sys/class/fpga-bridge/lwhps2fpga/enable
}

# Enable bridges
# ===============
enable_bridges()
{
    echo "[INFO] Enabling the bridges!"
    echo 1 > /sys/class/fpga-bridge/fpga2hps/enable
    echo 1 > /sys/class/fpga-bridge/hps2fpga/enable
    echo 1 > /sys/class/fpga-bridge/lwhps2fpga/enable
}

# Configure FPGA with the RBF passed as first argument
# ====================================================
configure_fpga()
{
    RBF_PATH=$1
    echo "[INFO] Configuring FPGA with '$1'"

    # If FPGA is in 'configuration phase' then it can accept the new .rbf
    # Replace whitespace to underscore for comparison
    FPGA_STATUS=`cat /sys/class/fpga/fpga0/status | sed 's| |_|'`
    CONFIG_STATUS="configuration_phase"

    if [[ "${FPGA_STATUS}" -eq "${CONFIG_STATUS}" ]]; then
        # The configuration is a simple copy to a file which represents the FPGA
        dd if=${RBF_PATH} of=/dev/fpga0

        # Check the status after configuration
        # Now it should be in 'user mode'
        FPGA_STATUS=`cat /sys/class/fpga/fpga0/status`
        echo "[INFO] FPGA is now in '${FPGA_STATUS}'. Configuration DONE!"
    else
        echo "[INFO] FPGA is in '${FPGA_STATUS}'. Configuration FAILED!"
        exit 1
    fi
}
#===============================================================================
#===============================================================================

# Check input
# ===========
if [[ "$#" -eq "0" ]]; then
    echo "[INFO] Usage: ./configure_fpga.sh <path to an .rbf file>"
    exit 1
# Check file extension
elif ! [[ "$1" == *.rbf ]]; then
    echo "[INFO] Please add an *.rfb file as first argument"
    exit 1
fi

# Get the status of the bridges
# =============================
check_bridges

# Disable them
# ============
if [[ "${BRIDGES_ENABLED}" -eq "1" ]]; then
    disable_bridges
fi

# Configure the FPGA
# ==================
configure_fpga $1

# Enable them again
# =================
enable_bridges

#======================================
exit 0