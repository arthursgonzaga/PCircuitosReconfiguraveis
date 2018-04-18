----------------------------------------------------------------------------------
-- [PCR] Lista de Exercício 01 
-- Exercício nº 1 - Implementação de Filtro Sobel
-- Alunos: Arthur Gonzaga - 14/0016775
-- 		   Leonardo Brandão - 14/0025197 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_signed.ALL;
use IEEE.STD_LOGIC_arith.ALL;

entity filtrosobel_5x5 is
    Generic ( dim: integer := 250;
              bits_in: integer := 7;
              bits_out: integer := 12);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pixin : in STD_LOGIC_VECTOR (bits_in downto 0);
           sel : in STD_LOGIC;
           pixout : out STD_LOGIC_VECTOR (bits_out downto 0);
           M : out STD_LOGIC_VECTOR (bits_out downto 0);
           ready : out STD_LOGIC);
          
end filtrosobel_5x5;

architecture Behavioral of filtrosobel_5x5 is

-- kernel Gx
constant Gx11 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gx12 : std_logic_vector(3 downto 0) := "0001"; -- +1
constant Gx13 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gx14 : std_logic_vector(3 downto 0) := "1001"; -- -1
constant Gx15 : std_logic_vector(3 downto 0) := "1010"; -- -2
constant Gx21 : std_logic_vector(3 downto 0) := "0011"; -- +3
constant Gx22 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gx23 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gx24 : std_logic_vector(3 downto 0) := "1010"; -- -2
constant Gx25 : std_logic_vector(3 downto 0) := "1011"; -- -3
constant Gx31 : std_logic_vector(3 downto 0) := "0100"; -- +4
constant Gx32 : std_logic_vector(3 downto 0) := "0011"; -- +3
constant Gx33 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gx34 : std_logic_vector(3 downto 0) := "1011"; -- -3
constant Gx35 : std_logic_vector(3 downto 0) := "1100"; -- -4
constant Gx41 : std_logic_vector(3 downto 0) := "0011"; -- +3
constant Gx42 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gx43 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gx44 : std_logic_vector(3 downto 0) := "1010"; -- -2
constant Gx45 : std_logic_vector(3 downto 0) := "1011"; -- -3
constant Gx51 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gx52 : std_logic_vector(3 downto 0) := "0001"; -- +1
constant Gx53 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gx54 : std_logic_vector(3 downto 0) := "1001"; -- -1
constant Gx55 : std_logic_vector(3 downto 0) := "1010"; -- -2

-- kernel Gy
constant Gy11 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gy12 : std_logic_vector(3 downto 0) := "0011"; -- +3
constant Gy13 : std_logic_vector(3 downto 0) := "0100"; -- +4
constant Gy14 : std_logic_vector(3 downto 0) := "0011"; -- +3
constant Gy15 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gy21 : std_logic_vector(3 downto 0) := "0001"; -- +1
constant Gy22 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gy23 : std_logic_vector(3 downto 0) := "0011"; -- +3
constant Gy24 : std_logic_vector(3 downto 0) := "0010"; -- +2
constant Gy25 : std_logic_vector(3 downto 0) := "0001"; -- +1
constant Gy31 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gy32 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gy33 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gy34 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gy35 : std_logic_vector(3 downto 0) := "0000"; -- 0
constant Gy41 : std_logic_vector(3 downto 0) := "1001"; -- -1
constant Gy42 : std_logic_vector(3 downto 0) := "1010"; -- -2
constant Gy43 : std_logic_vector(3 downto 0) := "1011"; -- -3
constant Gy44 : std_logic_vector(3 downto 0) := "1010"; -- -2
constant Gy45 : std_logic_vector(3 downto 0) := "1001"; -- -1
constant Gy51 : std_logic_vector(3 downto 0) := "1010"; -- -2
constant Gy52 : std_logic_vector(3 downto 0) := "1011"; -- -3
constant Gy53 : std_logic_vector(3 downto 0) := "1100"; -- -4
constant Gy54 : std_logic_vector(3 downto 0) := "1011"; -- -3
constant Gy55 : std_logic_vector(3 downto 0) := "1010"; -- -2

-- sinais para imagem A(5x5)
signal A11 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A12 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A13 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A14 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A15 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A21 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A22 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A23 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A24 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A25 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A31 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A32 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A33 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A34 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A35 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A41 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A42 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A43 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A44 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A45 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A51 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A52 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A53 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A54 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');
signal A55 : std_logic_vector(bits_in+1 downto 0) := (others=>'0');


-- saidas multiplicadores
signal m11 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m12 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m13 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m14 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m15 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m21 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m22 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m23 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m24 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m25 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m31 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m32 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m33 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m34 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m35 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m41 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m42 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m43 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m44 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m45 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m51 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m52 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m53 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m54 : std_logic_vector(bits_out downto 0) := (others=>'0');
signal m55 : std_logic_vector(bits_out downto 0) := (others=>'0');


-- sinal para FIFOs com 8039 bits
-- 4 linhas de 250/100 pixels e mais 5 pixels (8 bits para cada)
 signal regwin : std_logic_vector((((4*dim)+5)*(bits_in+1))-1 downto 0) := (others=>'0');
--signal regwin : std_logic_vector(8039 downto 0) := (others=>'0');

-- sinal para saida somador
signal accout : std_logic_vector(bits_out downto 0) := (others=>'0');

begin

-- ready
process(clk,reset)
   -- variable count : integer range 0 to 1005+3 := 0; 
    variable count : integer range 0 to (4*dim+8) := 0; 
begin
    if reset='1' then
        count:=0;
        ready <= '0';
    elsif rising_edge(clk) then
       -- if count=1008 then -- 4 linhas + 5 pixels + 1 das multiplicacoes + 1 da soma + 1 do comparador
        if count=(4*dim+8) then -- 4 linhas + 5 pixels + 1 das multiplicacoes + 1 da soma + 1 do comparador
            count :=0;
            ready <= '1';
        else
            count := count+1;
        end if; 
    end if;
end process;

-- fifo register
process(clk,reset)
begin
    if reset='1' then
        regwin <= (others=>'0');
    elsif rising_edge(clk) then 
        regwin <= pixin & regwin((((4*dim)+5)*(bits_in+1))-1 downto bits_in+1);
        --regwin <= pixin & regwin(8039 downto 8);
    end if;
end process;

-- disponibilizador de vizinhanca
A11 <= '0'&regwin(bits_in downto 0);
A12 <= '0'&regwin((2*bits_in)+1 downto bits_in+1);
A13 <= '0'&regwin((3*bits_in)+2 downto (2*bits_in)+2);
A14 <= '0'&regwin((4*bits_in)+3 downto (3*bits_in)+3);
A15 <= '0'&regwin((5*bits_in)+4 downto (4*bits_in)+4);

A21 <= '0'&regwin(((dim+1)*(bits_in+1))-1 downto ((dim+1)*(bits_in+1))-(bits_in+1));
A22 <= '0'&regwin(((dim+2)*(bits_in+1))-1 downto ((dim+2)*(bits_in+1))-(bits_in+1));
A23 <= '0'&regwin(((dim+3)*(bits_in+1))-1 downto ((dim+3)*(bits_in+1))-(bits_in+1));
A24 <= '0'&regwin(((dim+4)*(bits_in+1))-1 downto ((dim+4)*(bits_in+1))-(bits_in+1));
A25 <= '0'&regwin(((dim+5)*(bits_in+1))-1 downto ((dim+5)*(bits_in+1))-(bits_in+1));

A31 <= '0'&regwin(((2*dim+1)*(bits_in+1))-1 downto ((2*dim+1)*(bits_in+1))-(bits_in+1));
A32 <= '0'&regwin(((2*dim+2)*(bits_in+1))-1 downto ((2*dim+2)*(bits_in+1))-(bits_in+1));
A33 <= '0'&regwin(((2*dim+3)*(bits_in+1))-1 downto ((2*dim+3)*(bits_in+1))-(bits_in+1));
A34 <= '0'&regwin(((2*dim+4)*(bits_in+1))-1 downto ((2*dim+4)*(bits_in+1))-(bits_in+1));
A35 <= '0'&regwin(((2*dim+5)*(bits_in+1))-1 downto ((2*dim+5)*(bits_in+1))-(bits_in+1));

A41 <= '0'&regwin(((3*dim+1)*(bits_in+1))-1 downto ((3*dim+1)*(bits_in+1))-(bits_in+1));
A42 <= '0'&regwin(((3*dim+2)*(bits_in+1))-1 downto ((3*dim+2)*(bits_in+1))-(bits_in+1));
A43 <= '0'&regwin(((3*dim+3)*(bits_in+1))-1 downto ((3*dim+3)*(bits_in+1))-(bits_in+1));
A44 <= '0'&regwin(((3*dim+4)*(bits_in+1))-1 downto ((3*dim+4)*(bits_in+1))-(bits_in+1));
A45 <= '0'&regwin(((3*dim+5)*(bits_in+1))-1 downto ((3*dim+5)*(bits_in+1))-(bits_in+1));

A51 <= '0'&regwin(((4*dim+1)*(bits_in+1))-1 downto ((4*dim+1)*(bits_in+1))-(bits_in+1));
A52 <= '0'&regwin(((4*dim+2)*(bits_in+1))-1 downto ((4*dim+2)*(bits_in+1))-(bits_in+1));
A53 <= '0'&regwin(((4*dim+3)*(bits_in+1))-1 downto ((4*dim+3)*(bits_in+1))-(bits_in+1));
A54 <= '0'&regwin(((4*dim+4)*(bits_in+1))-1 downto ((4*dim+4)*(bits_in+1))-(bits_in+1));
A55 <= '0'&regwin(((4*dim+5)*(bits_in+1))-1 downto ((4*dim+5)*(bits_in+1))-(bits_in+1));


-- Multiplicadores

-- Primeira Linha
-- M11
process(clk,reset)
begin
    if reset='1' then
        m11 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m11 <= A11 * Gx11;
        else
            m11 <= A11 * Gy11;
        end if;
    end if;
end process;

-- M12
process(clk,reset)
begin
    if reset='1' then
        m12 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m12 <= A12 * Gx12;
        else
            m12 <= A12 * Gy12;
        end if;
    end if;
end process;

-- M13
process(clk,reset)
begin
    if reset='1' then
        m13 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m13 <= A13 * Gx13;
        else
            m13 <= A13 * Gy13;
        end if;
    end if;
end process;

-- M14
process(clk,reset)
begin
    if reset='1' then
        m14 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m14 <= A14 * Gx14;
        else
            m14 <= A14 * Gy14;
        end if;
    end if;
end process;

-- M15
process(clk,reset)
begin
    if reset='1' then
        m15 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m15 <= A15 * Gx15;
        else
            m15 <= A15 * Gy15;
        end if;
    end if;
end process;

-- Segunda linha
-- M21
process(clk,reset)
begin
    if reset='1' then
        m21 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m21 <= A21 * Gx21;
        else
            m21 <= A21 * Gy21;
        end if;
    end if;
end process;


-- M22
process(clk,reset)
begin
    if reset='1' then
        m22 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m22 <= A22 * Gx22;
        else
            m22 <= A22 * Gy22;
        end if;
    end if;
end process;

-- M23
process(clk,reset)
begin
    if reset='1' then
        m23 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m23 <= A23 * Gx23;
        else
            m23 <= A23 * Gy23;
        end if;
    end if;
end process;

-- M24
process(clk,reset)
begin
    if reset='1' then
        m24 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m24 <= A24 * Gx24;
        else
            m24 <= A24 * Gy24;
        end if;
    end if;
end process;

-- M25
process(clk,reset)
begin
    if reset='1' then
        m25 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m25 <= A25 * Gx25;
        else
            m25 <= A15 * Gy25;
        end if;
    end if;
end process;


-- Terceira linha
-- M31
process(clk,reset)
begin
    if reset='1' then
        m31 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m31 <= A31 * Gx31;
        else
            m31 <= A31 * Gy31;
        end if;
    end if;
end process;


-- M32
process(clk,reset)
begin
    if reset='1' then
        m32 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m32 <= A32 * Gx32;
        else
            m32 <= A32 * Gy32;
        end if;
    end if;
end process;

-- M33
process(clk,reset)
begin
    if reset='1' then
        m33 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m33 <= A33 * Gx33;
        else
            m33 <= A33 * Gy33;
        end if;
    end if;
end process;

-- M34
process(clk,reset)
begin
    if reset='1' then
        m34 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m34 <= A34 * Gx34;
        else
            m34 <= A34 * Gy34;
        end if;
    end if;
end process;

-- M35
process(clk,reset)
begin
    if reset='1' then
        m35 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m35 <= A35 * Gx35;
        else
            m35 <= A35 * Gy35;
        end if;
    end if;
end process;

-- Quarta linha
-- M41
process(clk,reset)
begin
    if reset='1' then
        m41 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m41 <= A41 * Gx41;
        else
            m41 <= A41 * Gy41;
        end if;
    end if;
end process;


-- M42
process(clk,reset)
begin
    if reset='1' then
        m42 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m42 <= A42 * Gx42;
        else
            m42 <= A42 * Gy42;
        end if;
    end if;
end process;

-- M43
process(clk,reset)
begin
    if reset='1' then
        m43 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m43 <= A43 * Gx43;
        else
            m43 <= A43 * Gy43;
        end if;
    end if;
end process;

-- M44
process(clk,reset)
begin
    if reset='1' then
        m44 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m44 <= A44 * Gx44;
        else
            m44 <= A44 * Gy44;
        end if;
    end if;
end process;

-- M45
process(clk,reset)
begin
    if reset='1' then
        m45 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m45 <= A45 * Gx45;
        else
            m45 <= A45 * Gy45;
        end if;
    end if;
end process;

-- Quinta linha
-- M51
process(clk,reset)
begin
    if reset='1' then
        m51 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m51 <= A51 * Gx51;
        else
            m51 <= A51 * Gy51;
        end if;
    end if;
end process;


-- M52
process(clk,reset)
begin
    if reset='1' then
        m52 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m52 <= A52 * Gx52;
        else
            m52 <= A52 * Gy52;
        end if;
    end if;
end process;

-- M53
process(clk,reset)
begin
    if reset='1' then
        m53 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m53 <= A53 * Gx53;
        else
            m53 <= A53 * Gy53;
        end if;
    end if;
end process;

-- M54
process(clk,reset)
begin
    if reset='1' then
        m54 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m54 <= A54 * Gx54;
        else
            m54 <= A54 * Gy54;
        end if;
    end if;
end process;

-- M55
process(clk,reset)
begin
    if reset='1' then
        m55 <= (others=>'0');
    elsif rising_edge(clk) then
        if sel='1' then
            m55 <= A55 * Gx55;
        else
            m55 <= A55 * Gy55;
        end if;
    end if;
end process;


-- Acumulador
process(clk,reset)
begin
    -- accout <= (others => '0');
    if reset='1' then
        accout <= (others=>'0');
    elsif rising_edge(clk) then
        accout <= m11+m12+m13+m14+m15+m21+m22+m23+m24+m25+m31+m32+m33+m34+m35+m41+m42+m43+m44+m45+m51+m52+m53+m54+m55;
    end if;
end process;

M <= accout;

process(clk,reset)
begin
    if reset='1' then
        pixout <= (others=>'0');
    elsif rising_edge(clk) then
            if accout(bits_out) = '1' then
                pixout <= (others=>'0');
            elsif accout > "000000011111111" then
                pixout <= "000000011111111";
            else
                pixout <= accout;
            end if;
     end if;
end process; 

end Behavioral;
