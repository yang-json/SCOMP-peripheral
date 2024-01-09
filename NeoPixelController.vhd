-- WS2812 communication interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NeoPixelController is

	port(
		clk_10M  : in   std_logic;
		resetn   : in   std_logic;
		WRITE_LEDS : in std_logic;
		WRITE_COL_16_ALL : in std_logic;
		WRITE_SINGLE_IMMED : in std_logic;
		LOAD_COL_16 : in std_logic;
		LOAD_R8 : in std_logic;
		LOAD_G8 : in std_logic;
		LOAD_B8 : in std_logic;
		LOAD_ALL : in std_logic;
		LOAD_ONE_LED : in std_logic;
		SET_BRIGHTNESS : in std_logic;
		SECOND_COLOR : in std_logic;
		WAVE		: in std_logic;
		SHIFT : in std_logic;
		data     : in   std_logic_vector(15 downto 0);
		sda      : out  std_logic
	);

end entity;

architecture internals of NeoPixelController is
	--singal incomping is a composite signal to detect when any of the API endpoints are called
	signal incoming : std_logic;
	-- Buffer containing the color data for 256 NeoPixel LEDs.
	-- To access the color values for an individual pixel, use array access syntax:
	-- 	led_buffer(n)
	--type COLOR_BUFFER is array (0 to 255) of std_logic_vector(23 downto 0);
	--signal led_buffer 			: COLOR_BUFFER;
	signal led_buffer : std_logic_vector(6143 downto 0);
	--signal intermediate_buffer is the buffer the programmer most directly interacts with.
	--it is mutated by the programmer until it is stable, at which point it is copied over to the main buffer to be written out
	signal running : std_logic := '0';
	
	signal brightness : unsigned(6 downto 0) := "1000000";

begin

	-- Background NeoPixel output driver
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8;
		constant t1l : integer := 4;
		constant t0h : integer := 3;
		constant t0l : integer := 9;

		-- Variable for iterating through pixel colors
		variable bit_count   : integer range 0 to 6143;
		
		-- Holds the temporary brightness-corrected color value currently being written
		variable bri_color : std_logic_vector(7 downto 0);
		
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 1000;

		variable temp_value_for_repeating : integer range 0 to 23;

	begin
		if resetn = '0' then
			-- reset all counters
			bit_count := 6143;
			bri_color := x"00";
			enc_count := 0;
			reset_count := 1000;
			-- set sda inactive
			sda <= '0';

		elsif (rising_edge(clk_10M)) then

			-- during reset period, ensure other counters are reset
			if reset_count > 0 then
				bit_count := 6143;
				bri_color := led_buffer(bit_count downto bit_count-7);
				
				enc_count := 0;
				
				-- decrement the reset count
				reset_count := reset_count - 1;

			-- not in reset period (i.e. currently sending data)
			else
				-- If this bit is at the top of a color channel, then apply a brightness scaling to it
				if bit_count mod 8 = 7 then
					bri_color := std_logic_vector((unsigned(led_buffer(bit_count downto bit_count-7)) * brightness) / 64)(7 downto 0);
				end if;
				
				-- handle reaching end of a bit
				if (bri_color(bit_count mod 8) = '1' and enc_count = (t1h+t1l-1)) or
					(bri_color(bit_count mod 8) = '0' and enc_count = (t0h+t0l-1)) then
					enc_count := 0;
					
					-- Handle overflow conditions
					if bit_count = 0 then
						bit_count := 6143;
						
						-- begin the reset period
						reset_count := 1000;
					else
						-- if not end of data, decrement count
						bit_count := bit_count - 1;
					end if;
				else
					-- within a bit, count to achieve correct pulse widths
					enc_count := enc_count + 1;
				end if;
			end if;

			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif
				-- sda is 1 if it's the first part of a bit, which depends on if it's 1 or 0
				( ((bri_color(bit_count mod 8) = '1') and (enc_count < t1h))
				or
				((bri_color(bit_count mod 8) = '0') and (enc_count < t0h)) )
				then sda <= '1';
			else
				sda <= '0';
			end if;

		end if;
	end process;


	-- OPCODE Processor
	process(clk_10M, resetn)

		-- Signal from the CNTRL register that selects which LED the single-bulb write and read commands
		-- act on.
		--initial value is 0. in case someone tries something without setting index first, it will just mess with the first one
		--variable cntrl_index : integer range 0 to 255 := 0;
		--set some sort of initial value for GRB 24 bit. STORED AS GREEN | RED | BLUE
		variable GRB_24 : std_logic_vector(23 downto 0) := "000000000000000000000000";
		variable saved_color : std_logic_vector(23 downto 0) := "000000000000000000000000";
		variable temp_color : std_logic_vector(23 downto 0) := "000000000000000000000000";
		variable led_index : integer range 0 to 255;
		variable intermediate_buffer : std_logic_vector(6143 downto 0);
		-- WAVE Function variables/constants
		--   wave_buffer  -> contains pre-programmed rainbow wave pattern
		--   wave_period  -> contains # clock cycles between each color step   (OSC. Mode)
		--   wave_counter -> tracks how far through wave_period the system is  (OSC. Mode)
		--   wave_index   -> which color within the wave to set all pixels to  (OSC. Mode)
		constant wave_buffer : std_logic_vector(6143 downto 0) := x"00ff0000ff0500ff0b00ff1000ff1600ff1c00ff2100ff2700ff2d00ff3300ff3900ff3f00ff4500ff4c00ff5200ff5800ff5e00ff6400ff6b00ff7100ff7700ff7d00ff8400ff8a00ff9000ff9700ff9d00ffa300ffa900ffaf00ffb600ffbc00ffc200ffc800ffce00ffd400ffda00ffdf00ffe500ffeb00fff100fff600fffc00fcff00f6ff00f1ff00ebff00e5ff00dfff00daff00d4ff00ceff00c8ff00c2ff00bcff00b6ff00afff00a9ff00a3ff009dff0097ff0090ff008aff0084ff007dff0077ff0071ff006bff0064ff005eff0058ff0052ff004cff0045ff003fff0039ff0033ff002dff0027ff0021ff001cff0016ff0010ff000bff0005ff0000ff0500ff0b00ff1000ff1600ff1c00ff2100ff2700ff2d00ff3300ff3900ff3f00ff4500ff4c00ff5200ff5800ff5e00ff6400ff6b00ff7100ff7700ff7d00ff8400ff8a00ff9000ff9700ff9d00ffa300ffa900ffaf00ffb600ffbc00ffc200ffc800ffce00ffd400ffda00ffdf00ffe500ffeb00fff100fff600fffc00ffff00fcff00f6ff00f1ff00ebff00e5ff00dfff00daff00d4ff00ceff00c8ff00c2ff00bcff00b6ff00afff00a9ff00a3ff009dff0097ff0090ff008aff0084ff007dff0077ff0071ff006bff0064ff005eff0058ff0052ff004cff0045ff003fff0039ff0033ff002dff0027ff0021ff001cff0016ff0010ff000bff0005ff0000ff0500ff0b00ff1000ff1600ff1c00ff2100ff2700ff2d00ff3300ff3900ff3f00ff4500ff4c00ff5200ff5800ff5e00ff6400ff6b00ff7100ff7700ff7d00ff8400ff8a00ff9000ff9700ff9d00ffa300ffa900ffaf00ffb600ffbc00ffc200ffc800ffce00ffd400ffda00ffdf00ffe500ffeb00fff100fff600fffc00fcff00f6ff00f1ff00ebff00e5ff00dfff00daff00d4ff00ceff00c8ff00c2ff00bcff00b6ff00afff00a9ff00a3ff009dff0097ff0090ff008aff0084ff007dff0077ff0071ff006bff0064ff005eff0058ff0052ff004cff0045ff003fff0039ff0033ff002dff0027ff0021ff001cff0016ff0010ff000bff0005ff0000ff00";
		variable wave_period : integer range -1 to 10000000 := -1;
		variable wave_counter : integer range 0 to 10000000 := 0;
		variable wave_index : integer range 0 to 255 := 0;
		variable shift_end_index : integer range 0 to 255;
        variable shift_buffer : std_logic_vector(23 downto 0);
	begin
	
		if resetn = '0' then
			GRB_24 := x"000000";
			saved_color := x"000000";
			temp_color := x"000000";
			intermediate_buffer := (others => '0');
			led_index := 0;
			
			wave_period := -1;
			wave_counter := 0;
			wave_index := 0;
			shift_end_index := 0;
			shift_buffer := (others => '0');
		
		elsif (rising_edge(clk_10M)) then
			if WRITE_LEDS = '1' or wave_period > -1 then
				led_buffer <= intermediate_buffer;
			end if;
			if WRITE_COL_16_ALL = '1' then
				for i in 255 downto 0 loop
					intermediate_buffer(24*i+23 downto 24*i) := data(10 downto 5) & "00" & data(15 downto 11) & "000" & data(4 downto 0) & "000" ;
				end loop;
				led_buffer <= intermediate_buffer;
			end if;
			if WRITE_SINGLE_IMMED = '1' then
				led_index := 255-to_integer(unsigned(data(7 downto 0)));
				intermediate_buffer(24*led_index+23 downto 24*led_index) :=  GRB_24;
				led_buffer <= intermediate_buffer;
			end if;
			if LOAD_COL_16 = '1' then
				GRB_24 := data(10 downto 5) & "00" & data(15 downto 11) & "000" & data(4 downto 0) & "000";
			end if;
			if LOAD_R8 = '1' then
				GRB_24 := GRB_24(23 downto 16) & data(7 downto 0) & GRB_24(7 downto 0);
			end if;
			if LOAD_G8 = '1' then
				GRB_24 := data(7 downto 0) & GRB_24(15 downto 0);
			end if;
			if LOAD_B8 = '1' then
				GRB_24 := GRB_24(23 downto 8) & data(7 downto 0);
			end if;
			if LOAD_ALL = '1' then
				for i in 0 to 255 loop
					intermediate_buffer(24*i+23 downto 24*i) := GRB_24;
				end loop;
			end if;
			if LOAD_ONE_LED =  '1' then
				led_index := 255-to_integer(unsigned(data(7 downto 0)));
				intermediate_buffer(24*led_index+23 downto 24*led_index) :=  GRB_24;
			end if;
			if SECOND_COLOR = '1' then
				--save color in primary buffer to saved buffer
				if data(0) = '0' then
					saved_color := GRB_24;
				end if;
				--swap saved color buffer with primary color buffer
				if data(0) = '1' then
					temp_color := saved_color;
					saved_color := GRB_24;
					GRB_24 := temp_color;
				end if;
			end if;
			if SHIFT = '1' then
				shift_end_index := to_integer(unsigned(data(7 downto 0)));
				shift_buffer := intermediate_buffer(6143 downto 6120);
				for j in 255 downto 1 loop
					exit when j = 255-shift_end_index;
					intermediate_buffer(24*j+23 downto 24*j) := intermediate_buffer(24*(j-1)+23 downto 24*(j-1));
				end loop;
				intermediate_buffer(24*(255-shift_end_index)+23 downto 24*(255-shift_end_index)) := shift_buffer;
			end if;
			if SET_BRIGHTNESS = '1' then
				brightness <= unsigned(data(6 downto 0));
				if (to_integer(brightness) > 64) then
					brightness <= "1000000";
				end if;
			end if;

			-------------------
			-- WAVE FUNCTION --
			-------------------
			if WAVE = '1' then
				-- If control bit is asserted, stop oscillations (if active)
				if data(8) = '1' then
					wave_period := -1;
				
				-- If an integral argument is provided, then we are enter "color oscillation mode" where
				-- the entire neopixel strand is set to the same color, which over time drifts down the
				-- rainbow pattern.
				-- The frequency argument is used in the same convention as the Variable Refresh Rate.
				elsif to_integer(unsigned(data(7 downto 0))) > 0 then
					wave_period := (10000000 / to_integer(unsigned(data(7 downto 0))));
					wave_counter := 0;
					wave_index := 255 - to_integer(unsigned(data(15 downto 8)));
				
				-- If no valid argument is provided, simply copy the pattern to the LEDs
				else
					intermediate_buffer := wave_buffer;
					wave_period := -1;
				end if;
			end if;
			
			-- If `wave_period` is positive, then we overwrite the buffer with a single uniform color
			-- determined by time
			if wave_period > -1 then
				if wave_counter = 0 then
					for i in 255 downto 0 loop
						intermediate_buffer(24*i+23 downto 24*i) := wave_buffer((wave_index)*24+23 downto wave_index*24);
					end loop;
					
					if wave_index = 255 then wave_index := 0;
					else wave_index := wave_index + 1;
					end if;
					
					wave_counter := wave_period;
				end if;
				
				wave_counter := wave_counter - 1;
			end if;
		end if;
	end process;
end internals;
