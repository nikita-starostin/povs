;Создайте массив в памяти данных и заполните его с помощью цикла
;значениями 0x1, 0x2, 0x3 и т.д. Напишите процедуру, которая копирует значения
;из этого массива в память EEPROM.
#include p16f84a.inc

array_start equ 0x13
array_length equ 0x14
mem_array_start equ 0x15
index equ 0x21

org 0x0000 ; our program offset
GOTO  START
PRC_WRITE_ARRAY_TO_EEPROM
PRC_WRITE_ARRAY_TO_EEPROM_START:
; check if already copied (index < length)
	MOVF index, 0
	SUBWF array_length, 0
	BTFSC STATUS, 2 ; stop, if result is zero
	RETURN
; preparations for write to EEPROM
; set address where write
	MOVFW mem_array_start ; W = destination
	ADDWF index, 0 ; W += offset in array
	MOVWF EEADR ; EEADR = W
; set data value to write
	MOVFW array_start ; W = source array
	ADDWF index, 0 ; W += offset in array
	MOVWF FSR ; FSR = W
	MOVF INDF, 0 ; W = array[index]
	MOVWF EEDATA ; EEDATA = array[index]
; EEPROM writing cycle
	BSF STATUS, RP0 ; Bank 1
	BCF INTCON, GIE ; Disable INTs
	BSF EECON1, WREN ; Enable Write
	MOVLW 0x55 ; 4 'magic' lines for real eeprom write
	MOVWF EECON2
	MOVLW 0xAA
	MOVWF EECON2
	BSF EECON1, WR ; EE Write
	BCF EECON1, WREN; clear possibility to write (disable write)
	BSF INTCON, GIE ; Enable INTs
; waiting for finishing writing
WAIT_WRITE:
	BTFSS EECON1, EEIF ; check for interrupt bit
	goto WAIT_WRITE ; if not set then repeat check
	BCF EECON1, EEIF ; clear interrupt bit
	BCF STATUS, RP0 ; Bank 0
; iteration finished, inc index in array
	INCF index, 0x1
	GOTO PRC_WRITE_ARRAY_TO_EEPROM_START
	
START:
CLRF index ; set index to 0
BSF   STATUS,RP0; use first bank
; init array with initial values
WRITE_ARRAY_ITEM_START: 
    MOVF index, 0; write value at index into W
    SUBWF array_length, 0; W = W - (value from array_length reg)
    BTFSC STATUS, 2 ; stop, if result is zero
    GOTO WRITE_ARRAY_ITEM_END
	MOVFW array_start ; W = source array
	ADDWF index, 0 ; W += offset in array
	MOVWF FSR ; FSR = W
    INCF index, 0; write index + 1 to W
    MOVWF INDF; write index + 1 to array element
    INCF index, 1; increment index
    GOTO WRITE_ARRAY_ITEM_START; fill next item
WRITE_ARRAY_ITEM_END:

CLRF index; reset index
CALL PRC_WRITE_ARRAY_TO_EEPROM; write array to EEPROM
CLRF index
CLRF mem_array_start 
CLRF array_length
CLRF array_start
end;

