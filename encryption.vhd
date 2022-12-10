LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.atm_prototypes.ALL;

-- Enkripsi ini mengadaptasi algoritma enkripsi DES, namun diberikan modifikasi untuk menyesuaikan input pin
-- Output enkripsi berupa 56-bit hasil operasi enkripsi terhadap 6 digit integer input PIN ATM 

ENTITY encryption IS
  PORT (
    -- PIN input berukuran 6 digit integer, sesuai package atm_prototypes
    pin_code : IN password_type;
    CLK : IN STD_LOGIC;
    -- Output enkripsi yang terdiri dari 56-bit std_logic_vector
    encrypted_pin_code : OUT STD_LOGIC_VECTOR(55 DOWNTO 0)
  );
END encryption;

ARCHITECTURE behavioral OF encryption IS
  -- Sub-keys K1 dan K2
  SIGNAL K1, K2 : STD_LOGIC_VECTOR(27 DOWNTO 0);

  -- Sub-keys yang sudah di-rotate
  SIGNAL rotated_K1, rotated_K2 : STD_LOGIC_VECTOR(27 DOWNTO 0);

  -- Round shift untuk penanda bit mana yang di-shift
  SIGNAL shift_r : INTEGER RANGE 1 TO 16;

  -- Key untuk menyimpan sub-keys yang sudah di-rotate
  SIGNAL key : STD_LOGIC_VECTOR(27 DOWNTO 0);

  -- Key masking untuk mengenkripsi pin ATM dalam hexadecimal
  SIGNAL secret_key : STD_LOGIC_VECTOR(55 DOWNTO 0) := x"5A6D2F38E19C74";
BEGIN
  PROCESS (secret_key, pin_code, clk)
    -- Variabel intermediate untuk operasi permutasi awal
    VARIABLE intermediate : STD_LOGIC_VECTOR(55 DOWNTO 0);
  BEGIN
    -- Assign secret key ke intermediate
    intermediate := secret_key;
    -- Permutasi awal mengikuti rumusan
    -- intermdiate((8n + 7) downto (8n)) diisi oleh masing-masing integer pin ATM dalam bit
    intermediate(47 DOWNTO 40) := STD_LOGIC_VECTOR(to_unsigned(pin_code(0), 8));
    intermediate(39 DOWNTO 32) := STD_LOGIC_VECTOR(to_unsigned(pin_code(1), 8));
    intermediate(31 DOWNTO 24) := STD_LOGIC_VECTOR(to_unsigned(pin_code(2), 8));
    intermediate(23 DOWNTO 16) := STD_LOGIC_VECTOR(to_unsigned(pin_code(3), 8));
    intermediate(15 DOWNTO 8) := STD_LOGIC_VECTOR(to_unsigned(pin_code(4), 8));
    intermediate(7 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(pin_code(5), 8));

    -- Membagi secret key menjadi dua bagian 28-bit sub-keys, yaitu K1 dan K2
    K1(27 DOWNTO 24) <= secret_key(55 DOWNTO 52);
    K1(23 DOWNTO 20) <= secret_key(47 DOWNTO 44);
    K1(19 DOWNTO 16) <= secret_key(39 DOWNTO 36);
    K1(15 DOWNTO 12) <= secret_key(31 DOWNTO 28);
    K1(11 DOWNTO 8) <= secret_key(23 DOWNTO 20);
    K1(7 DOWNTO 4) <= secret_key(15 DOWNTO 12);
    K1(3 DOWNTO 0) <= secret_key(7 DOWNTO 4);
    K2(27 DOWNTO 24) <= secret_key(3 DOWNTO 0);
    K2(23 DOWNTO 20) <= secret_key(55 DOWNTO 52);
    K2(19 DOWNTO 16) <= secret_key(47 DOWNTO 44);
    K2(15 DOWNTO 12) <= secret_key(39 DOWNTO 36);
    K2(11 DOWNTO 8) <= secret_key(31 DOWNTO 28);
    K2(7 DOWNTO 4) <= secret_key(23 DOWNTO 20);
    K2(3 DOWNTO 0) <= secret_key(15 DOWNTO 12);
    --
    -- Rotasi sub-keys sesuai variabel counter looping r
    -- Nilai shift_1 sampai dengan shift_16 di-inisialisasi sebagai konstan di 
    -- file package atm_prototypes.vhd
    FOR r IN 1 TO 16 LOOP
      IF (r = 1) THEN
        shift_r <= shift_1;
      ELSIF (r = 2) THEN
        shift_r <= shift_2;
      ELSIF (r = 3) THEN
        shift_r <= shift_3;
      ELSIF (r = 4) THEN
        shift_r <= shift_4;
      ELSIF (r = 5) THEN
        shift_r <= shift_5;
      ELSIF (r = 6) THEN
        shift_r <= shift_6;
      ELSIF (r = 7) THEN
        shift_r <= shift_7;
      ELSIF (r = 8) THEN
        shift_r <= shift_8;
      ELSIF (r = 9) THEN
        shift_r <= shift_9;
      ELSIF (r = 10) THEN
        shift_r <= shift_10;
      ELSIF (r = 11) THEN
        shift_r <= shift_11;
      ELSIF (r = 12) THEN
        shift_r <= shift_12;
      ELSIF (r = 13) THEN
        shift_r <= shift_13;
      ELSIF (r = 14) THEN
        shift_r <= shift_14;
      ELSIF (r = 15) THEN
        shift_r <= shift_15;
      ELSE
        shift_r <= shift_16;
      END IF;
    END LOOP;
    --
    -- Rotasi sesuai nilai shift_r
    -- Jika shift_r bernilai 1 maka terjadi contoh berikut
    --
    -- K1: 1011010111011010 => 0110101110110101
    -- K2: 0110101110110101 => 1101101011101101
    --
    IF shift_r = 1 THEN
      rotated_K1(26 DOWNTO 0) <= K1(26 DOWNTO 0);
      rotated_K1(27) <= K1(27);
      rotated_K2(26 DOWNTO 0) <= K2(26 DOWNTO 0);
      rotated_K2(27) <= K2(27);
    ELSIF shift_r = 2 THEN
      rotated_K1(25 DOWNTO 0) <= K1(25 DOWNTO 0);
      rotated_K1(26 DOWNTO 1) <= K1(27 DOWNTO 2);
      rotated_K1(27) <= K1(27);
      rotated_K2(25 DOWNTO 0) <= K2(25 DOWNTO 0);
      rotated_K2(26 DOWNTO 1) <= K2(27 DOWNTO 2);
      rotated_K2(27) <= K2(27);
    END IF;
    
    -- Menentukan key yang akan digunakan untuk operasi XOR dengan cara
    -- shift_r hanya akan bernilai 1 atau 2
    -- Jika shift_r adalah 1 maka gunakan subkey K1 yang sudah di-rotate untuk XOR
    -- Jika shift_r adalah 2 maka gunakan subkey K2 yang sudah di-rotate untuk XOR 
    IF (shift_r MOD 2 = 1) THEN
      key <= rotated_K1;
    ELSE
      key <= rotated_K2;
    END IF;

    -- Melakukan operasi XOR antara intermediate dengan subkey terpilih
    intermediate(55 DOWNTO 28) := intermediate(55 DOWNTO 28) XOR key;
    intermediate(27 DOWNTO 0) := intermediate(27 DOWNTO 0) XOR key;
    
    -- OUTPUT
    encrypted_pin_code <= intermediate;
  END PROCESS;
END behavioral;