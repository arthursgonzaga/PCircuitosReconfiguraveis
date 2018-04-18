----------------------------------------------------------------------------------
-- [PCR] Lista de Exercício 01 
-- Exercício nº 1 - Implementação de Filtro Sobel
-- Alunos: Arthur Gonzaga - 14/0016775
-- 		   Leonardo Brandão - 14/0025197 
-- 
----------------------------------------------------------------------------------


-- Bordas Verticais

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_filtrosobel_2 is
--  Port ( );
end tb_filtrosobel_2;

architecture Behavioral of tb_filtrosobel_2 is

signal reset : STD_LOGIC := '0';
signal clk : STD_LOGIC := '0';
signal pixin : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal sel : STD_LOGIC := '0';
signal pixout : STD_LOGIC_VECTOR (12 downto 0);
signal M : STD_LOGIC_VECTOR (12 downto 0);
signal ready : STD_LOGIC := '0';

signal WOMenable : std_logic := '0';
signal cnt_ena : integer range 1 to 1008 := 1;
signal ROMaddress : std_logic_vector(13 downto 0) := (others=>'0');

component filtrosobel_5x5 is
    Port ( 
               clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               pixin : in STD_LOGIC_VECTOR (7 downto 0);
               sel : in STD_LOGIC;
               pixout : out STD_LOGIC_VECTOR (12 downto 0);
               M : out STD_LOGIC_VECTOR (12 downto 0);
               ready : out STD_LOGIC);
end component;


begin

    reset <= '0', '1' after 15ns, '0' after 25ns;
    clk <= not clk after 5ns;
    sel <= '1';     

    uut: filtrosobel_5x5 port map(
         reset => reset,
         clk => clk,
         sel => sel,
         pixin => pixin,
         pixout => pixout,
         M => M,
         ready => ready); 

    read_file: process
    file infile	: text is in "toysflash.txt";
    variable inline : line;
    variable dataf  : std_logic_vector(7 downto 0); 
    begin
        while (not endfile(infile)) loop
            wait until rising_edge(clk);
            readline(infile, inline);
            read(inline,dataf);
            pixin <= dataf;
        end loop;
        assert not endfile(infile) report "FIM DA LEITURA" severity warning;
        wait;        
    end process;
    
    WOMenable <= ready;
        
    write_file : process(clk) 
        variable out_line : line;
        file out_file     : text is out "res_toys.txt";
        begin
            -- write line to file every clock
            if (rising_edge(clk)) then
                if WOMenable = '1' then
                    write (out_line, pixout);
                    writeline (out_file, out_line);
                end if; 
            end if;  
        end process ;

end Behavioral;
