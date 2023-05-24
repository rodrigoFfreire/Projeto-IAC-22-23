;**********
; sprites
;**********


; *********************************************************************************
; * Constantes
; *********************************************************************************

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

		

;ENTITIES:
AGENTS:
  ;number of agents
  WORD 1

  ;agent 1
  WORD 0, 0, -1, ENEMY_SPRITES ; (x, y, state, sprites)

  ;agent 2
  WORD 0, 0, -1, ENEMY_SPRITES ; (x, y, state, sprites)

  ;agent 3
  WORD 0, 0, -1, ENEMY_SPRITES ; (x, y, state, sprites)

  ;agent 4
  WORD 0, 0, -1, FRIEND_SPRITES ; (x, y, state, sprites)

SPACESHIP:
  WORD 27, 27, -1, SPRITE_SPACESHIP; (x, y, estado, sprite_atual)

SONDA:
  WORD 26, 31, -1, SPRITE_SONDA; (x, y, state, sprites)


;SPRITES

SPRITE_SPACESHIP:
    ;sprite #0 (default)
	WORD		9; length
  WORD    5; height
	WORD		0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
	WORD		0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
  WORD    BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
  WORD    BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
	WORD		BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 

SPRITE_SONDA:
  WORD  1; length
  WORD  1; height
  WORD  RED

ENEMY_SPRITES:
  ;sprite #0
  WORD  5; length
  WORD  5; height  
  WORD  0, BLACK, BLACK, BLACK, 0
  WORD  BLACK, GREY, GREY, GREY, BLACK
  WORD  BLACK, GREY, 0, GREY, BLACK
  WORD  BLACK, GREY, GREY, GREY, BLACK
  WORD  0, BLACK, BLACK, BLACK, 0

FRIEND_SPRITES:
  ;sprite #0
  WORD  5; length
  WORD  5; height
  WORD  GREEN, GREEN,


