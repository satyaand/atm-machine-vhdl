LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_unsigned.ALL;

package atm_prototypes is
    TYPE account_database IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
    TYPE password_type IS ARRAY (0 TO 5) OF INTEGER;
    TYPE passwordArrays IS ARRAY(0 TO 3) OF password_type;
    TYPE balance_type IS ARRAY(0 TO 3) OF INTEGER;

    -- Array untuk menyimpan value tombol yang hendak ditekan jika ingin menarik pecahan kembalian
    -- 0 untuk Rp1,000.00
    -- 1 untuk Rp2,000.00
    -- 2 untuk Rp5,000.00
    -- 3 untuk Rp10,000.00
    -- 4 untuk Rp20,000.00
    -- 5 untuk Rp50,000.00
    -- 6 untuk Rp100,000.00
    TYPE button_amount IS ARRAY(0 TO 6) OF INTEGER;

    -- Constant untuk menyimpan account yang dituju
    CONSTANT account : account_database := ("00", "01", "10", "11");

    --  Loop ke-  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
    --     Shift  1  1  2  2  2  2  2  2  1  2  2  2  2  2  2  1
    CONSTANT shift_1 : INTEGER RANGE 1 TO 16 := 1;
    CONSTANT shift_2 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_3 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_4 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_5 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_6 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_7 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_8 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_9 : INTEGER RANGE 1 TO 16 := 1;
    CONSTANT shift_10 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_11 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_12 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_13 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_14 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_15 : INTEGER RANGE 1 TO 16 := 2;
    CONSTANT shift_16 : INTEGER RANGE 1 TO 16 := 1;
end package;

package body atm_prototypes is
end package body;