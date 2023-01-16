#include p16f84a.inc                ; Include register definition file

;====================================================================
; VARIABLES
;====================================================================
delay1 		equ 0x30
delay2 		equ 0x31
musicIndex	equ 0x32
musicAddress	equ 0x33
musicSize		equ 0x34
delay1s		equ 0x35
playing		equ 0x36
ADDRESS1	equ 0x2100
SIZE1		equ 0xAA
ADDRESS2	equ 0x21AA
SIZE2		equ 0xAB
FALSE 		equ 0x0
TRUE		equ 0x1

; init EEDATA with music bits, every bit is PORTA desired output
org 0x2100 ; EEPROM offset specific for PIC16F84A
de 0x1,0x2,0x8,0x1 ; bits for first track, not complete
de 0x1, 0x3, 0x5, 0x1 ; bits for second track, not complete
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
RST   code  0x0 
      goto  Start

;====================================================================
; CODE SEGMENT
;====================================================================

DELAY:
	BCF STATUS, RP0 ; Bank 0
	MOVLW 0xC4
	MOVWF delay1
	MOVLW 0xC4
	MOVWF delay2
DELAY_LOOP_START:
	DECFSZ delay1, 1
	GOTO DELAY_LOOP_ADDITIONAL
	DECFSZ delay2, 1	
DELAY_LOOP_ADDITIONAL:
	GOTO DELAY_LOOP_START
	RETURN

PLAY_MUSIC_BIT:
    MOVF musicIndex, 0
    SUBWF musicSize, 0
    BTFSS STATUS, Z
    CLRF musicIndex
    MOVF musicAddress, 0
    ADDWF musicIndex, 0
    MOVWF EEADR
    BSF STATUS, RP0
    BSF EECON1, RD
    BCF STATUS, RP0
    MOVF EEDATA, 0
    MOVWF PORTA
    RETURN

PGM   code
Start
      BCF STATUS, RP0
      CLRF PORTA
      CLRF PORTB
      BSF STATUS, RP0
      CLRF TRISA
      CLRF TRISB
      BSF TRISB, 0
      BCF STATUS, RP0
Loop  
     CLRF playing
WAIT_FOR_FIRST_PRESS:
     BTFSC playing, 0
     CALL PLAY_MUSIC_BIT
     BTFSS PORTB, 0
     GOTO WAIT_FOR_FIRST_PRESS
     BTFSS playing, 0
     GOTO START_WAIT_FOR_PLAY
     GOTO WAIT_FOR_FIRST_UNPRESS
START_WAIT_FOR_PLAY:
     MOVLW ADDRESS1
     MOVWF musicAddress
     MOVLW SIZE1
     MOVWF musicSize
     MOVLW 0x4E
     MOVWF delay1s
WAIT_FOR_FIRST_UNPRESS:
     BTFSC PORTB, 0
     GOTO WAIT_FOR_FIRST_UNPRESS
     BTFSS playing, 0
     GOTO WAIT_FOR_SECOND_PRESS
     MOVLW FALSE
     MOVWF playing
     GOTO WAIT_FOR_FIRST_PRESS
WAIT_FOR_SECOND_PRESS:
     DECF delay1s, 1
     MOVF delay1s, 0
     SUBLW 0
     BTFSC STATUS, Z
     GOTO PLAY_MUSIC
     BTFSS PORTB, 0
     GOTO WAIT_FOR_SECOND_PRESS
     MOVLW ADDRESS2
     MOVWF musicAddress
     MOVLW SIZE2
     MOVWF musicSize
WAIT_FOR_SECOND_UNPRESS:
     BTFSC PORTB, 0
     GOTO WAIT_FOR_SECOND_UNPRESS
PLAY_MUSIC:
     CALL DELAY
     CLRF musicIndex
     GOTO WAIT_FOR_FIRST_PRESS
     GOTO Loop

;====================================================================
      END
