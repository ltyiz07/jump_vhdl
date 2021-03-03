library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sensor_test is
	port (
			FPGA_RSTB : IN std_logic;
			FPGA_CLK    : IN std_logic;
			SEN_IN    : IN std_logic_vector (6 downto 0);
			SEN_OUT   : OUT std_logic_vector (6 downto 0);
			SC_LED    : OUT std_logic;  --센서부 center 돌출LED
			SR_LED    : OUT std_logic;  --센서부 right 돌출 LED
			SL_LED    : OUT std_logic;  --센서부 left 돌출 LED
			LED       : OUT std_logic_vector (6 downto 0)
			);			
end sensor_test;

architecture Behavioral of sensor_test is

signal cnt : std_logic_vector (15 downto 0);
signal load : std_logic;
signal clk_5k : std_logic;
signal sclk : std_logic;

begin


--========================================= Clock(5kHz) Generator =====================
	process(FPGA_RSTB,FPGA_CLK,load,cnt)
	begin
		if FPGA_RSTB = '0' then
			cnt <= (others => '0');
			clk_5k <= '0';
		elsif rising_edge (FPGA_CLK) then
			if load = '1' then
				cnt <= (others => '0');
				clk_5k <= not clk_5k;
			else 
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	load <= '1' when (cnt = X"2710") else '0';          --X"2710" = 10,000
--======================================================================================
--==================================== Sensor Clock(2.5kHz) Generator ===================
	process(FPGA_RSTB,clk_5k,sclk)
	begin
		if FPGA_RSTB = '0' then
			sclk <= '0';
		elsif rising_edge (clk_5k) then
			sclk <= not sclk;
		end if;
	end process;
--======================================================================================

SEN_OUT(0) <= sclk;
SEN_OUT(1) <= sclk;
SEN_OUT(2) <= sclk;
SEN_OUT(3) <= sclk;
SEN_OUT(4) <= sclk;
SEN_OUT(5) <= sclk;
SEN_OUT(6) <= sclk;

LED <= SEN_IN;

SC_LED <= '1' when SEN_IN(3) = '1' else '0';
SL_LED <= '1' when SEN_IN(0) = '1' else '0';
SR_LED <= '1' when SEN_IN(6) = '1' else '0';

end Behavioral;
