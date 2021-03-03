library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity line_tracer is
    Port ( rstb : in std_logic;									--���¹�ư
           clk_50m : in std_logic;								--FPGAŬ��50MHz
           sen_in : in std_logic_vector(6 downto 0);		--���� ������
           sen_out : out std_logic_vector(6 downto 0);	--���� �߱���
			  SC_LED : out std_logic;								--������ Ȯ���� �߰�LED
			  SR_LED : out std_logic;								--������ Ȯ���� ������LED
			  SL_LED : out std_logic;								--������ Ȯ���� ����LED
			  mtl : out std_logic_vector(3 downto 0);			--���� �������
           mtr : out std_logic_vector(3 downto 0));		--������ �������
end line_tracer;

architecture Behavioral of line_tracer is

signal sclk : std_logic;															--���� ����Ŭ��
signal speed_l : integer range 0 to 250000;									--���� ���� ���ļ� ���ֺ���
signal speed_r : integer range 0 to 250000;									--������ ���� ���ļ� ���ֺ���
signal mtl_speed : std_logic_vector(1 downto 0);							--���� ���ͽ��ǵ� ��������
signal mtr_speed : std_logic_vector(1 downto 0);							--������ ���ͽ��ǵ� ��������
signal motor_lcnt : integer range 0 to 250000;								--���� ���� ���ļ� ���ֺ���
signal phase_lclk : std_logic;													--���ʸ��� ����Ŭ��
signal motor_rcnt : integer range 0 to 250000;								--������ ���� ���ļ� ���ֺ���
signal phase_rclk : std_logic;													--������ ���� ����Ŭ��
signal phase_lcnt : std_logic_vector(1 downto 0);							--���� ���� ����� ���к���
signal phase_lout : std_logic_vector(3 downto 0);							--���� ���� ����»��º���
signal phase_rcnt : std_logic_vector(1 downto 0);							--������ ���� ����� ���к���
signal phase_rout : std_logic_vector(3 downto 0);							--������ ���� ����»��º���

begin

	process(rstb, clk_50m)                             --���� Ŭ��(sclk) ����

	variable cnt : integer range 0 to 4000;

	begin
	
		if rstb = '0' then
			cnt := 0;
			sclk <= '0';
		elsif rising_edge(clk_50m) then
			if cnt >= 3999 then
				cnt := 0;
				sclk <= not sclk;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;

	sen_out(0) <= sclk;                    --�����߱��ο� ���� Ŭ������ �����ΰ�
	sen_out(1) <= sclk;
	sen_out(2) <= sclk;
	sen_out(3) <= sclk;
	sen_out(4) <= sclk;
	sen_out(5) <= sclk;
	sen_out(6) <= sclk;

	process(rstb, sclk)

	begin

		if rstb = '0' then
			mtl_speed <= "00";
			mtr_speed <= "00";						--���� ��ư�� ���������� ���� ����
		elsif falling_edge(sclk) then
			case sen_in is
				when "1110111" =>						--�����κ�
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
		end if;
	end process;

	process(mtl_speed)

	begin

		case mtl_speed is							--���� ���� �ӵ� ���� ����
			when "00" => speed_l <= 0;          --����
			when "01" => speed_l <= 166666;     --300Hz
			when "10" => speed_l <= 124999;     --400Gz
			when "11" => speed_l <= 78125;      --640Hz
			when others => speed_l <= 78125;    --640Hz
		end case;

	end process;

	process(mtr_speed)

	begin

		case mtr_speed is
			when "00" => speed_r <= 0;
			when "01" => speed_r <= 166666;
			when "10" => speed_r <= 124999;
			when "11" => speed_r <= 78125;
			when others => speed_r <= 78125;
		end case;

	end process;
	
	process(rstb, speed_l, clk_50m, motor_lcnt)

	begin

		if rstb = '0' or speed_l = 0 then
			motor_lcnt <= 0;
			phase_lclk <= '0';
		elsif rising_edge(clk_50m) then
			if motor_lcnt >= speed_l then					--����Ŭ�� ���ָ� ���� ����
				motor_lcnt <= 0;
				phase_lclk <= not phase_lclk;
			else
				motor_lcnt <= motor_lcnt + 1;
			end if;
		end if;

	end process;

	process(rstb, speed_r, clk_50m, motor_rcnt)

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

	process(rstb, phase_lclk, phase_lcnt)

	begin

		if rstb = '0' then 
			phase_lcnt <= (others => '0');
		elsif rising_edge(phase_lclk) then
			phase_lcnt <= phase_lcnt + 1;
		end if;

	end process;

	process(rstb, phase_lcnt)

	begin

		if rstb = '0' then
			phase_lout <= (others => '0');
		else
			case phase_lcnt is
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

	process(rstb, phase_rclk, phase_rcnt)

	begin

		if rstb = '0' then 
			phase_rcnt <= (others => '0');
		elsif rising_edge(phase_rclk) then
			phase_rcnt <= phase_rcnt + 1;
		end if;

	end process;

	process(rstb, phase_rcnt)

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

	mtl(0) <= phase_lout(0);					--���� �Է°� ����� ���ᱸ��
	mtl(1) <= phase_lout(1);
	mtl(2) <= phase_lout(2);
	mtl(3) <= phase_lout(3);

	mtr(0) <= phase_rout(3);
	mtr(1) <= phase_rout(2);
	mtr(2) <= phase_rout(1);
	mtr(3) <= phase_rout(0);


SC_LED <='1' when sen_in = "1110111" else '0';			--������ Ȯ����LED ���� ���ǹ�
SL_LED <='1' when sen_in = "1111110" else '0';
SR_LED <='1' when sen_in = "0111111" else '0';
end Behavioral;
