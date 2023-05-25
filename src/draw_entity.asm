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


PLACE 1000H

pilha:
    STACK 100H ; (100H * 2 Bytes Allocated to Stack)

SP_INICIAL:

; Control variables
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
    WORD 32, 26, 1, SPRITE_PROBE ; (pos_x, pos_y, visible, sprite)

SPACESHIP:
    WORD (), (), 1, SPRITE_SPACESHIP ; (pos_x, pos_y, visible, sprite)

ASTEROID:
    WORD 0, 0, 1, SPRITE_ASTEROID ; (pos_x, pos_y, visible, sprite)

; Sprites
SPRITE_PROBE:
    WORD 1, 1 ; (x, y)
    WORD RED

SPRITE_SPACESHIP:
    WORD (), () ; (x, y)
    ; criar a textura

SPRITE_ASTEROID:
    WORD (), () ; (x, y)
    ; criar a textura


init:
    MOV  SP, SP_inicial

    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV	R8, 0			; cenário de fundo número 0
    MOV  [EXECUTE_COMMAND], 0
    MOV  [LAST_PRESSED_KEY], -1

    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV  [SELECIONA_CENARIO_FUNDO], R8	; seleciona o cenário de fundo




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
            CALL get_pixel_address
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
    MOV [SET_PIXEL], R7

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
    ADD R7, R5 ; get final memory address of correct pixel

    MOV R0, [R7]
    CMP R0, 0 ; check if pixel is empty

    POP R6
    POP R5
    POP R0
    RET