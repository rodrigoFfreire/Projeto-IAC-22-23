; Ignorar isto apenas para testing purposes
DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
LINHA      EQU 8       ; linha a testar (4� linha, 1000b)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado


	PLACE       1000H
pilha:
	STACK 100H			; espa�o reservado para a pilha 
						; (200H bytes, pois s�o 100H words)
SP_inicial:				; este � o endere�o (1200H) com que o SP deve ser 
						; inicializado. O 1.� end. de retorno ser� 
						; armazenado em 11FEH (1200H-2)
LAST_PRESSED_KEY:
    WORD -1 ; Start with default value   

; Used together with LAST_PRESSED_KEY to determine when to execute a command
; 0 -> dont execute; 1 -> execute; -1 -> dont execute [key was not released]
EXECUTE_COMMAND:
    WORD 0



    PLACE      0
init:
    MOV  SP, SP_inicial

    MOV  R9, DISPLAYS

loop:
    CALL keyboard_listner

    MOV R10, [LAST_PRESSED_KEY]
    MOVB [R9], R10

    JMP loop


;**********
; Rotina de controlo do input (Teclado)
; Registos Usados (Argumentos):
;   - R0 (valor da coluna)
;   - R1 (valor da linha, linha a testar, tecla convertida)
;   - R2 (Endereco Teclado linha, linha convertida)
;   - R3 (Endereco Teclado Coluna, coluna convertida)
;   - R4 (Mascara)
;**********
;Copiar para o ficheiro final a partir daqui:
keyboard_listner:
    PUSH R0
    PUSH R1
    PUSH R4

    MOV R4, 8 ; max lines (1000b)

    MOV R1, 8000H ; Start at here for bit roll to begin at 1
    line_check_loop:
        ROL R1, 1
        CALL test_line
        JNZ press_key ; If key was detected goto press routine

        CMP R1, R4
        JNZ line_check_loop ; keeping looping until all lines are checked

    MOV R1, 0 ; no key was pressed so turn off execute flag
    MOV [EXECUTE_COMMAND], R1

    end_keyboard_listner:
        POP R4
        POP R1
        POP R0
        RET

test_line:
    PUSH R1
    PUSH R2
    PUSH R3
    ; read from keyboard
    MOV R2, TEC_LIN
    MOV R3, TEC_COL
    MOVB [R2], R1
    MOVB R0, [R3]

    MOV R1, 0FH   
    AND R0, R1      ; Mask nibble low
    CMP R0, 0

    POP R3
    POP R2
    POP R1
    RET

press_key:
    CALL convert_to_key
    MOV R0, [EXECUTE_COMMAND]
    CMP R0, 0 ; Check if last cycle key was released
    JZ store_key

    MOV R1, -1
    MOV [EXECUTE_COMMAND], R1 ; Lock command execution due to key not released
    JMP end_keyboard_listner

    store_key:
        MOV [LAST_PRESSED_KEY], R1
        MOV R1, 1
        MOV [EXECUTE_COMMAND], R1
        JMP end_keyboard_listner

convert_to_key:
    PUSH R5
    PUSH R6

    MOV R6, R1 ; move line to R6 to be converted
    CALL convert_to_key_aux
    MOV R1, R5 ; move result to R1
    MOV R6, R0 ; move column to R6 to be converted
    CALL convert_to_key_aux

    MOV R6, 4
    MUL R1, R6
    ADD R1, R5 ; R1 will contain converted key

    POP R6
    POP R5
    RET

convert_to_key_aux:
    MOV R5, -1

    keep_shifting:
        ADD R5, 1
        SHR R6, 1
        CMP R6, 0
        JNZ keep_shifting

    RET