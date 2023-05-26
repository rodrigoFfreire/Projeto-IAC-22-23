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

; colors
BLACK              EQU 0F000H
GREY               EQU 0F888H
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
; **Adicionar mais cores aqui se for preciso**

; Audio/Video
PLAY_AUDIO         EQU MEDIA_COMMAND + 5AH
PLAY_VIDEO_LOOP    EQU MEDIA_COMMAND + 5CH


; Keys
KEY_INCREMENT      EQU 6                       ; Increment Energy Display 
KEY_DECREMENT      EQU 4                       ; Decrement Energy Display
KEY_MOVE_PROBE     EQU 1                       ; Move probe up
KEY_MOVE_ASTEROID  EQU 5                       ; Move asteroid in diagonal

; other constants
PROBE_START_Y      EQU 26                      ; initial pos_y of probe
ASTEROID_START_X   EQU 0
ASTEROID_START_Y   EQU 0


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
    WORD 1

    ;asteroid 1
    WORD 0, 0, 1, ENEMY_SPRITES ; (x, y, state, sprite)

SPACESHIP:
    WORD 27, 27, 1, SPRITE_SPACESHIP; (x, y, visibility, sprite)

PROBE:
    WORD 32, 26, 1, SPRITE_PROBE; (x, y, visibility, sprite)

;SPRITES
SPRITE_SPACESHIP:
    WORD  11; length
    WORD  5; height
	WORD  0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
	WORD  0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
	WORD  BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 
    WORD  BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD  BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN

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

PROBE_UPDATE_FLAG:
    WORD 0

ASTEROID_UPDATE_FLAG:
    WORD 0


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
    MOV [CURRENT_ENERGY], R0
    MOV [ENERGY_DISPLAYS], R0

    ; Draw entities first time
    MOV R2, PROBE
    CALL draw_entity
    MOV R2, SPACESHIP
    CALL draw_entity
    MOV R2, ASTEROIDS
    ADD R2, 2
    CALL draw_entity


game_loop:
    CALL keyboard_listner ; Listen for input
    CALL event_handler    ; carry out keyboard commands
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
    MOV R2, KEYBOARD_LINE
    MOV R3, KEYBOARD_COLUMN
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


; ***************************************************************************
; * EVENT_HANDLER
; ***************************************************************************
event_handler:
    PUSH R0
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV R0, [EXECUTE_COMMAND]
    CMP R0, 1
    JNZ end_event_handler

    MOV R0, [LAST_PRESSED_KEY]
    CMP R0, KEY_MOVE_PROBE
    JZ move_probe

    CMP R0, KEY_MOVE_ASTEROID
    JZ move_asteroid

    CMP R0, KEY_DECREMENT
    JZ decrement_energy

    CMP R0, KEY_INCREMENT
    JZ increment_energy

    end_event_handler:
        POP R5
        POP R4
        POP R3
        POP R2
        POP R0
        RET


move_probe:
    MOV R2, PROBE
    MOV R4, [R2+2] ; current y

    MOV R5, PROBE_START_Y
    CMP R4, R5              ; check if probe needs to be moved home
    JNZ end_move_probe
    
    ADD R5, 1     ; account for last SUB
    MOV R4, R5    ; move probe home
    end_move_probe:
        SUB R4, 1 ; move y 1 up
        CALL update_object
        JMP end_event_handler

move_asteroid:
    MOV R2, ASTEROIDS
    ADD R2, 2  ; get address of first asteroid
    
    MOV R3, [R2]   ; current x
    MOV R4, [R2+2] ; current y
    MOV R4, ASTEROID_START_Y      ; check if asteroid needs to be moved home
    JNZ end_move_asteroid

    MOV R3, ASTEROID_START_X
    MOV R4, ASTEROID_START_Y     ; move asteroid home
    SUB R3, 1
    SUB R4, 1                   ; account for last ADDs
    end_move_asteroid:
        ADD R3, 1
        ADD R4, 1
        CALL update_object
        JMP end_event_handler

decrement_energy:
    MOV R0, [CURRENT_ENERGY]
    SUB R0, 1
    MOV [CURRENT_ENERGY], R0

    MOV R0, [CURRENT_ENERGY]
    MOV [ENERGY_DISPLAYS], R0
    JMP end_event_handler

increment_energy:
    MOV R0, [CURRENT_ENERGY]
    ADD R0, 1
    MOV [CURRENT_ENERGY], R0

    MOV R0, [CURRENT_ENERGY]
    MOV [ENERGY_DISPLAYS], R0
    JMP end_event_handler


; ***************************************************************************
; * UPDATE_OBJECT
; ***************************************************************************
update_object:
	PUSH R1
	PUSH R2
	PUSH R3 ; X NOVO
    PUSH R4 ; Y NOVO
	PUSH R5
	
	MOV R5, [R2+4] ; GET ENTITY STATE
	CMP R5, 0
	JZ return_update_object ; IF OBJECT IS INVISIBLE IGNORE
	
    MOV R1, 0
    MOV [R2+4], R1    ; IF OBJECT IS VISIBLE, TURN IT'S FLAG TO 0 TO BECOME INVISIBLE
    CALL draw_entity  ; DRAW OBJECT INVISIBLE (DELETE PREVIOUS OBJECT)

	MOV [R2], R3  ; UPDATE MEMORY OF OBJECT WITH NEW X POSITION
	MOV [R2+2], R4  ; UPDATE MEMORY OF OBJECT WITH NEW Y POSITION

    MOV R1, 1
    MOV [R2+4], R1   ; AFTER UPDATING POSITION TURN OF VISIBILITY FLAG TO 1 SO IT BECOMES VISIBLE
    CALL draw_entity ; DRAW OBJECT IN NEW COORDINATES 

	return_update_object:
    PUSH R5
    PUSH R4
    PUSH R3
    PUSH R2
    PUSH R1


; ***************************************************************************
; * DRAW ENTITY
; ***************************************************************************
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