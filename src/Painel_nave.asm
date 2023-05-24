;**********
; Rotina para desenhar o painel de instrumentos da nave
; Registos Usados:
;**********


; *********************************************************************************
; * Constantes
; *********************************************************************************


COMANDOS				EQU	6000H			    ; endereço de base dos comandos do MediaCenter

SET_X             		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
SET_Y              		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
SET_PIXEL       		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
DELETE_WARNING     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
CLEAR_SCREEN 		    EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SET_BACKGROUND          EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
SET_LAYER               EQU COMANDOS + 04H      ; endereço do comando para selecionar uma layer


MIN_SCREEN_WIDTH        EQU 0
MAX_SCREEN_WIDTH        EQU 64

MIN_SCREEN_HEIGHT       EQU 0
MAX_SCREEN_HEIGHT        EQU 32

LINHA        		EQU  27        	; linha do nave (a meio do ecrã)
COLUNA			    EQU  28      	; coluna do nave (a meio do ecrã)

LARGURA			    EQU	 8   		; largura da nave
ALTURA              EQU  5          ; altura da nave

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

; #######################################################################
; * ZONA DE DADOS 
; #######################################################################
PLACE		1000H	

pilha:
	STACK 100H			; espa�o reservado para a pilha 
						; (200H bytes, pois s�o 100H words)
SP_inicial:				; este � o endere�o (1200H) com que o SP deve ser 
						; inicializado. O 1.� end. de retorno ser� 
						; armazenado em 11FEH (1200H-2)
		

;ENTITIES:

SPACESHIP:
    WORD LINHA, COLUNA, -1, SPRITE_SPACESHIP; (x, y, estado, sprite_atual)


;SPRITES

SPRITE_SPACESHIP:
    ;sprite #0 (default)
	WORD		LARGURA
    WORD        ALTURA
	WORD		0, 0, BROWN, BROWN, BROWN, BROWN, 0, 0
	WORD		0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
    WORD        BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD        BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
	WORD		BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 

PLACE 0 

MOV SP, SP_INICIAL
MOV [DELETE_WARNING], R1
MOV [CLEAR_SCREEN], R1
MOV R1, 0 ; Set background to static.jpg
MOV [SET_BACKGROUND], R1

MOV R2, SPACESHIP
CALL draw_entity

draw_entity:
  PUSH R1
  PUSH R2
  PUSH R3
  PUSH R4
  PUSH R5
  PUSH R6 ;iterator

  MOV R6, R4 ;starting iterator value
  
  draw_line:
    ; loop to render line of pixels
    CALL draw_pixel
    ADD R3, 2 ;get pixel index to render
    ADD R1, 1 ;move to next horizontal render position
    SUB R6, 1 ;decrement index of column iterator
    JNZ draw_line

    ;otherwise
    MOV R6, R4 ;reset index of column iterator
    SUB R1, R4 ;go back to the first column position
    ADD R2, 1 ;move to next "y" render position
    SUB R5, 1 ;decrement height of sprite
    JNZ draw_line

  ;reset layer
  MOV R1, 0
  MOV [SET_LAYER], R1

  POP R6
  POP R5
  POP R4
  POP R3
  POP R2
  POP R1
  RET


draw_pixel:
  PUSH R4
    
  ;if action is set to 0 then delete pixel
  CMP R8, 0
  JZ delete_pixel

  ;otherwise
  MOV R4, [R3] ;get pixel color from index R3
  JMP set_pixel

  delete_pixel:
    MOV R4, 0 ;set pixel color to 0

  set_pixel:
    MOV [SET_X], R1 ;set line
    MOV [SET_Y], R2 ;set line
    MOV [SET_PIXEL], R4 ;change pixel color
    
  POP R4
  RET

fim: 
    JMP fim