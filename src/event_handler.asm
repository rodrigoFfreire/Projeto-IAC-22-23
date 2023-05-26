KEY_INCREMENT      EQU 6                       ; Increment Energy Display 
KEY_DECREMENT      EQU 4                       ; Decrement Energy Display
KEY_MOVE_PROBE     EQU 1                       ; Move probe up
KEY_MOVE_ASTEROID  EQU 5 



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
    MOV R2, ASTEROID
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