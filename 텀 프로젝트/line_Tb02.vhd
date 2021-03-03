----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:31:10 06/28/2020 
-- Design Name: 
-- Module Name:    line_Tb02 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity line_Tb02 is
    Port ( rstb : in std_logic;									--리셋버튼
           clk_50m : in std_logic;								--FPGA클락50MHz
           sen_in : in std_logic_vector(6 downto 0);		--센서 수광부
           sen_out : out std_logic_vector(6 downto 0);	--센서 발광부
			  SC_LED : out std_logic;								--센서부 확산형 중간LED
			  SR_LED : out std_logic;								--센서부 확산형 오른쪽LED
			  SL_LED : out std_logic;								--센서부 확산형 왼쪽LED
			  mtl : out std_logic_vector(3 downto 0);			--왼쪽 모터출력
           mtr : out std_logic_vector(3 downto 0);			--오른쪽 모터출력
			  rf_data : in std_logic_vector(2 downto 0);		--===========rf_data 입력 추가
			  buzzer : out std_logic := '0';				--!!==============buzzer 추가 in-out 문제해결!!!!!
	
			  SEG : out std_logic_vector(6 downto 0)		--=======segment 출력
			  );	
end line_Tb02;

architecture Behavioral of line_Tb02 is

signal sclk : std_logic;															--센서 구동클락
signal speed_l : integer range 0 to 250000;									--왼쪽 모터 주파수 분주변수
signal speed_r : integer range 0 to 250000;									--오른쪽 모터 주파수 분주변수
signal mtl_speed : std_logic_vector(1 downto 0);							--왼쪽 모터스피드 지정변수
signal mtr_speed : std_logic_vector(1 downto 0);							--오른쪽 모터스피드 지정변수
signal motor_lcnt : integer range 0 to 250000;								--왼쪽 모터 주파수 분주변수
signal phase_lclk : std_logic;													--왼쪽모터 구동클락
signal motor_rcnt : integer range 0 to 250000;								--오른쪽 모터 주파수 분주변수
signal phase_rclk : std_logic;													--오른쪽 모터 구동클락
signal phase_lcnt : std_logic_vector(1 downto 0);							--왼쪽 모터 상출력 구분변수
signal phase_lout : std_logic_vector(3 downto 0);							--왼쪽 모터 상출력상태변수
signal phase_rcnt : std_logic_vector(1 downto 0);							--오른쪽 모터 상출력 구분변수
signal phase_rout : std_logic_vector(3 downto 0) := "1000";							--오른쪽 모터 상출력상태변수
signal in_sen : std_logic_vector(6 downto 0);


--============sensor clock jenarate
begin

	process(rstb, clk_50m)                             --센서 클락(sclk) 생성

	variable cnt : integer range 0 to 4000;

	begin
	
		if rstb = '0' then
			cnt := 0;
			sclk <= '0';
		elsif rising_edge(clk_50m) then
			if cnt >= 3999 then					
				cnt := 0;
				sclk <= not sclk;					--주기 (1/50m)*4000*2 = 160microsec
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
--==========set sensor output
	sen_out(0) <= sclk;                    --센서발광부에 센서 클락으로 전원인가
	sen_out(1) <= sclk;
	sen_out(2) <= sclk;
	sen_out(3) <= sclk;
	sen_out(4) <= sclk;
	sen_out(5) <= sclk;
	sen_out(6) <= sclk;
	
	--=============timing problem 해결 위해 추가
	
	process(sclk, sen_in, in_sen)

	begin
		if falling_edge(sclk) then				--라인 트레이싱기능의 정상작동 위하여 추가.(sen_out의 값이 없을때에도 sen_in 에 값들이 변하는 문제 해결)
			in_sen <= sen_in;
		end if;

	end process;
	
--================rf_data, rstb inoutput set

	process(rstb, sclk, rf_data, in_sen)

	begin

		if rstb = '0' then
			mtl_speed <= "00";
			mtr_speed <= "00";						--리셋 버튼이 눌러졌을때 모터 정지
			buzzer <= '0';
			
					
		elsif  rf_data = "010" then		--===============010 눌렀을때 라인트레이싱 기능
				case in_sen is
					when "1110111" =>						--각각의 상황시에 왼쪽, 오른족바퀴에 속도를 다르게 함으로써 방향 조절.
						mtl_speed <= "11";
						mtr_speed <= "11";
					when "1100011" =>
						mtl_speed <= "01";
						mtr_speed <= "01";
					when "1100111" =>
						mtl_speed <= "11";
						mtr_speed <= "10";
					when "1101111" =>
						mtl_speed <= "11";
						mtr_speed <= "01";
					when "1000111" =>
						mtl_speed <= "11";
						mtr_speed <= "01";
					when "1001111" =>
						mtl_speed <= "11";
						mtr_speed <= "01";
					when "1011111" =>
						mtl_speed <= "11";
						mtr_speed <= "01";
					when "1110011" =>
						mtl_speed <= "10";
						mtr_speed <= "11";
					when "1111011" =>
						mtl_speed <= "01";
						mtr_speed <= "11";
					when "1110001" =>
						mtl_speed <= "01";
						mtr_speed <= "11";
					when "1111001" =>
						mtl_speed <= "01";
						mtr_speed <= "11";
					when "1111101" =>
						mtl_speed <= "01";
						mtr_speed <= "11";
					when others =>
						mtl_speed <= "00";
						mtr_speed <= "00";
				end case;
				buzzer <= '0';
			
		elsif  rf_data = "001" then			--============001 눌렀을때
			mtl_speed <= "01";
			mtr_speed <= "01";
			buzzer <= '1';
	
			--==============100 제자리 회전
			else 
				mtl_speed <= "00";
				mtr_speed <= "01";
				buzzer <= '0';
			
		end if;
	end process;
	
--========left motor speed set
	process(mtl_speed)

	begin

		case mtl_speed is							--왼쪽 모터 속도 결정 구문
			when "00" => speed_l <= 0;          --정지
			when "01" => speed_l <= 122222;     --300Hz
			when "10" => speed_l <= 100000;     --400Gz
			when "11" => speed_l <= 78125;      --640Hz
			when others => speed_l <= 78125;    --640Hz    -- 라인트레이싱시 각각의 상황에대해 모터의 속도 설정
		end case;

	end process;
	
--============right motor speed set
	process(mtr_speed)

	begin

		case mtr_speed is
			when "00" => speed_r <= 0;				-- 라인트레이싱시 각각의 상황에대해 모터의 속도 설정
			when "01" => speed_r <= 122222;
			when "10" => speed_r <= 100000;
			when "11" => speed_r <= 78125;
			when others => speed_r <= 78125;
		end case;

	end process;
	
	--==============set for motor clock left
	
	process(rstb, speed_l, clk_50m, motor_lcnt, phase_lclk)

	begin

		if rstb = '0' or speed_l = 0 then
			motor_lcnt <= 0;
			phase_lclk <= '0';
		elsif rising_edge(clk_50m) then
			if motor_lcnt >= speed_l then					--모터클락 분주를 통해 생성
				motor_lcnt <= 0;
				phase_lclk <= not phase_lclk;
			else
				motor_lcnt <= motor_lcnt + 1;
			end if;
		end if;

	end process;

	--==============set for motor clock right
	process(rstb, speed_r, clk_50m, motor_rcnt, phase_rclk)

	begin

		if rstb = '0' or speed_r = 0 then
			motor_rcnt <= 0;
			phase_rclk <= '0';
		elsif rising_edge(clk_50m) then
			if motor_rcnt >= speed_r then
				motor_rcnt <= 0;
				phase_rclk <= not phase_rclk;
			else
				motor_rcnt <= motor_rcnt + 1;
			end if;
		end if;

	end process;

--=============set motor phase left
	process(rstb, phase_lclk, phase_lcnt)

	begin

		if rstb = '0' then 
			phase_lcnt <= (others => '0');
		elsif rising_edge(phase_lclk) then
			phase_lcnt <= phase_lcnt + 1;		--상향 엣지에서 카운트 1 증가.
		end if;

	end process;

	process(rstb, phase_lclk, phase_lcnt, phase_lout)

	begin

		if rstb = '0' then
			phase_lout <= (others => '0');
		else
			case phase_lcnt is				--모터의 상 출력
				when "00" =>
					phase_lout <= "1000";
				when "01" =>
					phase_lout <= "0100";
				when "10" =>
					phase_lout <= "0010";
				when "11" =>
					phase_lout <= "0001";
				when others =>
					phase_lout <= "0000";
			end case;
		end if;

	end process;


--=============set motor phase right
	process(rstb, phase_rclk, phase_rcnt)

	begin

		if rstb = '0' then 
			phase_rcnt <= (others => '0');
		elsif rising_edge(phase_rclk) then
			phase_rcnt <= phase_rcnt + 1;
		end if;

	end process;

	process(rstb, phase_rclk, phase_rcnt, phase_rout)

	begin

		if rstb = '0' then
			phase_rout <= (others => '0');
		else
			case phase_rcnt is
				when "00" =>
					phase_rout <= "1000";
				when "01" =>
					phase_rout <= "0100";
				when "10" =>
					phase_rout <= "0010";
				when "11" =>
					phase_rout <= "0001";
				when others =>
					phase_rout <= "0000";
			end case;
		end if;

	end process;


--=====================7-seg========
			process(rf_data)

		begin

			case rf_data is
							           --gfedcba
				when "001" => SEG <= "0000110";  --가장 오른쪽디지트 1
				when "010" => SEG <= "1011011";  --2
				when "100" => SEG <= "1001111";  --3
				when others   => SEG <= "0000000";  --0
	
			end case;

		end process;	

	
	

	mtl(0) <= phase_lout(0);					--모터 입력과 상출력 연결구문
	mtl(1) <= phase_lout(1);
	mtl(2) <= phase_lout(2);
	mtl(3) <= phase_lout(3);

	mtr(0) <= phase_rout(3);
	mtr(1) <= phase_rout(2);
	mtr(2) <= phase_rout(1);
	mtr(3) <= phase_rout(0);
	



SC_LED <='1' when sen_in = "1110111" else '0';			--센서부 확산형LED 점등 조건문, 센서의 정 가운데 인식 될시에 가운데 led,
SL_LED <='1' when sen_in = "1111110" else '0';			-- 가장 왼쪽 센서단에 인식될시에 왼쪽 led 점멸
SR_LED <='1' when sen_in = "0111111" else '0';			-- 가장 오른쪽 센서단에 인식될시에 오른쪽 led 점멸


end Behavioral;

