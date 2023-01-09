;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Mon Jan 9 2023
; Processor: PIC16F84A
; Compiler:  MPASM (Proteus)
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

#include p16f84a.inc                ; Include register definition file

;====================================================================
; VARIABLES
;====================================================================
delay1 		equ 	0x40
delay2 		equ 	0x41
loop_index  equ     0x42
loop_count  equ     0x43

__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _RC_OSC
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
RST   code  0x0 
      goto  Start

DELAY:
	BCF STATUS, RP0 ; Bank 0
	MOVLW 0x4E
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

ALL_TOGETHER:
	;allow to change bits of portb progammatically
	BSF STATUS, RP0 ; start using bank 1
	MOVLW b'01111000' ; set zeros to TRISB to allow to set bits for PORTB
	MOVWF TRISB
	BCF STATUS, RP0 ; start using Bank 0

	MOVLW b'10000111' ;1111
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000000' ;0000
	MOVWF PORTB
	CALL DELAY
	
	RETURN      	

ONLY_ONE:
	;allow to change bits of portb progammatically
	BSF STATUS, RP0 ; start using bank 1
	MOVLW b'01111000' ; set zeros to TRISB to allow to set bits for PORTB
	MOVWF TRISB
	BCF STATUS, RP0 ; start using Bank 0

	MOVLW b'00000001' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000010' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000100' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000000' 
	MOVWF PORTB
	CALL DELAY

	RETURN      	


TWO:
	;allow to change bits of portb progammatically
	BSF STATUS, RP0 ; start using bank 1
	MOVLW b'01111000' ; set zeros to TRISB to allow to set bits for PORTB
	MOVWF TRISB
	BCF STATUS, RP0 ; start using Bank 0

	MOVLW b'10000100' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000010' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000001' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000110' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000101' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000011' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000001' 
	MOVWF PORTB
	CALL DELAY
	
	RETURN      	

BINARY:
	;allow to change bits of portb progammatically
	BSF STATUS, RP0 ; start using bank 1
	MOVLW b'00000000' ; set zeros to TRISB to allow to set bits for PORTB
	MOVWF TRISB
	BCF STATUS, RP0 ; start using Bank 0

	MOVLW b'00000001' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000010' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000011' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000100' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000101' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'00000111' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000000' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000001' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000010' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000011' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000100' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000101' 
	MOVWF PORTB
	CALL DELAY

	MOVLW b'10000111' 
	MOVWF PORTB
	CALL DELAY
	
	RETURN      	
	   
;====================================================================
; CODE SEGMENT
;====================================================================

PGM   code
Start
      CLRF loop_index
      MOVLW .2
      MOVWF loop_count
LED_LOOP
      MOVF loop_count, 0
      SUBWF loop_index, 0
      BTFSC STATUS, 2
        GOTO Loop
      CALL ALL_TOGETHER
      CALL ONLY_ONE
      CALL TWO
      CALL BINARY
      INCF loop_index, 1
      GOTO LED_LOOP
Loop  
      GOTO Loop

;====================================================================
      END
