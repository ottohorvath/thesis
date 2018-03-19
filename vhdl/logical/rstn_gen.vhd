---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ This module is responsible for providing reset signal for
--                the whole verification environment.
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;





---------------------------------------------------------------------------
entity rstn_gen is
    generic(
        REG_LAYER       :       boolean     :=  false  -- For timing closure purposes
    );
    port(
        clk         :   in  std_logic;
        rstn        :   in  std_logic;

        wr          :   in  std_logic;
        wdata       :   in  std_logic_vector(1  downto  0);
        rdata       :   out std_logic;
        trig_out    :   out std_logic;

        rstn_to_DUV  :   out std_logic
    );
end entity rstn_gen;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of rstn_gen is

    -- Write Data register
    -- ===================
    signal  wdata_reg   :   std_logic_vector(1 downto 0);


    -- Write signal flop for one cycle delay
    -- =====================================
    signal  wr_reg      :   std_logic;


    -- Reset generating flop
    -- =====================
    signal  rstn_reg    :   std_logic;
    signal  rstn_reg_nxt:   std_logic;


    -- Rising-edge detector
    -- ====================
    signal re_det_reg   :   std_logic;
    signal re_det_out   :   std_logic;


    -- SC FF
    -- =====
    signal  sc_ff_out   :   std_logic;


    -- Trigger output signals
    -- ======================
    signal  trig_out_reg:   std_logic;


begin

    --------------------------------------------------------
    -- Feeding the 'wr' input to a flop
    L_WR:   block
            begin
                process(clk,rstn) is
                begin
                    if(rstn='0')    then
                        wr_reg   <= '0';
                    elsif(rising_edge(clk)) then
                        wr_reg   <= wr;
                    end if;
                end process;
            end block;
    --------------------------------------------------------
    L_WDATA:    block
                begin
                    process(clk,rstn)  is
                    begin
                        if(rstn = '0')  then
                            wdata_reg <= (others => '0');
                        elsif( rising_edge(clk) )   then

                            if(wr = '1')    then
                                wdata_reg   <= wdata;
                            end if;

                        end if;
                    end process;
                end block;
    --------------------------------------------------------
    -- Implementing the active LOW reset pulse generating logic
    L_RSTN: block
            begin
                process(clk, rstn)   is
                begin
                    if(rstn = '0')  then
                        -- Reseting to 1
                        rstn_reg     <= '1';
                    elsif(rising_edge(clk))   then
                        rstn_reg     <= rstn_reg_nxt;
                    end if;
                end process;

                -- Feeding in the NAND of Enable bit and the delayed 'wr' signal
                rstn_reg_nxt    <=  not(wdata_reg(0) and wr_reg);
                -- Driving the output
                rstn_to_DUV     <= rstn_reg;
            end block;
    --------------------------------------------------------
    L_RDATA:    block
                begin
                    -- Drive the status of the module
                    rdata       <=  sc_ff_out;
                end block;
    --------------------------------------------------------
    L_TRIG:     block
                begin
                    L_REG:  if(REG_LAYER = true)    generate
                                process(clk,rstn) is
                                begin
                                    if(rstn = '0')  then
                                        trig_out_reg    <= '0';
                                    elsif(rising_edge(clk)) then
                                        trig_out_reg    <= re_det_out;
                                    end if;
                                end process;

                                -- Drive trig_out from flop
                                trig_out    <= trig_out_reg;
                            end generate;

                    L_NOREG:if(REG_LAYER = false)   generate

                                -- Drive it directly
                                trig_out    <= re_det_out;
                            end generate;
                end block;
    --------------------------------------------------------
    L_STATUS:   block
                begin
                    process(clk, rstn)  is
                    begin
                        if(rstn = '0')  then
                            -- Reset to 1 !!!
                            re_det_reg  <= '1';
                        elsif(rising_edge(clk)) then
                            re_det_reg  <= rstn_reg;

                        end if;
                    end process;

                    -- Drive the detector output
                    re_det_out  <= (re_det_reg and not(rstn_reg));

                    L_SC_FF:    entity work.sc_ff(rtl)
                        port map(
                            clk     => clk         ,
                            rstn    => rstn        ,
                            set     => re_det_out  ,
                            clr     => wdata_reg(1),
                            q       => sc_ff_out
                        );
                end block;
    --------------------------------------------------------





end architecture rtl;
---------------------------------------------------------------------------