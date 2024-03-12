org  0x8000
bits 16

jmp startProgram

; Variables ------------------------------------------------------------------------------------------------

time           db 00h   ; Tiempo que representa los fps del programa
level          dw 01h   ; Nivel del juego                                                                      ELIMINAR
lastColor      dw 00h   ; Color de la casilla en donde se encuentra
paintMode      dw 00h   ; Flag para indicar si el jugador está en modo de pintura
eraseMode      dw 00h   ; Flag para indicar si el jugador está en modo de borrador
secondsLeft    dw 60    ; Inicializar con el número de segundos deseados (1 minuto)
secondsunit    dw 48    ; Inicializar con las unidades  deseados (1 minuto)
secondsdecs    dw 54    ; Inicializar con las decenas  deseados (1 minuto)
currentColor   dw 0Ah   ; Color actual (por defecto, verde)
timerSeconds   dw 0     ; Contabiliza los ticks
clockSeconds   dw 0
difSeconds     dw 0

; Constantes -----------------------------------------------------------------------------------------------

width          dw 140h  ; El tamano del ancho de la pantalla 320 pixeles
height         dw 0c8H  ; El tamano del alto de la pantalla 200 pixeles
red_color      dw 90h   ; Establece el color del movimiento (NO, SE)
blue_color     dw 70h   ; Establece el color del movimiento (NE, SO)
yellow_color   dw 40h   ; Establece el color del movimiento (left, right)
purple_color   dw 50h   ; EEstablece el color del movimiento (up, down)

gameHeight     dw 46h   ; Define el tamano del alto area de juego 100 pixeles
gameWidth      dw 12ah  ; Define el tamano del ancho area de juego 150 pixeles
timerPosX      dw 19h   ; Posición X para decenas del temporizador
timerPosX2     dw 1ah   ; Posición X para unidades del temporizador
timerPosY      dw 15h   ; Posición Y para el temporizador



gamePaused     dw 00h   ; Flag to know if the game is paused. 0 not paused. 1 paused                              ELIMINAR

textColor      dw 150h  ; Color del texto para los menus
player_x       dw 03h   ; Posicion en x del jugador
player_y       dw 0ah   ; Posicion en y del jugador 
temp_player_x  dw 03h   ; Posicion temporal en x del jugador
temp_player_y  dw 0ah   ; Posicion temporal en y del jugador
color_player_x dw 03h   ; Posicion casilla en x del jugador (para pintar)
color_player_y dw 0ah   ; Posicion casilla en y del jugador (para pintar)
player_speed   dw 06h   ; Velocidad de movimiento del jugador
player_color   dw 0ah   ; Color por defecto del jugador (tortuga)
player_size    dw 05h   ; DImensiones del sprite de la tortuga (5x5)
player_dir     dw 00h   ; Ultima direccion que tuvo el jugador



tortugaSprite  db 0b00100, 0b11111, 0b01110, 0b11111, 0b00000                                                      ; NO HACE NADA


; Texto del menu principal del juego ---------------------------------------------------------------------------

menu1    dw '           ----------------         ', 0h
menu2    dw '           - MICRO-MUNDOS -         ', 0h
menu3    dw '           -  BIENVENIDO  -         ', 0h
menu4    dw '           ----------------         ', 0h
menu5    dw '   Presione ENTER para continuar    ', 0h

winner1  dw '          ---------------           ', 0h
winner2  dw '          - FELICIDADES -           ', 0h
winner3  dw '          -   GANASTE   -           ', 0h
winner4  dw '          ---------------           ', 0h
winner5  dw '   Presione ENTER para repetir    ', 0h

loser1   dw '          ---------------           ', 0h
loser2   dw '          -   PERDISTE  -           ', 0h
loser3   dw '          -             -           ', 0h
loser4   dw '          ---------------           ', 0h
loser5   dw '   Presione ENTER para repetir    ', 0h


timeText  dw '  Tiempo restante ->    ', 0h
timeValue dw '  ', 0h
timeUnits dw ' s  ', 0h

; Menu de controles In-Game --------------------------------------------------------------------------------------

inGame1  dw '-------------------------------------', 0h
inGame2  dw '- Lvl.1      Controles              -', 0h
inGame3  dw '- Mover-> Flechas y Q,E,A,D         -', 0h
inGame4  dw '- Reset-> R | Terminar -> ESC       -', 0h
inGame5  dw '- Pintar-> ESPACIO | Borrar -> Z    -', 0h
inGame6  dw '- Habilidad.:', 0h
inGame7  dw 'Pintando       -', 0h
inGame8  dw 'Borrando       -', 0h
inGame9  dw 'Sin accion     -', 0h
inGame10 dw '-------------------------------------', 0h


; Logica del juego  ****************************************************************************************************


startProgram:
    call initDisplay                ; Llama al inicializador de la pantalla

    call clearScreen                ; Llama al limpiador de pantalla

    jmp  menuLoop                   ; Salta al bucle del menu principal

startGame:                          
    call    setRandomSpawn          ; Establece el nivel 1 (deberia hacer que respawnee random)                                                 ELIMINAR

    call    clearScreen             ; Llama al limpiador de pantalla

    ;call    initTimer               ; Llama al iniciador del timer 

    call    drawInGameText          ; Dibuja el menu de controles dentro del juego

    jmp     gameLoop                ; Salta al bucle de juego principal


initDisplay:                        
    mov ah, 00h                     ; Establece el modo de video 
    mov al, 13h                     ; llamando a la interrupcion 
    int 10h                         ; 10h con el codigo 13h de video VGA
    ret

menuLoop:                           

    call    checkPlayerMenuAction   ; Revisa si el usuario presiono ENTER para empezar el juego

    call    drawTextMenu            ; Dibuja el menu principal en pantalla

    jmp     menuLoop                ; Se llama asi misma hasta que se detecte el ENTER

winnerLoop: 

    call    checkPlayerMenuAction   ; Verifica si el jugador presiono el ENTER para jugar de nuevo
    
    call    drawWinnerMenu          ; Dibuja el menu de ganador de la partida

    jmp     winnerLoop              ; Se llama asi misma hasta que se detecte el ENTER

loserLoop: 

    call    checkPlayerMenuAction   ; Verifica si el jugador presiono el ENTER para jugar de nuevo
    
    call    drawLoserMenu          ; Dibuja el menu de ganador de la partida

    jmp     loserLoop              ; Se llama asi misma hasta que se detecte el ENTER

gameLoop:                           

    call    drawInGameText          ; Dibuja el menu de controles dentro del juego principal

    ;call    timerLoop               ; Verifica el estado del temporizador

    call    drawInGameTime

    call    checkPlayerGameInput    ; Revisa contanstemente las teclas para detectar cualquier movimiento del jugador en juego 

    call    renderPlayer            ; Permite dibujar al jugador en la posicion donde se encuentre

    jmp     gameLoop                ; Se llama asi misma hasta que ocurra alguna accion por parte del usuario


initTimer:

    xor dx,dx
    mov ah, 00h        ; Función para obtener la hora del sistema
    int 0x1A

    mov  [timerSeconds], dx   ; Cl contiene los segundos 

    xor dx,dx

    ret

timerLoop:
    xor dx,dx
    mov ah, 00h        ; Función para obtener la hora del sistema
    int 0x1A

    mov [clockSeconds], dx          ; Movemos los segundos (DH) a AL 

    
    mov word [difSeconds], clockSeconds


    mov eax, [difSeconds]     
    sub eax, [timerSeconds]   

    ; Comparamos el resultado de la resta con 1
    cmp eax, 18
    jg delayLoop        ; Si la resta es mayor que 1, salta a delayLoop
    
    xor dx,dx

    ret

delayLoop:

    mov  word [timerSeconds], clockSeconds

    dec  word [secondsLeft]       ; Resta un segundo al temporizador  


    cmp  word [secondsunit], 48 
    je   delayLoopAux


    dec  word [secondsunit]

    cmp word [secondsLeft], 0
    je lose

    ret

delayLoopAux:

    mov  word [secondsunit], 57
    dec word [secondsdecs]

    ret


; Funciones de renderizado del jugador y pintado ------------------------------------------------------------------------------*

clearScreen:

    mov     cx, 00h                 ; Establece la posicion inicial x de la pantalla
    mov     dx, 00h                 ; Establece la posicion inicial y de la pantalla
    jmp     clearScreenAux          


clearScreenAux:
    mov     ah, 0ch                 
    mov     al, 00h                 
    mov     bh, 00h
    int     10h                     ; Llama a la interrupcion para que se pinte de negro el fondo
    inc     cx                      ; Va incrementando el valor en la horizontal de la pantalla
    cmp     cx, [width]             ; Compara si ya se llego al ancho maximo sino sigue hasta pintar todo
    jng     clearScreenAux          
    jmp     clearScreenAux2         


clearScreenAux2:                  
    mov     cx, 00h                 ; Reinicia la posicion en x
    inc     dx                      ; Incrementa en 1 la y para escribir en la siguiente linea
    cmp     dx, [height]            ; Compara si ya se llego a la altura maxima sino sigue hasta pintar todo
    jng     clearScreenAux          
    ret                             


checkPlayerMenuAction:             
    mov     ah, 01h                
    int     16h                     ; Llama a la interrupcion que detecta movimiento en el teclado
    jz      exitRoutine             ; Si no se presiona nada se retorna al bucle del juego principal
    mov     ah, 00h                 
    int     16h                     ; Llama a la interrupcion de movimiento en el teclado nuevamente
    cmp     al, 0Dh                 ; Verifica si la tecla presionada es ENTER
    je      startGame               ; Si es asi entonces inicia el juego

    ret                             ; Si ningun escenario pasa, devuelve al bucle prinicipal


drawTextMenu:                       
    mov     bx, [textColor]         ; Establece el color del texto para pintar el Menu Principal

    mov     bx, menu1               ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada x en pixeles donde se escribira
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, menu2           
    inc     dh                      ; Se aumenta el valor de y para seguir pintando los demas textos en la linea siguiente.
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu3            
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu4           
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu5           
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret

drawInGameTime:

    mov     bx, [textColor]         ; Establece el color del texto para pintar el texto In Game

    mov     bx, timeText            ; Selecciona el texto que quiere escribir
    mov     dh, 15h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 04h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, timeUnits           ; Selecciona el texto que quiere escribir
    mov     dh, 15h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 1dh                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, secondsdecs        ; Obtiene el valor actual del contador
    mov     dh, [timerPosY]         ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, [timerPosX]         ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText
    
    mov     bx, secondsunit         ; Obtiene el valor actual del contador
    mov     dh, [timerPosY]         ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, [timerPosX2]         ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText 

    ret


drawInGameText:
    mov     bx, [textColor]         ; Establece el color del texto para pintar el texto In Game

    mov     bx, inGame1             ; Selecciona el texto que quiere escribir
    mov     dh, 0ch                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, inGame2             ; Texto que indica el nivel y el titulo de controles   
    inc     dh            
    mov     dl, 02h               
    call    drawText   

    mov     bx, inGame3             ; Indica los controles de movimiento del juego      
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame4             ; Indica los controles para reiniciar y volver a menu principal
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame5             ; Indica los controles para activar las diferentes habilidades (pintar, borrar)
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame6             ; Indica en tiempo real cual habilidad esta activada
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame10             ; Decoracion para cerrar la caja de controles
    mov     dh, 12h          
    mov     dl, 02h               
    call    drawText

    ;Verifica la habilidad que esta en ejecucion para indicarla en pantalla

    mov     bx, [paintMode]          ; Revisa si esta en modo pintando
    cmp     bx, 1
    je      drawInGameTextAux

    mov     bx, [eraseMode]          ; Revisa si esta en modo pintando
    cmp     bx, 1
    je      drawInGameTextAux2
    
    jmp     drawInGameTextAux3       ; Ejecuta el modo sin habilidad en caso de no estar en ninguna de las mencionadas


    ret


drawInGameTextAux:

    mov     bx, inGame7              ; Dibuja el texto en pantalla indicando que esta pintando     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux2:

    mov     bx, inGame8              ; Dibuja el texto en pantalla indicando que esta borrando   
    mov     dl, 17h
    mov     dh, 11h              
    call    drawText
    ret

drawInGameTextAux3:

    mov     bx, inGame9              ; Dibuja el texto en pantalla indicando que esta sin habilidades        
    mov     dl, 17h
    mov     dh, 11h              
    call    drawText
    ret


drawWinnerMenu:                     ; Se encarga de dibujar el menu cuando el jugador gano la partida

    mov     bx, [textColor]         ; Se establece el color del texto 
    inc     bx                      ; Incrementa el color en 1 para que de un efecto de arcoiris y que la animacion sea cambiar de color
    mov     [textColor], bx         ; Guarda el nuevo color

    mov     bx, winner1             ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira 
    call    drawText                ; Llama a la funcion que lo coloca en pantalla


    mov     bx, winner2             ; Cambia a la siguiente linea de texto
    inc     dh                      ; Incrementa el valor de y para dibujar la nueva linea justo debajo de la otra
    mov     dl, 02h                 
    call    drawText                

    mov     bx, winner3          
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, winner4         
    inc     dh                                        
    mov     dl, 02h                 
    call    drawText                

    mov     bx, winner5         
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret

drawLoserMenu:                      ; Se encarga de dibujar el menu cuando el jugador gano la partida

    mov     bx, [textColor]         ; Se establece el color del texto 
    inc     bx                      ; Incrementa el color en 1 para que de un efecto de arcoiris y que la animacion sea cambiar de color
    mov     [textColor], bx         ; Guarda el nuevo color

    mov     bx, loser1             ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira 
    call    drawText                ; Llama a la funcion que lo coloca en pantalla


    mov     bx, loser2             ; Cambia a la siguiente linea de texto
    inc     dh                      ; Incrementa el valor de y para dibujar la nueva linea justo debajo de la otra
    mov     dl, 02h                 
    call    drawText                

    mov     bx, loser3          
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, loser4         
    inc     dh                                       
    mov     dl, 02h                 
    call    drawText                

    mov     bx, loser5         
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret

drawText:                           ; Esta funcion se encarga de dibujar texto en pantalla

    cmp     byte [bx],0             ; Verifica si el texto ya se termino de dibujar en pantalla
    jz      finishDraw              ; Vuelve al bucle principal si ya termino
    jmp     drawChar                ; Sino sigue al siguiente caracter


drawChar:                           ; Permite dibujar un caracter en pantalla

    push    bx                      ; Agrega el valor del caracter a la pila de dibujo
    mov     ah, 02h                 ; Indica que se va a pintar un caracter en pantalla
    mov     bh, 00h                 ; Indica que el caracter se va a pintar en la pantalla actual
    int     10h                     ; Llama a la interrupcion de pintar en pantalla
    pop     bx                      ; Saca al caracter de la pila

    push    bx                      
    mov     al, [bx]                ; Guarda el caracter actual que se va a pintar
    mov     ah, 0ah                 ; Se mueve 10 unidades 
    mov     bh, 00h                 
    mov     bl, [textColor]         ; Establece el color que va a tener el caracter que se dibujara
    mov     cx, 01h                 ; Indica que solo un caracter va a ser dibujado
    int     10h                     ; Llama a la interrupcion de dibujo en pantalla
    pop     bx                      

    inc     bx                      ; Incrementa en 1 para leer el siguiente caracter
    inc     dl                      
    jmp     drawText                ; Devuelve al ciclo de dibujado principal



finishDraw:                         ; Permite volver al ciclo principal cuando el caracter ya se pinto
    ret                             


setRandomSpawn:      

    xor dx, dx
    mov ah, 0x00       ; Función para obtener los timer ticks del sistema
    int 0x1A           ; Llamar a la interrupción 0x1A para obtener los timer ticks

    ; Restar 1000000 a los ticks
    sub dx, 1000000

    ; Dividir el resultado entre 1000000
    mov ax, dx
    xor dx, dx
    mov cx, 10000      ; Divisor (1000000 / 100 = 10000)
    div cx             ; Divide dx:ax por cx
    mov dx, ax         ; El resultado de la división queda en dx (parte alta de la división)

    ; Multiplicar el resultado por 65
    mov ax, dx
    imul ax, 10        ; Multiplica ax por 65

    ; Asignar el valor normalizado para x y y
    mov [player_x], ax ; Asigna el valor normalizado a x
    mov [temp_player_x], ax ; Guarda la misma coordenada en el temp x

    xor ax, ax

    xor dx, dx
    mov ah, 0x00       ; Función para obtener los timer ticks del sistema
    int 0x1A           ; Llamar a la interrupción 0x1A para obtener los timer ticks

    ; Restar 1000000 a los ticks
    sub dx, 1000000

    ; Dividir el resultado entre 1000000
    mov ax, dx
    xor dx, dx
    mov cx, 10000      ; Divisor (1000000 / 100 = 10000)
    div cx             ; Divide dx:ax por cx
    mov dx, ax         ; El resultado de la división queda en dx (parte alta de la división)

    ; Multiplicar el resultado por 65
    mov ax, dx
    imul ax, 10        ; Multiplica ax por 65

    mov [player_y], ax ; Asigna el valor normalizado a y
    mov [temp_player_y], ax ; Guarda la misma coordenada en el temp y

    ret


renderPlayer:                        ; Permite dibujar al jugador en pantalla.
    mov     cx, [player_x]           ; Posicion x donde sera dibujado
    mov     dx, [player_y]           ; Posicion y donde sera dibujado
    jmp     renderPlayerAux           

renderPlayerAux:
    mov    ah, 0ch                   ; Indica que se va a dibujar un pixel en pantalla
    mov    al, [player_color]        ; Indica el color del pixel (color del jugador)
    mov    bh, 00h                   ; Indica en que pagina lo va a dibujar (predeterminada)
    int    10h                       ; Llama a la interrupcion para dibujar en pantalla
    inc    cx                        ; Incremente en 1 el cx
    mov    ax, cx                   
    sub    ax, [player_x]            ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando anchura)
    cmp    ax, [player_size]         ; Verifica si el ax es mas grande que el tamano del jugador
    jng    renderPlayerAux           ; Si aun no es mas grande sigue dibujando la siguiente columna
    jmp    renderPlayerAux2          ; Sino salta a la siguiente funcion de dibujo (dibujar altura del sprite)

renderPlayerAux2:
    mov     cx, [player_x]           ; Restablece el valor de las columnas
    inc     dx                       ; Aumenta en la fila
    mov     ax, dx                  
    sub     ax, [player_y]           ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando altura)
    cmp     ax, [player_size]        ; Verifica si el ax es mas grande que el tamano del jugador
    jng     renderPlayerAux          ; Si aun no es mas grande sigue dibujando la siguiente fila
    ret                              ; Sino vuelve al bucle principal


deletePlayer:                        ; Funcion que elimina al jugador de la pantalla


    mov     ax, [eraseMode]          ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                  ; Invierte el valor (0 a 1 o 1 a 0)
    je      deletePlayerAux2

    jmp      deletePlayerAux1
   
    ret                              ; Vuelve al bucle principal


deletePlayerAux1:                   ; Modo no borrador, pasa encima de una casilla pintada

    mov     al, [lastColor]         ; Establece el color que a casilla tenia antes de llegar ahi el jugador
    mov     [player_color], al      ; Actualiza el color del jugador con el de la casilla
    call    renderPlayer            ; Llama a renderizar al jugador con ese color, para dejar la casilla como estaba
    mov     al, 0ah                 ; Se devuelve al color original del jugador
    mov     [player_color], al      ; Lo actualiza en la variable
    ret                             ; Vuelve al ciclo principal

deletePlayerAux2:                   ; Modo borrador

    mov     al, 00h                 ; Guarda el color del fondo (negro)
    mov     [player_color], al      ; Establece el color negro como el del jugador
    call    renderPlayer            ; Dibuja la casilla del color del fondo
    mov     al, 0ah                 ; SSe devuelve al color original del jugador
    mov     [player_color], al      ; Lo actualiza en la variable

    ret                             ; Vuelve al ciclo principal


checkPlayerGameInput:               ; Verifica cualquier accion del jugador

    mov     ax, 00h                 ; Restablece el valor del registro en 0
    cmp     ax, [gamePaused]        ; Si el juego no esta pausado revisa los movimientos
    je      makeMovements           ; Salta al chequeador de movimientos

makeMovements:                      ; Funcion que se encarga de ejecutar acciones segun el movimiento que se detecte

    mov     ah, 01h                 ; Indica que se va a leer una entrada de teclado
    int     16h                     ; Ejecuta la interrupcion de teclado

    jz      exitRoutine             ; Si no se detecta ninguna tecla vuelve al bucle principal

    mov     ah, 00h                 ; Detecta que se presiono una tecla
    int     16h                     ; Ejecuta la interrupcion para saber el valor de la tecla presionada

    cmp     ah, 48h                 ; Si la tecla es : Flecha arriba
    je      playerUp                ; Mueve al jugador hacia arriba

    
    cmp     ah, 50h                 ; Si la tecla es : Flecha abajo
    je      playerDown              ; Mueve al jugador hacia abajo

    cmp     ah, 4dh                 ; Si la tecla es : Flecha derecha
    je      playerRight             ; Mueve al jugador hacia derecha

    cmp     ah, 4bh                 ; Si la tecla es : Flecha izquierda
    je      playerLeft              ; Mueve al jugador hacia izquierda

    cmp     al, 'q'                 ; Si la tecla es : q
    je      playerSE                ; Mueve al jugador hacia el Sur-Este

    cmp     al, 'a'                 ; Si la tecla es : a
    je      playerNE                ; Mueve al jugador hacia el Nor-Este

    cmp     al, 'e'                 ; Si la tecla es : e
    je      playerSO                ; Mueve al jugador hacia el Sur-Oeste

    cmp     al, 'd'                 ; Si la tecla es : d
    je      playerNO                ; Mueve al jugador hacia el Nor-Oeste

    cmp     al, 'z'                 ; Si la tecla es :z
    je      toggleEraseMode         ; Activa/Desactiva el modo de borrado

    cmp     al, 20h                 ; Si la tecla es : Space
    je      togglePaintMode         ; Activa/Desactiva el modo de pintado

    cmp     ah, 13h                 ; Si la tecla es : r
    je      resetGame               ; Reinicia el juego

    cmp     al, 1Bh                 ; Si la tecla es : esc
    je      startProgram            ; EL juego termina y vuelve al menu principa


    ret

playerUp:                           ; Mueve al jugador hacia arriba

    mov     al, [purple_color]      ; Guarda el color del cual se debe pintar el movimiento
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax


    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento                                                         MODIFICAR (REVISA SI GANA)

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)


playerNO:                           ; Mueve al jugador hacia  Nor-Oeste

    mov     al, [red_color]         ; Guarda el color del cual se debe pintar el movimiento     
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve


    xor     ax,ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento   

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y



    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo izquierda
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

   
    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)


    
playerDown:                         ; Mueve al jugador hacia abajo

    mov     al, [purple_color]      ; Guarda el color del cual se debe pintar el movimiento  
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax



    mov     ax, [gameHeight]        ; Mueve la altura del juego a ax
    add     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jge      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo abajo
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal 


    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento  

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)



playerSE:                           ; Mueve al jugador hacia  Sur-Este

    mov     al, [red_color]         ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual
    xor     al, al
    mov     ax, [player_x]          
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y]          ;
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo abajo
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal  
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo derecha
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal  

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)

playerRight:                        ; Mueve al jugador hacia la derecha

    mov     al, [yellow_color]      ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x]          
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax


    mov     ax, [gameWidth]         ; Mueve el valor del ancho a ax
    add     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_x], ax          ; Compara si la posicion x esta por tocar un borde con el movimiento
    jge      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo derecha
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal


    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento   

    mov     [player_x], ax          ; Actualiza la posicion del jugador en y

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)



playerSO:                           ; Mueve al jugador hacia el Sur-Oeste

    mov     al, [blue_color]        ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax


    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal  
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo izquierda
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal  

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)


playerLeft:                         ; Mueve al jugador hacia la izquierda

    mov     al, [yellow_color]      ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella
    xor     ax, ax

    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_x], ax          ; Compara si la posicion x esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve

    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_x]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo izquierda
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal 

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento   

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x
    
    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando)

    
playerNE:                           ; Mueve al jugador hacia  Nor-Este

    mov     al, [blue_color]        ; Guarda el color del cual se debe pintar el movimiento 
    mov     [currentColor], al      ; Establece el color como el actual para luego colorear si es necesario
    xor     al, al
    mov     ax, [player_x] 
    mov     [color_player_x], ax    ; Guarda las posiones de x de la casilla para pintar en ella
    xor     ax, ax
    mov     ax, [player_y] 
    mov     [color_player_y], ax    ; Guarda las posiones de y de la casilla para pintar en ella

    xor     ax, ax


    mov     ax, 06h                 ; Mueve en 6 al registro ax
    cmp     [player_y], ax          ; Compara si la posicion y esta por tocar un borde con el movimiento
    jle      exitRoutine            ; Si lo tocaria entonces no lo mueve


    call    deletePlayer            ; Sino elimina al jugador de la posicion para moverlo

    mov     ax, [player_y]          
    sub     ax, [player_speed]      ; Resta la velocidad del jugador para poder moverlo arriba
    mov     [temp_player_y], ax     ; Guarda el nuevo valor de y en la variable temporal  
    
    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_y], ax          ; Actualiza la posicion del jugador en y

    mov     ax, [player_x]          
    add     ax, [player_speed]      ; Suma la velocidad del jugador para poder moverlo derecha
    mov     [temp_player_x], ax     ; Guarda el nuevo valor de x en la variable temporal  

    call    checkPlayerColision     ; Verifica si ocasiona colision el nuevo movimiento 

    mov     [player_x], ax          ; Actualiza la posicion del jugador en x

    jmp     verifyMode              ; Revisa el modo de movimiento (Normal,Pintando,Borrando) 



verifyMode:                    

    xor     ax,ax
    mov     ax, [paintMode]         ; Verifica el estado de pintura
    cmp     ax, 01h
    je      paintInGame             ; Si estamos en modo de pintura, salta a la rutina correspondiente

    mov     ax, [eraseMode]         ; Verifica el estado de borrado
    cmp     ax, 01h
    je      eraseInGame             ; Si estamos en modo de borrado, salta a la rutina correspondiente

    ; Si no estamos en modo de pintura ni de borrado, simplemente movemos al jugador

    ret                             ; Vuelve al bucle principal

togglePaintMode:

    mov     ax, [eraseMode]         ; Obtiene el valor actual de eraseMode
    cmp     ax, 01h                 ; Verifica si esta en modo borrar 
    jne     togglePaintModeAux      ; Sino lo esta entonces activa modo pintar

    ret                             ; Vuelve al ciclo principal

togglePaintModeAux:

    mov     ax, [paintMode]         ; Obtiene el valor actual de paintMode
    xor     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    mov     [paintMode], ax         ; Actualiza paintMode

    ret                             ; Vuelve al ciclo principal

toggleEraseMode:

    mov     ax, [paintMode]         ; Obtiene el valor actual de paintMode
    cmp     ax, 01h                 ; Verifica si esta en modo pintar 
    jne      toggleEraseModeAux     ; Sino lo esta entonces activa modo pintar

    ret                             ; Vuelve al ciclo principal

toggleEraseModeAux:

    mov     ax, [eraseMode]         ; Obtiene el valor actual de eraseMode
    xor     ax, 01h                 ; Invierte el valor (0 a 1 o 1 a 0)
    mov     [eraseMode], ax         ; Actualiza eraseMode

    ret                             ; Vuelve al ciclo principal


paintInGame:

    mov     cx, [color_player_x]    ; Obtiene el valor de x de la casilla que se va a pintar
    mov     dx, [color_player_y]    ; Obtiene el valor de y de la casilla que se va a pintar
    jmp     paintLoop               ; Llama al paintloop que pintara la casilla

paintLoop:

    mov     ah, 0ch                 ; Indica que se va a dibujar un pixel en pantalla
    mov     al, [currentColor]      ; Indica el color del pixel (color segun movimiento) 
    mov     bh, 00h                 ; Indica en que pagina lo va a dibujar (predeterminada)
    int     10h                     ; Llama a la interrupcion para dibujar en pantalla
    inc     cx                      ; Incrementa en 1 el cx 
    mov     ax, cx                  
    sub     ax, [color_player_x]    ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando anchura)
    cmp     ax, [player_size]       ; Verifica si el ax es mas grande que el tamano del jugador
    jng     paintLoop               ; Si aun no es mas grande sigue dibujando la siguiente columna
    jmp     paintLoop2              ; Sino salta a la siguiente funcion de dibujo (dibujar altura del sprite)



paintLoop2:

    mov     cx, [color_player_x]    ; Restablece el valor de las columnas
    inc     dx                      ; Aumenta en la fila
    mov     ax, dx                  
    sub     ax, [color_player_y]    ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando altura)
    cmp     ax, [player_size]       ; Verifica si el ax es mas grande que el tamano del jugador
    jng     paintLoop               ; Si aun no es mas grande sigue dibujando la siguiente fila

    ret                             ; Sino vuelve al bucle principal 
    
eraseInGame:
    mov     al, 00h                 ; Guarda el hexa del color verde en el registro al
    mov     [currentColor], al      ; Establece el color como el actual
    xor     al, al
    mov     cx, [color_player_x]    ; Obtén el tamaño del jugador (ancho o alto, asumiendo que es cuadrado)
    mov     dx, [color_player_y]    ; Establece el contador de bucle para el tamaño del jugador
    jmp     paintLoop
    

    ret                             ; Sino vuelve al bucle principal 
        

exitPlayerMovement:
    mov     ax, [player_x]            
    mov     [temp_player_x], ax           
    mov     ax, [player_y]            
    mov     [temp_player_y], ax          

    call    resetGame 

resetGame:
    call    clearScreen             ; Llama al limpiador de pantalla 
    jmp     startGame               ; Vuelve a llamar al inicio de juego

win:
    call    clearScreen
    jmp     winnerLoop

lose:
    call    clearScreen
    jmp     loserLoop

exitRoutine:                       
    ret                             ; Permite salir de una rutina y vuelve al ciclo principal




;-----------------------Check colisions-----------------------

;compares if the pixel in the position of the temp x and y of the player, matches the color of a wall
;if that happens it means the player movement made him collide with a wall
;But if the color of the pixel is red, it means the player reached the goal
checkPlayerColision:
    push ax

    mov cx, [temp_player_x]
    mov dx, [temp_player_y]
    mov ah, 0dh
    mov bh, 00h
    int 10h

    mov [lastColor], al  ; Establece el color como el actual

    ; Comparación adicional entre lastColor y currentColor
    cmp al, [currentColor]
    je skipWin  ; Si lastColor es igual a currentColor, salta la etiqueta win


    ; Verifica si paintMode es 1
    mov al, [paintMode]  ; Carga el valor de paintMode en al
    cmp al, 01h            ; Compara con 1
    je skipAdditionalComparison  ; Si paintMode no es 1, salta la comparación adicional

    
skipAdditionalComparison:
    ; Comparaciones regulares de colores
    mov al, [lastColor]

    cmp al, [purple_color]
    je  win

    cmp al, [blue_color]
    je  win
     
    cmp al, [red_color]
    je  win

    cmp al, [yellow_color]
    je  win

skipWin:
    pop ax

    ret





;goalReached:
;     mov    ax, 01h
;     cmp    ax, [level]
;     je     startLevel2
;     call   clearScreen
;     jmp    winnerLoop


; ;-----------------------Render Goal-----------------------

; renderGoal:
;     mov    ax, 01h
;     cmp    ax, [level]
;     je     renderGoalLevel1
;     jmp    renderGoalLevel2

; renderGoalLevel1: 
;     mov ax, [goal_level_1_x]
;     mov [goal_x], ax
;     mov ax, [goal_level_1_y]
;     mov [goal_y], ax
;     jmp renderGoalAux

; renderGoalLevel2: 
;     mov ax, [goal_level_2_x]
;     mov [goal_x], ax
;     mov ax, [goal_level_2_y]
;     mov [goal_y], ax
;     jmp renderGoalAux

; renderGoalAux:
;     mov     cx, [goal_x]            
;     mov     dx, [goal_y]            
;     jmp     renderGoalAux1         

; renderGoalAux1:
;     mov     ah, 0ch                 ; Draw pixel
;     mov     al, [goal_color]        ; player color 
;     mov     bh, 00h                 ; Page
;     int     10h                     ; Interrupt 
;     inc     cx                      ; cx +1
;     mov     ax, cx                  
;     sub     ax, [goal_x]          ; Substract player width with the current column
;     cmp     ax, [player_size]       ; compares if ax is greater than player size
;     jng     renderGoalAux1         ; if not greater, draw next column
;     jmp     renderGoalAux2        ; Else, jump to next aux function

; renderGoalAux2:
;     mov     cx, [goal_x]            ; reset columns
;     inc     dx                        ; dx +1
;     mov     ax, dx                  
;     sub     ax, [goal_y]            ; Substract player height with the current row
;     cmp     ax, [player_size]         ; compares if ax is greater than player size
;     jng     renderGoalAux1           ; if not greater, draw next row
;     ret                               ; Else, return

