---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Generic synchronizer for de-asserting async. reset
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity mode_selector is
    port(
        clk     :   in  std_logic;
        rstn    :   in  std_logic;
        wdata   :   in  std_logic_vector(1  downto 0);
        wr      :   in  std_logic;
        rdata   :   out std_logic;
        mode_sel:   out std_logic
    );
end entity mode_selector;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of mode_selector is

    -- Write Data register
    -- ===================
    signal  wdata_reg   :   std_logic_vector(1  downto 0);


    -- SC FF output
    -- ============
    signal  sc_ff_out   :   std_logic;
begin

    -------------------------------------------------------------
    L_MS    :   mode_sel    <=  sc_ff_out;
    -------------------------------------------------------------
    L_RDATA:    rdata       <=  sc_ff_out;
    -------------------------------------------------------------
    L_WDATA:    block
                begin
                    ---------------------------------------------
                    process(clk,rstn) is
                    begin
                        if(rstn = '0')  then
                            wdata_reg   <=  (others => '0');
                        elsif(rising_edge(clk)) then
                            if(wr = '1')    then
                                wdata_reg   <= wdata;
                            end if;
                        end if;
                    end process;
                    ---------------------------------------------
                    ---------------------------------------------
                end block;
    -------------------------------------------------------------
    L_SC_FF:    entity work.sc_ff(rtl)
                    port map(
                        clk     => clk          ,
                        rstn    => rstn         ,
                        set     => wdata_reg(0) ,
                        clr     => wdata_reg(1) ,
                        q       => sc_ff_out
                    );
    -------------------------------------------------------------

end architecture rtl;
---------------------------------------------------------------------------