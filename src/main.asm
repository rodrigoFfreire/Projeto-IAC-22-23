; ***************************************************************************
; * GRUPO 01
; 
; * Rodrigo Freire - 106485
; * Goncalo Aleixo - 106900
; * David Rodrigues - 106763
; ***************************************************************************


; ***************************************************************************
; * CONSTANTS
; ***************************************************************************

; Keyboard
KEYBOARD_LINE      EQU 0C000H                   ; (POUT-2)
KEYBOARD_COLUMN    EQU 0E000H                   ; (PIN)
BIT_MASK           EQU 0FH                      ; Get low nibble only

; Energy
ENERGY_DISPLAYS    EQU 0A000H                   ; (POUT-1)

; Screen
MEDIA_COMMAND	   EQU 6000H                    ; Media center commands

SET_LINE           EQU MEDIA_COMMAND + 0AH
SET_COLUMN         EQU MEDIA_COMMAND + 0CH
SET_PIXEL   	   EQU MEDIA_COMMAND + 12H
SET_BACKGROUND     EQU MEDIA_COMMAND + 42H
CLEAR_SCREEN	   EQU MEDIA_COMMAND + 02H
DELETE_WARNING     EQU MEDIA_COMMAND + 40H

SCREEN_WIDTH       EQU 64
SCREEN_HEIGHT      EQU 32
SCREEN_ORIGIN      EQU 0

BLACK              EQU 0F000H
GRAY               EQU 0F888H
RED                EQU 0FF00H
DARKRED            EQU 0FE00H
GREEN              EQU 0F0F0H	
DARKGREEN          EQU 0F0A0H	
BROWN              EQU 0FA52H
BLUE               EQU 0F06FH
WHITE              EQU 0FFFFH
YELLOW             EQU 0FFF0H
DARKYELLOW         EQU 0FFA3H
; **Adicionar mais cores aqui se for preciso**

; Audio/Video
PLAY_AUDIO         EQU MEDIA_COMMAND + 5AH
PLAY_VIDEO_LOOP    EQU MEDIA_COMMAND + 5CH


; Keys
KEY_INCREMENT      EQU 6                       ; Increment Energy Display 
KEY_DECREMENT      EQU 4                       ; Decrement Energy Display
KEY_MOVE_PROBE     EQU 1                       ; Move probe up
KEY_MOVE_ASTEROID  EQU 5                       ; Move asteroid in diagonal


; ***************************************************************************
; * DATA
; ***************************************************************************

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

PROBE:
    WORD 26, 31, -1, SPRITE_PROBE; (x, y, state, sprites)

;SPRITES
SPRITE_SPACESHIP:
    ;sprite #0 (default)
    WORD	9; length
    WORD    5; height
    WORD	0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
    WORD	0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
    WORD    BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 
    WORD    BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD    BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 

SPRITE_PROBE:
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
    WORD  GREEN, GREEN, 0, GREEN, GREEN
    WORD  GREEN, 0, DARKGREEN, 0, GREEN
    WORD  0, DARKGREEN, 0, DARKGREEN, 0
    WORD  GREEN, 0, DARKGREEN, 0, GREEN
    WORD  GREEN, GREEN, 0, GREEN, GREEN
 


; ***************************************************************************
; * CODE
; ***************************************************************************

PLACE 0

initialize:
    MOV SP, SP_INICIAL
    MOV [DELETE_WARNING], R1
    MOV [CLEAR_SCREEN], R1

    MOV R1, 0 ; Set background to static.jpg
    MOV [SET_BACKGROUND], R1

    ; Set energy to 100 and update display
    MOV R0, 100
    MOV [ENERGY], R0
    MOV [ENERGY_DISPLAYS], R0

    ; Draw entities first time
    MOV R2, PROBE
    CALL draw_entity
    MOV R2, SPACESHIP
    CALL draw_entity
    MOV R2, ASTEROID
    CALL draw_entity


game_loop:
    CALL keyboard_listner ; Listen for input
    CALL command_handler ; Carry out correct command
    CALL event_handler ; Update required events

    JMP game_loop


; Passar o argumento com R2
draw_entity:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7 ; iterador para o for loop
    MOV R0, [R2] ; Entity base address
    MOV R1, [R0+6] ; Sprite base address
    MOV R2, [R0] ; pos_x
    MOV R3, [R0+2] ; pos_y
    MOV R4, [R0+4] ; Visible
    MOV R5, [R1] ; sprite length
    MOV R6, [R1+2] ; sprite height

    ; fazer especie de double for-loop que percorre a tabela de pixeis decrementando R5 e R6
    ; com se R4 = 1 -> desenhar o pixel com a cor da tabela 
    ;     se R4 = 0 -> apagar o pixel 
    ; criar funcao draw_pixel? onde pega no R4 e decide

    end_draw_entity:
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET


draw_pixel: