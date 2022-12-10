LIBRARY IEEE, work;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.atm_prototypes.ALL;

ENTITY Penarikan IS
  PORT (
    CLK : IN STD_LOGIC;
    nom_penarikan : IN INTEGER;
    saldo_awal : IN INTEGER;
    buttonAmount : IN button_amount := (0, 0, 0, 0, 0, 0, 0);
    reset : IN STD_LOGIC;
    saldo_akhir : OUT INTEGER;
    keluar : OUT INTEGER
  );
END ENTITY Penarikan;

ARCHITECTURE behavior_penarikan OF Penarikan IS

  SIGNAL State, Nextstate : INTEGER RANGE 0 TO 3 := 0;
  SIGNAL wd_sum : INTEGER := 0;

BEGIN
  PROCESS (CLK, State, reset)
  BEGIN
    IF (rising_edge(CLK)) THEN
      CASE (State) IS
        WHEN 0 =>
          wd_sum <= 0;
          IF (nom_penarikan > 0) THEN
            Nextstate <= 1;
          ELSE
            Nextstate <= 0;
          END IF;
        WHEN 1 =>
          IF (saldo_awal >= nom_penarikan) THEN
            wd_sum <= (buttonAmount(0) * 1_000) + (buttonAmount(1) * 2_000) + (buttonAmount(2) * 5_000) + (buttonAmount(3) * 10_000) + (buttonAmount(4) * 20_000) + (buttonAmount(5) * 50_000) + (buttonAmount(6) * 100_000);
            Nextstate <= 2;
          ELSIF (saldo_awal < nom_penarikan) THEN
            wd_sum <= 0;
            Nextstate <= 1;
          ELSE
            Nextstate <= 1;
          END IF;
        WHEN 2 =>
          IF (wd_sum = nom_penarikan) THEN
            Nextstate <= 3;
          ELSE
            Nextstate <= 1;
          END IF;
        WHEN 3 =>
          Nextstate <= 0;
        WHEN OTHERS =>
          Nextstate <= 0;
      END CASE;
    END IF;
  END PROCESS;

  saldo_akhir <= saldo_awal - wd_sum;
  keluar <= wd_sum;

  PROCESS (CLK, Nextstate, reset)
  BEGIN
    IF(reset = '1') THEN
      State <= 0;
    ELSIF(rising_edge(CLK)) THEN
      State <= Nextstate;
    END IF;
  END PROCESS;
END behavior_penarikan;