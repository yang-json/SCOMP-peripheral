ORG 0


Start:
	CALL OscWave
	CALL Wait2s
	CALL OscWaveOff
	CALL Wait2s
	JUMP Start
	
; Function to enter oscillation mode
OscWave:
	LOADI 32
	OUT NeoPixel_WAVE
	RETURN

; Function to exit oscillation mode
OscWaveOff:
	LOADI 256
	OUT NeoPixel_WAVE

; Function to wait 2 seconds, then return
Wait2s:
	OUT Timer
Wait2sLoop:
	IN Timer
	SUB Wait2sPeriod
	JNEG Wait2sLoop
	RETURN

; Function to load the fixed rainbow wave pattern to the LEDs
FixedPattern:
	LOADI 0
	OUT NeoPixel_WAVE
	RETURN
	

Wait2sPeriod: DW 50

OscPeriod:	DW 1000
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
NeoPixel_WAVE:				EQU &H0AD
