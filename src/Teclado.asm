;**********
; Rotina de controlo do input (Teclado)
; Registos Usados:
;   - R0 (valor da coluna)
;   - R1 (valor da linha, linha a testar, tecla convertida)
;   - R2 (Endereco Teclado linha, linha convertida)
;   - R3 (Endereco Teclado Coluna, coluna convertida)
;   - R5 (Mascara)
;   - R9 (Flag que indica se é para executar um comando ou nao) [Registo exclusivo para isto - nao utilizar]
;   - R10 (Ultima Tecla armazenada para futuros comandos) [Registo exclusivo para isto - nao utilizar]
;**********


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


    PLACE      0
init:
    MOV  SP, SP_inicial

    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
    MOV  R4, DISPLAYS
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R9, 0
    MOV  R10, -1

loop:
    CALL keyboard_listner
    NOP
    NOP
    NOP
    MOVB [R4], R10
    NOP
    NOP
    NOP
    JMP loop


;Copiar para o ficheiro final a partir daqui:
keyboard_listner:
    PUSH R0
    PUSH R1
    PUSH R5
    MOV  R1, 0001b         ; Testar Linha 1
    CALL test_line
    JNZ  press
    MOV  R1, 0010b         ; Testar Linha 2
    CALL test_line
    JNZ  press
    MOV  R1, 0100b         ; Testar Linha 3
    CALL test_line
    JNZ  press
    MOV  R1, 1000b         ; Testar Linha 4
    CALL test_line
    JNZ  press
    MOV R9, 0
    end_keyboard_listner:
        POP R5
        POP R1
        POP R0
        RET

test_line:
    MOVB [R2], R1
    MOVB R0, [R3]   
    AND R0, R5      ; Mask low bits
    CMP R0, 0
    RET

press:
    CALL convert
    SHL R1, 2
    ADD R1, R0      ; conversao final
    CMP R9, 0
    JZ press_update
    MOV R9, -1
    JMP end_keyboard_listner
    press_update:
        MOV R10, R1
        MOV R9, 1
        JMP end_keyboard_listner

convert:
    PUSH R2
    PUSH R3
    MOV R2, 0
    MOV R3, 0
    compare:                ; Verificar apos SHR se o numero = 0001b
        CMP R0, 1
        JNZ convert_aux_col
        CMP R1, 1
        JNZ convert_aux_lin
    MOV R0, R2
    MOV R1, R3
    POP R3
    POP R2
    RET

convert_aux_lin:
    SHR R1, 1
    ADD R3, 1
    JMP compare

convert_aux_col:
    SHR R0, 1
    ADD R2, 1
    JMP compare
