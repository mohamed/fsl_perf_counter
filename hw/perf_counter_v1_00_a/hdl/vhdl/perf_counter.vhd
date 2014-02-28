-- Performance Counter for MicroBlaze
-- Author: Mohamed A. Bamakhrama <m.a.m.bamakhrama@liacs.leidenuniv.nl>
-- Copyrights (c) 2010 by Universiteit Leiden

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity perf_counter is
generic
(
    C_NUM_OF_COUNTERS : integer := 4;
    C_LOG2_NUM_OF_COUNTERS : integer := 2;
    C_EXT_RESET_HIGH : integer := 1
);
port 
(
    FSL_Clk : in    std_logic;
    FSL_Rst : in    std_logic;
    FSL_S_Clk   : out   std_logic;
    FSL_S_Read  : out   std_logic;
    FSL_S_Data  : in    std_logic_vector(0 to 31);
    FSL_S_Control   : in    std_logic;
    FSL_S_Exists    : in    std_logic;
    FSL_M_Clk   : out   std_logic;
    FSL_M_Write : out   std_logic;
    FSL_M_Data  : out   std_logic_vector(0 to 31);
    FSL_M_Control   : out   std_logic;
    FSL_M_Full  : in    std_logic
);
end perf_counter;

architecture rtl of perf_counter is

constant MSB_OP : integer := 31;
constant LSB_OP : integer := 29;
constant MSB_ID : integer := 28;
constant LSB_ID : integer := 28-C_LOG2_NUM_OF_COUNTERS+1;

constant RST_ALL  : std_logic_vector(0 to 2) := "000";
constant RST_ID   : std_logic_vector(0 to 2) := "001";
constant START_ID : std_logic_vector(0 to 2) := "010";
constant STOP_ID  : std_logic_vector(0 to 2) := "011";
constant READ_ID  : std_logic_vector(0 to 2) := "100";

-- 64-bit counter @ 100MHz = > 5800 years
-- This eliminates the need for handling overflows
type counter_t is array(1 to C_NUM_OF_COUNTERS) of std_logic_vector(0 to 63);
signal counter : counter_t; 

type op_t is (idle, running, reset, rd);
type op_array_t is array(1 to C_NUM_OF_COUNTERS) of op_t;
signal op_r : op_array_t;
signal op_i : op_array_t;

subtype id_int_t is integer range 0 to C_NUM_OF_COUNTERS;
signal rd_id_r : id_int_t;
signal rd_id_i : id_int_t;

signal rst : std_logic;

begin

rst <= FSL_Rst when (C_EXT_RESET_HIGH = 1) else not FSL_Rst;
FSL_M_Control <= '0';
FSL_M_Clk <= FSL_Clk;
FSL_S_Clk <= FSL_Clk;

registers: process(FSL_Clk)
begin
    if rising_edge(FSL_Clk) then
        if (rst = '1') then
            counter <= (others => (others => '0'));
            op_r <= (others => idle);
            rd_id_r <= 0;
        else
            op_r <= op_i;
            rd_id_r <= rd_id_i;
            for i in 1 to C_NUM_OF_COUNTERS loop
                case (op_i(i)) is
                    when idle =>
                        counter(i) <= counter(i);
                    when running =>
                        counter(i) <= std_logic_vector(unsigned(counter(i))+1);
                    when reset =>
                        counter(i) <= (others => '0');
                    when rd =>
                        counter(i) <= counter(i);
                    when others =>
                        null;
                end case;
            end loop;
        end if;
    end if;
end process;

fsm: process(FSL_S_Exists, FSL_S_Data, op_r, counter, rd_id_r)

variable id : integer;

begin
    -- Default assignments
    id := 0;
    op_i <= op_r;
    FSL_M_Data <= (others => '0');
    FSL_M_Write <= '0';
    FSL_S_Read <= '0';
    rd_id_i <= 0;
    if (FSL_S_Exists = '1' and rd_id_r = 0) then
        id := to_integer(unsigned(FSL_S_Data(LSB_ID to MSB_ID))) + 1;
        case(FSL_S_Data(LSB_OP to MSB_OP)) is
            when RST_ALL =>
                op_i <= (others => reset);
                FSL_S_Read <= '1';
            when RST_ID =>
                op_i(id) <= reset;
                FSL_S_Read <= '1';
            when STOP_ID =>
                op_i(id) <= idle;
                FSL_S_Read <= '1';
            when START_ID =>
                op_i(id) <= running;
                FSL_S_Read <= '1';              
            when READ_ID =>
                op_i(id) <= rd;
                rd_id_i <= id;
                FSL_S_Read <= '1';
                FSL_M_Data <= counter(id)(32 to 63);
                FSL_M_Write <= '1';
            when others =>
                null;
        end case;
    end if;
    if (rd_id_r /= 0) then
        op_i(rd_id_r) <= running;
        FSL_S_Read <= '0';
        FSL_M_Data <= counter(rd_id_r)(0 to 31);
        FSL_M_Write <= '1';
        rd_id_i <= 0;
    end if;
end process;


end architecture rtl;
