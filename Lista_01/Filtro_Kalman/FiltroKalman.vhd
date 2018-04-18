----------------------------------------------------------------------------------
-- [PCR] Lista de Exercício 01 
-- Exercício nº 2 - Cálculo do Ganho de um Filtro Kalman
-- Alunos: Arthur Gonzaga - 14/0016775
-- 		   Leonardo Brandão - 14/0025197 
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_signed.ALL;
use IEEE.STD_LOGIC_arith.ALL;

entity kalman is
    Port ( reset 	: in STD_LOGIC;
           clk 		: in STD_LOGIC;
           start 	: in STD_LOGIC;
           input 	: in STD_LOGIC_VECTOR (15 downto 0);
           output	: out STD_LOGIC_VECTOR (15 downto 0);
           ready	: out STD_LOGIC);
end kalman;

architecture Behavioral of kalman is

component addsubfsm_v6 is
  port (reset      :  in std_logic;
        clk        :  in std_logic;
		op		   :  in std_logic;
		op_a 	   :  in std_logic_vector(15 downto 0);
		op_b 	   :  in std_logic_vector(15 downto 0);
		start_i    :  in std_logic;
		addsub_out : out std_logic_vector(15 downto 0);
		ready_as   : out std_logic);
 end component;
 
component multiplierfsm_v2 is
  port (reset     :  in std_logic; 
        clk       :  in std_logic;          
        op_a      :  in std_logic_vector(15 downto 0);
        op_b      :  in std_logic_vector(15 downto 0);
        start_i   :  in std_logic;
        mul_out   : out std_logic_vector(15 downto 0);
        ready_mul : out std_logic);
end component;	

	component divisor is
	end component;

	--Sinal de READY--
	signal s_ready : std_logic := '0';

	--Registrador de entrada--
	-- A matriz de entrada A é 3x3 e portanto tem 9 posições de 16 bits (9*16 = 144) 
	signal reg_IN : STD_LOGIC_VECTOR (143 downto 0) := (others => '0');
	signal flag1 : STD_LOGIC := '0';

	--Matriz de entrada A 3x3--
	signal A11 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A12 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A13 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A21 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A22 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A23 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A31 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A32 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal A33 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

	--Matriz constante B 2x3--
	constant B11 : STD_LOGIC_VECTOR (15 downto 0) := "0000001000000000"; -- (+2,0) -- Bt11
	constant B12 : STD_LOGIC_VECTOR (15 downto 0) := "1000000010000000"; -- (-0,5) -- Bt21
	constant B13 : STD_LOGIC_VECTOR (15 downto 0) := "0000000110000000"; -- (+1,5) -- Bt31
	constant B21 : STD_LOGIC_VECTOR (15 downto 0) := "1000000110000000"; -- (-1,5) -- Bt12
	constant B22 : STD_LOGIC_VECTOR (15 downto 0) := "0000000010000000"; -- (+0,5) -- Bt22 
	constant B23 : STD_LOGIC_VECTOR (15 downto 0) := "1000001000000000"; -- (-2,0) -- Bt32

	--Matriz constante C 2x2--
	--constant c11 : STD_LOGIC_VECTOR (15 downto 0) := "00000000.10000000"; -- (0,5)
	--constant c12 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000"; -- (0,0)
	--constant c21 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000"; -- (0,0) 
	--constant c22 : STD_LOGIC_VECTOR (15 downto 0) := "00000000.10000000"; -- (0,5)

	--Registrador X --
	-- A primeira multiplicação (A*BT) gera uma matriz X de tamanho 3x2
	signal X11 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal X12 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal X21 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal X22 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal X31 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal X32 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

	--Registrador Y
	-- Asegunda Multiplicação (A*BT*B) gera uma matriz Y de tamanho 2x2
	signal Y11 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal Y12 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal Y21 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal Y22 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

	--Sinal da matriz de saída K--
	signal s_k11 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s_k12 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s_k21 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s_k22 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

	--Registradores intermediários de multiplicação e soma --
	signal m1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m2 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m3 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m4 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m5 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m6 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m7 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m8 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m9 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m10 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m11 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m12 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m13 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m14 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m15 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m16 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m17 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal m18 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

	signal s1 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s2 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s3 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s4 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s5 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
	signal s6 : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

begin

------------------------ 1º processo: Carrega as entradas no reg_IN e monta a Matriz A ---------------------------
	process(clk,reset)
	begin
		if reset='1' then
		    reg_IN <= (others => '0');
		    flag1 <= '0';
		elsif rising_edge(clk) then
		    if start='1' then
		        reg_IN <= input & reg_IN(143 downto 16);
				flag1 <= '1';
		    end if;
		end if;
	end process;

	A11 <= reg_IN(15 downto 0);
	A12 <= reg_IN(31 downto 16);
	A13 <= reg_IN(47 downto 32);
	A21 <= reg_IN(63 downto 48);
	A22 <= reg_IN(79 downto 64);
	A23 <= reg_IN(95 downto 80);
	A31 <= reg_IN(111 downto 96);
	A32 <= reg_IN(127 downto 112);
	A33 <= reg_IN(143 downto 128);

----------------------------------------------Multiplicação A * BT -------------------------------------------------------
------------------------------------------------ calculo de X11 ------------------------------------------------
x_m_A11_BT11: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => A11,
				 op_b => B11,
			  start_i => flag1,
			  mul_out => m1,
			ready_mul => rdm1); 

x_m_A12_BT21: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => A12,
				 op_b => B12,
			  start_i => flag1,
			  mul_out => m2,
			ready_mul => rdm2);

x_m_A13_BT31: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => A13,
				 op_b => B13,
			  start_i => flag1,
			  mul_out => m3,
			ready_mul => rdm3);

x_s_m1_m2: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m1,	   
				op_b  => m2,	   
			  start_i => rdm3,   
		   addsub_out => s1,
			ready_as  => rds1);

x_s_s1_m3: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s1,	   
				op_b  => m3,	   
			  start_i => rds1,   
		   addsub_out => X11,
			ready_as  => rds1);

------------------------------------------------ calculo de X12 ------------------------------------------------
x_m_A11_BT12: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => A11,
				 op_b => B21,
			  start_i => flag1,
			  mul_out => m4,
			ready_mul => rdm4); 

x_m_A12_BT22: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => A12,
				 op_b => B22,
			  start_i => flag1,
			  mul_out => m5,
			ready_mul => rdm5);

x_m_A13_BT32: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => A13,
				 op_b => B23,
			  start_i => flag1,
			  mul_out => m6,
			ready_mul => rdm6);

x_s_m4_m5: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m4,	   
				op_b  => m5,	   
			  start_i => rdm6,  
		   addsub_out => s2,
			ready_as  => rds2);

x_s_s2_m6: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s2,	   
				op_b  => m6,	   
			  start_i => rds2,   
		   addsub_out => X12,
			ready_as  => rds2);

------------------------------------------------ calculo de X21 ------------------------------------------------
x_m_A21_BT11: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => A21,
				 op_b => B11,
			  start_i => flag1,
			  mul_out => m7,
			ready_mul => rdm7); 

x_m_A22_BT21: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => A22,
				 op_b => B12,
			  start_i => flag1,
			  mul_out => m8,
			ready_mul => rdm8);

x_m_A23_BT31: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => A23,
				 op_b => B13,
			  start_i => flag1,
			  mul_out => m9,
			ready_mul => rdm9);

x_s_m7_m8: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m7,	   
				op_b  => m8,	   
			  start_i => rdm9,   
		   addsub_out => s3,
			ready_as  => rds3);

x_s_s3_m9: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s3,	   
				op_b  => m9,	   
			  start_i => rds3,   
		   addsub_out => X21,
			ready_as  => rds3);

------------------------------------------------ calculo de X22 ------------------------------------------------
x_m_A21_BT12: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => A21,
				 op_b => B21,
			  start_i => flag1,
			  mul_out => m10,
			ready_mul => rdm10); 

x_m_A22_BT22: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => A22,
				 op_b => B22,
			  start_i => flag1,
			  mul_out => m11,
			ready_mul => rdm11);

x_m_A23_BT32: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => A23,
				 op_b => B23,
			  start_i => flag1,
			  mul_out => m12,
			ready_mul => rdm12);

x_s_m10_m11: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m10,	   
				op_b  => m11,   
			  start_i => rdm12,  
		   addsub_out => s4,
			ready_as  => rds4);

x_s_s4_m12: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s4,	   
				op_b  => m12,	   
			  start_i => rds4,   
		   addsub_out => X22,
			ready_as  => rds4);

------------------------------------------------ calculo de X31 ------------------------------------------------
x_m_A31_BT11: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => A31,
				 op_b => B11,
			  start_i => flag1,
			  mul_out => m13,
			ready_mul => rdm13); 

x_m_A32_BT21: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => A32,
				 op_b => B12,
			  start_i => flag1,
			  mul_out => m14,
			ready_mul => rdm14);

x_m_A33_BT31: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => A33,
				 op_b => B13,
			  start_i => flag1,
			  mul_out => m15,
			ready_mul => rdm15);

x_s_m13_m14: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m15,	   
				op_b  => m16,   
			  start_i => rdm15,  
		   addsub_out => s5,
			ready_as  => rds5);

x_s_s5_m15: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s5,	   
				op_b  => m6,	   
			  start_i => rds5,   
		   addsub_out => X31,
			ready_as  => rds5);

------------------------------------------------ calculo de X32 ------------------------------------------------
x_m_A31_BT12: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => A31,
				 op_b => B21,
			  start_i => flag1,
			  mul_out => m16,
			ready_mul => rdm16); 

x_m_A32_BT22: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => A32,
				 op_b => B22,
			  start_i => flag1,
			  mul_out => m17,
			ready_mul => rdm17);

x_m_A33_BT32: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => A33,
				 op_b => B23,
			  start_i => flag1,
			  mul_out => m18,
			ready_mul => rdm18);

x_s_m16_m17: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m16,	   
				op_b  => m17,   
			  start_i => rdm18,  
		   addsub_out => s6,
			ready_as  => rds6);

x_s_s6_m18: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s6,	   
				op_b  => m18,	   
			  start_i => rds6,   
		   addsub_out => X32,
			ready_as  => flag2);

----------------------------------------------Multiplicação (A * BT) * B -------------------------------------------------------
------------------------------------------------ calculo de Y11 ------------------------------------------------
y_m_X11_B11: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => X11,
				 op_b => B11,
			  start_i => flag2,
			  mul_out => m1,
			ready_mul => rdm1); 

y_m_X21_B12: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => X21,
				 op_b => B12,
			  start_i => flag2,
			  mul_out => m2,
			ready_mul => rdm2);

y_m_X31_B13: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => X31,
				 op_b => B13,
			  start_i => flag2,
			  mul_out => m3,
			ready_mul => rdm3);

y_s_m1_m2: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m1,	   
				op_b  => m2,	   
			  start_i => rdm3,   
		   addsub_out => s1,
			ready_as  => rds1);

y_s_s1_m3: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s1,	   
				op_b  => m3,	   
			  start_i => rds1,   
		   addsub_out => Y11,
			ready_as  => rds1);

------------------------------------------------ calculo de Y12 ------------------------------------------------
y_m_X12_B11: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => X12,
				 op_b => B11,
			  start_i => flag2,
			  mul_out => m4,
			ready_mul => rdm4); 

y_m_X22_B12: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => X22,
				 op_b => B12,
			  start_i => flag2,
			  mul_out => m5,
			ready_mul => rdm5);

y_m_X32_BT13: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => X32,
				 op_b => B13,
			  start_i => flag2,
			  mul_out => m6,
			ready_mul => rdm6);

y_s_m4_m5: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m4,	   
				op_b  => m5,	   
			  start_i => rdm6,  
		   addsub_out => s2,
			ready_as  => rds2);

y_s_s2_m6: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s2,	   
				op_b  => m6,	   
			  start_i => rds2,   
		   addsub_out => Y12,
			ready_as  => rds2);

------------------------------------------------ calculo de Y21 ------------------------------------------------
y_m_X11_B21: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => X11,
				 op_b => B21,
			  start_i => flag2,
			  mul_out => m7,
			ready_mul => rdm7); 

y_m_X21_B22: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => X21,
				 op_b => B22,
			  start_i => flag2,
			  mul_out => m8,
			ready_mul => rdm8);

y_m_X31_B23: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => X31,
				 op_b => B23,
			  start_i => flag2,
			  mul_out => m9,
			ready_mul => rdm9);

y_s_m7_m8: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m7,	   
				op_b  => m8,	   
			  start_i => rdm9,   
		   addsub_out => s3,
			ready_as  => rds5);

y_s_s3_m9: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s3,	   
				op_b  => m9,	   
			  start_i => rds3,   
		   addsub_out => Y21,
			ready_as  => rds3);

------------------------------------------------ calculo de Y22 ------------------------------------------------
y_m_X12_B21: multiplierfsm_v2 port map(
			    reset => reset,
				  clk => clk,
				 op_a => X12,
				 op_b => B21,
			  start_i => flag2,
			  mul_out => m10,
			ready_mul => rdm10); 

y_m_X22_B22: multiplierfsm_v2 port map(
				reset => reset,
				  clk => clk,
				 op_a => X22,
				 op_b => B22,
			  start_i => flag2,
			  mul_out => m11,
			ready_mul => rdm11);

y_m_X32_B23: multiplierfsm_v2 port map(
				 reset => reset,
				  clk => clk,
				 op_a => X32,
				 op_b => B23,
			  start_i => flag2,
			  mul_out => m12,
			ready_mul => rdm12);

y_s_m10_m11: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => m10,	   
				op_b  => m11,   
			  start_i => rdm12,  
		   addsub_out => s4,
			ready_as  => rds4);

y_s_s4_m12: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => s4,	   
				op_b  => m12,	   
			  start_i => rds4,   
		   addsub_out => X22,
			ready_as  => flag3);

----------------------------------------------Soma ((A * BT) * B) + C -------------------------------------------------------

z_s_Y11_C11: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => Y11,	   
				op_b  => "0000000010000000",   
			  start_i => flag3,  
		   addsub_out => s4,
			ready_as  => rds4);


z_s_Y22_C22: addsubfsm_v6 port map(
				reset => reset,     
        		clk   => clk,     
				op	  => '0',	   
				op_a  => Y22,	   
				op_b  => "0000000010000000",	   
			  start_i => flag3,   
		   addsub_out => X22,
			ready_as  => flag3);

		Z12 <= Y12; --Soma com 0 (C12)
		Z21 <= Y21; --Soma com 0 (C21)


end Behavioral;







