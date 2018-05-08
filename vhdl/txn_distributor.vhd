---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description:     ~   Routes MMIO-Slave transaction to its proper
--                      destination, based on the address of the transaction
--
--                  ~   The memory map is received as a generic parameter
--
--                  ~   'resp' signals back with '1' that the transaction
--                      would have been directed to unmapped region
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


-- Use the package belonging to this module from sim/tbench_pkg/ folder
use     work.txn_distributor_pkg.all  ;

---------------------------------------------------------------------------
entity txn_distributor is
    generic(
        MEM_MAP:    mem_map_t
    );
    port(
        txn_in  :   in  txn_in_t    ;
        txn_out :   out txn_out_t   ;
        dec_err :   out std_logic
    );
end entity;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
architecture bhv of txn_distributor is

begin

    L_ROUTING:  process(txn_in) is
                    -- Counting the number of missed slaves during decoding
                    variable    miss_cntr    :   integer;
                begin

                    miss_cntr := 0;

                    -- For all the slaves in the memory map
                    for slv in 0 to NUM_OF_SLAVES-1 loop
                        -- Check the incoming transaction's address against the map
                        if(
                            is_addr_in_mem_map(txn_in.addr,MEM_MAP(slv)) = true
                        )then
                            txn_out(slv).wr    <=   txn_in.wr   ;
                            txn_out(slv).wdata <=   txn_in.wdata;
                            txn_out(slv).rd    <=   txn_in.rd   ;
                            txn_out(slv).rdata <=   txn_in.rdata;
                        else
                        -- Otherwise, increase a missed slave counter
                            miss_cntr := miss_cntr + 1;
                        end if;
                    end loop;

                    -- If the number of misses equals the number of slaves
                    if(miss_cntr = NUM_OF_SLAVES)   then
                        -- Generate error response
                        dec_err <=  '1';
                    else
                        -- Generate okay response
                        dec_err <=  '0';
                    end if;
                end process;

end architecture;
---------------------------------------------------------------------------