ORG 0
call LoadRed
loadi 0
out NeoPixel_SECOND_COLOR
call loadYellow
flashLoop:
loadi 0
out NeoPixel_WRITE_SINGLE_IMMED
loadi 1
out NeoPixel_SECOND_COLOR
call fiveSecWait
jump flashLoop

LoadRed:
	LOAD RED_R
	out NeoPixel_LOAD_R8
	LOAD RED_G
	out NeoPixel_LOAD_G8
	LOAD RED_B
	out NeoPixel_LOAD_B8
	Return
	
LoadYellow:
	LOAD YELLOW_R
	out NeoPixel_LOAD_R8
	LOAD YELLOW_G
	out NeoPixel_LOAD_G8
	LOAD YELLOW_B
	out NeoPixel_LOAD_B8
	Return
	
LoadGreen:
	LOAD GREEN_R
	out NeoPixel_LOAD_R8
	LOAD GREEN_G
	out NeoPixel_LOAD_G8
	LOAD GREEN_B
	out NeoPixel_LOAD_B8
	Return
	
LoadBlue:
	LOAD BLUE_R
	out NeoPixel_LOAD_R8
	LOAD BLUE_G
	out NeoPixel_LOAD_G8
	LOAD BLUE_B
	out NeoPixel_LOAD_B8
	Return
	
LoadPurple:
	LOAD PURPLE_R
	out NeoPixel_LOAD_R8
	LOAD PURPLE_G
	out NeoPixel_LOAD_G8
	LOAD PURPLE_B
	out NeoPixel_LOAD_B8
	Return

SmallWait:
	OUT Timer
TimerLoop:
	IN Timer
	SUB TWO
	JNEG TimerLoop
	RETURN
	
fiveSecWait:
	OUT Timer
fiveSecLoop:
	IN Timer
	Sub FIFTY
	JNEG fiveSecLoop
	RETURN

; Variables
Color16: 	DW  0
Color16Test1: DW &B1111111111111111
Color16Test2: DW &B1010101010101010

; Important Constants
ONE:		DW	1
TWO: 		DW  2
THREE:		DW  3
FIFTY:		DW 50
;IDK why these are EQU and not DW lol I'll change them when i get around to it
All:		EQU 65535
RedMask:	EQU &B110000
GreenMask:	EQU &B000111000
BlueMask:	EQU &B000000111
Low9Mask:   EQU &B111111111
Low8Mask: 	EQU	&B11111111
Bit15:		EQU &H1000000000000000
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
NeoPixel_WRITE_LEDS:		EQU	&H0A0
NeoPixel_WRITE_COL_16_ALL:	EQU	&H0A1
NeoPixel_WRITE_SINGLE_IMMED: EQU &H0A2
NeoPixel_LOAD_COL_16:		EQU &H0A3
NeoPixel_LOAD_R8:			EQU	&H0A4
NeoPixel_LOAD_G8:			EQU	&H0A5
NeoPixel_LOAD_B8:			EQU &H0A6
NeoPixel_LOAD_ALL:	 		EQU &H0A7
NeoPixel_LOAD_ONE_LED:	 	EQU &H0A8
NeoPixel_SECOND_COLOR:	 	EQU &H0AE

;16 bit colors
BLUE_16:   DW  &B0000000000011111
WHITE_16:   DW &B1111111111111111

;RED
RED_R:		DW &B11111111
RED_G:		DW &B00000000
RED_B:		DW &B00000000
;ORANGE
ORANGE_R:		DW &H0FF
ORANGE_G:		DW &H0A5
ORANGE_B:		DW &H000
;YELLOW
YELLOW_R:		DW &H0FF
YELLOW_G:		DW &H0FF
YELLOW_B:		DW &H000
;GREEN
GREEN_R:	DW &H000
GREEN_G:		DW &H080
GREEN_B:	DW &H000
;BLUE
BLUE_R:	DW &H000
BLUE_G:	DW &H000
BLUE_B:	DW &H0FF
;PURPLE
PURPLE_R:	DW &H04B
PURPLE_G:	DW &H000
PURPLE_B:	DW &H082
;VIOLET
VIOLET_R:	DW &H0EE
VIOLET_G:	DW &H082
VIOLET_B:	DW &H0EE