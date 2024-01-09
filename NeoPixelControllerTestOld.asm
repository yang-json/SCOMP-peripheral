ORG 0

Start:
	; Loop Until Ready to select test
	LOAD 	Switches
	AND 	Bit9
	JPOS 	TestSelect
	JUMP	Start
	
; Select Test using switches	
TestSelect:
	LOAD 	Switches
	AND 	Low9Mask
	JZERO 	TestConstant16Bit
	ADDI	-1
	JZERO   Test24Bit
	ADDI	-1
	JZERO	Test16BitIndex
	JUMP 	Start

; Constantly output 3-4-3 RGB to all lights
TestConstant16Bit:
	; Place red bits in correct spot
	LOAD 	Switches
	AND 	RedMask
	SHIFT   4
	STORE	Color16
	; Place green bits in correct spot
	LOAD 	Switches
	AND  	GreenMask
	SHIFT	3
	OR		Color16
	; Place blue bits in correct spot
	LOAD	Switches
	AND		GreenMask
	OR		Color16
	; Display Pixels and loop
	LOAD	Color16
	OUT		COL_16_ALL
	JUMP 	TestConstant16Bit
	
; Test 24 Bit input and output
Test24Bit:
	;Loop until Bit9 is on
	LOAD 	Switches
	AND		Bit9
	JPOS	ReadRed
	JUMP	Test24Bit
ReadRed:
	; Put 8 bits into red
	LOAD 	Switches
	AND		Low8Mask
	OUT 	R8
	; Loop until Bit9 is off
	LOAD 	Switches
	AND		Bit9
	JZERO 	ReadGreen
	JUMP 	Test24Bit
ReadGreen:
	; Put 8 bits into green
	LOAD 	Switches
	AND		Low8Mask
	OUT 	G8
	; Loop until Bit9 is on
	LOAD 	Switches
	AND		Bit9
	JPOS 	ReadBlue
	JUMP 	ReadGreen
ReadBlue:
	; Put 8 bits into blue
	LOAD	Switches
	AND		Low8Mask
	OUT 	B8
	;Loop until Bit9 is off
	LOAD	Switches
	AND		Bit9
	JZERO	Output24Bit
	JUMP	ReadBlue
Output24Bit:
	LOAD	Bit9
	OUT		CNTRL
	JUMP	Test24Bit
	
; Test 16 bit input to LED at index
Test16BitIndex:
	; Read in 3-4-3 RGB input and scale to 16 bits
	; Place red bits in correct spot
	LOAD 	Switches
	AND 	RedMask
	SHIFT   4
	STORE	Color16
	; Place green bits in correct spot
	LOAD 	Switches
	AND  	GreenMask
	SHIFT	3
	OR		Color16
	; Place blue bits in correct spot
	LOAD	Switches
	AND		GreenMask
	OR		Color16
	; Loop until SW9 is off
	LOAD	Switches
	AND		Bit9
	JPOS	Test16BitIndex
	; Store color and go to index loop
	LOAD	Color16
	OUT		COL_16
	JUMP	Test16BitIndex
Test16BitIndexInput:
	; Loop until SW9 is on
	LOAD	Switches
	AND		Bit9
	JZERO	Test16BitIndexInput
	; Output to index
	LOAD	Switches
	AND		Low8Mask
	OUT		CNTRL
	JUMP 	Test16BitIndex
	
	
	
; Variables
Color16: 	DW  0

; Important Constants
RedMask:	EQU &B111000000
GreenMask:	EQU &B000111000
BlueMask:	EQU &B000000111
Low9Mask:   EQU &B111111111
Low8Mask: 	EQU	&B11111111
Bit9: 		EQU &B1000000000
	
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
CNTRL:		EQU	&H0A0
COL_16:		EQU	&H0A1
R8:			EQU	&H0A2
G8:			EQU	&H0A3
B8:			EQU &H0A4
COL_16_ALL: EQU &H0A5