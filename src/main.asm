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
; Different because the same address is used in different situations
PIN_IN             EQU 0E000H                   ; (PIN)

; Energy
ENERGY_DISPLAYS    EQU 0A000H                   ; (POUT-1)

; Screen Commands
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

; Layers
LAYER_NAVPANEL     EQU 0
LAYER_SPACESHIP    EQU 1
LAYER_PROBES       EQU 2
LAYER_ASTEROIDS    EQU 3

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

; Audio/Video
PLAY_AUDIO         EQU MEDIA_COMMAND + 5AH
PLAY_VIDEO_LOOP    EQU MEDIA_COMMAND + 5CH


; Keys
KEY_START_GAME     EQU 0CH
KEY_PAUSE_GAME     EQU 0DH
KEY_STOP_GAME      EQU 0EH
KEY_SHOOT_UP       EQU 1
KEY_SHOOT_LEFT     EQU 4
KEY_SHOOT_RIGHT    EQU 6

; other constants
PROBE_DIR_LEFT     EQU -1                      ; Direction LEFT
PROBE_DIR_UP       EQU 0                       ; Direction UP
PROBE_DIR_RIGHT    EQU 1                       ; Direction RIGHT
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
    WORD 8

    ;asteroid 1
    WORD 0, 0, 1, ENEMY_SPRITES, 0, 0 ; (x, y, state, sprite, nothing just padding, direction)

    ;...

PROBES:
    ; number of probes
    WORD 3
    ; state is current sub-sprite (0 means invisible), steps is number of movements
    WORD X, Y, 0, SPRITE_PROBE, 0, -1, homeX, homeY; (x, y, state, sprite, steps, direction (LEFT) )

    WORD X, Y, 0, SPRITE_PROBE, 0, 0, homeX, homeY; (x, y, state, sprite, steps, direction (UP) )

    WORD X, Y, 0, SPRITE_PROBE, 0, 1, homeX, homeY; (x, y, state, sprite, steps, direction (RIGHT) )

SPACESHIP:
    WORD 27, 27, 1, SPRITE_SPACESHIP; (x, y, state, sprite)


;SPRITES
SPRITE_SPACESHIP:
    WORD 11 ; length
    WORD 5  ; height
	WORD 0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
	WORD 0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
	WORD BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 
    WORD BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN

SPRITE_PROBE:
    WORD 1 ; length
    WORD 1 ; height
    WORD RED

ENEMY_SPRITES:
    WORD 5 ; length
    WORD 5 ; height  
    WORD 0, BLACK, BLACK, BLACK, 0
    WORD BLACK, GREY, GREY, GREY, BLACK
    WORD BLACK, GREY, 0, GREY, BLACK
    WORD BLACK, GREY, GREY, GREY, BLACK
    WORD 0, BLACK, BLACK, BLACK, 0

FRIEND_SPRITES:
    WORD 5 ; length
    WORD 5 ; height
    WORD GREEN, GREEN, 0, GREEN, GREEN
    WORD GREEN, 0, DARKGREEN, 0, GREEN
    WORD 0, DARKGREEN, 0, DARKGREEN, 0
    WORD GREEN, 0, DARKGREEN, 0, GREEN
    WORD GREEN, GREEN, 0, GREEN, GREEN

; Exceptions Table
EXCEPTIONS:
    WORD asteroids_exception
    WORD probes_exception
    WORD energy_exception
    WORD navpanel_exception

; Exception Flags
ASTEROIDS_UPDATE_FLAG:
    WORD 0

PROBES_UPDATE_FLAG:
    WORD 0

ENERGY_UPDATE_FLAG:
    WORD 0

NAVPANEL_UPDATE_FLAG:
    WORD 0

; Other Flags
GAME_OVER_FLAG:
    WORD 0


; ***************************************************************************
; * CODE
; ***************************************************************************
PLACE 0

initialize:
    MOV SP, SP_INICIAL       ; Initialize Stack Pointer
    MOV BTE, EXCEPTIONS      ; Initialize Exception Table
    MOV [DELETE_WARNING], R1 ; Clear warnings
    MOV [CLEAR_SCREEN], R1   ; Clear Screen

    ; Set background to main_menu.png (index 0)
    MOV R1, 0
    MOV [SET_BACKGROUND], R1

    ; Set energy to 100
    MOV R0, 100
    MOV [CURRENT_ENERGY], R0

    EI0
    EI1
    EI2
    EI3
    EI


start:
    ;CALL main_menu - WIP


    game_loop:
        CALL keyboard_listner ; Listen for input

        CALL update_energy
        CALL update_probes
        ;CALL update_asteroids

        CALL event_handler    ; carry out keyboard commands

        ; CALL check_game_over
        JMP game_loop


    ;main_menu:



; ***************************************************************************
; * KEYBOARD LISTNER
; * _________________________________________________________________________
; * R0 - Current column, execute command flag
; * R1 - Current line, Converted key, execute command flag 
; * R4 - Number of max lines (each bit is a line so 4 lines = 4bits -> 8)
; ***************************************************************************
keyboard_listner:
    PUSH R0
    PUSH R1
    PUSH R4

    MOV R4, 8 ; max lines (1000b)

    MOV R1, 8000H ; Start at here so after bit roll its begins at 1 (0001b)
    line_check_loop:
        ROL R1, 1      ; Roll right to test next line
        CALL test_line ; Tests that line
        JNZ press_key  ; If key was detected goto press routine

        CMP R1, R4 
        JNZ line_check_loop ; keeping looping until all lines are checked R1=8

    MOV R1, 0 ; no key was pressed so turn off execute flag
    MOV [EXECUTE_COMMAND], R1

    end_keyboard_listner:
        POP R4
        POP R1
        POP R0
        RET

test_line: 
    PUSH R2 ; keyboard Line address, Mask
    PUSH R3 ; keyboard column address

    ; read from keyboard addresses
    MOV R2, KEYBOARD_LINE
    MOV R3, KEYBOARD_COLUMN
    MOVB [R2], R1  ; activate line
    MOVB R0, [R3]  ; read colmuns

    MOV R2, MASK
    AND R0, R2 ; Get low nibble only with MASK -> R0 is the column
    CMP R0, 0  ; Update State Register for later

    POP R3
    POP R2
    RET

press_key:
    CALL convert_to_key       ; R1 will contain converted key
    MOV R0, [EXECUTE_COMMAND] ; Read execute flag if 0 means last key was released
    CMP R0, 0                 ; Check if last cycle key was released then store_key
    JZ store_key

    MOV R0, -1 ; Last key was not released so put flag to -1
    MOV [EXECUTE_COMMAND], R0 ; Lock command execution due to key not released
    JMP end_keyboard_listner ; Nothing to store just end the listner

    store_key:
        MOV [LAST_PRESSED_KEY], R1 ; Store the pressed key in memory
        MOV R1, 1
        MOV [EXECUTE_COMMAND], R1  ; Turn on command flag for execution later
        JMP end_keyboard_listner

convert_to_key:
    PUSH R5
    PUSH R6

    MOV R6, R1 ; move line to R6 to be converted
    CALL convert_to_key_aux
    MOV R1, R5 ; move result (R5) to R1
    MOV R6, R0 ; move column to R6 to be converted
    CALL convert_to_key_aux

    ; Formula: 4 * line + column = key
    MOV R6, 4
    MUL R1, R6
    ADD R1, R5 ; R1 will contain converted key

    POP R6
    POP R5
    RET

; To normalize the keyboard values (1, 2, 4, 8) -> (0, 1, 2, 3) we
; apply SHR and count the amount of shitfs until it reaches 0 that count
; will be the normalized output
convert_to_key_aux:
    MOV R5, -1 ; Start counter at -1 to account for first ADD 

    keep_shifting:
        ADD R5, 1 ; Add 1 to counter
        SHR R6, 1 ; Shift right 1 bit
        CMP R6, 0 ; keep shifting until it reaches 0
        JNZ keep_shifting

    RET


; ***************************************************************************
; * EVENT_HANDLER
; * _________________________________________________________________________
; * R0 - Execute command flag, last pressed key
; * R2 - Entity base address
; * R3 - Entity current and updated x
; * R4 - Entity current and updated y
; * R5 - Used for CMPs 
; ***************************************************************************
event_handler:
    PUSH R0
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV R0, [EXECUTE_COMMAND]  ; Read execute command flag
    CMP R0, 1
    JNZ end_event_handler      ; If flag not on (1) then it means no command needs to be executed

    MOV R0, [LAST_PRESSED_KEY] ; Read last pressed key and following CMPs to determine the correct action

    CMP R0, KEY_SHOOT_UP
    ;JZ shoot_up - WIP

    CMP R0, KEY_SHOOT_LEFT
    ;JZ shoot_left - WIP

    CMP R0, KEY_SHOOT_RIGHT
    ;JZ shoot_right - WIP

    CMP R0, KEY_PAUSE_GAME
    ;JZ game_pause - WIP

    CMP R0, KEY_STOP_GAME
    ;JZ game_stop - WIP

    end_event_handler:
        POP R5
        POP R4
        POP R3
        POP R2
        POP R0
        RET


; ***************************************************************************
; * UPDATE_OBJECT
; * Arguments
; *     - R2 -> Base address of entity/object
; *     - R3 -> New x coordinate
; *     - R4 -> New y coordinate
; *     - R5 -> Layer ID
; * _________________________________________________________________________
; * R1 - Used to modify objects visible flag 
; ***************************************************************************
update_object:
	PUSH R1
	
	MOV R1, [R2+4] ; Get entity visible flag
	CMP R1, 0
	JZ return_update_object ; If object is invisible (flag=0) then dont render
	
    MOV [DELETE_LAYER], R5  ; Update correct layer

	MOV [R2], R3  ; UPDATE MEMORY OF OBJECT WITH NEW X POSITION
	MOV [R2+2], R4  ; UPDATE MEMORY OF OBJECT WITH NEW Y POSITION

    CALL draw_entity ; DRAW OBJECT IN NEW COORDINATES 

	return_update_object:
    POP R1
    RET


; ***************************************************************************
; * DRAW ENTITY
; * Arguments
; *     - R2 -> Base address of entity/object
; *     - R3 -> New x coordinate
; *     - R4 -> New y coordinate
; * _________________________________________________________________________
; R0 - Entity/object base address
; R1 - Sprite base address
; R2 - Length of sprite, current x pos
; R3 - Height of sprite, current y pos
; R5 - Sprite Table y pos
; R6 - Sprite Table x pos
; R7 - Address of pixel color
; ***************************************************************************
draw_entity:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R5
    PUSH R6
    PUSH R7
    MOV R0, R2     ; Entity base address
    MOV R1, [R2+6] ; Sprite base address
    MOV R2, [R1]   ; Length of sprite
    MOV R3, [R1+2] ; Height of sprite

    MOV R5, -1 ; Start at -1 to account for first ADD
    draw_from_table:
        ADD R5, 1  ; Increment Sprite table to next line
        CMP R5, R3 ; Reached last pixel already if so end draw loop?
        JZ end_draw_entity ; All pixels rendered
        MOV R6, 0 ; Start Sprite Table x pos at 0 (columns)
        inner_loop:
            CALL check_pixel_address ; Check if the current pixel is invisble and therefore skippable and calculate offsets
            JZ skip_draw
            CALL draw_pixel ; dont skip so draw pixel
            
            skip_draw:
                ADD R6, 1  ; Next column
                CMP R6, R2 ; Reached last pixel of line?
                JZ draw_from_table ; If so go to next line
                JMP inner_loop ; Continue drawing line

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

    MOV R2, [R0]   ; Current x coord
    MOV R3, [R0+2] ; Current y coord
    ADD R2, R6     ; Add x coord + offset for correct column
    ADD R3, R5     ; Add y coord + offset for correct line
    
    MOV [SET_COLUMN], R2 ; Set pixel column
    MOV [SET_LINE], R3   ; Set pixel Line
    MOV R2, [R7]         ; get color from address of pixel - R7 calculated by check_pixel_adress
    
    MOV R3, [R0+4]       ; Get visibility flag
    CMP R3, 1
    JZ set_pixel         ; If one draw with that color
    MOV R2, 0            ; If not erase pixel (draw with color 0000H)

    set_pixel:
        MOV [SET_PIXEL], R2 ; Draw pixel

    POP R3
    POP R2
    RET 

; Calculates the address of a given pixel from its table
; Saves that value in R7
check_pixel_address:
    PUSH R0
    PUSH R5
    PUSH R6

    MOV R7, [R1] ; Get sprite length
    MUL R5, R7   ; 2D coords into 1D -> length*x + y
    ADD R5, R6   ; 2D coords into 1D -> length*x + y
    SHL R5, 1    ; Multiply by 2 due to byte-adressable memory design (only pair addresses)
    ADD R5, 4    ; Add offset of 4 because the table starts at (Base Address + 4)
    ADD R5, R1   ; Add the base address of object and get final address
    
    MOV R7, R5   ; Save it in R7
    MOV R0, [R7] ; Read the value (color)
    CMP R0, 0 ; check if pixel is empty for later

    POP R6
    POP R5
    POP R0
    RET

; Exception Routines
asteroids_exception:
    PUSH R0

    MOV R0, 1
    MOV [ASTEROIDS_UPDATE_FLAG], R0 ; Activate flag (flag=1)

    POP R0
    RFE

probes_exception:
    PUSH R0

    MOV R0, 1
    MOV [PROBES_UPDATE_FLAG], R0 ; Activate flag (flag=1)

    POP R0
    RFE

energy_exception:
    PUSH R0

    MOV R0, 1
    MOV [ENERGY_UPDATE_FLAG], R0 ; Activate flag (flag=1)

    POP R0
    RFE

navpanel_exception:
    PUSH R0

    MOV R0, 1
    MOV [NAVPANEL_UPDATE_FLAG], R0 ; Activate flag (flag=1)

    POP R0
    RFE



update_energy:
    PUSH R0

    MOV R0, [ENERGY_UPDATE_FLAG] ; Get energy_update flag
    CMP R0, 0
    JZ end_update_energy         ; If 0 means dont update

    CALL energy_decrement        ; Update energy
    MOV R0, 0
    MOV [ENERGY_UPDATE_FLAG], R0 ; Reset update flag

    end_update_energy:
        POP R0
        RET


energy_decrement:
    PUSH R8
    PUSH R9

    ; Get current energy, subtract 5 and update memory
    MOV R9, [CURRENT_ENERGY]
    SUB R9, 5
    MOV [CURRENT_ENERGY], R9

    ;CALL hex_to_dec
    MOV [ENERGY_DISPLAYS], R8 ; Display energy (converted)

    CMP R8, 0 ; Check energy is 0 (game over)
    JNZ end_energy_decrement

    MOV R8, 1
    MOV [GAME_OVER_FLAG], R8 ; Enable game over flag

    end_energy_decrement:
        POP R9
        POP R8
        RET


; UPDATE PROBES - Missing colisions detection and some other shit
update_probes:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV R0, [PROBES_UPDATE_FLAG] ; Get update flag
    CMP R0, 0
    JZ end_update_probes         ; Skip update if flag is 0

    MOV R0, [PROBES]     ; Get number of probes
    MOV R2, PROBES
    ADD R2, 2            ; Store address of first probe (offset by 4)
    MOV R5, LAYER_PROBES ; Set correct layer
    MOV [SET_LAYER], R5

    update_loop:
        CMP R0, 0
        JZ end_update_loop ; End loop when all probes were checked

        MOV R1, [R2+8] ; Get amount of steps
        CMP R1, -1     ; If -1 (not active) then skip update
        JZ next_iter

        MOV R3, 12
        CMP R1, R3     ; If 12 (12 steps were taken) then move home
        JZ move_probe_home

        MOV R3, [R2]    ; Current X
        MOV R4, [R2+10] ; Direction (-1, 0, 1 -> left, up, right)
        ADD R3, R4
        MOV R4, [R2+2]  ; Current Y
        SUB R4, 1       ; Move 1 up
        JMP move_probe  ; After gathering new coordinates goto move_probe

        move_probe_home:
            MOV R3, [R2+14] ; Get homeX
            MOV R4, [R2+16] ; Get homeY

        move_probe:
            ADD R1, 1       ; Steps++
            MOV [R2+8], R1  ; Update steps in memory
            CALL update_object

        next_iter:
            ADD R2, 16 ; Offset by 16 to get address of next probe
            SUB R0, 1  ; Decrement iterator (number of probes)
            JMP update_loop


    end_update_loop:
        MOV R0, 0
        MOV [PROBES_UPDATE_FLAG], R0

    end_update_probes:
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET


update_asteroids:

    MOV R0, [ASTEROIDS_UPDATE_FLAG] ; Get update flag
    CMP R0, 0
    JZ end_update_probes         ; Skip update if flag is 0

    MOV R0, [ASTEROIDS]     ; Get number of probes
    MOV R2, PROBES
    ADD R2, 2            ; Store address of first asteroid (offset by 2)
    MOV R5, LAYER_ASTEROIDS ; Set correct layer
    MOV [SET_LAYER], R5


; RANDOM NUMBER GEN
; Arguments:
;   - R9 : Range of numbers
; Returns R10 : Final Random number
rnd_generator:
    MOVB R10, [PIN_IN] ; Read bits from "air"
    SHR R10, 4         ; Put bits in low nibble
    MOD R10, R9       ; Mod by the argument passed by R10
    RET