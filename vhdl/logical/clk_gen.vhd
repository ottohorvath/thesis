---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ This module is responsible for providing clock signal for
--                the whole verification environment.
--
--              ~ The clock can be enabled and disabled as well.
--
--              ~ One can choose from one clock-gating architecture:
--                 + flop-based.
--
---------------------------------------------------------------------------
--
-- Note:        ~ The gated clock output 'clk_out' has to be added to the FPGA's
--                clock routing/distributing network in the synthesizer !!!
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;




---------------------------------------------------------------------------
entity clk_gen  is
    port(
        clk     :   in  std_logic;
        rstn    :   in  std_logic;

        wr      :   in  std_logic;                      --
        wdata   :   in  std_logic_vector(1 downto 0);   -- Processor IF
        rdata   :   out std_logic;                      --

        trig_out:   out std_logic;

        clk_out :   out std_logic       -- The gated output clock
    );
end entity clk_gen;
---------------------------------------------------------------------------





---------------------------------------------------------------------------
architecture rtl  of  clk_gen is

    -- Write Data register
    -- ===================
    signal  wdata_reg   :   std_logic_vector(1 downto 0);


    -- SC FF output
    -- ============
    signal sc_ff_out    :   std_logic;


    -- Inverted clock
    -- ==============
    signal nclk         :   std_logic;


    -- Clock gating Flop
    -- =================
    signal  cg          :   std_logic;


begin

    --------------------------------------------------------
    L_WDATA: block
                begin
                    process( clk, rstn )   is
                    begin
                        if(rstn = '0')  then
                            wdata_reg <= b"00";
                        elsif(rising_edge(clk)) then

                            if(wr = '1')    then
                                wdata_reg   <= wdata;
                            end if;

                        end if;
                    end process;

                end block;
    --------------------------------------------------------
    -- Drive out the status as level-based trigger
    L_TRIG:     trig_out    <=  sc_ff_out;
    --------------------------------------------------------
    L_RDATA:    block
                begin
                    rdata   <=  sc_ff_out;
                end block;
    --------------------------------------------------------
    L_CG:   block
            begin
                -- Process is runnning from inverted clock
                process( nclk, rstn )   is
                begin
                    if(rstn = '0')  then
                        cg <= '0';

                    elsif( rising_edge(nclk) )   then

                        cg <= sc_ff_out;

                    end if;
                end process;

                -- Inverting the clock
                nclk    <= not(clk);
                -- Gating clock and flop output
                clk_out <= cg and clk;
            end block;
    --------------------------------------------------------
    -- Instantiate the 'sc_ff' to control the clock gen. logic
    L_SC_FF:    entity work.sc_ff(rtl)
                    port map(
                        clk     => clk          ,
                        rstn    => rstn         ,
                        set     => wdata_reg(0) ,
                        clr     => wdata_reg(1) ,
                        q       => sc_ff_out
                    );
    --------------------------------------------------------

end architecture rtl;
---------------------------------------------------------------------------























