--------------------------------------------------------------------------------
-- Company: Libertron
-- Engineer: Ki-Seok Kim
--
-- Create Date:    
-- Design Name:    
-- Module Name:    LCD_test - Behavioral
-- Project Name:   ATOM
-- Target Device:  XC3S400-FT256
-- Tool versions:  ISE9.2i
-- Description: LCD Test Design
--
-- Dependencies:
-- 
-- Revision: V1.0
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stop_right_left is
	port (
			FPGA_RSTB : IN std_logic;
			FPGA_CLK : IN std_logic;
			LCD_A : OUT std_logic_vector (1 downto 0);
			LCD_EN : OUT std_logic;
			LCD_D : OUT std_logic_vector (7 downto 0)
			);
end stop_right_left;

architecture Behavioral of stop_right_left is

-- 시간 조절부
signal clk_100k : std_logic;
signal clk_25 : std_logic;
-- LCD 기능부
signal lcd_cnt : std_logic_vector (8 downto 0);
signal lcd_state : std_logic_vector (7 downto 0);
signal lcd_db : std_logic_vector (7 downto 0);

begin

	process(FPGA_RSTB,FPGA_CLK)		--Clock(100kHz) Generator
	
	variable cnt_100k : integer range 0 to 250;
	
	begin
		if FPGA_RSTB = '0' then
			cnt_100k := 0;
			clk_100k <= '0';
		elsif rising_edge (FPGA_CLK) then
			if cnt_100k >= 249 then
				cnt_100k := 0;
				clk_100k <= not clk_100k;
			else 
				cnt_100k := cnt_100k + 1;
			end if;
		end if;
	end process;

	process(FPGA_RSTB,clk_100k)		--Clock(25Hz) Generator
	
	variable cnt_25 : integer range 0 to 2000;
	
	begin
		if FPGA_RSTB = '0' then
			cnt_25 := 0;
			clk_25 <= '0';
		elsif rising_edge (clk_100k) then
			if cnt_25 >= 1999 then
				cnt_25 := 0;
				clk_25 <= not clk_25;
			else 
				cnt_25 := cnt_25 + 1;
			end if;
		end if;
	end process;

	process(FPGA_RSTB,clk_25,lcd_cnt)
	begin
		if FPGA_RSTB = '0' then
			lcd_cnt <= (others => '0');
		elsif rising_edge (clk_25) then
			if (lcd_cnt >= "001010001") then -- 상태는 총 40 X 2 개 있으므로 81을 2진수로 바꾼 수를 선택합니다. 여유 상태 1을 남깁니다.
				lcd_cnt <= (others => '0');
			else
				lcd_cnt <= lcd_cnt + 1;
			end if;
		end if;
	end process;

lcd_state <= lcd_cnt (8 downto 1);

	process(lcd_state, lcd_cnt)	
	begin
		case lcd_state is
			when  X"00" =>	lcd_db <= "00111000";		-- Function set
			when  X"01" => lcd_db <= "00001000";		-- Display OFF
			when  X"02" => lcd_db <= "00000001";		-- Display clear
			when 	X"03" => lcd_db <= "00000110";		-- Entry mode set
			when	X"04" => lcd_db <= "00001100";		-- Display ON
			when	X"05" => lcd_db <= "00000011";		-- Return Home
			when	X"06" => lcd_db <= X"53";				-- S
			when	X"07" => lcd_db <= X"54";				-- T
			when	X"08" => lcd_db <= X"4F";				-- O
			when	X"09" => lcd_db <= X"50";				-- P
			when others =>	lcd_db <= (others => '0');
		end case;
	
		if lcd_state >= X"10" and lcd_state < X"1C" then
			lcd_db <= "00011100";		-- 12회 오른편으로 시프트
		elsif lcd_state >= X"1C" and lcd_state < X"28" then
			lcd_db <= "00011000";		-- 12회 왼편으로 시프트
		end if;
	end process;

LCD_A(1) <= '0';
LCD_A(0) <= '1' when (lcd_state >= X"06" and lcd_state <= X"09") else '0'; -- STOP이라는 네 글자를 입력할 때만 LCD_A(0) 비트가 1이 됩니다.
LCD_EN <= not lcd_cnt(0); -- 입력 허가 상태와 입력 불가 상태를 반복하여 캐리어를 오른편으로 한 칸씩 이동시킵니다.
LCD_D <= lcd_db;

end Behavioral;

