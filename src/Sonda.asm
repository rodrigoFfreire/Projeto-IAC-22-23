;**********
; Rotina para desenhar a sonda
; Registos Usados:
;**********

DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

COMANDOS			EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    	EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   	EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    	EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     	EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 	EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

N_LINHAS        	EQU  32				; número de linhas do ecrã (altura)
N_COLUNAS       	EQU  64				; número de colunas do ecrã (largura)

COR_SONDA       	EQU 0FF00H			; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)


COLUNA_INIT         EQU  32
LINHA_INIT          EQU  26
INC_SONDA           EQU  1

TECLA_MOVER_SONDA   EQU  5


	PLACE       1000H
pilha:
	STACK 100H			; espa�o reservado para a pilha 
						; (200H bytes, pois s�o 100H words)
SP_inicial:				; este � o endere�o (1200H) com que o SP deve ser 
						; inicializado. O 1.� end. de retorno ser� 
						; armazenado em 11FEH (1200H-2)

SONDA:                  ; (x, y, cor)
    WORD COLUNA_INIT, LINHA_INIT, COR_SONDA


    PLACE      0
init:
    MOV  SP, SP_inicial

    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
    MOV  R4, DISPLAYS
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV	R8, 0			; cenário de fundo número 0
    MOV  R9, 0
    MOV  R10, -1

    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV  [SELECIONA_CENARIO_FUNDO], R8	; seleciona o cenário de fundo

    ; draw sonda first time
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    MOV R0, SONDA
    MOV R1, [R0]
    MOV R2, [R0+2]
    MOV R3, COR_SONDA

    MOV [DEFINE_COLUNA], R1
    MOV [DEFINE_LINHA], R2
    MOV [DEFINE_PIXEL], R3

    POP R3
    POP R2
    POP R1
    POP R0 


loop:
    CALL keyboard_listner
    MOVB [R4], R10
    CALL update_sonda
    JMP loop

; copiar a partir daqui
update_sonda:
    PUSH R0             ; endereco base
    PUSH R1             ; linha
    PUSH R2             ; coluna
    PUSH R3             ; cor
    CMP R9, 1
    JNZ end_update_sonda
    CMP R10, TECLA_MOVER_SONDA
    JNZ end_update_sonda
    MOV R0, SONDA
    MOV R1, [R0]         ; x
    MOV R2, [R0+2]      ; y
    CMP R2, 0
    JZ move_sonda_home
    CALL delete_sonda
    SUB R2, 1          ; subir sonda
    CALL draw_sonda
    update_memory: 
        MOV [R0+2], R2
        MOV [R0], R1
    end_update_sonda:
        POP R3
        POP R2
        POP R1
        POP R0
        RET 

move_sonda_home:
    CALL delete_sonda
    MOV R2, LINHA_INIT
    CALL draw_sonda
    JMP update_memory

delete_sonda:
    MOV R3, 0           ; blank
    CALL write_pixel
    RET

draw_sonda:
    MOV R3, [R0+4]
    CALL write_pixel
    RET

write_pixel:
    MOV [DEFINE_COLUNA], R1
    MOV [DEFINE_LINHA], R2
    MOV [DEFINE_PIXEL], R3          ; Desenha a sonda na pos inicial 
    RET



; ignorar apenas para testing purposes
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