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


------ Packages from "../tbench_pkg/" ----
use work.tb_log_pkg.all     ;
use work.tb_utils_pkg.all   ;
use work.tb_report_pkg.all  ;
----------------------------------------



package txn_distributor_pkg
is
    -- Transaction data width
    constant    TXN_DW              :       natural :=  32;
    -- Transaction address width
    constant    TXN_AW              :       natural :=  32;
    -- Number of slaves stiched to the distributor entity
    constant    NUM_OF_SLAVES       :       natural :=  8;

    -----------------------------------------------
    type mem_region_t  is
    record
        base    :   std_logic_vector(TXN_AW-1   downto 0);
        high    :   std_logic_vector(TXN_AW-1   downto 0);
    end record;
    -----------------------------------------------
    type mem_map_t is
        array(NUM_OF_SLAVES-1 downto 0) of
            mem_region_t;
    -----------------------------------------------
    -- Outgoing transaction from distributor
    -- Removed the address
    type mmio_slv_t is
    record
        wr      :   std_logic;
        wdata   :   std_logic_vector(TXN_DW-1   downto 0);
        rd      :   std_logic;
        rdata   :   std_logic_vector(TXN_DW-1   downto 0);
    end record;
    -----------------------------------------------
    type txn_out_t  is
        array(NUM_OF_SLAVES-1 downto 0) of
            mmio_slv_t;
    -----------------------------------------------
    -- Incoming transaction from BFM
    -- Contains address
    type txn_in_t   is
    record
        addr    :   std_logic_vector(TXN_AW-1   downto 0);
        wr      :   std_logic;
        wdata   :   std_logic_vector(TXN_DW-1   downto 0);
        rd      :   std_logic;
        rdata   :   std_logic_vector(TXN_DW-1   downto 0);
    end record;
    -----------------------------------------------


    -----------------------------------------------
    -- Returns true if the 'addr' is in the 'mem_region'
    function is_addr_in_mem_map(
        addr        :   std_logic_vector(TXN_AW-1   downto 0);
        mem_region  :   mem_region_t
    )   return boolean;
    -----------------------------------------------

end package;

package body txn_distributor_pkg
is

    -----------------------------------------------
    function is_addr_in_mem_map(
        addr        :   std_logic_vector(TXN_AW-1   downto 0);
        mem_region  :   mem_region_t
    )   return boolean
    is
        variable    address_is_inside_map: boolean :=  false;

        variable    addr_int        :   integer;
        variable    map_base_int    :   integer;
        variable    map_high_int    :   integer;
    begin
        -- Convert adresses from slv to integer
        addr_int        :=  to_integer(unsigned( addr ));
        map_base_int    :=  to_integer(unsigned( mem_region.base ));
        map_high_int    :=  to_integer(unsigned( mem_region.high ));

        -- Check the passed address if it is in the memory map 
        if( (addr_int >= map_base_int) and (addr_int <= map_high_int) ) then
            address_is_inside_map   := true;
        else
            address_is_inside_map   := false;
        end if;

        return address_is_inside_map;
    end function;
    -----------------------------------------------

end package body;

