ORG 0
	

Start:
	; Loop Until Ready to select test
	LOADI	0
	OUT		NeoPixel_WRITE_COL_16_ALL
	IN      Switches
	AND 	Bit9
	JPOS 	TestSelect
	JUMP	Start
	
; Select Test using switches	
TestSelect:
	IN      Switches
	AND 	Low8Mask
	OUT		Hex0
	JZERO 	TestConstant16Bit ; 0
	ADDI	-1
	JZERO   Test16BitIndex ; 1
	ADDI	-1
	JZERO	Test24BitAll ; 2
	ADDI	-1
	JZERO	Test24BitIndex ; 3
	ADDI	-1
	JZERO	TestBrightness ; 4
	ADDI	-1
	JZERO	TestRainbow ; 5
	ADDI	-1
	JZERO	TestSecondColor ; 6
	ADDI	-1
	JZERO	TestAsyncColor ; 7
	ADDI	-1
	JZERO	TestOscillate ; 8
	ADDI	-1
	JZERO	TestSingleLoop ; 9
	ADDI	-1
	JZERO	TestPartialRainbow ; 10
	JUMP 	Start

; Constantly output 3-4-3 RGB to all lights
TestConstant16Bit:
	; Place red bits in correct spot
	IN      Switches
	AND 	RedMask
	SHIFT   4
	STORE	Color16
	; Place green bits in correct spot
	IN      Switches
	AND  	GreenMask
	SHIFT	3
	OR		Color16
	STORE	Color16
	; Place blue bits in correct spot
	IN      Switches
	AND		BlueMask
	OR		Color16
	STORE	Color16
	; Display Pixels and loop
	OUT		NeoPixel_WRITE_COL_16_ALL
	JUMP 	TestConstant16Bit
	
; Test 16 bit input to LED at index
Test16BitIndex:
	; Read in 3-4-3 RGB input and scale to 16 bits
	; Place red bits in correct spot
	IN      Switches
	AND 	RedMask
	SHIFT   4
	STORE	Color16
	; Place green bits in correct spot
	IN      Switches
	AND  	GreenMask
	SHIFT	3
	OR		Color16
	STORE	Color16
	; Place blue bits in correct spot
	IN      Switches
	AND		BlueMask
	OR		Color16
	STORE	Color16
	; Loop until SW9 is off
	IN      Switches
	AND		Bit9
	JPOS	Test16BitIndex
	; Store color and go to index loop
	LOAD	Color16
	OUT		NeoPixel_LOAD_COL_16
Test16BitIndexInput:
	; Loop until SW9 is on
	IN      Switches
	AND		Bit9
	JZERO	Test16BitIndexInput
	; Output to index
	IN      Switches
	AND		Low8Mask
	OUT		NeoPixel_WRITE_SINGLE
	JUMP 	Test16BitIndex

; Test 24 Bit to All
Test24BitAll:
	LOADI	0
	OUT		NeoPixel_LOAD_G8
	LOAD	Full8
	OUT		NeoPixel_LOAD_R8
	OUT		NeoPixel_LOAD_B8
	; Output buffer to all
	OUT 	NeoPixel_LOAD_ALL
	OUT		NeoPixel_WRITE_LEDS
	JUMP	Test24BitALL
	
Test24BitIndex:
	; Loop until Bit9 is on
	IN		Switches
	AND		Bit9
	JZERO	Test24BitIndex
	LOADI	0
	OUT		NeoPixel_LOAD_G8
	LOAD	Full8
	OUT		NeoPixel_LOAD_R8
	OUT		NeoPixel_LOAD_B8
Index24BitLoop:
	; Loop until Bit9 is off
	IN		Switches
	AND		Bit9
	JPOS	Index24BitLoop
	IN		Switches
	AND		Low8Mask
	OUT		NeoPixel_LOAD_SINGLE
	OUT		NeoPixel_WRITE_LEDS
	JUMP	Test24BitIndex
	
	
; Test brightness
TestBrightness:
	LOAD	Purple
	OUT		NeoPixel_WRITE_COL_16_ALL
BrightnessLoop:
	; Loop until Bit9 is on
	IN      Switches
	AND		Bit9
	JZERO	BrightnessLoop
SetBrightness:
	; Loop until Bit9 is off
	IN      Switches
	AND		Bit9
	JPOS	SetBrightness
	; Set increment or decrement with Bit0
	IN      Switches
	AND		Low7Mask
	OUT		NeoPixel_LOAD_BRI
	OUT		NeoPixel_WRITE_LEDS
	JUMP	BrightnessLoop

; Test rainbow wave
TestRainbow:
	LOADI	0
	OUT		NeoPixel_LOAD_RAINBOW
	OUT		NeoPixel_WRITE_LEDS
RainbowLoop:
	LOADI	255
	OUT		NeoPixel_LOAD_SHIFT
	OUT		NeoPixel_WRITE_LEDS
	LOAD	fourk
	STORE	BusyCount
RainbowDelay:
	LOAD	BusyCount
	ADDI	-1
	STORE	BusyCount
	JNEG	RainbowLoop
	JUMP	RainbowDelay

; Test color storage by flashing between purple and white
TestSecondColor:
	LOAD	Full8
	OUT		NeoPixel_LOAD_R8
	OUT		NeoPixel_LOAD_B8
	LOADI	0
	OUT		NeoPixel_LOAD_G8
	OUT		NeoPixel_SECOND_COLOR
	LOAD	Full8
	OUT		NeoPixel_LOAD_G8
FirstColor:
	IN      Switches
	AND		Bit9
	JZERO	FirstColor
	OUT		NeoPixel_LOAD_ALL
	OUT		NeoPixel_WRITE_LEDS
	LOAD	Bit0
	OUT		NeoPixel_SECOND_COLOR
	OUT		Timer
FirstColorDelay:
	IN		Timer
	ADDI	-1
	JNEG	FirstColorDelay
SecondColor:
	IN      Switches
	AND		Bit9
	JPOS	SecondColor
	OUT		NeoPixel_LOAD_ALL
	OUT		NeoPixel_WRITE_LEDS
	LOAD	Bit0
	OUT		NeoPixel_SECOND_COLOR
SecondColorDelay:
	IN		Timer
	ADDI	-1
	JNEG	SecondColorDelay
	JUMP	FirstColor
	
TestAsyncColor:
	LOAD 	Purple
	OUT		NeoPixel_LOAD_COL_16
	LOADI	1
	OUT		NeoPixel_LOAD_SINGLE
	LOAD	White
	OUT		NeoPixel_LOAD_COL_16
	LOADI	4
	OUT		NeoPixel_LOAD_SINGLE
AsyncLoop:
	IN		Switches
	AND		Bit9
	JPOS	AsyncLoop
	OUT		NeoPixel_WRITE_LEDS
	JUMP	TestAsyncColor

TestOscillate:
	; Loop until Bit9 is off
	IN      Switches
	AND		Bit9
	JPOS	TestOscillate
	IN      Switches
	AND		Low8Mask
	OUT		NeoPixel_LOAD_RAINBOW
OscillateLoop:
	; Loop until Bit9 is on
	IN      Switches
	AND		Bit9
	JZERO	OscillateLoop
	OUT		NeoPixel_LOAD_RAINBOW
	JUMP	TestOscillate

TestSingleLoop:
	LOAD	White
	OUT		NeoPixel_LOAD_COL_16
	LOADI	255
	OUT		NeoPixel_WRITE_SINGLE
TestLoop:
	LOADI	255
	OUT		NeoPixel_LOAD_SHIFT
	OUT		NeoPixel_WRITE_LEDS
	LOAD	fourk
	STORE	BusyCount
TestDelay:
	LOAD	BusyCount
	ADDI	-1
	STORE	BusyCount
	JNEG	RainbowLoop
	JUMP	RainbowDelay
	
; Test rainbow wave
TestPartialRainbow:
	LOADI	0
	OUT		NeoPixel_LOAD_RAINBOW
	OUT		NeoPixel_WRITE_LEDS
PartialRainbowLoop:
	LOADI	30
	OUT		NeoPixel_LOAD_SHIFT
	OUT		NeoPixel_WRITE_LEDS
	LOAD	fourk
	STORE	BusyCount
PartialRainbowDelay:
	LOAD	BusyCount
	ADDI	-1
	STORE	BusyCount
	JNEG	PartialRainbowLoop
	JUMP	PartialRainbowDelay	


	
; Variables
Color16: 	DW  0
BusyCount:	DW	0
fourk:		DW	4000

; Important Constants
RedMask:	DW 	&B1110000000
GreenMask:	DW 	&B0001111000
BlueMask:	DW 	&B0000000111
Low9Mask:   DW 	&B111111111
Low8Mask: 	DW	&B11111111
Low7Mask:	DW	&B1111111
Bit9: 		DW 	&B1000000000
Bit8:		DW	&B100000000
Bit0:		DW 	&B1

; Color Constants
Purple:		DW	&HF81F
White:		DW	&HFFFF
Full8:		DW	&HFF
	
; IO Addr Constants
Switches:  	EQU &H000
LEDs:      	EQU &H001
Timer:     	EQU &H002
Hex0:      	EQU &H004
Hex1:      	EQU &H005
I2C_cmd:   	EQU &H090
I2C_data:  	EQU &H091
I2C_rdy:   	EQU &H092

; Controller IO Addr
NeoPixel_WRITE_LEDS:		EQU	&H0A0
NeoPixel_WRITE_COL_16_ALL:	EQU	&H0A1
NeoPixel_WRITE_SINGLE:		EQU	&H0A2
NeoPixel_LOAD_COL_16:		EQU	&H0A3
NeoPixel_LOAD_R8:			EQU	&H0A4
NeoPixel_LOAD_G8:			EQU	&H0A5
NeoPixel_LOAD_B8:			EQU	&H0A6
NeoPixel_LOAD_ALL:			EQU &H0A7
NeoPixel_LOAD_SINGLE:		EQU &H0A8
NeoPixel_LOAD_SHIFT:		EQU	&H0A9
NeoPixel_LOAD_BRI:			EQU	&H0AA
NeoPixel_LOAD_RAINBOW:		EQU &H0AD
NeoPixel_SECOND_COLOR:		EQU	&H0AE