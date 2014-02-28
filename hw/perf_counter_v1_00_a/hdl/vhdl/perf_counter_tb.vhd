-- Testbench of Performance Counter for MicroBlaze 
-- Author: Mohamed A. Bamakhrama <m.a.m.bamakhrama@liacs.leidenuniv.nl>
-- Copyrights (c) 2010 by Universiteit Leiden

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity perf_counter_tb is
end perf_counter_tb;

architecture sim of perf_counter_tb is

constant clock_frequency : natural := 100_000_000;
constant clock_period : time := 1000 ms  /clock_frequency;

signal clock : std_logic := '0';
signal rst : std_logic := '1'; --active high reset

signal tb_FSL_Clk   : std_logic;
signal tb_FSL_Rst   : std_logic;
signal tb_FSL_S_Clk : std_logic;
signal tb_FSL_S_Read    : std_logic;
signal tb_FSL_S_Data    : std_logic_vector(0 to 31);
signal tb_FSL_S_Control : std_logic;
signal tb_FSL_S_Exists  : std_logic;
signal tb_FSL_M_Clk : std_logic;
signal tb_FSL_M_Write   : std_logic;
signal tb_FSL_M_Data    : std_logic_vector(0 to 31);
signal tb_FSL_M_Control : std_logic;
signal tb_FSL_M_Full    : std_logic;

component perf_counter
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
end component;

begin
    clock <= not clock after clock_period/2;
    tb_FSL_Clk <= clock;
    tb_FSL_Rst <= rst;

    dut: perf_counter 
        port map (
            FSL_Clk => tb_FSL_Clk,
            FSL_Rst => tb_FSL_Rst,
            FSL_S_Clk => open,
            FSL_S_Read => tb_FSL_S_Read,
            FSL_S_Control => tb_FSL_S_Control,
            FSL_S_Data => tb_FSL_S_Data,
            FSL_S_Exists => tb_FSL_S_Exists,
            FSL_M_Clk => open,
            FSL_M_Write => tb_FSL_M_Write,
            FSL_M_Data => tb_FSL_M_Data,
            FSL_M_Control => tb_FSL_M_Control,
            FSL_M_Full => tb_FSL_M_Full
        );
    stim: process
    begin
        rst <= '0';
        wait for clock_period;
        rst <= '1';
        wait for clock_period;
        rst <= '0';
        tb_FSL_S_Exists <= '1';
        tb_FSL_S_Data <= X"00000000";
        wait for clock_period;
        tb_FSL_S_Exists <= '1';
        tb_FSL_S_Data <= X"00000001";
        wait for clock_period;
        tb_FSL_S_Exists <= '1';
        tb_FSL_S_Data <= X"0000000A";
        wait for clock_period;
        tb_FSL_S_Exists <= '0';
        tb_FSL_S_Data <= X"00000000";       
        wait for 10*clock_period;       
        tb_FSL_S_Exists <= '1';
        tb_FSL_S_Data <= X"0000000B";
        wait for clock_period;
        tb_FSL_S_Exists <= '0';
        tb_FSL_S_Data <= X"00000000";       
        wait for 10*clock_period;
        tb_FSL_S_Exists <= '1';
        tb_FSL_S_Data <= X"0000000C";
        wait for clock_period;
        tb_FSL_S_Exists <= '0';
        tb_FSL_S_Data <= X"00000000";       
        wait for 10*clock_period;       
        assert false report "Testbench terminated successfully!" severity note;
        assert false report "Simulation stopped" severity failure; 
    end process;
    
end sim;
