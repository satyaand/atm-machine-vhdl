library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity setor is
    port (
        clk : in std_logic;
        saldoAwal : in INTEGER;
        nominal : in integer;
        setoran : in integer;
        but_pecahan : in std_logic_vector (6 downto 0);
        saldoAkhir : out INTEGER;
        kembali : out integer
    );
end entity setor;

architecture rtl of setor is
    signal CurrState, NextState : integer range 0 to 2 := 0;
    signal temp_return : integer;

begin
    process (clk)
    begin
        if(rising_edge(clk)) then
            case CurrState is
                when 0 =>
                    temp_return <= 0;
                    if(nominal > 0 and setoran > 0) then
                        NextState <= 1;
                    else
                        NextState <= 0;
                    end if;
                when 1 =>
                    if(nominal > setoran) then
                        temp_return <= nominal - setoran;
                        NextState <= 2;
                    else
                        NextState <= 0;
                    end if;
                when 2 =>
                    -- saldoAkhir <= nominal;
                    if(but_pecahan = "0000001") then
                        temp_return <= temp_return - 1000;
                    elsif (but_pecahan = "0000010") then
                        temp_return <= temp_return - 2000;
                    elsif (but_pecahan = "0000100") then
                        temp_return <= temp_return - 5000;
                    elsif (but_pecahan = "0001000") then
                        temp_return <= temp_return - 10000;
                    elsif (but_pecahan = "0010000") then
                        temp_return <= temp_return - 20000;
                    elsif (but_pecahan = "0100000") then
                        temp_return <= temp_return - 50000;
                    elsif (but_pecahan = "1000000") then
                        temp_return <= temp_return - 100000;
                    else
                        temp_return <= temp_return - 0;
                    end if;
                    NextState <= 0;
            end case;
        end if;
    end process;
    saldoAkhir <= saldoAwal + setoran;
    kembali <= temp_return;
    
    process(clk)
    begin
        if(clk = '1') then
            CurrState <= NextState;
        end if;
    end process;

end architecture;