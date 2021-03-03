library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity diff_step is
    Port ( CLK_50M : in std_logic;
           RSTB : in std_logic;
           DIP_SW : std_logic_vector(3 downto 0);
			  MTR : out std_logic_vector(3 downto 0);
           MTL : out std_logic_vector(3 downto 0));
end diff_step;

architecture Behavioral of diff_step is

signal key_in_l : std_logic_vector (1 downto 0);
signal key_in_r : std_logic_vector (1 downto 0);

signal speed_l : integer range 0 to 250000;
signal speed_r : integer range 0 to 250000;
signal motor_lcnt : integer range 0 to 250000;
signal phase_lclk : std_logic;
signal motor_rcnt : integer range 0 to 250000;
signal phase_rclk : std_logic;

signal phase_lcnt : std_logic_vector (1 downto 0);
signal phase_lout : std_logic_vector (3 downto 0);
signal phase_rcnt : std_logic_vector (1 downto 0);
signal phase_rout : std_logic_vector (3 downto 0);

begin
-------------DIP SW로 모터의 속도결정-----------------
	key_in_l <= (not DIP_SW(0) & not DIP_SW(1));
	key_in_r <= (not DIP_SW(2) & not DIP_SW(3));

	process(key_in_l)
	variable for_sim : std_logic;

	begin

		for_sim := '0';
		if for_sim = '0' then
			case key_in_l is
				when "00" => speed_l <= 0;
				when "01" => speed_l <= 166666;   -- 150Hz --249999 100Hz 로 하면 구동안됨
				when "10" => speed_l <= 124999;   -- 200Hz
				when "11" => speed_l <= 78124;    -- 320Hz
				when others => speed_l <= 78124;
			end case;
		else
			case key_in_l is
				when "00" => speed_l <= 0;
				when "01" => speed_l <= 8;
				when "10" => speed_l <= 4;
				when "11" => speed_l <= 2;
				when others => speed_l <= 2;
			end case;
		end if;
	end process;

	process(key_in_r)
	variable for_sim : std_logic;

	begin
		for_sim := '0';
		if for_sim = '0' then
			case key_in_r is
				when "00" => speed_r <= 0;
				when "01" => speed_r <= 249999;  -- 150Hz --249999 100Hz 로 하면 구동안됨
				when "10" => speed_r <= 124999;  -- 200Hz 
				when "11" => speed_r <= 78124;   -- 320Hz
				when others => speed_r <= 78124;
			end case;
		else
			case key_in_r is
				when "00" => speed_r <= 0;
				when "01" => speed_r <= 8;
				when "10" => speed_r <= 4;
				when "11" => speed_r <= 2;
				when others => speed_r <= 2;
			end case;
		end if;
	end process;

	process(RSTB,speed_l,CLK_50M,motor_lcnt)

	begin
		if RSTB = '0' or speed_l = 0 then
			motor_lcnt <= 0;
			phase_lclk <='0';
		
		elsif rising_edge (CLK_50M) then
			
			if (motor_lcnt >= speed_l)	then
				motor_lcnt <=0;
				phase_lclk <= not phase_lclk;
			
			else
				motor_lcnt <= motor_lcnt + 1;
			end if;
		end if;
	end process;

	process(RSTB,speed_r,CLK_50M,motor_rcnt)

	begin
		if RSTB = '0' or speed_r = 0 then
			motor_rcnt <= 0;
			phase_rclk <='0';
		
		elsif rising_edge (CLK_50M) then
			
			if (motor_rcnt >= speed_r)	then
				motor_rcnt <= 0;
				phase_rclk <= not phase_rclk;			

			else
				motor_rcnt <= motor_rcnt + 1;
			end if;
		end if;
	end process;
----------------------------------------------------------
-------------왼쪽모터 상 출력(1상 여자방식)---------------
	process(RSTB,phase_lclk,phase_lcnt)
	
	begin
		if RSTB = '0' then
			phase_lcnt <= (others => '0');
		
		elsif rising_edge (phase_lclk) then 
			phase_lcnt <= phase_lcnt + 1;
		end if;
	end process;
	
	process(RSTB,phase_lcnt)
	begin
		if RSTB = '0' then
			phase_lout <= (others =>'0');
		
		else
			case phase_lcnt is 
				when "00" => phase_lout <= "1000";
				when "01" => phase_lout <= "0100";
				when "10" => phase_lout <= "0010";
				when "11" => phase_lout <= "0001";
				when others => phase_lout <= "0000";
			end case;
		end if;
	end process;
------------------------------------------------------
------------오른쪽모터 상 출력(1상 여자방식)---------------
	process(RSTB,phase_rclk,phase_rcnt)
	
	begin
		if RSTB = '0' then
			phase_rcnt <= (others => '0');
		
		elsif rising_edge (phase_rclk) then 
			phase_rcnt <= phase_rcnt + 1;
		end if;
	end process;
	
	process(RSTB,phase_rcnt)
	begin
		if RSTB = '0' then
			phase_rout <= (others =>'0');
		
		else
			case phase_rcnt is 
				when "00" => phase_rout <= "0001";
				when "01" => phase_rout <= "0010";
				when "10" => phase_rout <= "0100";
				when "11" => phase_rout <= "1000";
				when others => phase_rout <= "0000";
			end case;
		end if;
	end process;

	MTL(0) <= phase_lout(0);
	MTL(1) <= phase_lout(1);
	MTL(2) <= phase_lout(2);
	MTL(3) <= phase_lout(3);

	MTR(0) <= phase_rout(0);
	MTR(1) <= phase_rout(1);
	MTR(2) <= phase_rout(2);
	MTR(3) <= phase_rout(3);

end Behavioral;
