library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity motor1_rot is
    Port ( clk_50m : in  STD_LOGIC;
           rstb : in  STD_LOGIC;
           mtl_a : out  STD_LOGIC;
           mtl_b : out  STD_LOGIC;
           mtl_na : out  STD_LOGIC;
           mtl_nb : out  STD_LOGIC;
		   --오른쪽 바퀴 추가
		   mtr_a : out STD_LOGIC;
		   mtr_b : out STD_LOGIC;
		   mtr_na : out STD_LOGIC;
		   mtr_nb : out STD_LOGIC
		   );
end motor1_rot;

architecture Behavioral of motor1_rot is

signal cnt : std_logic_vector (15 downto 0);
signal mtr_clk : std_logic;
signal mot_cnt : std_logic_vector (1 downto 0);
signal phase_out : std_logic_vector (3 downto 0);

signal stop : std_logic;
signal step_cnt : integer range 0 to 50000;


begin

--======================Motor Clock(500 Hz) Generator=============
	process(rstb, clk_50m, cnt)
	begin
		if rstb = '0' then
			cnt <= (others => '0');
			mtr_clk <= '0';
			
		elsif rising_edge(clk_50m) then
			
			if cnt = X"c350" then              --X"c350"은 이진수로 1100 0011 0101 0000 십진수로 50000을 의미
				cnt <= (others=>'0');
				mtr_clk <= not mtr_clk;
			else
				cnt <= cnt + '1';
							
			end if;
		end if;
	end process;
	
--================================================================
--=====================Phase Output(1상 여자방식)===================
	process(mtr_clk, rstb, mot_cnt)
	begin
		if rstb = '0' then
			mot_cnt <= (others => '0');
		elsif rising_edge (mtr_clk) then
			mot_cnt <= mot_cnt+1;
		end if;
	end process;
	
	process(mot_cnt,rstb)
	begin
			if rstb = '0' then
				phase_out <= (others => '0');
			else
				case mot_cnt is
					when "00" => phase_out <= "0001";
					when "01" => phase_out <= "0010";
					when "10" => phase_out <= "0100";
					when "11" => phase_out <= "1000";
					when others => phase_out <= "0000";
				end case;
			end if;
		end process;
--=======================================================================
--=================2바퀴만 회전 후, 정지====================================
		process(rstb, mtr_clk, step_cnt,stop)
		begin
			if	rstb = '0' then
				stop <= '0';	step_cnt <=0;
			elsif rising_edge(mtr_clk) then
			--두바퀴 회전후 정지 임으로 200=>400 대체
				if step_cnt >=400	then
					stop <='1';
				else
					step_cnt<= step_cnt + 1;
				end if;
			
			end if;
		end process;
		mtl_a <= phase_out(3) when stop = '0' else '0';
		mtl_b <= phase_out(2) when stop = '0' else '0';
		mtl_na <= phase_out(1) when stop = '0' else '0';
		mtl_nb <= phase_out(0) when stop = '0' else '0';
		--오른쪽 바퀴도 같은 방향으로 돌아야함으로 페이즈 비트를 반대로 대입
		mtr_a <= phase_out(0) when stop = '0' else '0';
		mtr_b <= phase_out(1) when stop = '0' else '0';
		mtr_na <= phase_out(2) when stop = '0' else '0';
		mtr_nb <= phase_out(3) when stop = '0' else '0';
		
--======================================================
			
	
	
end Behavioral;

