; ИПР 2. Задание 1.
; Инициализируйте память EEPROM из ассемблерного кода, используя
; директиву "DE", строкой "БГУИР". Напишите процедуру, читающую эту строку
; из EEPROM в массив, расположенный в памяти данных.
#include "p16f84.inc"

mem_str_start equ 0x10
str_length equ 0x11
array_start equ 0x12
index equ 0x20

BEGIN:
	org 0x2100 ; EEPROM offset, specific to pic16f84
	de "БГУИР"
	;de "\xC1", "\xC3", "\xD3", "\xC8", "\xD0"
	;de "BSUIR"
	
	org 0x0000 ; our program offset
	CLRF index
;cycle loop
TRY_COPY_NEXT_SYMBOL:
; check if already copied (index < length)
	MOVF index, 0
	SUBWF str_length, 0
	BTFSC STATUS, 2 ; stop, if result is zero
	GOTO FINISHED
; destination preparations
	MOVFW array_start ; W = destination
	ADDWF index, 0 ; W += offset in string
	MOVWF FSR ; FSR = W
; eeprom read
	BCF STATUS, RP0 ; Bank 0
	MOVFW mem_str_start ; W = string start address
	ADDWF index, 0 ; W += offset in string
	MOVWF EEADR ; Address to read
	BSF STATUS, RP0 ; Bank 1
	BSF EECON1, RD ; EE Read
	BCF STATUS, RP0 ; Bank 0
	MOVF EEDATA, 0 ; W = EEDATA
	MOVWF INDF ; copy byte from eeprom to destination array element
; iteration finished, inc index in string
	INCF index, 0x1
	GOTO TRY_COPY_NEXT_SYMBOL
; procedure logic finished, clearing memory
FINISHED:
	CLRF index
	CLRF array_start
	CLRF str_length
	CLRF mem_str_start

