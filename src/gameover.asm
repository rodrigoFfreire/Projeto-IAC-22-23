
STOP_AUDIO EQU MEDIA_COMMAND + 66H

rot_game_over:
    PUSH R0
    PUSH R1
    PUSH R2

    ;confirma se a flag do game over é 1
    MOV R0, [GAME_OVER_FLAG]
    CMP R0, 1
    JNZ ret_game_over

    MOV R2, 5
    MOV[PLAY_AUDIO], R2

    MOV [CLEAR_SCREEN], R0
    MOV [SET_BACKGROUND], R9


    ;espera até se clicar na tecla para voltar a jogar
    loop_game_over:
        CALL keyboard_listner
        MOV R0, [LAST_PRESSED_KEY]
        MOV R1, KEY_START_GAME
        CMP R0, R1
        JNZ loop_game_over

    ;pausa o audio
    MOV R0, 1
    MOV [STOP_AUDIO], R0

    ;retoma o background inicial
    MOV R0, 0
    MOV [SET_BACKGROUND], R0

    ;flag do game over a 0
    MOV R0, 0
    MOV [GAME_OVER_FLAG], R0

    CALL rot_reset_game

    ret_game_over:
        POP R2
        POP R1
        POP R0
        RET

