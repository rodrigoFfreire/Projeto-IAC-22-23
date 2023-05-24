;DADOS
CURRENT_ENERGY:
  WORD 100 ;starting value  (105 because exception will decrease it in beggining)

;FLAGS
ENERGY_FLAG:
  WORD 0 ;by default flag is 0 (no energy update)


energy_increase:
  PUSH R2
  PUSH R7
  PUSH R8
  PUSH R10

  MOV R10, [CURRENT_ENERGY] ;get current energy
  
  ;if current energy is 100 skip it
  MOV R7, MAX_ENERGY
  CMP R10, R7
  JZ return_energy_encrease

  ;otherwise
  ADD R10, 5
  CALL hexa_to_decimal

  ;save new energy
  MOV [CURRENT_ENERGY], R10

  ;set new energy on display
  MOV R2, SET_ENERGY
  MOV [R2], R8

  return_energy_encrease:
    POP R10
    POP R8
    POP R7
    POP R2
    RET