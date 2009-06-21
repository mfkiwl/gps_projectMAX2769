-----------------------------------------------------------
-- rs232 main module 
--
--
-- Developer: Alex Nikiforov nikiforov.al [at] gmail.com
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rs232main is
    	Port (	clk : in STD_LOGIC ;
		reset : in STD_LOGIC ; -- FIXME ucf-file
		dout : out STD_LOGIC_VECTOR (7 downto 0) ; 
		din : in STD_LOGIC_VECTOR (7 downto 0) ; 
		rs232_in: in std_logic ;
		rs232_out: out std_logic ;
		rx_done_tick : out std_logic ;
		tx_done_tick : out std_logic ;
		tx_start : in std_logic
	     );
end rs232main;

architecture Behavioral of rs232main is
	signal rs232_clk: std_logic ;
	
begin

rs232clk_unit: entity work.rs232clk(arch)
	port map( clk => clk, rs232_clk => rs232_clk );	

rs232rx_unit: entity work.rs232rx(arch)
	port map( clk => clk, reset => reset, dout => dout,
	          rs232_clk => rs232_clk, rx_done_tick => rx_done_tick, rs232_in => rs232_in );	

rs232tx_unit: entity work.rs232tx(arch)
	port map( clk => clk, reset => reset, din => din,
	          rs232_out => rs232_out, tx_start => tx_start, tx_done_tick => tx_done_tick, rs232_clk => rs232_clk);	
	
end Behavioral;