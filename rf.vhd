library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
entity rf_con is 
        port ( RF_DATA : IN std_logic_vector (2 downto 0); 
                 LED        : OUT std_logic_vector (2 downto 0);
				seg			: out std_logic_vector(6 downto 0)
                 ); 
end rf_con; 

architecture Behavioral of rf_con is 
begin 
LED <= RF_DATA; 



process(RF_DATA)

		begin

			case RF_DATA is
							              --gfedcba
				when "001" => seg <= "1111101";  --가장 오른쪽디지트 1
				when "010" => seg <= "1101101";  --2
				when "100" => seg <= "1100110";  --3
				when others   => seg <= "0000000";  --
	
			end case;

		end process;	
		
		
end Behavioral; 


