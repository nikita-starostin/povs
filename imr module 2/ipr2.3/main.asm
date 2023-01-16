#include "p16f84a.inc"

w_temp 		equ 	0x40
status_temp equ		0x41

delay1 equ 0x42
delay2 equ 0x43

result		equ		0x30

readed	equ 0x44
first_value equ 0x45
action equ 0x46
second_value equ 0x47
state equ 0x48
loop equ 0x49
is_action equ 0x4a
temp equ 0x4b
op_result equ 0x4c

__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _RC_OSC

	ORG 0x000
	GOTO Start
	
	ORG 0x004 ; interrupts
;save W state
	MOVWF w_temp ; save off current W register contents
	MOVF STATUS,0 
	MOVWF status_temp ; save off contents of STATUS register

	BTFSS INTCON, RBIF ; check, is RB4-RB-7 bit port value changed
	GOTO OTHER_INTERRUPT

	MOVF PORTB, 0
	ANDLW b'11111000'
	IORLW b'00000011'
	MOVWF PORTB
	
	BTFSS PORTB, 4
	MOVLW 1
	BTFSS PORTB, 4
	MOVWF result
	BTFSS PORTB, 5
	MOVLW 4
	BTFSS PORTB, 5
	MOVWF result
	BTFSS PORTB, 6
	MOVLW 7
	BTFSS PORTB, 6
	MOVWF result
	BTFSS PORTB, 7
	MOVLW 0x0A
	BTFSS PORTB, 7
	MOVWF result
	
	MOVF PORTB, 0
	ANDLW b'11111000'
	IORLW b'00000101'
	MOVWF PORTB

	BTFSS PORTB, 4
	MOVLW 2
	BTFSS PORTB, 4
	MOVWF result
	BTFSS PORTB, 5
	MOVLW 5
	BTFSS PORTB, 5
	MOVWF result
	BTFSS PORTB, 6
	MOVLW 8
	BTFSS PORTB, 6
	MOVWF result
	BTFSS PORTB, 7
	MOVLW 0
	BTFSS PORTB, 7
	MOVWF result
	
	MOVF PORTB, 0
	ANDLW b'11111000'
	IORLW b'00000110'
	MOVWF PORTB

	BTFSS PORTB, 4
	MOVLW 3
	BTFSS PORTB, 4
	MOVWF result
	BTFSS PORTB, 5
	MOVLW 6
	BTFSS PORTB, 5
	MOVWF result
	BTFSS PORTB, 6
	MOVLW 9
	BTFSS PORTB, 6
	MOVWF result
	BTFSS PORTB, 7
	MOVLW 0x0B
	BTFSS PORTB, 7
	MOVWF result
	
	MOVF PORTB, 0
	ANDLW b'11111000'
	MOVWF PORTB
	
	BTFSC readed, 0
	GOTO REPEATING_READ
	
	MOVF state, 0
	SUBLW 4
	BTFSC STATUS, Z
	GOTO FIRST_NUMBER
	MOVF state, 0
	SUBLW 0
	BTFSC STATUS, Z
	GOTO FIRST_NUMBER
	MOVF state, 0
	SUBLW 1
	BTFSC STATUS, Z
	GOTO FIRST_NUMBER
	MOVF state, 0
	SUBLW 2
	BTFSC STATUS, Z
	GOTO SECOND_NUMBER
	MOVF state, 0
	SUBLW 3
	BTFSC STATUS, Z
	GOTO ACTION_DOING
	GOTO FINISH_PROCESSING
ACTION_DOING:
	MOVF result, 0
	MOVWF second_value
	CALL CHECK_STATE
	BTFSC is_action, 0
	GOTO SECOND_NUMBER
	BTFSC action, 0
	GOTO REALIZE_MULTIPLY
	MOVF first_value, 0
	ADDWF result, 1
	GOTO POST_ACTION
REALIZE_MULTIPLY:
	CLRF result
	CLRF loop
MULTIPLY_LOOP:
	MOVF second_value, 0
	SUBWF loop, 0
	BTFSC STATUS, 2 ; stop, if result is zero
	GOTO POST_ACTION
	MOVF result, 0
	ADDWF first_value, 0
	MOVWF result
	INCF loop, 1
	GOTO MULTIPLY_LOOP
POST_ACTION:
	MOVLW 1
	MOVWF state
	MOVF result, 0
	MOVWF op_result
	CLRF first_value
	CLRF action
	CLRF second_value
FIRST_NUMBER:
	MOVF result, 0
	MOVWF first_value
	CALL CHECK_STATE
	BTFSC is_action, 0
	GOTO FINISH_PROCESSING
	MOVLW 2
	MOVWF state
	GOTO FINISH_PROCESSING
SECOND_NUMBER:
	MOVF result, 0
	SUBLW 0x0A
	BTFSC STATUS, Z
	GOTO MULTIPLY
	MOVF result, 0
	SUBLW 0x0B
	BTFSC STATUS, Z
	GOTO PLUS
	MOVLW 1
	MOVWF state
	GOTO FINISH_PROCESSING
PLUS:
	BSF action, 1
	MOVLW 3
	MOVWF state
	GOTO FINISH_PROCESSING
MULTIPLY:
	BSF action, 0
	MOVLW 3
	MOVWF state
	GOTO FINISH_PROCESSING
REPEATING_READ:
	;MOVF state, 0
	;SUBLW 3
	;BTFSC STATUS, Z
	;GOTO FINISH_PROCESSING
	;MOVF op_result, 0
	;MOVWF result
FINISH_PROCESSING:
	BSF readed, 0
	MOVF PORTA, 0
	ANDLW b'11110000';
	IORWF result, 0
	MOVWF PORTA
	BCF INTCON, RBIF
	CALL DELAY
OTHER_INTERRUPT:
;restore W state
	MOVF status_temp, 0     ; retrieve copy of STATUS register
	MOVWF STATUS            ; restore pre-isr STATUS register contents
	SWAPF w_temp, 1
	SWAPF w_temp, 0          ; restore pre-isr W register contents
	RETFIE                   ; return from interrupt

DELAY:
	BCF STATUS, RP0 ; Bank 0
	MOVLW 0x10
	MOVWF delay1
	MOVLW 0x10
	MOVWF delay2
DELAY_LOOP_START:
	DECFSZ delay1, 1
	GOTO DELAY_LOOP_ADDITIONAL
	DECFSZ delay2, 1
DELAY_LOOP_ADDITIONAL:
	GOTO DELAY_LOOP_START
	RETURN

CHECK_STATE:
	MOVF result, 0
	MOVWF temp
	CLRF is_action
	MOVF result, 0
	SUBLW 0x0A
	BTFSC STATUS, Z
	BSF is_action, 0
	SUBLW 1
	BTFSC STATUS, Z
	BSF is_action, 0
	BTFSC is_action, 0
	MOVLW 1
	BTFSC is_action, 0
	MOVWF state
	MOVF temp, 0
	MOVWF result
	RETURN

; ========================================
;         PROGRAM START
; ========================================
	
Start:
;initializing ports
	BCF STATUS, RP0 ; Bank 0
	MOVLW b'00000000';
	MOVWF PORTB ; Initializing PORTB
	CLRF PORTA ; Initializing PORTA
	BSF STATUS, RP0 ; Bank 1
	MOVLW b'11110000' ; bit value for TRISB state
	MOVWF TRISB
	CLRF TRISA
	BCF OPTION_REG, 7

	BCF STATUS, RP0 ; Bank 0
	
	CLRF readed
	CLRF state
	
    BCF INTCON, RBIF    ; clear interrupt value for RB4-7
    BSF INTCON, RBIE    ; allow interrupts on RB4-7
    BSF INTCON, GIE     ; enable interrupts
    CLRF state

Loop:
	SLEEP
	CLRF readed
	GOTO Loop
	END
; ========================================
;         PROGRAM END
; ========================================