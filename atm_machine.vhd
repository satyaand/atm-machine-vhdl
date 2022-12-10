LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.atm_prototypes.ALL;

ENTITY atm_machine IS
    PORT (
        CLK : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        CARD_READER : IN STD_LOGIC;
        PIN_INPUT : IN password_type;
        PIN_NEW_INPUT : IN password_type;
        DEPOSIT_BUTTON : IN STD_LOGIC;
        WITHDRAW_BUTTON : IN STD_LOGIC;
        CHANGE_PIN_BUTTON : IN STD_LOGIC;
        CONTINUE_BUTTON : IN STD_LOGIC;
        NOMINAL_MASUK_MESIN : IN INTEGER;
        NOMINAL_PENARIKAN : IN INTEGER;
        NOMINAL_DEPOSIT : IN INTEGER; 
        buttonDeposit : in std_logic_vector(6 downto 0);
        buttonAmountWithdraw : in button_amount;

        -- OUTPUT
        MONEY_OUT : OUT INTEGER
    );
END ENTITY atm_machine;

ARCHITECTURE rtl OF atm_machine IS
    TYPE state_type IS (IDLE, ENTER_PIN, PIN_ATTEMPT_1, PIN_ATTEMPT_2, PIN_ATTEMPT_3, READY, DEPOSIT, WITHDRAWAL, PIN_CHANGE);
    SIGNAL state : state_type;
    SIGNAL pinAcc1 : password_type := (1, 4, 3, 6, 7, 8); -- PIN milik akun 00 adalah 143678
    SIGNAL pinAcc2 : password_type := (7, 2, 0, 5, 4, 1); -- PIN milik akun 01 adalah 720541
    SIGNAL pinAcc3 : password_type := (4, 0, 3, 6, 7, 4); -- PIN milik akun 10 adalah 403674
    SIGNAL pinAcc4 : password_type := (2, 8, 8, 0, 2, 1); -- PIN milik akun 11 adalah 288021
    SIGNAL balance_database : balance_type := (100_000, 80_000, 0, 2_000); -- Database balance sesuai index akun

    -- passwordCollection(0) = PIN akun 1 -> 143678 (PIN awal)
    -- passwordCollection(1) = PIN akun 2 -> 720541 (PIN awal)
    -- passwordCollection(2) = PIN akun 3 -> 403674 (PIN awal)
    -- passwordCollection(3) = PIN akun 4 -> 288021 (PIN awal)
    SIGNAL passwordCollection : passwordArrays := (pinAcc1, pinAcc2, pinAcc3, pinAcc4);

    SIGNAL encryptedPin : STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL passwordUsage : password_type;

    SIGNAL accountUsageIndex : INTEGER;
    SIGNAL accountUsageIndexID : INTEGER;
    SIGNAL balanceUser : INTEGER;
    SIGNAL new_pin : password_type;
    SIGNAL moneyChange : INTEGER;
    SIGNAL moneyOut : INTEGER;
    SIGNAL newBalanceAfterDeposit : INTEGER;
    SIGNAL newBalanceAfterWithdrawal : INTEGER;

    component encryption IS
        PORT (
            pin_code : IN password_type;
            CLK : IN STD_LOGIC;

            encrypted_pin_code : OUT STD_LOGIC_VECTOR(55 DOWNTO 0)
        );
    end COMPONENT encryption;

    COMPONENT pin_changer IS
        PORT (
            CLK : IN STD_LOGIC;
            OLD_PIN : IN password_type;
            NEW_PIN_INPUT : IN password_type;
            NEW_PIN : OUT password_type
        );
    end COMPONENT pin_changer;

    COMPONENT setor is
        PORT (
            clk : in std_logic;
            saldoAwal : in INTEGER;
            nominal : in integer;
            setoran : in integer;
            but_pecahan : in std_logic_vector (6 downto 0);
            saldoAkhir : out INTEGER;
            kembali : out integer
        );
    end COMPONENT setor;

    COMPONENT Penarikan IS
        PORT (
            CLK : IN STD_LOGIC;
            nom_penarikan : IN INTEGER;
            saldo_awal : IN INTEGER;
            buttonAmount : IN button_amount := (0, 0, 0, 0, 0, 0, 0);
            reset : IN STD_LOGIC;
            saldo_akhir : OUT INTEGER;
            keluar : OUT INTEGER
        );
    end COMPONENT Penarikan;

BEGIN

    accountUsageIndexID <= 0 WHEN PIN_INPUT = passwordCollection(0) ELSE
                         1 WHEN PIN_INPUT = passwordCollection(1) ELSE
                         2 WHEN PIN_INPUT = passwordCollection(2) ELSE
                         3 WHEN PIN_INPUT = passwordCollection(3) ELSE
                         0;

    balanceUser <= balance_database(0) WHEN accountUsageIndexID = 0 ELSE
                   balance_database(1) WHEN accountUsageIndexID = 1 ELSE
                   balance_database(2) WHEN accountUsageIndexID = 2 ELSE
                   balance_database(3) WHEN accountUsageIndexID = 3 ELSE
                   0;

    ENCRYPT_PIN : encryption port map(passwordUsage, CLK, encryptedPin);
    CHANGING_PIN : pin_changer port map(CLK, passwordUsage, PIN_NEW_INPUT, new_pin);
    DEPOSIT_PROC : setor port map(CLK, balanceUser, NOMINAL_MASUK_MESIN, NOMINAL_DEPOSIT, buttonDeposit, newBalanceAfterDeposit, moneyChange);
    WITHDRAW_PROC : Penarikan port map(CLK, NOMINAL_PENARIKAN, balanceUser, buttonAmountWithdraw, RESET, newBalanceAfterWithdrawal, moneyOut);
    
    onUsage : PROCESS (CLK, DEPOSIT_BUTTON, WITHDRAW_BUTTON, CHANGE_PIN_BUTTON,RESET)
        VARIABLE buttonPressed: STD_LOGIC_VECTOR(2 downto 0);
        VARIABLE validAccount : STD_LOGIC;
    BEGIN
        IF (RESET = '1') THEN
            state <= IDLE;
        ELSIF (RISING_EDGE(CLK)) THEN
            CASE STATE IS
                WHEN IDLE =>
                    passwordUsage <= (0, 0, 0, 0, 0, 0);
                    IF (CARD_READER = '1') THEN
                        STATE <= ENTER_PIN;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN ENTER_PIN =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = passwordCollection(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= passwordCollection(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= PIN_ATTEMPT_1;
                    END IF;
                WHEN PIN_ATTEMPT_1 =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = passwordCollection(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= passwordCollection(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= PIN_ATTEMPT_2;
                    END IF;
                WHEN PIN_ATTEMPT_2 =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = passwordCollection(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= passwordCollection(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= PIN_ATTEMPT_3;
                    END IF;
                WHEN PIN_ATTEMPT_3 =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = passwordCollection(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= passwordCollection(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN READY =>
                    buttonPressed := DEPOSIT_BUTTON & WITHDRAW_BUTTON & CHANGE_PIN_BUTTON;
                    IF(buttonPressed = "100") THEN
                        -- STATE DEPOSIT
                        STATE <= DEPOSIT;
                    ELSIF(buttonPressed = "010") THEN 
                        -- STATE WITHDRAWAL
                        STATE <= WITHDRAWAL;
                    ELSIF(buttonPressed = "001") THEN
                        -- STATE CHANGE_PIN_BUTTON
                        STATE <= PIN_CHANGE;
                    ELSE 
                        STATE <= READY;
                    END IF;
                WHEN DEPOSIT =>
                    -- MEMANGGIL
                    -- DEPOSIT COMPONENT
                    -- DI SINI
                    IF(balanceUser = balance_database(0)) THEN
                        balance_database(0) <= newBalanceAfterDeposit;
                    ELSIF(balanceUser = balance_database(1)) THEN
                        balance_database(1) <= newBalanceAfterDeposit;
                    ELSIF(balanceUser = balance_database(2)) THEN
                        balance_database(2) <= newBalanceAfterDeposit;
                    ELSIF(balanceUser = balance_database(3)) THEN
                        balance_database(3) <= newBalanceAfterDeposit;
                    END IF;
                    MONEY_OUT <= moneyChange; 
                    IF(CONTINUE_BUTTON = '1') THEN
                        STATE <= READY;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN WITHDRAWAL =>
                    -- MEMANGGIL
                    -- WITHDRAWAL COMPONENT
                    -- DI SINI
                    IF(balanceUser = balance_database(0)) THEN
                        balance_database(0) <= newBalanceAfterWithdrawal;
                    ELSIF(balanceUser = balance_database(1)) THEN
                        balance_database(1) <= newBalanceAfterWithdrawal;
                    ELSIF(balanceUser = balance_database(2)) THEN
                        balance_database(2) <= newBalanceAfterWithdrawal;
                    ELSIF(balanceUser = balance_database(3)) THEN
                        balance_database(3) <= newBalanceAfterWithdrawal;
                    END IF;
                    MONEY_OUT <= moneyOut; 
                    IF(CONTINUE_BUTTON = '1') THEN
                        STATE <= READY;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN PIN_CHANGE =>
                    -- MEMANGGIL
                    -- PIN CHANGE COMPONENT
                    -- DI SINI
                    IF(accountUsageIndexID = 0) THEN
                        pinAcc1 <= new_pin;
                    ELSIF(accountUsageIndexID = 1) THEN
                        pinAcc2 <= new_pin;
                    ELSIF(accountUsageIndexID = 2) THEN
                        pinAcc3 <= new_pin;
                    ELSIF(accountUsageIndexID = 3) THEN
                        pinAcc4 <= new_pin;
                    END IF;
                    IF(CONTINUE_BUTTON = '1') THEN
                        STATE <= READY;
                    ELSE 
                        STATE <= IDLE;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;