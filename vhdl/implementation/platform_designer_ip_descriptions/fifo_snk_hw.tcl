# TCL File Generated by Component Editor 17.1
# Sun May 13 23:41:14 CEST 2018
# DO NOT MODIFY


# 
# fifo_snk "fifo_snk" v1.0
#  2018.05.13.23:41:14
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module fifo_snk
# 
set_module_property DESCRIPTION ""
set_module_property NAME fifo_snk
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME fifo_snk
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL fifo_snk_wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file fifo_snk_wrapper.vhd VHDL PATH ../platform_designer_wrappers/fifo_snk_wrapper.vhd TOP_LEVEL_FILE
add_fileset_file fifo.vhd VHDL PATH ../../logical/fifo.vhd
add_fileset_file fifo_snk.vhd VHDL PATH ../../logical/fifo_snk.vhd


# 
# parameters
# 
add_parameter DEPTH INTEGER 8
set_parameter_property DEPTH DEFAULT_VALUE 8
set_parameter_property DEPTH DISPLAY_NAME DEPTH
set_parameter_property DEPTH TYPE INTEGER
set_parameter_property DEPTH UNITS None
set_parameter_property DEPTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property DEPTH HDL_PARAMETER true
add_parameter DW INTEGER 32
set_parameter_property DW DEFAULT_VALUE 32
set_parameter_property DW DISPLAY_NAME DW
set_parameter_property DW TYPE INTEGER
set_parameter_property DW UNITS None
set_parameter_property DW ALLOWED_RANGES -2147483648:2147483647
set_parameter_property DW HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock csi_clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset rsi_rstn reset_n Input 1


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 maximumPendingWriteTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitStates 0
set_interface_property avalon_slave_0 readWaitTime 0
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 avs_read read Input 1
add_interface_port avalon_slave_0 avs_readdata readdata Output dw
add_interface_port avalon_slave_0 avs_write write Input 1
add_interface_port avalon_slave_0 avs_writedata writedata Input dw
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point trig_out
# 
add_interface trig_out conduit end
set_interface_property trig_out associatedClock clock
set_interface_property trig_out associatedReset reset
set_interface_property trig_out ENABLED true
set_interface_property trig_out EXPORT_OF ""
set_interface_property trig_out PORT_NAME_MAP ""
set_interface_property trig_out CMSIS_SVD_VARIABLES ""
set_interface_property trig_out SVD_ADDRESS_GROUP ""

add_interface_port trig_out trig_out new_signal Output 1


# 
# connection point full_to_DUV
# 
add_interface full_to_DUV conduit end
set_interface_property full_to_DUV associatedClock clock
set_interface_property full_to_DUV associatedReset reset
set_interface_property full_to_DUV ENABLED true
set_interface_property full_to_DUV EXPORT_OF ""
set_interface_property full_to_DUV PORT_NAME_MAP ""
set_interface_property full_to_DUV CMSIS_SVD_VARIABLES ""
set_interface_property full_to_DUV SVD_ADDRESS_GROUP ""

add_interface_port full_to_DUV full_to_DUV new_signal Output 1


# 
# connection point wr_from_DUV
# 
add_interface wr_from_DUV conduit end
set_interface_property wr_from_DUV associatedClock clock
set_interface_property wr_from_DUV associatedReset reset
set_interface_property wr_from_DUV ENABLED true
set_interface_property wr_from_DUV EXPORT_OF ""
set_interface_property wr_from_DUV PORT_NAME_MAP ""
set_interface_property wr_from_DUV CMSIS_SVD_VARIABLES ""
set_interface_property wr_from_DUV SVD_ADDRESS_GROUP ""

add_interface_port wr_from_DUV wr_from_DUV new_signal Input 1


# 
# connection point wdata_from_DUV
# 
add_interface wdata_from_DUV conduit end
set_interface_property wdata_from_DUV associatedClock clock
set_interface_property wdata_from_DUV associatedReset reset
set_interface_property wdata_from_DUV ENABLED true
set_interface_property wdata_from_DUV EXPORT_OF ""
set_interface_property wdata_from_DUV PORT_NAME_MAP ""
set_interface_property wdata_from_DUV CMSIS_SVD_VARIABLES ""
set_interface_property wdata_from_DUV SVD_ADDRESS_GROUP ""

add_interface_port wdata_from_DUV wdata_from_DUV new_signal Input dw
