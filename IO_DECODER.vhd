-- IO DECODER for SCOMP
-- This eliminates the need for a lot of AND decoders or Comparators
--    that would otherwise be spread around the top-level BDF

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IO_DECODER IS

  PORT
  (
    IO_ADDR       : IN STD_LOGIC_VECTOR(10 downto 0);
    IO_CYCLE      : IN STD_LOGIC;
    SWITCH_EN     : OUT STD_LOGIC;
    LED_EN        : OUT STD_LOGIC;
    TIMER_EN      : OUT STD_LOGIC;
    HEX0_EN       : OUT STD_LOGIC;
    HEX1_EN       : OUT STD_LOGIC;
    I2C_CMD_EN    : OUT STD_LOGIC;
    I2C_DATA_EN   : OUT STD_LOGIC;
    I2C_RDY_EN    : OUT STD_LOGIC;
	  NeoPixel_WRITE_LEDS			: OUT STD_LOGIC;
	  NeoPixel_WRITE_COL_16_ALL	: OUT STD_LOGIC;
    NeoPixel_WRITE_SINGLE_IMMED : OUT STD_LOGIC;
    NeoPixel_LOAD_COL_16				: OUT STD_LOGIC;
	 NeoPixel_LOAD_R8					: OUT STD_LOGIC;
	 NeoPixel_LOAD_G8					: OUT STD_LOGIC;
	 NeoPixel_LOAD_B8					: OUT STD_LOGIC;
	 NeoPixel_LOAD_ALL				: OUT STD_LOGIC;
	 NeoPixel_LOAD_ONE_LED			: OUT STD_LOGIC;
	 NeoPixel_SET_BRIGHTNESS 		: OUT STD_LOGIC;
	 NeoPixel_SECOND_COLOR 			: OUT std_logic;
	 NeoPixel_WAVE						: OUT STD_LOGIC;
     NeoPixel_SHIFT           : OUT STD_LOGIC
  );

END ENTITY;

ARCHITECTURE a OF IO_DECODER IS

  SIGNAL  ADDR_INT  : INTEGER RANGE 0 TO 2047;

begin

  ADDR_INT <= TO_INTEGER(UNSIGNED(IO_ADDR));

  SWITCH_EN    <= '1' WHEN (ADDR_INT = 16#000#) and (IO_CYCLE = '1') ELSE '0';
  LED_EN       <= '1' WHEN (ADDR_INT = 16#001#) and (IO_CYCLE = '1') ELSE '0';
  TIMER_EN     <= '1' WHEN (ADDR_INT = 16#002#) and (IO_CYCLE = '1') ELSE '0';
  HEX0_EN      <= '1' WHEN (ADDR_INT = 16#004#) and (IO_CYCLE = '1') ELSE '0';
  HEX1_EN      <= '1' WHEN (ADDR_INT = 16#005#) and (IO_CYCLE = '1') ELSE '0';
  I2C_CMD_EN   <= '1' WHEN (ADDR_INT = 16#090#) and (IO_CYCLE = '1') ELSE '0';
  I2C_DATA_EN  <= '1' WHEN (ADDR_INT = 16#091#) and (IO_CYCLE = '1') ELSE '0';
  I2C_RDY_EN   <= '1' WHEN (ADDR_INT = 16#092#) and (IO_CYCLE = '1') ELSE '0';

  --setters
  NeoPixel_WRITE_LEDS	     	<= '1' WHEN (ADDR_INT = 16#0A0#) and (IO_CYCLE = '1') ELSE '0'; --action: changes physical LED colors
  NeoPixel_WRITE_COL_16_ALL	<= '1' WHEN (ADDR_INT = 16#0A1#) and (IO_CYCLE = '1') ELSE '0'; --action: LEDs all change to new color --- input: 16-bit RGB color
  NeoPixel_WRITE_SINGLE_IMMED	<= '1' WHEN (ADDR_INT = 16#0A2#) and (IO_CYCLE = '1') ELSE '0'; --action: LEDs all change to new color --- input: 16-bit RGB color
  NeoPixel_LOAD_COL_16			<= '1' WHEN (ADDR_INT = 16#0A3#) and (IO_CYCLE = '1') ELSE '0'; --action: set color variable --- input: 16-bit RGB color
  NeoPixel_LOAD_R8 				<= '1' WHEN (ADDR_INT = 16#0A4#) and (IO_CYCLE = '1') ELSE '0'; --action: set red --- input: 8-bit red
  NeoPixel_LOAD_G8 				<= '1' WHEN (ADDR_INT = 16#0A5#) and (IO_CYCLE = '1') ELSE '0'; --action: set green --- input: 8-bit green
  NeoPixel_LOAD_B8 				<= '1' WHEN (ADDR_INT = 16#0A6#) and (IO_CYCLE = '1') ELSE '0'; --action: set blue --- input: 8-bit blue
  --changers
		--change all
  NeoPixel_LOAD_ALL				<= '1' WHEN (ADDR_INT = 16#0A7#) and (IO_CYCLE = '1') ELSE '0'; --action: LEDs all set to stored color --- input: NO INPUT NEEDED
  NeoPixel_LOAD_ONE_LED			<= '1' WHEN (ADDR_INT = 16#0A8#) and (IO_CYCLE = '1') ELSE '0'; --action: set one LED to stored color
  NeoPixel_SECOND_COLOR			<= '1' WHEN (ADDR_INT = 16#0AE#) and (IO_CYCLE = '1') ELSE '0'; --action: save/swap the secondary color
  NeoPixel_SHIFT          <= '1' WHEN (ADDR_INT = 16#0A9#) and (IO_CYCLE = '1') ELSE '0'; --rotate shift
		--change one
  NeoPixel_SET_BRIGHTNESS <= '1' WHEN (ADDR_INT = 16#0AA#) and (IO_CYCLE = '1') ELSE '0'; --action: set one LED to stored color
  NeoPixel_WAVE					<= '1' WHEN (ADDR_INT = 16#0AD#) and (IO_CYCLE = '1') ELSE '0'; --action: Fill buffer with pre-programmed WAVE pattern
  
END a;
