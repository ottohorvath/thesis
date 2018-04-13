---------------------------------------------------------------------------
--
-- Author: Otto Horvath
--
---------------------------------------------------------------------------
--
-- Description: ~ Fully synchronous, generic FIFO
--
--
--
---------------------------------------------------------------------------

library ieee                    ;
use     ieee.std_logic_1164.all ;
use     ieee.numeric_std.all    ;



---------------------------------------------------------------------------
entity fifo is
    generic (
        DEPTH       :       integer range 8 to 512  :=  8           ;-- Depth of the FIFO
        DW          :       integer                 :=  32          -- Data width
    );
    port (
        clk         :       in  std_logic                           ;
        rstn        :       in  std_logic                           ;-- Async. active LOW reset

        empty       :       out std_logic                           ;--
        rd          :       in  std_logic                           ;-- Read side
        -- coverage off t
        rdata       :       out std_logic_vector(DW-1 downto 0) ;--
        -- coverage on

        full        :       out std_logic                           ;--
        wr          :       in  std_logic                           ;-- Write side
        -- coverage off t
        wdata       :       in  std_logic_vector(DW-1 downto 0)  --
        -- coverage on
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of fifo is
    -----------------------------------------------------------------
    function clog2  (
        arg     :   in  natural
    )   return          natural
    is
        variable nbits : integer;
        variable num   : integer;
    begin
        num   := arg;
        nbits := 0;

        while num > 1 loop

            nbits   := nbits +1;
            num     := num / 2;

        end loop;

        return nbits;
    end function;
    -----------------------------------------------------------------


    type data_t is  array (0 to DEPTH-1) of std_logic_vector(DW-1 downto 0);

    -- FIFO slots
    -- ==========
    signal  payload : data_t;


    -- FIFO occupancy counter, wider with 1 bit than clog(DEPTH)
    -- because its MSB will be used for indicating full flag
    -- ======================================================
    signal  occupancy   :   std_logic_vector(clog2(DEPTH) downto 0);

    -- Address pointer, it is 1 bit wider than clog(DEPTH), too
    -- because it will be used for empty flag generation
    -- ======================================================
    signal  addr        :   std_logic_vector(clog2(DEPTH) downto 0);



begin
    ------------------------------------------------------------------
    L_SHR:      process(clk)  is
                begin
                    if( rising_edge(clk) ) then
                        if(wr = '1')    then
                            for i in 1 to DEPTH-1 loop
                                payload(i)  <= payload(i-1);
                            end loop;
                            payload(0)  <=  wdata;
                        end if;
                    end if;
                end process;
    ------------------------------------------------------------------
    L_OCCUP:    process(clk, rstn)  is
                begin
                    if(rstn = '0')  then
                        occupancy   <= (others =>'0');
                    elsif( rising_edge(clk) ) then
                        -- Increment occupancy on write
                        if(wr = '1' and rd = '0')    then
                            occupancy   <=  std_logic_vector(unsigned(occupancy) + 1);
                        end if;
                        -- Decrement on read
                        if(wr = '0' and rd = '1')    then
                            occupancy   <=  std_logic_vector(unsigned(occupancy) - 1);
                        end if;
                    end if;
                end process;
    ------------------------------------------------------------------
    L_ADDR:     process(clk, rstn)  is
                begin
                    if(rstn = '0')  then
                        addr   <= (others =>'1');
                    elsif( rising_edge(clk) ) then
                        -- Increment occupancy on write
                        if(wr = '1' and rd = '0')    then
                            addr   <=  std_logic_vector(unsigned(addr) + 1);
                        end if;
                        -- Decrement on read
                        if(wr = '0' and rd = '1')    then
                            addr   <=  std_logic_vector(unsigned(addr) - 1);
                        end if;
                    end if;
                end process;
    ------------------------------------------------------------------
    L_OUTPUTS:  block
                begin
                    empty   <=  addr(clog2(DEPTH));
                    full    <=  occupancy(clog2(DEPTH));
                    rdata   <=  payload(    to_integer(unsigned(addr(clog2(DEPTH)-1 downto 0))) );
                end block;


end architecture;
---------------------------------------------------------------------------------------------------