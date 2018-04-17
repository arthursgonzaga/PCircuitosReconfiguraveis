library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_sobel_dim100 is
--  Port ( );
end tb_sobel_dim100;

architecture Behavioral of tb_sobel_dim100 is

signal reset : STD_LOGIC := '0';
signal clk : STD_LOGIC := '0';
signal pixin : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');
signal sel : STD_LOGIC := '0';
signal pixout : STD_LOGIC_VECTOR (14 downto 0);
signal M : STD_LOGIC_VECTOR (14 downto 0);
signal ready : STD_LOGIC := '0';

signal WOMenable : std_logic := '0';
--signal cnt_ena : integer range 1 to 1008 := 1;
signal ROMaddress : std_logic_vector(13 downto 0) := (others=>'0');

component filtrosobel_5x5 is
    Generic ( dim: integer := 100;
          bits_in: integer := 9;
          bits_out: integer := 14);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pixin : in STD_LOGIC_VECTOR (bits_in downto 0);
           sel : in STD_LOGIC;
           pixout : out STD_LOGIC_VECTOR (bits_out downto 0);
           M : out STD_LOGIC_VECTOR (bits_out downto 0);
           ready : out STD_LOGIC);
end component;


begin

    reset <= '0', '1' after 15ns, '0' after 25ns;
    clk <= not clk after 5ns;
    sel <= '1';     

    uut: filtrosobel_5x5 
    generic map(
        dim => 100,
        bits_in => 9,
        bits_out => 14)
    port map(
         reset => reset,
         clk => clk,
         sel => sel,
         pixin => pixin,
         pixout => pixout,
         M => M,
         ready => ready); 

    read_file: process
    file infile	: text is in "tire.txt";
    variable inline : line;
    variable dataf  : std_logic_vector(9 downto 0); 
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
        file out_file     : text is out "res_tire.txt";
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
