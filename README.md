# Projeto IAC 22/23
![](banner.png)


# Indice
1. [TODO](#TODO)
2. [Documentação Rotinas](#Documentação-Rotinas)

<br/><br/>

## TODO (Lista de coisas para fazer)
- [X] Temporizações (Interrupções)    (Rodas)
  - EI0 -> Update movimento asteroids
  - EI1 -> Update movimento sondas
  - EI2 -> Descrescimo da energia
  - EI3 -> Update animação do painel

- [ ] Menu Inicial  (David)
- [ ] Rotinas de Atualizacao (asteroids, sondas, energia, painel) (Rodas)
- [ ] Refazer texturas + Animações(painel, asteroides)  (Aleixo)
  - Animação do painel
  - Animação asteroide a explodir
  - Animação asteroide amigavel
- [ ] Criar tabela de objetos (3 sondas, 4 asteroides)  (Aleixo)
- [ ] Random Number Generator   (Rodas)
- [ ] Sonda desaparece apos 12 movimentos
- [ ] Colisões
- [ ] Atualizacao da energia + converter hexa para decimal
- [ ] Menus + Sons + backgrounds (Verificar condicoes: sem energia, colisao com a nave, terminar pela tecla, pausa)
  
- [ ] Controlo (para tratar das teclas de começar, suspender/continuar e terminar o jogo).
- [ ] Nave (para desenhar o painel de instrumentos e produzir o efeito das luzes);
- [ ] Energia da nave (para implementar o gasto periódico de energia);
- [ ] Sonda (para controlar o lançamento, implementar o movimento, o limite do alcance e a deteção 
 de colisão de cada sonda);
- [ ] Asteroide (para controlar as ações e evolução de cada um dos asteroides, incluindo verificação 
de colisão com a nave).


<br/><br/>

## Documentação Rotinas
Encontra-se aqui em baixo informações sobre as rotinas principais do jogo como registos de argumentos, memoria acedida etc...

### **LISTEN_KEYBOARD**
Testa todas as linhas do teclado até encontrar uma tecla premida
- **Argumentos**
  - Nenhum
- **Memoria Acedida/Escrita**
  - Escreve em ```LAST_PRESSED_KEY``` o número da ultima tecla premida (0-F)
  - Lê/Escreve em ```EXECUTE_COMMAND``` -1 / 0 / 1 para indicar se um comando deve ser executado ou não (previne spam do teclado ao não largar a tecla)

**Como usar para detetar uma tecla para ativar uma funcionalidade?**
Ex: Fazer algo acontecer se a Tecla 5 for premida
```asm
  rotina_exemplo:
      MOV RX, [LAST_PRESSED_KEY]
      CMP RX, 5                   ; Tecla desejada
      JNZ return_rotina_exemplo   ; Salta para o final
      
      CMP RX, [EXECUTE_COMMAND]
      CMP RX, 1                   ; EXECUTE_COMMAND em modo ativo
      JNZ return_rotina_exemplo   ; Salta para o final
      
      ; Resto da rotina. (Codigo vai para aqui apenas se os dois CMP de cima derem certo)
      
      return_rotina_exemplo:      ; Final da rotina 
          RET
 ```

<br/><br/>

### **DRAW_ENTITY**
Desenha qualquer entidade guardada na memória
- **Argumentos**
  - R2 <- Endereço da entidade
- **Memoria Acedida/Escrita**
  - Desenha no ecrã o sprite da entidade
  - Lê da memória uma entidade guardada da seguinte forma ```WORD: pos_x, pos_y, state, sprite```

**Como usar para desenhar uma entidade?**
Ex: Desenhar a entidade ```SPACE_SHIP```
```asm
  PLACE 1000H
  ; ...
  
  SPACE_SHIP:
    WORD 27, 27, 1, SPRITE_SPACESHIP; (pos_x, pos_y, state, sprite)
    
  SPRITE_SPACESHIP:
    WORD  11; length
    WORD  5; height
    ; Pixel Matrix
    WORD  0, 0, BROWN, BROWN, BROWN, BROWN, BROWN, BROWN, BROWN, 0, 0
    WORD  0, BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN, 0
    WORD  BROWN, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, BROWN 
    WORD  BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN 
    WORD  BROWN, YELLOW, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, CYAN, YELLOW, BROWN
    
  PLACE 0
  ; ...
  MOV R2, SPACE_SHIP
  CALL draw_entity
 ```

### **RND_GENERATOR**
Gera um número aleatório numa range N especificada [0;N] (N <= 15)
- **Argumentos**
  - R10 <- Range
- **Retorna**
  - R9 -> Numero aleatorio entre [0;N]

**Como usar?**
Ex: Obter número aleatorio de 0 a 5, se for 3 chama uma rotina X
```asm
rotina_exemplo:
  PUSH R9
  PUSH R10

  MOV R10, 5 ; para obter um numero entre 0 e 5
  CALL rnd_generator
  
  CMP R9, 3
  JNZ end

  CALL rotina_x

  end:
    POP R10
    POP R9
    RET
```