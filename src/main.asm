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
KEYBOARD_LINE            EQU 0C000H                    ; (POUT-2)
KEYBOARD_COLUMN          EQU 0E000H                    ; (PIN)
MASK                     EQU 0FH                       ; Get low nibble only

PIN_IN                   EQU 0E000H                    ; (PIN)

; Energy
ENERGY_DISPLAYS          EQU 0A000H                    ; (POUT-1)

; Screen and Media C    ommands
MEDIA_COMMAND	         EQU 6000H                     ; Media center commands

SET_LINE                 EQU MEDIA_COMMAND + 0AH
SET_COLUMN               EQU MEDIA_COMMAND + 0CH
SET_PIXEL   	         EQU MEDIA_COMMAND + 12H
SET_BACKGROUND           EQU MEDIA_COMMAND + 42H
SET_LAYER                EQU MEDIA_COMMAND + 04H
DELETE_LAYER             EQU MEDIA_COMMAND
SET_FOREGROUND           EQU MEDIA_COMMAND + 46H
DELETE_FOREGROUND        EQU MEDIA_COMMAND + 44H
CLEAR_SCREEN	         EQU MEDIA_COMMAND + 02H
DELETE_WARNING           EQU MEDIA_COMMAND + 40H

PLAY_MEDIA               EQU MEDIA_COMMAND + 5AH
PLAY_MEDIA_LOOP          EQU MEDIA_COMMAND + 5CH
PAUSE_MEDIA              EQU MEDIA_COMMAND + 5EH
RESUME_MEDIA             EQU MEDIA_COMMAND + 60H
STOP_MEDIA               EQU MEDIA_COMMAND + 66H

; Layers
LAYER_NAVPANEL           EQU 0
LAYER_SPACESHIP          EQU 1
LAYER_PROBE_RIGHT        EQU 2
LAYER_PROBE_UP           EQU 3
LAYER_PROBE_LEFT         EQU 4
LAYER_ASTEROID_1         EQU 5
LAYER_ASTEROID_2         EQU 6
LAYER_ASTEROID_3         EQU 7
LAYER_ASTEROID_4         EQU 8

; Colors
LIGHTGREY                EQU 0F888H
BLACK                    EQU 0F000H
GREY                     EQU 4888H
SALMON                   EQU 8F10H
MAGENTA                  EQU 0D933H
DARKRED                  EQU 0F900H
NEONRED                  EQU 0FF00H
NEONGREEN                EQU 0F0F0H	
DARKGREEN                EQU 0F070H	
DARKBLUE                 EQU 0F04FH
LIGHTBLUE                EQU 607FH
BLUE                     EQU 903FH
CYAN                     EQU 0F1FFH
NEONPINK                 EQU 0FF0FH
ORANGE                   EQU 0FD60H 
WHITE                    EQU 0FFFFH
NEONYELLOW               EQU 0FFF0H
YELLOW                   EQU 0FEE0H

; Keys
KEY_START_GAME           EQU 0CH
KEY_STOP_GAME            EQU 0EH
KEY_PAUSE_GAME           EQU 0DH
KEY_SHOOT_UP             EQU 1
KEY_SHOOT_RIGHT          EQU 6
KEY_SHOOT_LEFT           EQU 4

; other constants
DIR_LEFT                 EQU -1                        ; Direction LEFT
DIR_UP                   EQU 0                         ; Direction UP
DIR_RIGHT                EQU 1                         ; Direction RIGHT

PROBE_MAX_STEPS          EQU 11                        ; Probes MaxSteps - 1
ASTEROID_MAX_STEPS       EQU 31                        ; Asteroids MaxSteps - 1

SHIP_HITBOX_LOW_X        EQU 22
SHIP_HITBOX_HIGH_X       EQU 38
SHIP_HITBOX_HIGH_Y       EQU 16
ASTEROID_HITBOX_OFFSET   EQU 5                         ; Asteroid side size

ENERGY_GAIN              EQU 25
ENERGY_SPEND             EQU -5
ENERGY_SPEND_IDLE        EQU -3

; ***************************************************************************
; * DATA
; ***************************************************************************
PLACE 1000H

pilha:
    STACK 100H                         ; (100H * 2 Bytes Allocated to Stack)

SP_INICIAL:


; CONTROL VARIABLES
LAST_PRESSED_KEY:
    WORD -1                            ; Start with default value   

; Used together with LAST_KEY_PRESSED to determine when to execute a command (Used like a LOCK)
; 0 -> dont execute; 1 -> execute; -1 -> dont execute [key was not released]
EXECUTE_COMMAND:
    WORD 0

CURRENT_ENERGY:
    WORD 100

; ENTITIES
ASTEROIDS:
    ;number of asteroids
    WORD 4

    ; (x, y, subsprite_index, sprite address, state/steps, direction (left, up, right), breakable)
    WORD 0, 0, 0, ENEMY_SPRITES, -1, 0, 1

    WORD 0, 0, 0, ENEMY_SPRITES, -1, 0, 1

    WORD 0, 0, 0, ENEMY_SPRITES, -1, 0, 1

    WORD 0, 0, 0, ENEMY_SPRITES, -1, 0, 1


SPACESHIP:
    WORD 23, 21, 0, SPRITE_SPACESHIP   ; (x, y, subsprite_index, sprite address)


PROBES:
    ; number of probes
    WORD 3

    ; (x, y, subsprite_index, sprite address, state/steps, direction, Home x, Home y) 
    WORD 26, 26, 0, SPRITE_PROBE, -1, DIR_LEFT, 26, 26

    WORD 32, 20, 0, SPRITE_PROBE, -1, DIR_UP, 32, 20

    WORD 38, 26, 0, SPRITE_PROBE, -1, DIR_RIGHT, 38, 26


SPACESHIP_PANEL:
    WORD 31, 27, 0, SPRITE_PANEL; (x, y, subsprite_index, sprite address)


; SPRITES
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
    WORD NEONPINK


ENEMY_SPRITES:
    ;sprite #0
    WORD 5 ; length
    WORD 5 ; height 
    WORD SALMON, 0, 0, 0, SALMON
    WORD 0, SALMON, 0, SALMON, 0
    WORD DARKRED, DARKRED, DARKRED, DARKRED, DARKRED
    WORD DARKRED, 0, DARKRED, 0, DARKRED
    WORD DARKRED, DARKRED, DARKRED, DARKRED, DARKRED

    ;sprite #1
    WORD 5 ; length
    WORD 5 ; height 
    WORD 0, SALMON, SALMON, SALMON, 0
    WORD SALMON, 0, SALMON, 0, SALMON
    WORD DARKRED, DARKRED, 0, DARKRED, DARKRED
    WORD 0, DARKRED, 0, DARKRED, 0
    WORD DARKRED, 0, DARKRED, 0, DARKRED

    ;sprite #2
    WORD 5 ; length
    WORD 5 ; height 
    WORD SALMON, 0, 0, 0, SALMON
    WORD 0, SALMON, SALMON, SALMON, 0
    WORD SALMON, 0, SALMON, 0, SALMON
    WORD DARKRED, DARKRED, DARKRED, DARKRED, DARKRED
    WORD 0, DARKRED, DARKRED, DARKRED, 0

    ;desctruction sprite
    WORD 5 ; length
    WORD 5 ; height 
    WORD 0, LIGHTBLUE, 0, 0, 0
    WORD LIGHTBLUE, BLUE, DARKBLUE, 0, 0
    WORD 0, DARKBLUE, 0, LIGHTBLUE, 0
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


; EXCEPTIONS TABLE
EXCEPTIONS:
    WORD asteroids_exception
    WORD probes_exception
    WORD energy_exception
    WORD navpanel_exception

; EXCEPTION FLAGS
ASTEROIDS_UPDATE_FLAG:
    WORD 0

PROBES_UPDATE_FLAG:
    WORD 0

ENERGY_UPDATE_FLAG:
    WORD 0

NAVPANEL_UPDATE_FLAG:
    WORD 0

; OTHER FLAGS
GAME_OVER_FLAG:
    WORD 0


; ***************************************************************************
; * CODE
; ***************************************************************************
PLACE 0

initialize:
    MOV SP, SP_INICIAL                 ; Initialize Stack Pointer
    MOV BTE, EXCEPTIONS                ; Initialize Exception Table
    MOV [DELETE_WARNING], R1           ; Clear warnings
    MOV [CLEAR_SCREEN], R1             ; Clear Screen

    EI0
    EI1
    EI2
    EI3
    EI                                  ; Activate all interrupts


start:
    CALL reset_game                     ; Reset/Initialize everything correctly + Main menu call 

    game_loop:
        CALL keyboard_listner           ; Listen for input

        CALL update_panel
        CALL update_energy_idling
        CALL update_asteroids
        CALL update_probes

        CALL event_handler              ; carrys out keyboard commands

        CALL check_game_over
        JMP game_loop


    main_menu:
        PUSH R0
        PUSH R1

        MOV R0, 0
        MOV [SET_BACKGROUND], R0         ; Set to main_menu.png (index 0)

        MOV R0, 3
        MOV [PLAY_MEDIA_LOOP], R0        ; Set to intro.wav (index 3)

        loop_main_menu:                  ; Loop until start game key was pressed
            CALL keyboard_listner
            MOV R0, [EXECUTE_COMMAND]
            CMP R0, 1
            JNZ loop_main_menu

            MOV R0, [LAST_PRESSED_KEY]   ; Get last pressed key
            MOV R1, KEY_START_GAME
            CMP R0, R1
            JNZ loop_main_menu           ; If correct key then end loop to start game

        MOV R0, 3
        MOV [STOP_MEDIA], R0             ; Stop intro.wav (index 3)

        MOV R0, 1
        MOV [PLAY_MEDIA], R0             ; Play beep sound effect (index 1)

        POP R0
        POP R1
        RET

; ***************************************************************************
; * KEYBOARD LISTNER -> - Listens to keyboard input
;                       - Locks command execution if key was not released
; * _________________________________________________________________________
; ***************************************************************************
keyboard_listner:
    PUSH R0
    PUSH R1
    PUSH R4

    MOV R4, 8                   ; max lines (1000b)

    MOV R1, 8000H               ; Start at here so after bit roll its begins at 1 (0001b)
    line_check_loop:
        ROL R1, 1               ; Roll right to test next line
        CALL test_line          ; Tests that line
        JNZ press_key           ; If key was detected goto press routine

        CMP R1, R4 
        JNZ line_check_loop     ; keeping looping until all lines are checked R1=8

    MOV R1, 0                   ; no key was pressed so turn off execute flag
    MOV [EXECUTE_COMMAND], R1

    end_keyboard_listner:
        POP R4
        POP R1
        POP R0
        RET

test_line: 
    PUSH R2                     ; keyboard Line address, Mask
    PUSH R3                     ; keyboard column address

    ; read from keyboard addresses
    MOV R2, KEYBOARD_LINE
    MOV R3, KEYBOARD_COLUMN
    MOVB [R2], R1               ; activate line
    MOVB R0, [R3]               ; read colmuns

    MOV R2, MASK
    AND R0, R2                  ; Get low nibble only with MASK -> R0 is the column
    CMP R0, 0                   ; Update State Register for later

    POP R3
    POP R2
    RET

press_key:
    CALL convert_to_key            ; R1 will contain converted key
    MOV R0, [EXECUTE_COMMAND]      ; Read execute flag if 0 means last key was released
    CMP R0, 0                      ; Check if last cycle key was released then store_key
    JZ store_key

    MOV R0, -1                     ; Last key was not released so put flag to -1
    MOV [EXECUTE_COMMAND], R0      ; Lock command execution due to key not released
    JMP end_keyboard_listner       ; Nothing to store just end the listner

    store_key:
        MOV [LAST_PRESSED_KEY], R1 ; Store the pressed key in memory
        MOV R1, 1
        MOV [EXECUTE_COMMAND], R1  ; Turn on command flag for execution later
        JMP end_keyboard_listner

convert_to_key:
    PUSH R5
    PUSH R6

    MOV R6, R1               ; move line to R6 to be converted
    CALL convert_to_key_aux
    MOV R1, R5               ; move result (R5) to R1
    MOV R6, R0               ; move column to R6 to be converted
    CALL convert_to_key_aux

    ; Formula: 4 * line + column = key
    MOV R6, 4
    MUL R1, R6
    ADD R1, R5               ; R1 will contain converted key

    POP R6
    POP R5
    RET

; To normalize the keyboard values (1, 2, 4, 8) -> (0, 1, 2, 3) we
; apply SHR and count the amount of shitfs until it reaches 0 that count
; will be the normalized output
convert_to_key_aux:
    MOV R5, -1            ; Start counter at -1 to account for first ADD 

    keep_shifting:
        ADD R5, 1         ; Add 1 to counter
        SHR R6, 1         ; Shift right 1 bit
        CMP R6, 0         ; keep shifting until it reaches 0
        JNZ keep_shifting

    RET

; ***************************************************************************
; * EVENT_HANDLER -> handles keyboard events
; * _________________________________________________________________________
; ***************************************************************************
event_handler:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R8

    MOV R0, [EXECUTE_COMMAND]  ; Read execute command flag
    CMP R0, 1
    JNZ end_event_handler      ; If flag not on (1) then it means no command needs to be executed

    MOV R0, [LAST_PRESSED_KEY] ; Read last pressed key and following CMPs to determine the correct action

    ; Carry out correct events depending on key
    MOV R1, KEY_SHOOT_UP
    CMP R0, R1
    JZ shoot_up

    MOV R1, KEY_SHOOT_LEFT
    CMP R0, R1
    JZ shoot_left

    MOV R1, KEY_SHOOT_RIGHT
    CMP R0, R1
    JZ shoot_right

    MOV R1, KEY_PAUSE_GAME
    CMP R0, R1
    JZ game_pause

    MOV R1, KEY_STOP_GAME
    CMP R0, R1
    JZ game_stop

    end_event_handler:
        POP R8
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET


    shoot_up:
        MOV R3, 18                     ; Offset for middle probe
        MOV R2, PROBES                 ; Get probes base address
        ADD R2, R3                     ; Get middle probe base address

        MOV R4, LAYER_PROBE_UP
        MOV [SET_LAYER], R4            ; Sets correct layer for this probe

        JMP ready_up_probe

    shoot_left:
        MOV R3, 2                      ; Offset for left probe
        MOV R2, PROBES                 ; Get probes base address
        ADD R2, R3                     ; Get middle probe base address

        MOV R4, LAYER_PROBE_LEFT
        MOV [SET_LAYER], R4            ; Sets correct layer for this probe

        JMP ready_up_probe

    shoot_right:
        MOV R3, 34                     ; Offset for right probe
        MOV R2, PROBES                 ; Get probes base address
        ADD R2, R3                     ; Get middle probe base address

        MOV R4, LAYER_PROBE_RIGHT
        MOV [SET_LAYER], R4            ; Sets correct layer for this probe

        JMP ready_up_probe

    ready_up_probe:
        MOV R3, [R2+8]                 ; Get state/steps of current probe
        CMP R3, 0
        JGE end_event_handler          ; If probe already exists (steps != -1) dont do nothing

        MOV R3, 0
        MOV [R2+8], R3                 ; Set steps flag to 0 (ready with 0 steps taken)
        MOV [R2+4], R3                 ; Set sprite index to 0 (visible)
        CALL draw_entity               ; Draw entity reads R2 to draw the probe

        MOV R8, ENERGY_SPEND 
        CALL energy_value_update       ; Probe spends energy (-5%)

        MOV R3, 6
        MOV [PLAY_MEDIA], R3           ; Play shoot.wav
        
        JMP end_event_handler

    game_pause:
        MOV R3, 0
        MOV [PAUSE_MEDIA], R3          ; Pause stars.mp4

        MOV R3, 7
        MOV [PAUSE_MEDIA], R3          ; Pause main theme

        MOV R4, 1
        MOV [SET_FOREGROUND], R4       ; Set foreground as paused_overlay.png (index 1)
        MOV [PLAY_MEDIA], R4           ; Play beep sound effect (index 1)

        pause_loop:                    ; Loops until pause/resume key or stop key havent been pressed
            CALL keyboard_listner
            MOV R0, [EXECUTE_COMMAND]
            CMP R0, 1
            JNZ pause_loop

            MOV R0, [LAST_PRESSED_KEY]
            MOV R1, KEY_STOP_GAME
            CMP R0, R1
            JZ game_stop               ; Stop key was pressed

            MOV R1, KEY_PAUSE_GAME
            CMP R0, R1
            JNZ pause_loop

        MOV [PLAY_MEDIA], R4           ; Play beep sound effect (index 1)
        MOV [DELETE_FOREGROUND], R4    ; Delete foreground

        MOV [RESUME_MEDIA], R3         ; Resume main_theme
        MOV R3, 0
        MOV [RESUME_MEDIA], R3         ; Resume stars.mp4


        JMP end_event_handler

    game_stop:
        MOV [DELETE_FOREGROUND], R4    ; Delete pause_overlay foreground

        MOV R3, 7
        MOV [STOP_MEDIA], R3           ; Stop main theme

        MOV R3, 5
        MOV [PLAY_MEDIA], R3           ; Play game over sound effect

        MOV R3, 4
        MOV [SET_BACKGROUND], R3       ; Set game_over.png
        
        MOV R3, 0
        MOV [STOP_MEDIA], R3           ; Stops stars.mp4 video

        MOV [CLEAR_SCREEN], R3         ; Clears screen

        stop_loop:                     ; Loops until start/restart key hasnt been pressed
            CALL keyboard_listner
            MOV R0, [EXECUTE_COMMAND]
            CMP R0, 1
            JNZ stop_loop

            MOV R0, [LAST_PRESSED_KEY]
            MOV R1, KEY_START_GAME
            CMP R0, R1
            JNZ stop_loop

        CALL reset_game                ; Resets the game + goes to main menu
        JMP end_event_handler

; ***************************************************************************
; * UPDATE_entity -> Updates entities position and subsprite
; * Arguments
; *     - R2 -> Base address of entity
; *     - R3 -> New x coordinate
; *     - R4 -> New y coordinate
; *     - R5 -> Pixel Layer ID
; * _________________________________________________________________________
; ***************************************************************************
update_entity:
    PUSH R0

    MOV [DELETE_LAYER], R5  ; Deletes previous frame for layer stored in R5

	MOV [R2], R3            ; UPDATE MEMORY OF entity WITH NEW X POSITION
	MOV [R2+2], R4          ; UPDATE MEMORY OF entity WITH NEW Y POSITION

    MOV R0, [R2+4]
    CMP R0, -1              ; Check if entity is invisible (if so skip draw)
    JZ end_update_entity

    CALL draw_entity        ; DRAW entity IN NEW COORDINATES

    end_update_entity:
        POP R0
        RET

; ***************************************************************************
; * DRAW ENTITY -> Draws an entity to the screen
; * Arguments
; *     - R2 -> Base address of entity
; * _________________________________________________________________________
; ***************************************************************************
draw_entity:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R5
    PUSH R6
    PUSH R7

    MOV R0, [R2+6]                   ; Get base address of sprites
    
    MOV R1, [R0]                     ; Sprite length
    MOV R3, [R0+2]
    MUL R1, R3                       ; Multiply with sprite height to get sprite area
    SHL R1, 1                        ; Multiply by 2 for correct memory address
    ADD R1, 4                        ; Add 4 to skip to next subsprite length (subsprite mapping offset)
    
    MOV R3, [R2+4]
    MUL R1, R3                       ; Finally multiply by subsprite index to get final offset
    ADD R1, R0                       ; Get the base address of the current subsprite

    MOV R0, R2                       ; Get base address of entity
    MOV R2, [R1]                     ; Length of sprite
    MOV R3, [R1+2]                   ; Height of sprite    

    MOV R5, -1                       ; Start at -1 to account for first ADD
    draw_from_table:
        ADD R5, 1                    ; Increment Sprite table to next line
        CMP R5, R3                   ; Reached last pixel already if so end draw loop?
        JZ end_draw_entity           ; All pixels rendered
        MOV R6, 0                    ; Start Sprite Table x pos at 0 (columns)
        inner_loop:
            CALL check_pixel_address ; Check if the current pixel is invisble and calculate offsets
            JZ skip_draw             ; Invisble pixel so skip draw
            CALL draw_pixel          
            
            skip_draw:
                ADD R6, 1            ; Next column
                CMP R6, R2           ; Reached last pixel of line?
                JZ draw_from_table   ; If so go to next line
                JMP inner_loop       ; Continue drawing line

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

    MOV R2, [R0]                     ; Current x coord
    MOV R3, [R0+2]                   ; Current y coord
    ADD R2, R6                       ; Add x coord + offset for correct column
    ADD R3, R5                       ; Add y coord + offset for correct line
    
    MOV [SET_COLUMN], R2             ; Set pixel column
    MOV [SET_LINE], R3               ; Set pixel Line
    MOV R2, [R7]                     ; get color from address of pixel - R7 calculated by check_pixel_adress
    
    MOV [SET_PIXEL], R2              ; Draw pixel

    POP R3
    POP R2
    RET 

; Calculates the address of a given pixel from its table
; Saves that value in R7
check_pixel_address:
    PUSH R0
    PUSH R5
    PUSH R6

    MOV R7, [R1]          ; Get sprite length
    MUL R5, R7            ; 2D coords into 1D -> length*x + y
    ADD R5, R6            ; 2D coords into 1D -> length*x + y
    SHL R5, 1             ; Multiply by 2 due to byte-adressable memory design (only pair addresses)
    ADD R5, 4             ; Add offset of 4 because the table starts at (Base Address + 4)
    ADD R5, R1            ; Add the base address of entity and get final address
    
    MOV R7, R5            ; Save it in R7
    MOV R0, [R7]          ; Read the value (color)
    CMP R0, 0             ; check if pixel is empty for later

    POP R6
    POP R5
    POP R0
    RET

; ***************************************************************************
; * UPDATE_ENERGY_IDLING -> Updates energy while ship is idling
; * _________________________________________________________________________
; ***************************************************************************
update_energy_idling:
    PUSH R0
    PUSH R8

    MOV R0, [ENERGY_UPDATE_FLAG]        ; Get energy_update flag
    CMP R0, 0
    JZ end_update_energy_idling         ; If 0 means dont update

    MOV R8, ENERGY_SPEND_IDLE
    CALL energy_value_update            ; Update energy (-3%)
    MOV R0, 0
    MOV [ENERGY_UPDATE_FLAG], R0        ; Reset update flag

    end_update_energy_idling:
        POP R8
        POP R0
        RET

; ***************************************************************************
; * UPDATE_PANEL -> Animates spaceship panel
; * _________________________________________________________________________
; ***************************************************************************
update_panel:
    PUSH R0
    PUSH R2

    ; Get update flag (if not 1 then dont update)
    MOV R0, [NAVPANEL_UPDATE_FLAG]
    CMP R0, 1
    JNZ end_update_panel

    MOV R2, SPACESHIP_PANEL             ; Get base address of spaceship panel
    MOV R0, [R2+4]                      ; Get subprite index (keyframe)
    CMP R0, 5                           ; If at index 5 set it back to 0
    JLT next_frame                      ; If < 5 just increment normally
    MOV R0, -1                          ; first set at -1 to account for next add

    next_frame:
        ADD R0, 1
    
    MOV [R2+4], R0                      ; Update new subsprite

    MOV R0, LAYER_NAVPANEL
    MOV [SET_LAYER], R0                 ; Set correct layer
    CALL draw_entity                    ; Draw panel

    MOV R0, 0
    MOV [NAVPANEL_UPDATE_FLAG], R0      ; Turn off panel update flag

    end_update_panel:
        POP R2 
        POP R0
        RET

; ***************************************************************************
; * UPDATE_PROBES -> - Updates movement, checks colisions, renders probes
;                    - Moves probes to initial position
; * _________________________________________________________________________
; ***************************************************************************
update_probes:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R10

    MOV R6, 16                              ; Next probe offset
    MOV R0, [PROBES_UPDATE_FLAG]            ; Get update flag
    CMP R0, 0
    JZ end_update_probes                    ; Skip update if flag is 0

    MOV R0, [PROBES]                        ; Get number of probes
    MOV R2, PROBES
    ADD R2, 2                               ; Store address of first probe (offset by 2)
    MOV R5, R0
    ADD R5, 1                               ; 3 probes -> layers (2, 3, 4) so add 1 to account for that

    update_probes_loop:
        CMP R0, 0
        JZ end_update_loop                  ; End loop when all probes were checked

        MOV R1, [R2+8]                      ; Get amount of steps
        CMP R1, -1
        JZ next_iter_probes                 ; If -1 (not active) then skip update

        MOV R7, PROBE_MAX_STEPS
        CMP R1, R7                          ; If 12 (12 steps were taken) then move home
        JZ move_probe_home

        asteroid_colision:
            MOV R3, [R2]                    ; Current X
            MOV R4, [R2+2]                  ; Current Y

            MOV R10, 0                      ; Sets colision flag to 0 (disabled)
            CALL check_asteroid_colision    ; Checks if probe colided with an asteroid (R10 = 1 if colided)

            CMP R10, 1           
            JZ move_probe_home              ; If there was a colision reset that probe

        MOV R7, [R2+10]                     ; Get Direction (-1, 0, 1 -> left, up, right)
        ADD R3, R7                          ; Update new X coordinate
        SUB R4, 1                           ; Move 1 up
        JMP move_probe                      ; After gathering new coordinates goto move_probe

        move_probe_home:
            MOV R3, [R2+12]                 ; Get homeX
            MOV R4, [R2+14]                 ; Get homeY

            MOV R7, -1
            MOV [R2+4], R7                  ; Set sprite index to -1 (invisible)
            MOV R1, -2                      ; Set steps to -1 (not active) (-2 to account for ADD in move_probe)

        move_probe:
            ADD R1, 1                       ; Steps++
            MOV [R2+8], R1                  ; Update steps in memory 
            MOV [SET_LAYER], R5             ; Set correct layer
            CALL update_entity              ; Renders probe

        next_iter_probes:
            SUB R5, 1                       ; Next probe layer
            ADD R2, R6                      ; Offset by 16 to get address of next probe
            SUB R0, 1                       ; Decrement iterator (number of probes)
            JMP update_probes_loop

    end_update_loop:
        MOV R0, 0
        MOV [PROBES_UPDATE_FLAG], R0        ; Disable probe update flag

    end_update_probes:
        POP R10
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

; ***************************************************************************
; * CHECK ASTEROID COLISION -> Checks if probe colided with an asteroid
; * Arguments:
; *     - R3 -> Current probe X ; - R4 -> Current probe Y
; * Returns:
; *     - R10 -> Colision flag
; * _________________________________________________________________________
; ***************************************************************************
check_asteroid_colision:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R6
    PUSH R7

    MOV R0, [ASTEROIDS]                  ; Get number of asteroids
    MOV R2, ASTEROIDS
    ADD R2, 2                            ; Get address of first asteroid (offset by 2)
    MOV R1, 14                           ; Next asteroid offset

    check_probe_loop:
        CMP R0, 0
        JZ end_check_probe_colision      ; Check if all asteroids have been checked

        MOV R6, [R2+12]                  ; Get asteroid breakable flag (breakable = not explosion)
        CMP R6, 0
        JZ check_probe_next_iter         ; Check if asteroid is breakable if not check next iteration

        MOV R6, [R2]                     ; Asteroid current X
        MOV R7, [R2+2]                   ; Asteroid current Y

        CMP R3, R6                       ; R3 = Probe Current X
        JLT check_probe_next_iter        ; Check asteroid hitbox lower X bound

        ADD R6, ASTEROID_HITBOX_OFFSET   ; Add hitbox offset (size of asteroid)
        CMP R3, R6
        JGT check_probe_next_iter        ; Check asteroid hitbox higher X bound

        CMP R4, R7                       ; R4 = Probe Current Y
        JLT check_probe_next_iter        ; Check asteroid hitbox higher Y bound

        ADD R7, ASTEROID_HITBOX_OFFSET   ; Add hitbox offset
        CMP R4, R7
        JGT check_probe_next_iter        ; Check asteroid hitbox lower Y bound

        ; If flow reaches here than probe was inside hitbox
        MOV R7, [R2+6]                   ; Get current sprite (enemy/friend)
        MOV R6, ENEMY_SPRITES
        CMP R6, R7                       ; Check if asteroid is enemy or friend
        JZ colision_enemy

        colision_friend:
            MOV R7, -1
            MOV [R2+4], R7               ; Set to -1 means asteroid was mined and needs to update sprite animation
            JMP set_colision

        colision_enemy:
            MOV R7, 3
            MOV [R2+4], R7               ; Set to enemy explosion sprite

        set_colision:
            MOV R7, 0
            MOV [R2+12], R7              ; Set unbreakable (probe cant interact with explosion)
            MOV R10, 1                   ; Set colision happened
            JMP end_check_probe_colision ; End loop due to colision

        check_probe_next_iter:
            SUB R0, 1                    ; Decrement iterator   
            ADD R2, R1                   ; Get next asteroid adress
            JMP check_probe_loop

    end_check_probe_colision:
        POP R7
        POP R6
        POP R2
        POP R1
        POP R0
        RET

; ***************************************************************************
; * UPDATE ASTEROIDS -> - Updates asteroids movement
;                       - Updates asteroids sprites and renders
;                       - Regenerates asteroids
;                       - Updates if asteroid was mined or destroyed
;                       - Detects colision with ship
; * _________________________________________________________________________
; ***************************************************************************
update_asteroids:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R9
    PUSH R10

    MOV R0, [ASTEROIDS_UPDATE_FLAG]
    CMP R0, 0
    JZ end_update_asteroids              ; Skip update if flag is disabled (flag = 0)    

    MOV R6, 14                           ; Next asteroid offset
    MOV R0, [ASTEROIDS]                  ; Get number of asteroids
    MOV R2, ASTEROIDS
    ADD R2, 2                            ; Get Address of first asteroid (offset by 2)
    MOV R5, R0
    ADD R5, 1                            ; (start at layer 4 which is asteroid 1 and go up in order until layer 8 which is asteroid 4)

    update_asteroids_loop:
        CMP R0, 0
        JZ end_update_asteroids_loop     ; If all asteroid have been updated end loop

        MOV R3, [R2]                     ; Current Asteroid X
        MOV R4, [R2+2]                   ; Current Asteroid Y
        
        ; These 3 lines are only executed the first time the game starts
        MOV R1, [R2+8]                   ; Get amount of steps
        CMP R1, -1                       ; If -1 (not active) then regenerate asteroid
        JZ regen_asteroid

        MOV R7, [R2+6]                   ; Get sprite (enemy/friend)
        MOV R9, FRIEND_SPRITES
        CMP R7, R9
        JNZ skip_mine_energy             ; If asteroid is enemy type then skip energy boost

        MOV R7, [R2+4]                   ; Get subsprite index
        CMP R7, -1
        JZ mine_energy_first_time        ; If index at -1 means asteroid was just mined
        CMP R7, 1
        JGE mine_energy                  ; If index at >= 1 then continue mine animation

        skip_mine_energy:                ; Asteroid is enemy type
            MOV R7, [R2+4]               ; Get subsprite
            CMP R7, 3                    ; If subsprite is the destruction sprite then create explosion
            JZ create_explosion

            MOV R7, ASTEROID_MAX_STEPS
            CMP R1, R7                   ; If 31 (y coord reached bottom screen) then set regen asteroid
            JZ regen_asteroid


        ship_colision:
            MOV R7, SHIP_HITBOX_LOW_X    ; Hitbox X lower bound
            CMP R3, R7
            JLT asteroid_new_coords
            
            MOV R7, SHIP_HITBOX_HIGH_X   ; Hitbox X higher bound
            CMP R3, R7
            JGT asteroid_new_coords
            
            MOV R7, SHIP_HITBOX_HIGH_Y   ; Hitbox Y higher bound
            CMP R4, R7
            JLT asteroid_new_coords

            ; If flow reached here then asteroid was inside the ships hitbox
            MOV R7, 1
            MOV [GAME_OVER_FLAG], R7     ; Turn of game over flag    

            MOV R7, 2
            MOV [SET_BACKGROUND], R7     ; Set background to dead.png (index 2)
            MOV [PLAY_MEDIA], R7         ; Play game_over.wav (index 2)
            JMP end_update_asteroids     ; End update routine

        mine_energy_first_time:          ; This is needed to play sound effect and gain energy only once
            MOV R7, 4
            MOV [PLAY_MEDIA], R7         ; Play energy.wav (index 4)

            MOV R7, 1
            MOV [R2+4], R7               ; Begin mining animation (set to 1st keyframe which is subsprite 1)

            MOV R8, ENERGY_GAIN
            CALL energy_value_update     ; Update energy value with +25
            JMP move_asteroid            ; Update movement + render

        mine_energy:                     ; Just updates the mining animation
            ADD R7, 1                    ; Next keyframe
            CMP R7, 4
            JZ regen_asteroid            ; If subsprite index reaches 4 then animation is over

            MOV [R2+4], R7               ; Update subsprite in memory
            JMP move_asteroid            ; Update movement + render


        create_explosion:
            MOV R7, 2
            MOV [PLAY_MEDIA], R7         ; Plays asteroid_explosion.wav (index 1)
            MOV R1, -2                   ; Set steps to -1 to be regened later (set to -2 to account for ADD in move_asteroid)
            JMP move_asteroid

        asteroid_new_coords:
            MOV R7, [R2+10]              ; Get Direction (-1, 0, 1 -> left, up, right)
            ADD R3, R7                   ; Change X coord
            ADD R4, 1                    ; Move 1 down (Change y coord)
            JMP move_asteroid

        regen_asteroid:
            MOV R9, 5
            CALL rng_range 
            CALL column_gen              ; Generates pair (column/direction) 1/5 chance for each combination

            MOV R9, 100
            CALL rng_range
            CALL type_gen                ; Generate type (1/4 chance for friend asteroid)
            
            MOV R4, 0
            ; R3 now contains new X coord and R4 contains new Y coord
            MOV R1, -1                   ; Set steps to 0 (ready) (We set to -1 to account for the next ADD in move_asteroid)
            MOV R7, 1
            MOV [R2+12], R7              ; Set breakable again (probe can interact)

        move_asteroid:
            ADD R1, 1                    ; Steps++
            MOV [R2+8], R1               ; Update steps in memory  
            MOV [SET_LAYER], R5          ; Get correct layer
            CALL update_entity

        next_iter_asteroids:
            ADD R5, 1                    ; Next asteroid layer
            ADD R2, R6                   ; Offset by 10 to get address of next asteroid
            SUB R0, 1                    ; Decrement iterator (number of asteroids)
            JMP update_asteroids_loop


    end_update_asteroids_loop:
        MOV [ASTEROIDS_UPDATE_FLAG], R0  ; Turns off asteroid update flag (R0 = 0)

    end_update_asteroids:
        POP R10
        POP R9
        POP R7
        POP R6
        POP R5
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

; Generates "Randomly" Column to spawn
column_gen:
    PUSH R0

    ; Select correct option (0-4)
    CMP R10, 0
    JLT spawn_left

    CMP R10, 1
    JLT spawn_right

    CMP R10, 2
    JLT spawn_middle_down

    CMP R10, 3
    JLT spawn_middle_left

    CMP R10, 4
    JLT spawn_middle_right

    spawn_left:
        MOV R3, 0               ; Set x coord to 0
        MOV R0, 1               ; Set direction to 1 (right)
        JMP end_column_gen

    spawn_right:
        MOV R3, 59              ; set x coord to 59
        MOV R0, -1              ; Set direction to -1 (left)
        JMP end_column_gen

    spawn_middle_down:
        MOV R3, 30              ; Set x coord to 30 (middle)
        MOV R0, 0               ; Set direction to 0 (down)
        JMP end_column_gen

    spawn_middle_left:
        MOV R3, 30              ; Set x coord to 30 (middle)
        MOV R0, -1              ; Set direction to -1 (left)
        JMP end_column_gen

    spawn_middle_right:
        MOV R3, 30              ; Set x coord to 30 (middle)
        MOV R0, 1               ; Set direction to 1 (right)
        JMP end_column_gen

    end_column_gen:
        MOV [R2+10], R0         ; Update direction
        POP R0
        RET

; Generates "Randomly" Asteroid type and subsprite
type_gen:
    PUSH R0

    MOV R0, 25
    CMP R10, R0
    JLT spawn_friend            ; 25percent chance in being friend asteroid

    MOV R0, ENEMY_SPRITES       ; Set sprite to enemy type

    ; Set to enemy type - choose 1 of the 3 different enemy sprites
    MOV R9, 3
    CALL rng_range              ; Returns random value to R10
    MOV [R2+4], R10             ; Update new subsprite in memory

    JMP end_type_gen

    spawn_friend:
        MOV R0, 0
        MOV [R2+4], R0          ; Set subsprite to default 0
        MOV R0, FRIEND_SPRITES  ; Set sprite to friend type
    
    end_type_gen:
        MOV [R2+6], R0          ; Apply sprite changes in entity
        POP R0
        RET


; ***************************************************************************
; * ENERGY_VALUE_UPDATE -> - Increments or decrements energy
;                          - Checks if ship runs out of energy
; * Arguments:
; *     R8 -> new energy increment or decrement
; * _________________________________________________________________________
; ***************************************************************************
energy_value_update:
    PUSH R8
    PUSH R9

    ; Get current energy, add value of R4 (can be negative) and update memory
    MOV R9, [CURRENT_ENERGY]
    ADD R9, R8
    MOV [CURRENT_ENERGY], R9

    CALL hex_to_dec                     ; Reads from R9 and converted output gets written on R8
    MOV [ENERGY_DISPLAYS], R8           ; Display energy (converted)

    CMP R9, 0                           ; Check energy is <= 0 (game over)
    JGT end_energy_value_update         ; If not game over end routine

    MOV R8, 0
    MOV [ENERGY_DISPLAYS], R8           ; Make sure to display 000 at then end

    MOV R8, 1
    MOV [GAME_OVER_FLAG], R8            ; Enable game over flag

    MOV R8, 3
    MOV [SET_BACKGROUND], R8            ; Set background to no_energy.png (index 3)

    end_energy_value_update:
        POP R9
        POP R8
        RET


; ***************************************************************************
; * CHECK GAME OVER -> Checks if game needs to end
; * _________________________________________________________________________
; ***************************************************************************
check_game_over:
    PUSH R0
    PUSH R1

    MOV R0, [GAME_OVER_FLAG]
    CMP R0, 1
    JNZ end_check_game_over       ; Checks if flag is on (if not dont end game)

    MOV R0, 7
    MOV [STOP_MEDIA], R0          ; Stop main theme 

    MOV R0, 5
    MOV [PLAY_MEDIA], R0          ; Play game_over.wav (index 5)

    MOV R0, 0
    MOV [STOP_MEDIA], R0          ; Stop stars.mp4
    MOV [CLEAR_SCREEN], R0        ; Clears screen

    ; Loops until the start key is pressed
    loop_game_over:
        CALL keyboard_listner
        MOV R0, [EXECUTE_COMMAND]
        CMP R0, 1
        JNZ loop_game_over

        MOV R0, [LAST_PRESSED_KEY]
        MOV R1, KEY_START_GAME
        CMP R0, R1
        JNZ loop_game_over

    MOV R0, 0
    MOV [GAME_OVER_FLAG], R0      ; Turns off game over flag

    CALL reset_game               ; Resets game

    end_check_game_over:
        POP R1
        POP R0
        RET

; ***************************************************************************
; * RESET GAME -> - Resets the game, variables, entities, etc..
;                 - Calls main menu loop
; * Arguments:
; *     R4 -> new energy increment or decrement
; * _________________________________________________________________________
; ***************************************************************************
reset_game:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    MOV [CLEAR_SCREEN], R0              ; Clear screen

    CALL main_menu                      ; Starts main menu loop

    MOV R0, [ASTEROIDS]                 ; Get number of asteroids
    MOV R2, ASTEROIDS
    ADD R2, 2                           ; Get address of first asteroid

    reset_asteroids:
        CMP R0, 0
        JZ reset_spaceship              ; If all asteroids reset exit loop

        MOV R1, -1
        MOV [R2+8], R1                  ; Set each asteroid state to -1 (invisible and ready to regen)

        MOV R1, 14            
        ADD R2, R1                      ; Get address of next asteroid (offset by 12)

        SUB R0, 1                       ; Decrement loop iterator
        JMP reset_asteroids             ; Continue loop

    reset_spaceship:
        MOV R0, LAYER_SPACESHIP
        MOV [SET_LAYER], R0             ; Set correct layer for spaceship

        MOV R2, SPACESHIP
        CALL draw_entity                ; Get address of spaceship and draw it

    MOV R0, [PROBES]                    ; Get number of probes
    MOV R2, PROBES
    ADD R2, 2                           ; Get address of first probe

    reset_probes:
        CMP R0, 0
        JZ reset_rest                   ; If all probes reset exit loop

        MOV R1, -1
        MOV [R2+8], R1                  ; Set probe state to -1 (invisible and ready to be fired)

        MOV R3, [R2+12]                 ; get Home X
        MOV R4, [R2+14]                 ; get Home Y

        MOV [R2], R3
        MOV [R2+2], R4                  ; Update probes coordinates to the home coordinates

        MOV R1, 16            
        ADD R2, R1                      ; Get address of next probe (offset by 16)

        SUB R0, 1                       ; Decrement loop iterator
        JMP reset_probes                ; Continue loop

    reset_rest:
        MOV R0, 7
        MOV [PLAY_MEDIA_LOOP], R0       ; Start main_theme.mp3

        MOV R0, 100H
        MOV [ENERGY_DISPLAYS], R0       ; Update energy display
        MOV R0, 100
        MOV [CURRENT_ENERGY], R0        ; Reset current enery to 100

        MOV R0, 0
        MOV [PLAY_MEDIA_LOOP], R0       ; Start background video stars.mp4 (index 0)

        ; Disable exception flags (R0 = 0)
        MOV [ASTEROIDS_UPDATE_FLAG], R0

        MOV [PROBES_UPDATE_FLAG], R0

        MOV [ENERGY_UPDATE_FLAG], R0

        MOV [NAVPANEL_UPDATE_FLAG], R0

        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

; ***************************************************************************
; * HEX TO DEC -> Returns a converted hexadecimal to decimal (change of base)
; * Arguments:
; *     R9 -> Original hexadecimal value
; * _________________________________________________________________________
; * Returns:
; *     R8 -> Converted Value
; * _________________________________________________________________________
; ***************************************************************************
hex_to_dec:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R9

    MOV R1, 1000           ; Initial factor
    MOV R2, 10             ; factor lower bound

    MOV R8, 0              ; Initialize final convtered value

    loop_converter:
        MOD R9, R1         ; R9 is the Value being converted 
        DIV R1, R2         ; Get next division factor

        CMP R1, 0          ; End loop if 0
        JZ end_hex_to_dec

        MOV R3, R9         ; Get digit
        DIV R3, R1

        SHL R8, 4          ; Shift left for new digit
        OR R8, R3          ; Writes the result

        JMP loop_converter

    end_hex_to_dec:
    POP R9
    POP R3
    POP R2
    POP R1
    RET

; ***************************************************************************
; * RNG RANGE -> Generates random value between 0 and N-1 (R9 = N)
; * Arguments:
; *     R9 -> Range (N)
; * _________________________________________________________________________
; * Returns:
; *     R10 -> Pseudo-Random Number from (0 ; [R9]-1)
; * _________________________________________________________________________
; ***************************************************************************
rng_range:
    MOV R10, [PIN_IN]      ; Read bits from "air" (PIN)
    MOD R10, R9            ; Mod by the argument passed by R9
    RET

; ***************************************************************************
; * EXCEPTION ROUTINES
; * _________________________________________________________________________
; ***************************************************************************
asteroids_exception:
    PUSH R0

    MOV R0, 1
    MOV [ASTEROIDS_UPDATE_FLAG], R0 ; Activate flag (flag=1)

    POP R0
    RFE

probes_exception:
    PUSH R0

    MOV R0, 1
    MOV [PROBES_UPDATE_FLAG], R0    ; Activate flag (flag=1)

    POP R0
    RFE

energy_exception:
    PUSH R0

    MOV R0, 1
    MOV [ENERGY_UPDATE_FLAG], R0    ; Activate flag (flag=1)

    POP R0
    RFE

navpanel_exception:
    PUSH R0

    MOV R0, 1
    MOV [NAVPANEL_UPDATE_FLAG], R0  ; Activate flag (flag=1)

    POP R0
    RFE