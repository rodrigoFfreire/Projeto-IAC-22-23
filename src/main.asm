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
ASTEROIDS:
    ;number of asteroids
    WORD 1

    ;asteroid 1
    WORD 0, 0, 1, ENEMY_SPRITES ; (x, y, state, sprite)

SPACESHIP:
    WORD 27, 27, 1, SPRITE_SPACESHIP; (x, y, visibility, sprite)

PROBE:
    WORD 26, 31, 1, SPRITE_PROBE; (x, y, visibility, sprite)

;SPRITES
SPRITE_SPACESHIP:
    WORD 9; length
    WORD 5; height
    WORD 0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
    WORD 0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
    WORD BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 
    WORD BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 

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




; ***************************************************************************
; * KEYBOARD LISTNER
; ***************************************************************************
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