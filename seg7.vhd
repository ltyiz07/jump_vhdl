--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    15:15:45 04/10/09
-- Design Name:    
-- Module Name:    seg7 - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
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

entity seg7 is
    Port ( RSTB : in std_logic;
           CLK_50M : in std_logic;
           DIGIT : inout std_logic_vector(5 downto 0);
           SEG : out std_logic_vector(6 downto 0));
end seg7;

architecture Behavioral of seg7 is

signal clk_500 : std_logic;

begin
-----------------자리선택  Clock 5MHz ----------------------
	process(RSTB,CLK_50M)

	variable cnt : integer range 0 to 5000000;

		begin
		
			if RSTB = '0' then
				cnt := 0;
				clk_500 <= '0';
			
			elsif rising_edge (CLK_50M) then
 		
				if cnt >= 4999999 then
					cnt := 0;
					clk_500 <= not clk_500;

				else
					cnt := cnt + 1;
					clk_500 <= clk_500;

				end if;

			end if;

		end process;	
-------------------Digit selection-------------------------

	process(RSTB,clk_500)

		begin

			if RSTB = '0' then
				DIGIT <= "100000";
			
			elsif rising_edge (clk_500) then
				
				DIGIT <=  DIGIT(0) & DIGIT(5 downto 1)   ;

			end if;

		end process;

-------------각 자리마다 숫자 지정----------------------------	
	process(DIGIT)

		begin

			case DIGIT is
							              --gfedcba
				when "100000" => seg <= "0000110";  --가장 오른쪽디지트 1
				when "010000" => seg <= "1011011";  --2
				when "001000" => seg <= "1001111";  --3
				when "000100" => seg <= "1100110";  --4
				when "000010" => seg <= "1101101";  --5
				when "000001" => seg <= "1111101";  --가장 왼쪽디지트 6
				when others   => seg <= "0000000";  --
	
			end case;

		end process;	

end Behavioral;
