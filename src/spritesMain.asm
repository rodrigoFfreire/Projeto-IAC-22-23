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
MASK               EQU 0FH                      ; Get low nibble only

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

SCREEN_WIDTH       EQU 63                        ; Max screen width
SCREEN_HEIGHT      EQU 31                        ; Max screen height
SCREEN_ORIGIN      EQU 0                         ; Screen origin

; colors
BLACK              EQU 0F000H
LIGHTGREY          EQU 0F888H
GREY               EQU 04888H
SALMON             EQU 08F10H
MAGENTA            EQU 0D933H
DARKRED            EQU 0F900H
NEONRED            EQU 0FF00H
NEONGREEN          EQU 0F0F0H	
DARKGREEN          EQU 0F070H	
DARKBLUE           EQU 0F04FH
LIGHTBLUE          EQU 0607FH
BLUE               EQU 0903FH
CYAN               EQU 0F1FFH
NEONPINK           EQU 0FF0FH
ORANGE             EQU 0FD60H 
WHITE              EQU 0FFFFH
NEONYELLOW         EQU 0FFF0H
YELLOW             EQU 0FEE0H

; Audio/Video
PLAY_AUDIO         EQU MEDIA_COMMAND + 5AH
PLAY_VIDEO_LOOP    EQU MEDIA_COMMAND + 5CH


; Keys
KEY_INCREMENT      EQU 6                       ; Increment Energy Display 
KEY_DECREMENT      EQU 4                       ; Decrement Energy Display
KEY_MOVE_PROBE     EQU 1                       ; Move probe up
KEY_MOVE_ASTEROID  EQU 5                       ; Move asteroid in diagonal

; other constants
PROBE_START_Y      EQU 26                      ; initial y of probe
ASTEROID_START_X   EQU 0                       ; initial x of asteroid
ASTEROID_START_Y   EQU 0                       ; initial y of asteroid


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

CURRENT_ENERGY:
    WORD 100

; Entities
ASTEROIDS:
    ;number of asteroids
    WORD 4

    ;enemy 1
    WORD 0, 0, 1, ENEMY_SPRITES, 0, 0 ; (x, y, state, sprite, nothing just padding, direction)

    ;enemy 2
    WORD 0, 0, 1, ENEMY_SPRITES, 0, 0 ; (x, y, state, sprite, nothing just padding, direction)

    ;enemy 3
    WORD 0, 0, 1, ENEMY_SPRITES, 0, 0 ; (x, y, state, sprite, nothing just padding, direction)

    ;enemy 4
    WORD 0, 0, 1, ENEMY_SPRITES, 0, 0 ; (x, y, state, sprite, nothing just padding, direction)


SPACESHIP:
    WORD 23, 21, 0, SPRITE_SPACESHIP; (x, y, state, sprite)

PROBE:
    ; number of probes
    WORD 3
    ; state is current sub-sprite (0 means invisible), steps is number of movements
    WORD 26, 26, 0, SPRITE_PROBE, 0, -1, 26, 26; (x, y, state, sprite, steps, direction (LEFT) )

    WORD 32, 20, 0, SPRITE_PROBE, 0, 0, 32, 20; (x, y, state, sprite, steps, direction (UP) )

    WORD 38, 25, 0, SPRITE_PROBE, 0, 1, 38, 26; (x, y, state, sprite, steps, direction (RIGHT) )

SPACESHIP_PANEL:
    WORD 31, 27, 0, SPRITE_PANEL; (x, y, state, sprite)

;SPRITES
SPRITE_SPACESHIP:
    WORD 19 ; length
    WORD 11 ; height

	WORD 0, 0, 0, 0, 0, 0, 0, 0, 0, LIGHTGREY, 0, 0, 0, 0, 0, 0, 0, 0, 0
	WORD 0, 0, 0, 0, 0, 0, 0, 0, LIGHTGREY, LIGHTGREY, LIGHTGREY, 0, 0, 0, 0, 0, 0, 0, 0
	WORD 0, 0, 0, 0, 0, 0, 0, 0, LIGHTGREY, GREY, LIGHTGREY, 0, 0, 0, 0, 0, 0, 0, 0
	WORD 0, 0, 0, 0, 0, 0, ORANGE, LIGHTGREY, GREY, BLACK, GREY, LIGHTGREY, ORANGE, 0, 0, 0, 0, 0, 0
	WORD 0, 0, 0, 0, ORANGE, ORANGE, LIGHTGREY, GREY, BLACK, BLACK, BLACK, GREY, LIGHTGREY, ORANGE, ORANGE, 0, 0, 0, 0
    WORD 0, 0, 0, 0, ORANGE, ORANGE, LIGHTGREY, GREY, GREY, GREY, GREY, GREY, LIGHTGREY, ORANGE, ORANGE, 0, 0, 0, 0
	WORD GREY, GREY, ORANGE, ORANGE, ORANGE, LIGHTGREY, GREY, GREY, 0, 0, 0, GREY, GREY, LIGHTGREY, ORANGE, ORANGE, ORANGE, GREY, GREY
    WORD 0, GREY, ORANGE, ORANGE, ORANGE, LIGHTGREY, GREY, GREY, 0, 0, 0, GREY, GREY, LIGHTGREY, ORANGE, ORANGE, ORANGE, GREY, 0
    WORD 0, 0, GREY, ORANGE, ORANGE, LIGHTGREY, LIGHTGREY, GREY, 0, 0, 0, GREY, LIGHTGREY, LIGHTGREY, ORANGE, ORANGE, GREY, 0, 0
    WORD 0, 0, 0, GREY, 0, 0, LIGHTGREY, GREY, GREY, GREY, GREY, GREY, LIGHTGREY, 0, 0, GREY, 0, 0, 0
	WORD 0, 0, 0, 0, 0, 0, 0, LIGHTGREY, LIGHTGREY, LIGHTGREY, LIGHTGREY, LIGHTGREY, 0, 0, 0, 0, 0, 0, 0
    

SPRITE_PROBE:
    WORD 1 ; length
    WORD 1 ; height
    WORD NEONPINK ; color

ENEMY_SPRITES:
    ;sprite #0
    WORD 5 ; length
    WORD 7 ; height 
    WORD SALMON, 0, 0, 0, SALMON
    WORD 0, SALMON, 0, SALMON, 0
    WORD SALMON, SALMON, SALMON, SALMON, SALMON
    WORD SALMON, 0, SALMON, 0, SALMON
    WORD DARKRED, 0, DARKRED, 0, DARKRED
    WORD DARKRED, DARKRED, DARKRED, DARKRED, DARKRED
    WORD 0, DARKRED, 0, DARKRED, 0

    ;sprite #1
    WORD 5 ; length
    WORD 7 ; height 
    WORD SALMON, 0, 0, 0, SALMON
    WORD 0, SALMON, SALMON, SALMON, 0
    WORD SALMON, 0, SALMON, 0, SALMON
    WORD SALMON,SALMON, SALMON, SALMON, SALMON
    WORD 0, DARKRED, DARKRED, DARKRED, 0
    WORD DARKRED, DARKRED, 0, DARKRED, DARKRED
    WORD DARKRED, 0, 0, 0, DARKRED

    ;sprite #2
    WORD 5 ; length
    WORD 7 ; height 
    WORD SALMON, 0, 0, 0, SALMON
    WORD 0, SALMON, SALMON, SALMON, 0
    WORD SALMON, SALMON, SALMON, SALMON, SALMON
    WORD SALMON, 0, SALMON, 0, SALMON
    WORD DARKRED, DARKRED, 0, DARKRED, DARKRED
    WORD 0, DARKRED, DARKRED, DARKRED, 0
    WORD DARKRED, 0, 0, 0, DARKRED

    ;desctruction sprite
    WORD 5 ; length
    WORD 7 ; height 
    WORD 0, LIGHTBLUE, 0, 0, 0,
    WORD LIGHTBLUE, BLUE, DARKBLUE, 0, 0
    WORD 0, DARKBLUE, 0, 0, 0
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, 0, LIGHTBLUE, 0
    WORD 0, 0, LIGHTBLUE, BLUE, DARKBLUE
    WORD 0, 0, 0, DARKBLUE, 0

FRIEND_SPRITES:
    ;initial sprite
    WORD 5 ; length
    WORD 5 ; height
    WORD 0, DARKGREEN, DARKGREEN, DARKGREEN, 0
    WORD DARKGREEN, NEONGREEN, NEONGREEN, NEONGREEN, DARKGREEN
    WORD DARKGREEN, NEONGREEN, NEONGREEN, NEONGREEN, DARKGREEN
    WORD DARKGREEN, NEONGREEN, NEONGREEN, NEONGREEN, DARKGREEN
    WORD 0, DARKGREEN, DARKGREEN, DARKGREEN, 0    

    ;first sprite after destruction
    WORD 5 ; length
    WORD 5 ; height 
    WORD 0, 0, 0, 0, 0
    WORD 0, DARKGREEN, DARKGREEN, 0, 0
    WORD DARKGREEN, NEONGREEN, NEONGREEN, DARKGREEN, 0
    WORD DARKGREEN, NEONGREEN, NEONGREEN, DARKGREEN, 0
    WORD 0, DARKGREEN, DARKGREEN, 0, 0

    ;second sprite after destruction
    WORD 5 ; length
    WORD 5 ; height 
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, DARKGREEN, 0, 0
    WORD 0, DARKGREEN, NEONGREEN, DARKGREEN, 0
    WORD 0, 0, DARKGREEN, 0, 0
    WORD 0, 0, 0, 0, 0

    ;final sprite after destruction
    WORD 5 ; length
    WORD 5 ; height 
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, NEONGREEN, 0, 0
    WORD 0, 0, 0, 0, 0
    WORD 0, 0, 0, 0, 0
  
SPRITE_PANEL:
    ;sprite #0
    WORD 3 ; length
    WORD 3 ; height
    WORD NEONYELLOW, NEONRED, CYAN 
    WORD NEONPINK, CYAN, NEONYELLOW 
    WORD NEONRED, NEONYELLOW, NEONPINK 

    ;sprite #1
    WORD 3 ; length
    WORD 3 ; height
    WORD NEONPINK, CYAN, NEONYELLOW
    WORD NEONYELLOW, NEONPINK, NEONRED
    WORD NEONRED, CYAN, NEONPINK

    ;sprite #2
    WORD 3 ; length
    WORD 3 ; height
    WORD NEONYELLOW, NEONRED, CYAN 
    WORD NEONRED, NEONYELLOW, NEONPINK 
    WORD NEONPINK, CYAN, NEONYELLOW 

    ;sprite #3
    WORD 3 ; length
    WORD 3 ; height
    WORD NEONPINK, CYAN, NEONYELLOW 
    WORD NEONYELLOW, NEONRED, CYAN 
    WORD NEONRED, NEONYELLOW, NEONPINK

    ;sprite #4
    WORD 3 ; length
    WORD 3 ; height
    WORD NEONRED, NEONYELLOW, NEONPINK 
    WORD NEONYELLOW, NEONRED, CYAN 
    WORD NEONPINK, CYAN, NEONYELLOW 

    ;sprite #5
    WORD 3 ; length
    WORD 3 ; height
    WORD NEONPINK, CYAN, NEONYELLOW 
    WORD NEONRED, NEONYELLOW, NEONPINK
    WORD NEONYELLOW, NEONRED, CYAN 

PROBE_UPDATE_FLAG:
    WORD 0

ASTEROID_UPDATE_FLAG:
    WORD 0


; ***************************************************************************
; * CODE
; ***************************************************************************
PLACE 0

initialize:
    MOV SP, SP_INICIAL       ; Initialize Stack Pointer
    MOV [DELETE_WARNING], R1 ; Clear warnings
    MOV [CLEAR_SCREEN], R1   ; Clear Screen

    ; Set background to static.jpg (index 0)
    MOV R1, 0
    MOV [SET_BACKGROUND], R1

    ; Set energy to 100 and update display
    MOV R0, 100
    MOV [CURRENT_ENERGY], R0
    MOV [ENERGY_DISPLAYS], R0

    ; Draw Probe, Spaceship, Asteroid for the first time
    MOV R2, PROBE
    CALL draw_entity
    MOV R2, SPACESHIP
    CALL draw_entity
    MOV R2, ASTEROIDS
    ADD R2, 2 ; Offset memory address to base address for first asteroid
    CALL draw_entity


game_loop:
    CALL keyboard_listner ; Listen for input
    CALL event_handler    ; carry out keyboard commands
    JMP game_loop


update_panel:
    PUSH R0
    PUSH R2

    MOV R0, [NAVPANEL_UPDATE_FLAG] 
    CMP R0, 1
    JNZ end_panel

    MOV R2, SPACESHIP_PANEL
    MOV R0, [R2 + 4]
    CMP R0, 5
    JLT index_increment
    MOV R0, -1

    index_increment:
        ADD R0, 1
    
    MOV [R2 + 4], R0

    MOV R0, LAYER_NAVPANEL
    MOV [SET_LAYER], R0
    CALL draw_entity

    end_update_panel:
        POP R2 
        POP R0
        RET 