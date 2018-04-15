---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
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
entity config_reg_if is
    generic(
        ACK_NEEDED      :       boolean :=  false   ;
        REG_LAYER       :       boolean :=  false   ;
        DW              :       integer :=  32      ;
        AW              :       integer :=  32      ;
        RD_START        :       std_logic_vector(63 downto 0):=     X"00000000FFFF0000"; -- WorkAround: Can't use 'DW' here, so made it wide enough
        WR_START        :       std_logic_vector(63 downto 0):=     X"000000000000FFFF"  --
    );
    port(
        clk             :   in  std_logic;
        rstn            :   in  std_logic;
        wr              :   in  std_logic                           ;--
        wdata           :   in  std_logic_vector(DW-1   downto 0)   ;--
        rd              :   in  std_logic                           ;-- MMIO Slave IF
        rdata           :   out std_logic_vector(DW-1   downto 0)   ;--
        wstrb_to_DUV    :   out std_logic                           ;--
        rstrb_to_DUV    :   out std_logic                           ;--
        wdata_to_DUV    :   out std_logic_vector(DW-1   downto 0)   ;-- Simple config register IF
        addr_to_DUV     :   out std_logic_vector(AW-1   downto 0)   ;--
        rdata_from_DUV  :   in  std_logic_vector(DW-1   downto 0)   ;--
        cs_to_DUV       :   out std_logic                           ;-- Chip Select for the config register
        ack_from_DUV    :   in  std_logic                            -- Ack. input, when ACK_NEEDED is set to TRUE
    );
end entity config_reg_if;
---------------------------------------------------------------------------

architecture rtl of config_reg_if is

    signal  fsm_addr_en :   std_logic;
    signal  fsm_wdata_en:   std_logic;
    signal  fsm_rdata_en:   std_logic;

    signal  fsm_rstrb   :   std_logic;
    signal  fsm_wstrb   :   std_logic;
    signal  fsm_cs      :   std_logic;

    signal  rdata_reg   :   std_logic_vector(DW-1 downto 0);
    signal  wdata_reg   :   std_logic_vector(DW-1 downto 0);
    signal  addr_reg    :   std_logic_vector(AW-1 downto 0);


    signal  cs_reg      :   std_logic;
    signal  wstrb_reg   :   std_logic;
    signal  rstrb_reg   :   std_logic;


begin

    L_DUV_IF:   block
                begin
                    addr_to_DUV     <=  addr_reg;
                    wdata_to_DUV    <=  wdata_reg;
                end block;


    -----------------------------------------------------
    L_RD_IF: block
    begin
        -------------------------------------------------
        process(clk) is
        begin
            if(rising_edge(clk))    then

                if(fsm_rdata_en = '1')   then
                    rdata_reg   <= rdata_from_DUV;
                end if;

            end if;
        end process;

        -------------------------------------------------
        rdata <=    rdata_reg       when(rd = '1')   else
                    (others => '0');
        -------------------------------------------------
    end block;
    -----------------------------------------------------


    -----------------------------------------------------
    L_WR_IF: block
    begin
        -------------------------------------------------
        process(clk) is
        begin
            if(rising_edge(clk))    then

                if(fsm_wdata_en = '1')   then
                    wdata_reg   <= wdata;
                end if;

            end if;
        end process;
        -------------------------------------------------
        process(clk) is
        begin
            if(rising_edge(clk))    then

                if(fsm_addr_en = '1')    then
                    addr_reg   <= std_logic_vector(resize(signed(wdata), AW)); -- Resizing to address width
                end if;

            end if;
        end process;
        -------------------------------------------------

    end block;
    -----------------------------------------------------

    -----------------------------------------------------
    L_REG_LAYER: if(REG_LAYER = true)    generate
        -------------------------------------------------
        process(clk,rstn) is
        begin
            if(rstn = '0')  then
                cs_reg  <= '0';

            elsif(rising_edge(clk))    then
                cs_reg  <= fsm_cs;

            end if;
        end process;
        -------------------------------------------------
        cs_to_DUV  <= cs_reg;
        -------------------------------------------------
        process(clk,rstn) is
        begin
            if(rstn = '0')  then
                wstrb_reg   <= '0';

            elsif(rising_edge(clk))    then
                wstrb_reg  <= fsm_wstrb;

            end if;
        end process;
        -------------------------------------------------
        wstrb_to_DUV    <= wstrb_reg;
        -------------------------------------------------
        process(clk,rstn) is
        begin
            if(rstn = '0')  then
                rstrb_reg   <= '0';

            elsif(rising_edge(clk))    then
                rstrb_reg  <= fsm_rstrb;

            end if;
        end process;
        -------------------------------------------------
        rstrb_to_DUV    <= rstrb_reg;
        -------------------------------------------------
    end generate;
    -----------------------------------------------------

    -----------------------------------------------------
    L_NO_REG_LAYER: if(REG_LAYER = false)   generate
        cs_to_DUV       <= fsm_cs   ;
        wstrb_to_DUV    <= fsm_wstrb;
        rstrb_to_DUV    <= fsm_rstrb;
    end generate;
    -----------------------------------------------------


    -----------------------------------------------------
    -- 	Instantiating the 'config_reg_if_fsm' FSM.
    L_FSM:
        entity work.config_reg_if_fsm(rtl)
            generic map(
                ACK_NEEDED      =>  ACK_NEEDED  ,
                DW              =>  DW          ,
                RD_START        =>  RD_START    ,
                WR_START        =>  WR_START
            )
            port map(
                clk             => clk          ,
                rstn            => rstn         ,
                wr              => wr           ,
                wdata           => wdata        ,
                ack_from_DUV    => ack_from_DUV ,
                rstrb           => fsm_rstrb    ,
                wstrb           => fsm_wstrb    ,
                cs              => fsm_cs       ,
                addr_en         => fsm_addr_en  ,
                wdata_en        => fsm_wdata_en ,
                rdata_en        => fsm_rdata_en
            );
    -----------------------------------------------------

end architecture rtl;

