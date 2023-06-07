

rot_reset_game:

    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R8


    MOV R0, [ASTEROIDS]

    MOV R3, ASTEROIDS
    ADD R3, 2

    reset_asteroids:
        CMP R0, 0
        JNZ reset_rest

        MOV R2, -1
        MOV [R3 + 8], R2

        MOV R2, 12
        ADD R3, R2

        SUB R0, 1
        JMP reset_asteroids


    reset_rest:


    MOV R2, 100
    MOV [CURRENT_ENERGY], R2

    MOV R0, 0
    MOV [SET_BACKGROUND], R0


    ;update flags
    MOV R0, 0
    MOV [ASTEROIDS_UPDATE_FLAG], R0

    MOV R0, 0
    MOV [PROBES_UPDATE_FLAG], R0

    MOV R0, 0
    MOV[ENERGY_UPDATE_FLAG], R0

    MOV R0, 0
    MOV [NAVPANEL_UPDATE_FLAG], R0



    ret_reset_game:
        POP R8
        POP R3
        POP R2
        POP R1
        POP R0
        RET