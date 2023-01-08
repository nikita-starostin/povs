#include "pic16f84.inc"

c_adr set 0x30 ; начало массива
v_ptr equ 0x2F ; текущий элемент в массиве 
v_min equ 0x2E ; минимальный элемент в массиве 
c_num set 0x14 ; размер массива
 
BEGIN:
    BCF STATUS, 0x5 ; выбор Bank0 в памяти данных
    CLRF v_ptr ; v_ptr=0
    CLRF v_min ; v_min=0 
    MOVFF c_adr, v_min; initially the min element is the first element of array

LOOP1:
    MOVF v_ptr,0 ; W=v_ptr 
    ADDLW c_adr ; W=W+c_addr
    MOVWF FSR ; FSR=W, INDF=array[W] 
    MOVF INDF,0 ; W=INDF
    SUBWF v_min,0 ; W=W-v_min
    BTFSS STATUS,0 ; If W > 0 then goto SMALL 
    GOTO SKIP
	; Else W <= 0 then W is smaller than v_min	
    MOVF v_ptr,0 
    ADDLW c_adr 
    MOVWF FSR 
    MOVF INDF,0
    MOVWF v_min ; v_min=array[v_ptr]
SKIP:
    INCF v_ptr,0x1 ; v_ptr=v_ptr+1 
    MOVLW c_num ; W=c_num
    SUBWF v_ptr,0 ; W=W-v_ptr 
    BTFSS STATUS,0 ; v_ptr > c_num ?
    GOTO LOOP1
    CLRF v_ptr ; v_ptr=0
    CLRF v_min ; v_min=0
END
