LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.atm_prototypes.ALL;

entity atm_machine_tb is
end entity atm_machine_tb;

architecture rtl of atm_machine_tb is
  COMPONENT atm_machine IS
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
  end COMPONENT atm_machine;

  CONSTANT t : TIME := 30 ns;
  
  signal CLK : STD_LOGIC;
  SIGNAL RESET : STD_LOGIC;
  SIGNAL CARD_READER : STD_LOGIC := '1';
  SIGNAL PIN_INPUT : password_type := (7, 2, 0, 5, 4, 1);
  SIGNAL PIN_NEW_INPUT : password_type := (2, 9, 8 , 0, 1, 2);
  SIGNAL DEPOSIT_BUTTON : STD_LOGIC := '1';
  SIGNAL WITHDRAW_BUTTON : STD_LOGIC := '0';
  SIGNAL CHANGE_PIN_BUTTON : STD_LOGIC := '0';
  SIGNAL CONTINUE_BUTTON : STD_LOGIC := '1';
  SIGNAL NOMINAL_MASUK_MESIN : INTEGER := 30_000;
  SIGNAL NOMINAL_PENARIKAN : INTEGER := 30_000;
  SIGNAL NOMINAL_DEPOSIT : INTEGER := 25_000;
  SIGNAL buttonDeposit : std_logic_vector(6 DOWNTO 0) := "0000100";
  SIGNAL buttonAmountWithdraw : button_amount := (1, 2, 0, 0, 0, 0, 0);
  SIGNAL MONEY_OUT : INTEGER;


begin
  DUT_Deposit : atm_machine PORT MAP(
    CLK => CLK, RESET => RESET, CARD_READER => CARD_READER, PIN_INPUT => PIN_INPUT,
    PIN_NEW_INPUT => PIN_NEW_INPUT, DEPOSIT_BUTTON => DEPOSIT_BUTTON,
    WITHDRAW_BUTTON => WITHDRAW_BUTTON, CHANGE_PIN_BUTTON => CHANGE_PIN_BUTTON,
    CONTINUE_BUTTON => CONTINUE_BUTTON, NOMINAL_MASUK_MESIN => NOMINAL_MASUK_MESIN,
    NOMINAL_PENARIKAN => NOMINAL_PENARIKAN, NOMINAL_DEPOSIT => NOMINAL_DEPOSIT,
    buttonDeposit => buttonDeposit, buttonAmountWithdraw => buttonAmountWithdraw,
    MONEY_OUT => MONEY_OUT
  );

  PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR T/2;
    CLK <= '1';
    WAIT FOR T/2;
  END PROCESS;

  RESET <= '1', '0' AFTER T/2;
end architecture;