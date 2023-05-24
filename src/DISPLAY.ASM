; Ignorar isto apenas para testing purposes
DISPLAYS   EQU 0A000H  ; endere?o dos displays de 7 segmentos (perif?rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere?o das linhas do teclado (perif?rico POUT-2)
TEC_COL    EQU 0E000H  ; endere?o das colunas do teclado (perif?rico PIN)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 4		; tecla na primeira coluna do teclado (tecla 4)
TECLA_DIREITA			EQU 6		; tecla na segunda coluna do teclado (tecla 6)

;energy display
SET_ENERGY EQU 0A000H ;address of energy display (POUT-1)
MAX_ENERGY EQU 064H
MIN_ENERGY EQU 0H

	PLACE       1000H
pilha:
	STACK 100H			; espa?o reservado para a pilha 
						; (200H bytes, pois s?o 100H words)
SP_inicial:				; este ? o endere?o (1200H) com que o SP deve ser 
						; inicializado. O 1.? end. de retorno ser? 
						; armazenado em 11FEH (1200H-2)
LAST_PRESSED_KEY:
    WORD -1 ; Start with default value   

; Used together with LAST_KEY_PRESSED to determine when to execute a command
; 0 -> dont execute; 1 -> execute; -1 -> dont execute [key was not released]
EXECUTE_COMMAND:
    WORD 0
	
CURRENT_ENERGY:
  WORD 100 ;starting value  (105 because exception will decrease it in beggining)

;FLAGS
ENERGY_FLAG:
  WORD 0 ;by default flag is 0 (no energy update)



    PLACE      0
init:
    MOV  SP, SP_inicial
	;set energy flag as 0
	MOV R5, 0
	MOV [ENERGY_FLAG], R5

    MOV  R2, TEC_LIN   ; endere?o do perif?rico das linhas
    MOV  R3, TEC_COL   ; endere?o do perif?rico das colunas
    MOV  R6, DISPLAYS
    MOV  R4, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R1, 0
    MOV  R0, -1
    MOV  [EXECUTE_COMMAND], R1
    MOV  [LAST_PRESSED_KEY], R0

loop:
    CALL keyboard_listner
    NOP
    NOP
    NOP
    MOV R10, [LAST_PRESSED_KEY]
    MOVB [R6], R10
    NOP
	CALL energy_update
	CALL espera_nao_tecla
	CALL espera_tecla
    NOP
    NOP
    JMP loop


;**********
; Rotina de controlo do input (Teclado)
; Registos Usados (Argumentos):
;   - R0 (valor da coluna)
;   - R1 (valor da linha, linha a testar, tecla convertida)
;   - R2 (Endereco Teclado linha, linha convertida)
;   - R3 (Endereco Teclado Coluna, coluna convertida)
;   - R4 (Mascara)
;**********
;Copiar para o ficheiro final a partir daqui:
keyboard_listner:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    MOV  R2, TEC_LIN
    MOV  R3, TEC_COL
    MOV  R4, 0FH

    MOV  R1, 0001b         ; Testar Linha 1
    CALL test_line
    JNZ  press
    MOV  R1, 0010b         ; Testar Linha 2
    CALL test_line
    JNZ  press
    MOV  R1, 0100b         ; Testar Linha 3
    CALL test_line
    JNZ  press
    MOV  R1, 1000b         ; Testar Linha 4
    CALL test_line
    JNZ  press
    MOV R1, 0
    MOV [EXECUTE_COMMAND], R1
    end_keyboard_listner:
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET

test_line:
    MOVB [R2], R1
    MOVB R0, [R3]   
    AND R0, R4      ; Mask low bits
    CMP R0, 0
    RET

press:
    CALL convert
    SHL R1, 2
    ADD R1, R0      ; conversao final
    MOV R0, [EXECUTE_COMMAND]
    CMP R0, 0 
    JZ press_update
    MOV R1, -1
    MOV [EXECUTE_COMMAND], R1
    JMP end_keyboard_listner
    press_update:
        MOV [LAST_PRESSED_KEY], R1
        MOV R1, 1
        MOV [EXECUTE_COMMAND], R1
        JMP end_keyboard_listner

convert:
    PUSH R2
    PUSH R3
    MOV R2, 0
    MOV R3, 0
    compare:                ; Verificar apos SHR se o numero = 0001b
        CMP R0, 1
        JNZ convert_aux_col
        CMP R1, 1
        JNZ convert_aux_lin
    MOV R0, R2
    MOV R1, R3
    POP R3
    POP R2
    RET

convert_aux_lin:
    SHR R1, 1
    ADD R3, 1
    JMP compare

convert_aux_col:
    SHR R0, 1
    ADD R2, 1
    JMP compare
	
;**********
; Rotina de controlo do OUTPUT (DISPLAY)
;**********
;Copiar para o ficheiro final a partir daqui:
espera_nao_tecla:			; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	CALL keyboard_listner	; leitura às teclas
	CMP [EXECUTE_COMMAND], 0;
	JZ	espera_nao_tecla	; espera, enquanto houver tecla uma tecla carregada
	
espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	CALL	teclado			; leitura às teclas
	CMP	[EXECUTE_COMMAND], 0
	JZ	espera_tecla		; espera, enquanto não houver tecla
	
	CMP	[LAST_PRESSED_KEY], 6
	JNZ	testa_DECREMENTO
	JMP testa_INCREMENTO
	
testa_INCREMENTO:
  PUSH R5
  PUSH R7
  PUSH R8
  PUSH R10

  MOV R10, [CURRENT_ENERGY] ;get current energy
  
  ;if current energy is 100 skip it
  MOV R7, MAX_ENERGY
  CMP R10, R7
  JZ return_energy_encrease

  ;otherwise
  ADD R10, 1

  ;save new energy
  MOV [CURRENT_ENERGY], R10

  ;set new energy on display
  MOV R5, SET_ENERGY
  MOV [R5], R8

  return_energy_encrease:
    POP R10
    POP R8
    POP R7
    POP R5
    RET
	
testa_DECREMENTO:
  PUSH R5
  PUSH R7
  PUSH R8
  PUSH R10

  MOV R10, [CURRENT_ENERGY] ;get current energy
  
  ;if current energy is 0 skip it
  MOV R7, MIN_ENERGY
  CMP R10, R7
  JZ return_energy_decrease

  ;otherwise
  SUB R10, 1

  ;save new energy
  MOV [CURRENT_ENERGY], R10

  ;set new energy on display
  MOV R5, SET_ENERGY
  MOV [R5], R8

  ;check game over
  CMP R8, 0
  JNZ return_energy_decrease
  
  return_energy_decrease:
    POP R10
    POP R8
    POP R7
    POP R2
    RET

energy_update:
  PUSH R0

  MOV R0, [ENERGY_FLAG] ;get energy flag

  ;if flag is off skip update
  CMP R0, 0
  JZ return_energy_update

  ;otherwise handle the update
  CALL energy_decrease
  MOV R0, 0
  MOV [ENERGY_FLAG], R0 ;set energy flag to 0

  return_energy_update:
    POP R0
    RET
