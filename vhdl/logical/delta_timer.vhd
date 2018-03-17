---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;


---------------------------------------------------------------------------
entity delta_timer is
    generic(
        CNTR_WIDTH      :   integer:=   7
    );
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;

        wr              :   in  std_logic;
        wdata           :   in  std_logic_vector(1  downto  0);
        -- coverage off t
        rdata           :   out std_logic_vector(CNTR_WIDTH-1   downto  0);
        -- coverage on
        signal_from_DUV :   in  std_logic
    );
end entity delta_timer;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture rtl of delta_timer is

    signal  din         :   std_logic_vector(1  downto  0);
    signal  nxt_din     :   std_logic_vector(1  downto  0);

    -- coverage off t
    signal  cntr_dout_mux :   std_logic_vector(CNTR_WIDTH-1 downto 0);
    signal  cntr_dout_w :   std_logic_vector(CNTR_WIDTH-1 downto 0);
    -- coverage on

    signal  show_cntr_w :   std_logic;

    signal  cntr_en_w   :   std_logic;
    signal  cntr_clr_w  :   std_logic;

    signal  de_caught_w :   std_logic;

    signal  det_clr_w   :   std_logic;
    signal  det_en_w    :   std_logic;

begin







    L_WR_IF: process(clk, rstn)  is
        begin
            if(rstn = '0')  then
                din <= b"00";



            elsif(rising_edge(clk)) then
                din <= nxt_din;
            end if;
        end process;











    nxt_din         <=  wdata       when (wr = '1')  else
                        din;
    -------------------------------------------------
    rdata           <=  cntr_dout_mux;

    -------------------------------------------------
    cntr_dout_mux   <=  cntr_dout_w     when (show_cntr_w = '1') else
                        (others => '0');








    L_DE_DET: entity work.de_det(rtl)
                port map(
                    clk      => clk         ,
                    rstn     => rstn        ,
                    en       => det_en_w    ,
                    clr      => det_clr_w   ,
                    sig      => signal_from_DUV,
                    det_out  => de_caught_w
                );

    L_CNTR: entity work.cntr(rtl)
                generic map(
                    WIDTH               =>  CNTR_WIDTH
                )
                port map(
                    clk                 => clk          ,
                    rstn                => rstn         ,
                    en                  => cntr_en_w    ,
                    clr                 => cntr_clr_w   ,
                    cntr_out            => cntr_dout_w
                );

    L_FSM:  entity work.delta_timer_fsm(rtl)
                port map(
                    clk         =>  clk         ,
                    rstn        =>  rstn        ,
                    en          =>  din(0)      ,
                    clr         =>  din(1)      ,
                    de_caught   =>  de_caught_w ,
                    show_cntr   =>  show_cntr_w ,
                    cntr_clr    =>  cntr_clr_w  ,
                    cntr_en     =>  cntr_en_w   ,
                    det_clr     =>  det_clr_w   ,
                    det_en      =>  det_en_w
                );












end architecture rtl;
