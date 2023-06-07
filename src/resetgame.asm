

rot_reset_game:

    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5

    MOV [CLEAR_SCREEN], R0

    MOV R0, [ASTEROIDS]

    MOV R3, ASTEROIDS
    ADD R3, 2

    reset_asteroids:
        CMP R0, 0
        JZ reset_probes

        MOV R2, -1
        MOV [R3 + 8], R2

        MOV R2, 12
        ADD R3, R2

        SUB R0, 1
        JMP reset_asteroids


    reset_probes:

        ;probes
        MOV R0, [PROBES]

        MOV R3, PROBES
        ADD R3, 2

        probes:
            CMP R0, 0
            JZ reset_rest

            MOV R2, -1
            MOV [R3 + 8], R2

            MOV R4, [R3 + 12]
            MOV [R3], R4

            MOV R5, [R3 + 14]
            MOV [R3 + 2], R5

            MOV R2, 16
            ADD R3, R2 

            SUB R0, 1
            JMP probes

    ;spaceship
    MOV R3, LAYER_SPACESHIP
    MOV [SET_LAYER], R3 
    MOV R2, SPACESHIP
    CALL draw_entity

    reset_rest:

    MOV R2, 100
    MOV [CURRENT_ENERGY], R2

    MOV R0, 0
    MOV [PLAY_VIDEO_LOOP], R0

    MOV R2, 100H
    MOV [ENERGY_DISPLAYS], R2

    ;update flags
    MOV R0, 0
    MOV [ASTEROIDS_UPDATE_FLAG], R0

    MOV [PROBES_UPDATE_FLAG], R0

    MOV[ENERGY_UPDATE_FLAG], R0

    MOV [NAVPANEL_UPDATE_FLAG], R0



    ret_reset_game:
        POP R5
        POP R4        
        POP R3
        POP R2
        POP R1
        POP R0
        RET