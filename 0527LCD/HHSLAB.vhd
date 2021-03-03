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

entity LCD_test is
	port (
			FPGA_RSTB : IN std_logic;
			FPGA_CLK : IN std_logic;
			LCD_A : OUT std_logic_vector (1 downto 0);
			LCD_EN : OUT std_logic;
			LCD_D : OUT std_logic_vector (7 downto 0)
			);
end LCD_test;

architecture Behavioral of LCD_test is
--시간 설정 부분
signal clk_100k : std_logic;
signal clk_50 : std_logic;
--LCD 기능 관련 부분
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

	process(FPGA_RSTB,clk_100k)		--Clock(50Hz) Generator
	
	variable cnt_50 : integer range 0 to 1000;
	
	begin
		if FPGA_RSTB = '0' then
			cnt_50 := 0;
			clk_50 <= '0';
		elsif rising_edge (clk_100k) then
			if cnt_50 >= 999 then
				cnt_50 := 0;
				clk_50 <= not clk_50;
			else 
				cnt_50 := cnt_50 + 1;
			end if;
		end if;
	end process;

	process(FPGA_RSTB,clk_50,lcd_cnt)
	begin
		if FPGA_RSTB = '0' then
			lcd_cnt <= (others => '0');
		elsif rising_edge (clk_50) then
			if (lcd_cnt >= "001001101") then -- 상태는 총 76개이므로 여유를 두어 77로 설정
				lcd_cnt <= lcd_cnt;
			else
				lcd_cnt <= lcd_cnt + 1;
			end if;
		end if;
	end process;

lcd_state <= lcd_cnt (8 downto 1);

	process(lcd_state)
	begin
		case lcd_state is
			when  X"00" =>	lcd_db <= "00111000";		-- Function set
			when  X"01" => lcd_db <= "00001000";		-- Display OFF
			when  X"02" => lcd_db <= "00000001";		-- Display clear
			when 	X"03" => lcd_db <= "00000110";		-- Entry mode set
			when	X"04" => lcd_db <= "00001100";		-- Display ON
			when	X"05" => lcd_db <= "00000011";		-- Return Home

			when  X"06" =>	lcd_db <= X"20";		-- 공백
			when  X"07" =>	lcd_db <= X"20";		-- 공백
			when  X"08" =>	lcd_db <= X"20";		-- 공백
			when  X"09" =>	lcd_db <= X"20";		-- 공백
			when  X"0A" =>	lcd_db <= X"48";		-- H
			when  X"0B" =>	lcd_db <= X"48";		-- H
			when  X"0C" =>	lcd_db <= X"53";		-- S
			when  X"0D" =>	lcd_db <= X"20";		-- 공백
			when  X"0E" =>	lcd_db <= X"4C";		-- L
			when  X"0F" =>	lcd_db <= X"41";		-- A
			when  X"10" =>	lcd_db <= X"42";		-- B
			when  X"11" =>	lcd_db <= X"2E";		-- .
			when  X"12" =>	lcd_db <= X"20";		-- 공백
			when  X"13" =>	lcd_db <= X"20";		-- 공백
			when  X"14" =>	lcd_db <= X"20";		-- 공백
			when  X"15" =>	lcd_db <= X"20";		-- 공백

			when  X"16" =>	lcd_db <= X"C0";		-- Change Line

			when  X"17" =>	lcd_db <= X"20";		-- 공백
			when  X"18" =>	lcd_db <= X"20";		-- 공백
			when  X"19" =>	lcd_db <= X"20";		-- 공백
			when  X"1A" =>	lcd_db <= X"20";		-- 공백
			when  X"1B" =>	lcd_db <= X"4C";		-- L
			when  X"1C" =>	lcd_db <= X"43";		-- C
			when  X"1D" =>	lcd_db <= X"44";		-- D
			when  X"1E" =>	lcd_db <= X"20";		-- 공백
			when  X"1F" =>	lcd_db <= X"54";		-- T
			when  X"20" =>	lcd_db <= X"45";		-- E
			when  X"21" =>	lcd_db <= X"53";		-- S
			when  X"22" =>	lcd_db <= X"54";		-- T
			when  X"23" =>	lcd_db <= X"20";		-- 공백
			when  X"24" =>	lcd_db <= X"20";		-- 공백
			when  X"25" =>	lcd_db <= X"20";		-- 공백
			when  X"26" =>	lcd_db <= X"20";		-- 공백

			when others =>	lcd_db <= (others => '0');
		end case;
	end process;

LCD_A(1) <= '0';
LCD_A(0) <= '0' when (lcd_state >= X"00" and lcd_state < X"06") or (lcd_state = X"16") else '1'; -- LCD 명령 입력시 LCD_A(0)비트를 0로 한다.
LCD_EN <= not lcd_cnt(0); -- 입력 허가상태와 입력 금지 상태를 반복한다. 이렇게 하면 자동으로 한 칸씩 캐리어가 옮겨지게 되어있다.
LCD_D <= lcd_db;

end Behavioral;
