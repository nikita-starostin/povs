; ИПР 1. Задание 2. 
; Написать программу сортировки массива по убыванию
#include "p16f84.inc"

array_addr    set 0x30
array_size    set 0x14
is_swapped    equ 0x2E
loop_count    equ 0x2D
array_index   equ 0x2C
value_left    equ 0x2B
value_right   equ 0x2A

BEGIN:
    BCF STATUS, 0x5 ; set Bank0 in Data Memory by clearing RP0 bit in STATUS register
    CLRF array_index
LOOP_OUTTER: ; repeat
    MOVLW array_size ; W = array_size = 0x10
    MOVWF loop_count ; loop_count = W = 0x10
    CLRF array_index ; array_index = 0
    CLRF is_swapped
    
LOOP_INNER: ; for (loop_count = array_size
    CLRF value_left
    CLRF value_right
    
    ; value_left = array[array_index]
    MOVLW array_addr ; W = array_addr = 0x30
    ADDWF array_index, 0 ; W = W + array_index
    MOVWF FSR ; FSR = W, INDF = array[array_index]
    MOVF INDF, 0 ; W = INDF = array[array_index]
    MOVWF value_left
    
    ; value_right = array[array_index + 1]
    INCF array_index, 1
    MOVLW array_addr ; W = array_addr = 0x30
    ADDWF array_index, 0 ; W = W + array_index
    MOVWF FSR ; FSR = W, INDF = array[array_index]
    MOVF INDF, 0 ; W = INDF = array[array_index]
    MOVWF value_right
    SUBWF value_left, 0 ; W = value_left - W
    BTFSC STATUS, 0 ; if W < 0 (i.e. value_left < value_right)
    GOTO LOOP_INNER_END
    
    ; swap
    ; move value_right to array[array_index]
    DECF array_index, 1
    
    MOVLW array_addr ; W = array_addr
    ADDWF array_index, 0 ; W = W + array_index
    MOVWF FSR ; FSR = W
    MOVF value_right, 0 ; W = value_right
    MOVWF INDF

    ; move value_left to array[array_index + 1]
    INCF array_index, 1

    MOVLW array_addr ; W = array_addr
    ADDWF array_index, 0 ; W = W + array_index
    MOVWF FSR ; FSR = W
    MOVF value_left, 0 ; W = value_right
    MOVWF INDF
    
    INCF is_swapped, 1
    
LOOP_INNER_END:    
    DECF loop_count, 1
    MOVLW 1 ; W = 1
    SUBWF loop_count, 0
    BTFSS STATUS, 2 ; test if loop_count is zero (Z flag)
    GOTO LOOP_INNER

LOOP_OUTTER_END: ; until is_swapped = false
    MOVLW 0
    SUBWF is_swapped, 0
    BTFSS STATUS, 2
    GOTO LOOP_OUTTER
    
LOOP_END:
    CLRF is_swapped  
    CLRF loop_count  
    CLRF array_index   
    CLRF value_left 
    CLRF value_right
end
