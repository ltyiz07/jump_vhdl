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

entity Right_Left is
	port (
			FPGA_RSTB : IN std_logic;
			FPGA_CLK : IN std_logic;
			LCD_A : OUT std_logic_vector (1 downto 0);
			LCD_EN : OUT std_logic;
			LCD_D : OUT std_logic_vector (7 downto 0)
			);
end Right_Left;

architecture Behavioral of Right_Left is

-- 시간 설정부
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
			if (lcd_cnt >= "001001011") then -- 총 상태가 74개이므로 1개의 여유를 두어 75로 선택합니다.
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
			when others =>	lcd_db <= (others => '0');
		end case;
	
		if lcd_state >= X"07" and lcd_state < X"16" then
			lcd_db <= "00011100";		-- Shift to the Right
		elsif lcd_state >= X"16" and lcd_state < X"25" then
			lcd_db <= "00011000";		-- Shift to the Left
		end if;
	end process;

LCD_A(1) <= '0';
LCD_A(0) <= '1' when (lcd_state = X"06") else '0'; -- 명령이 아닌 문자를 입력해야하는 상태일 때만 LCD_A(0)를 1로 만듭니다.
LCD_EN <= not lcd_cnt(0); -- 입력 허가 상태와 불가 상태를 반복합니다. 이렇게 하면 캐리어가 자동으로 오른편으로 넘어갑니다.
LCD_D <= lcd_db;

end Behavioral;
