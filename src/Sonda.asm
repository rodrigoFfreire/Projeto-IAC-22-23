;**********
; Rotina para desenhar a sonda
; Registos Usados:
;**********

DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

COMANDOS			EQU	6000H			; endereço de base dos comandos do MediaCenter

SET_LINE    	EQU COMANDOS + 0AH		; endereço do comando para definir a linha
SET_COLUMN   	EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
SET_PIXEL    	EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     	EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 	EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo

N_LINHAS        	EQU  32				; número de linhas do ecrã (altura)
N_COLUNAS       	EQU  64				; número de colunas do ecrã (largura)

BLACK              EQU 0F000H
GRAY               EQU 0F888H
RED                EQU 0FF00H
DARKRED            EQU 0FE00H
GREEN              EQU 0F0F0H	
DARKGREEN          EQU 0F0A0H	
BROWN              EQU 0FA52H
BLUE               EQU 0F06FH
CYAN               EQU 0F0FFH
WHITE              EQU 0FFFFH
YELLOW             EQU 0FFF0H
DARKYELLOW         EQU 0FFA3H


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
LAST_PRESSED_KEY:
    WORD -1 ; Start with default value   

; Used together with LAST_KEY_PRESSED to determine when to execute a command
; 0 -> dont execute; 1 -> execute; -1 -> dont execute [key was not released]
EXECUTE_COMMAND:
    WORD 0

ENERGY:
    WORD 100

; Entities
PROBE:
    ;WORD 32, 26, 1, SPRITE_PROBE ; (pos_x, pos_y, visible, sprite)
    WORD 27, 27, 1, SPRITE_SPACESHIP; (x, y, estado, sprite_atual)

SPACESHIP:
    WORD 0, 0, 1, SPRITE_SPACESHIP ; (pos_x, pos_y, visible, sprite)

ASTEROID:
    WORD 0, 0, 1, SPRITE_ASTEROID ; (pos_x, pos_y, visible, sprite)

; Sprites
SPRITE_PROBE:
    WORD 1, 1 ; (x, y)
    WORD RED

SPRITE_SPACESHIP:
    ;WORD 1, 1 ; (x, y)
    ; criar a textura
    WORD 9, 5
	WORD		0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
	WORD		0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
    WORD    BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD    BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
	WORD		BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 

SPRITE_ASTEROID:
    WORD 1, 1 ; (x, y)
    ; criar a textura


    PLACE      0
init:
    MOV  SP, SP_inicial

    MOV  R4, DISPLAYS
    MOV	R8, 0			; cenário de fundo número 0

    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV  [SELECIONA_CENARIO_FUNDO], R8	; seleciona o cenário de fundo

    ; draw sonda first time
    MOV R2, PROBE
    CALL draw_entity


loop:
    CALL keyboard_listner
    MOV R10, [LAST_PRESSED_KEY]
    MOVB [R4], R10
    CALL update_sonda
    JMP loop

; copiar a partir daqui
update_sonda:
    PUSH R0             ; endereco base
    PUSH R1             ; linha
    PUSH R2             ; coluna
    PUSH R3             ; cor
    PUSH R4
    MOV R4, [EXECUTE_COMMAND]
    CMP R4, 1
    JNZ end_update_sonda
    MOV R4, [LAST_PRESSED_KEY]
    CMP R4, TECLA_MOVER_SONDA
    JNZ end_update_sonda

    MOV R0, PROBE
    MOV R1, [R0]         ; x
    MOV R2, [R0+2]      ; y
    CMP R2, 0
    JZ move_sonda_home
    CALL delete_sonda
    SUB R2, 1          ; subir sonda
    MOV [R0+2], R2
    CALL draw_sonda

    end_update_sonda:
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET 

move_sonda_home:
    PUSH R1
    CALL delete_sonda
    MOV R1, LINHA_INIT
    MOV [R0+2], R1
    CALL draw_sonda
    POP R1
    JMP end_update_sonda

delete_sonda:
    PUSH R1
    PUSH R2
    MOV R2, R0
    MOV R1, 0
    MOV [R2+4], R1
    CALL draw_entity
    POP R2
    POP R1
    RET

draw_sonda:
    PUSH R1
    PUSH R2
    MOV R2, R0
    MOV R1, 1
    MOV [R2+4], R1
    CALL draw_entity
    POP R1
    POP R2
    RET



; ignorar apenas para testing purposes
keyboard_listner:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV  R2, TEC_LIN
    MOV  R3, TEC_COL
    MOV  R4, 0FH

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
    MOV R1, 0
    MOV [EXECUTE_COMMAND], R1
    end_keyboard_listner:
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

test_line:
    MOVB [R2], R1
    MOVB R0, [R3]   
    AND R0, R4      ; Mask low bits
    CMP R0, 0
    RET

press:
    CALL convert
    SHL R1, 2
    ADD R1, R0      ; conversao final
    MOV R0, [EXECUTE_COMMAND]
    CMP R0, 0 
    JZ press_update
    MOV R1, -1
    MOV [EXECUTE_COMMAND], R1
    JMP end_keyboard_listner
    press_update:
        MOV [LAST_PRESSED_KEY], R1
        MOV R1, 1
        MOV [EXECUTE_COMMAND], R1
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


draw_entity:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R5
    PUSH R6
    PUSH R7
    MOV R0, R2 ; Entity base address
    MOV R1, [R2+6] ; Sprite base address
    MOV R2, [R1] ; l
    MOV R3, [R1+2] ; h

    MOV R5, -1 ; offset y
    draw_from_table:
        ADD R5, 1
        CMP R5, R3 ; Reached last pixel already?
        JZ end_draw_entity
        MOV R6, 0 ; offset x
        inner_loop:
            CALL check_pixel_address
            JZ skip_draw
            CALL draw_pixel
            
            skip_draw:
                ADD R6, 1
                CMP R6, R2 ; Reached last pixel of line?
            JZ draw_from_table
            JMP inner_loop

    end_draw_entity:
        POP R7
        POP R6
        POP R5
        POP R3
        POP R2
        POP R1
        POP R0
        RET

draw_pixel:
    PUSH R2
    PUSH R3

    MOV R2, [R0] ; pos x
    MOV R3, [R0+2] ; pos y
    ADD R2, R6
    ADD R3, R5
    
    MOV [SET_COLUMN], R2
    MOV [SET_LINE], R3
    MOV R2, [R7] ; get color from adress
    
    MOV R3, [R0+4] ; Get visibility flag
    CMP R3, 1
    JZ set_pixel
    MOV R2, 0

    set_pixel:
	    MOV  [SET_PIXEL], R2

    POP R3
    POP R2
    RET 

check_pixel_address:
    PUSH R0
    PUSH R5
    PUSH R6

    MOV R7, [R1]
    MUL R5, R7
    ADD R5, R6
    SHL R5, 1
    ADD R5, 4
    ADD R5, R1 ; get final memory address of correct pixel
    
    MOV R7, R5
    MOV R0, [R7]
    CMP R0, 0 ; check if pixel is empty

    POP R6
    POP R5
    POP R0
    RET