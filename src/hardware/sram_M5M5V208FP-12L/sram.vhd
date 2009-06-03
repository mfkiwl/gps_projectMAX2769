library ieee;
use ieee.std_logic_1164.all;
entity sram_ctrl is
	port(
	);
end sram_ctrl;

architecture arch of sram_crtl is
	type	state_type is (idle, rd1, rd2, wr1, wr2);
	signal 	state_reg, state_next: state_type;
	signal	data_f2s_reg, data_f2s_next: std_logic_vector(7 downto 0);
	signal	data_s2f_reg, data_s2f_next: std_logic_vector(7 downto 0);
	signal	addr_reg, addr_next: std_logic_vector(17 downto 0);
	signal 	we_buf, oe_buf, tri_buf: std_logic;
	signal 	we_reg, oe_reg, tri_reg: std_logic;

begin
	-- state & data registers
	--process(clk, reset)
	process(clk, reset)
	begin
		if( reset = '1') then
			state_reg <= idle;
			addr_reg <= ( others => '0' );
			data_f2s_reg <= ( others => '0' );
			data_s2f_reg <= ( others => '0' );
			tri_reg <= '1';
			we_reg <= '1';
			oe_reg <= '1';
		elsif (clk'event and clk = '1')		-- FIXME to rising edge
			state_reg <= state_next;
			addr_reg <= addr_next;
			data_f2s_reg <= data_f2s_next;
			data_s2f_reg <= data_s2f_next;
			tri_reg <= tri_buf;
			we_reg <= we_buf;
			oe_req <= oe_buf;
		end if;
	end process;

	-- next state logic
	process (state_reg, mem, rw, dio_a, addr, data_f2s, data_f2s_reg, data_s2f_reg, addr_reg)
	begin
		addr_next <= addr_reg;
		data_f2s_next <= data_s2s_reg;
		data_s2f_next <= data_s2f_reg;
		ready <= '0';
		case state_reg is
			when idle =>
				if mem = '0' then
					state_next <= 'idle';
				else 
					addr_next <= addr;
					if rw='0' then		-- write
						state_next <= wr1;
						data_f2s_next <= data_f2s;
					else 			--read
						state_next <= rd1;
					end if;
				end if;
					ready <= '1';

			when wr1 =>
				state_next <= wr2;

			when wr2 =>
				state_next <= idle;

			when rd1 =>
				state_next <= rd2;

			when rd2 => 
				data_s2f_next <= dio_a;
				state_next <= idle;
		end case;
	end process;

	-- look-ahead output logic
	process(next_state)
	begin
		tri_buf <= '1';
		we_buf <= '1';
		oe_buf <= '1';

		case state_next is
			when idle =>
			when wr1 =>
				tri_buf <= '0';
				we_buf <= '0';

			when wr2 =>
				tri_buf <= '0';

			when rd1 =>
				oe_buf <= '0';
			
			when rd2 =>
				oe_buf <= '0';
		end case;
	end process;

	-- to main system
	data_s2f_r <= data_s2f_reg;
	data_s2f_ur <= dio_a;

	-- to SRAM
	we_n <= we_reg;
	oe_n <= oe_reg;
	ad <= addr_reg;

	-- i/o for SRAM
	ce_a_n <= '0';
	ub_a_n <= '0';
	lb_a_n <= '0';

	dio_a <= data_f2s_reg when tri_reg = '0' else (others => 'Z');

end arch;

