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
        DWIDTH      :       integer                 :=  32          -- Data width
    );
    port (
        clk         :       in  std_logic                           ;
        rstn        :       in  std_logic                           ;-- Async. active LOW reset

        empty       :       out std_logic                           ;--
        rd          :       in  std_logic                           ;-- Read side
        -- coverage off t
        rdata       :       out std_logic_vector(DWIDTH-1 downto 0) ;--
        -- coverage on

        full        :       out std_logic                           ;--
        wr          :       in  std_logic                           ;-- Write side
        -- coverage off t
        wdata       :       in  std_logic_vector(DWIDTH-1 downto 0)  --
        -- coverage on
    );
end entity;
---------------------------------------------------------------------------------------------------
architecture rtl of fifo is

    type data_t is
        array (0 to DEPTH-1) of std_logic_vector(DWIDTH-1 downto 0);

    signal  payload: data_t;                                                -- FIFO slots
    
    
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
begin
    ------------------------------------------------------------------
    L_FIFO:    process(clk, rstn)  is

        variable rd_ptr_v   :   unsigned(clog2(DEPTH)-1 downto 0);
        variable wr_ptr_v   :   unsigned(clog2(DEPTH)-1 downto 0);

        variable full_v     :   std_logic;
        variable empty_v    :   std_logic;

    begin

        if(rstn = '0')  then
            rd_ptr_v    :=  (others => '0');
            wr_ptr_v    :=  (others => '0');

            full_v      :=  '0';    -- In reset state it is not full
            empty_v     :=  '1';    -- But it is empty

            empty       <=  '1';
            full        <=  '0';
            --rdata       <=  (others => '0');

        elsif( rising_edge(clk) ) then

            -------------------------------------------------
            -- Upstream logic

            if(wr = '1' and full_v /= '1')  then                    -- If it isn't full, and the upstream wants to write in data

                payload(to_integer(wr_ptr_v)) <= wdata  ;           -- Just store down the wdata

                wr_ptr_v    := wr_ptr_v + 1;                        -- Incrementing the write pointer

                if(wr_ptr_v = rd_ptr_v) then                        -- And then (in the same cycle) if they are the same then the FIFO just got
                    full_v  := '1';                                 -- fully occupied
                else
                    full_v  := '0';                                 -- Otherwise, there is still more to come
                end if;

                empty_v := '0';                                     -- If it wasn't full then it also couldn't be empty

            end if;
            -------------------------------------------------
            -- Downstream logic

            rdata       <= payload(to_integer(rd_ptr_v));       -- Placing the pointed data slot to the output
            
            if(rd = '1' and empty_v /= '1') then                    -- If it isn't empty, and the downstream side wants to read out

                

                rd_ptr_v    := rd_ptr_v + 1;                        -- Incrementing the read pointer

                if(wr_ptr_v = rd_ptr_v) then                        -- After it (in the same cycle) if the two pointers are pointing to the same slot
                    empty_v := '1';                                 -- after the read, then the FIFO got emptied out
                else
                    empty_v := '0';                                 -- Otherwise, there is still something inside
                end if;

                full_v := '0';                                      -- If it wasn't empty, then it also couldn't be full
            end if;
            -------------------------------------------------

            -- Driving the control outputs
            empty       <= empty_v      ;
            full        <= full_v       ;

        end if;
    end process;
    ------------------------------------------------------------------






end architecture;
---------------------------------------------------------------------------------------------------