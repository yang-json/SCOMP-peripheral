ORG 0


start:
; Constantly output 3-4-3 RGB to all lights
TestLoop:
	jump RainbowSnake
	;load BLUE_16
	out NeoPixel_SET_COL_16
	load TWO
	out NeoPixel_CHANGE_ONE_LED
	jump TestLoop

	; SOLID RAINBOW!!!!!
RainbowLoop:

	Call SetToRed
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	call SetToOrange
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	call SetToYellow
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	call SetToGreen
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	call SetToBlue
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	call SetToPurple
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	call SetToViolet
	OUT NeoPixel_CHANGE_ALL
	
	CALL SmallWait
	
	jump RainbowLoop	

	Counter: dw 0
RainbowSnake:
	Call SetToRed
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	call SetToOrange
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	call SetToYellow
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	call SetToGreen
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	call SetToBlue
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	call SetToPurple
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	call SetToViolet
	load Counter
	OUT NeoPixel_CHANGE_ONE_LED
	
	CALL SmallWait
	CALL IncrementCounterAndClearLastPixel
	
	jump RainbowSnake
	


IncrementCounterAndClearLastPixel:
	Loadi 0
	out NeoPixel_SET_COL_16
	Load Counter
	out NeoPixel_CHANGE_ONE_LED
	addi 1
	store Counter
	addi -60
	jneg Rtrn
	loadi 0
	store Counter
Rtrn:
	Return
	
	
SmallWait:
	OUT Timer
TimerLoop:
	IN Timer
	SUB TWO
	JNEG TimerLoop
	RETURN
	
SetToRed:
	LOAD RED_R
	out NeoPixel_SET_R8
	LOAD RED_G
	out NeoPixel_SET_G8
	LOAD RED_B
	out NeoPixel_SET_B8
	Return
SetToOrange:
	LOAD ORANGE_R
	out NeoPixel_SET_R8
	LOAD ORANGE_G
	out NeoPixel_SET_G8
	LOAD ORANGE_B
	out NeoPixel_SET_B8
	return
SetToYellow:
	LOAD YELLOW_R
	out NeoPixel_SET_R8
	LOAD YELLOW_G
	out NeoPixel_SET_G8
	LOAD YELLOW_B
	out NeoPixel_SET_B8
	Return
SetToGreen:
	LOAD GREEN_R
	out NeoPixel_SET_R8
	LOAD GREEN_G
	out NeoPixel_SET_G8
	LOAD GREEN_B
	out NeoPixel_SET_B8
	Return
SetToBlue:
	LOAD BLUE_R
	out NeoPixel_SET_R8
	LOAD BLUE_G
	out NeoPixel_SET_G8
	LOAD BLUE_B
	out NeoPixel_SET_B8
	Return
SetToPurple:
	LOAD PURPLE_R
	out NeoPixel_SET_R8
	LOAD PURPLE_G
	out NeoPixel_SET_G8
	LOAD PURPLE_B
	out NeoPixel_SET_B8
	Return
SetToViolet:
	LOAD VIOLET_R
	out NeoPixel_SET_R8
	LOAD VIOLET_G
	out NeoPixel_SET_G8
	LOAD VIOLET_B
	out NeoPixel_SET_B8
	Return
	
	
	
	
	
	
; Variables
Color16: 	DW  0
Color16Test: DW &B111111111111
; Important Constants
ONE:		DW	1
TWO: 		DW  2
THREE:		DW  3
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
NeoPixel_SET_COL_16:		EQU	&H0A0
NeoPixel_SET_R8:			EQU	&H0A1
NeoPixel_SET_G8:			EQU	&H0A2
NeoPixel_SET_B8:			EQU	&H0A3

NeoPixel_CHANGE_COL_16_ALL:	EQU &H0A4
NeoPixel_CHANGE_ALL: 		EQU &H0A5
NeoPixel_CHANGE_BRIGHTER: 	EQU &H0A6
NeoPixel_CHANGE_DARKER: 	EQU &H0A7

NeoPixel_CHANGE_ONE_LED: 	EQU &H0A8

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






