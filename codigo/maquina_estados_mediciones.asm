; Descripcion: maquina de estados perteneciente a la gestion
; de las mediciones
; Utiliza los registros EVENTO y ESTADO descriptos en main.asm


;************************************************************************************************


MAQUINA_ESTADOS_MEDICIONES:


	SBRC ESTADO, EST_OSCIOSO_MEDICION
	RJMP ESTADO_OSCIOSO_MEDICION

	SBRC ESTADO, EST_MEDIR_DEVOLVER_TIEMPOS
	RJMP ESTADO_MEDIR_DEVOLVER_TIEMPOS

	SBRC ESTADO, EST_MEDIR_DEVOLVER_TOTAL
	RJMP ESTADO_MEDIR_DEVOLVER_TOTAL

	; Pasar a la maquina de estado de UART
	RET


;************************************************************************************************


ESTADO_OSCIOSO_MEDICION:

	; Terminar de enviar la informacion del registro de desplazamiento si es que quedaron datos pendientes
	SBRS EVENTO, ENVIANDO_DATOS_UART
	CALL QUITAR_PULSO_REGISTRO_DESP_Y_ENVIAR_UART

	; Si se ha recibido un comando (por UART o teclado) de comenzar
	; una medicion, entonces iniciar la medicion y 
	; cambiar al estado ESTADO_MEDIR

	SBRS EVENTO, COMENZAR_MEDICION
	RJMP _FIN_ESTADO_OSCIOSO_MEDICION
	; ===================================================

	CALL INICIAR_MEDICION													;FUNCION A EJECUTAR PARA COMENZAR UNA MEDICION

	; ===================================================
	CBR EVENTO, (1<<DETENER_MEDICION)
	CBR ESTADO, (1<<EST_OSCIOSO_MEDICION)

	; No hay pulsos almacenados en el registro de desplazamiento
	CLR CANT_CARACTERES_GUARDADOS

	; Chequear si la configuracion indica que se deben enviar el total de los pulsos
	; o sus tiempos por UART y cambiar al estado correspondiente
	LDS R16, REGISTRO_CONF_GENERAL
	SBRC R16, BIT_ENVIAR_TIEMPO_PULSOS
	RJMP _CONF_ESTADO_ENVIAR_TIEMPO_PULSOS
	SBR ESTADO, (1<<EST_MEDIR_DEVOLVER_TOTAL)

	;CLR R4
	CALL INICIAR_TIMER_1								;Se enciende el TIMER 1, para comenzar a medir
	RJMP _FIN_ESTADO_OSCIOSO_MEDICION

_CONF_ESTADO_ENVIAR_TIEMPO_PULSOS:
	SBR ESTADO, (1<<EST_MEDIR_DEVOLVER_TIEMPOS)
	CALL INICIAR_TIMER_1								;Se enciende el TIMER 1, para comenzar a medir
	RJMP _FIN_ESTADO_OSCIOSO_MEDICION

_FIN_ESTADO_OSCIOSO_MEDICION:
	RET

;************************************************************************************************
ESTADO_MEDIR_DEVOLVER_TIEMPOS:
	CBR EVENTO, (1<<COMENZAR_MEDICION)

	; Chequear si se ha decrementado el multiplicador de ventana, y si es asi, enviar un indicador a la PC
	LDS R16, EVENTO2
	SBRS R16, BIT_MUL_VENTANA_DEC
	RJMP _ESTADO_MEDIR_CARGAR_REGISTRO_DESPLAZAMIENTO

	LDI ZL, LOW(MENSAJE_DEC_MUL<<1)
	LDI ZH, HIGH(MENSAJE_DEC_MUL<<1)
	CALL CARGAR_CADENA_REGISTRO_DESPLAZAMIENTO

	LDS R16, EVENTO2
	CBR R16, (1<<BIT_MUL_VENTANA_DEC)
	STS EVENTO2, R16

_ESTADO_MEDIR_CARGAR_REGISTRO_DESPLAZAMIENTO:
	; Si se recibio el tiempo de un pulso, 
	; entonces leer el registro donde se almacena dicho valor (ICR1)
	SBRS EVENTO, PULSO_RECIBIDO
	RJMP _ESTADO_MEDIR_ENVIAR_TIEMPO_PULSO
	
	; Limpiar el bit que indica que se recibio un pulso porque ya fue leido
	CBR EVENTO, (1<<PULSO_RECIBIDO)
	
	; Leer el tiempo del pulso y cargarlo en el registro de desplazamiento
	LDS R16, ICR1L 
	LDS R17, ICR1H

	CALL CARGAR_PULSO_REGISTRO_DESPLAZAMIENTO


_ESTADO_MEDIR_ENVIAR_TIEMPO_PULSO:
	; Chequear si se estan enviando datos por UART. Si es asi, no cargar de nuevo el buffer y
	; esperar a la siguiente iteracion de la maquina
	SBRS EVENTO, ENVIANDO_DATOS_UART
	CALL QUITAR_PULSO_REGISTRO_DESP_Y_ENVIAR_UART
	RJMP _ESTADO_MEDIR_CHEQUEAR_FIN_VENTANA


ESTADO_MEDIR_DEVOLVER_TOTAL:
	CBR EVENTO, (1<<COMENZAR_MEDICION)
	; Si se ha recibido (por UART o por teclado) un comando de 
	; comenzar una medición, entonces, una vez configurada esta, 
	; se entra en este estado.

_ESTADO_MEDIR_CHEQUEAR_FIN_VENTANA:
	;SBI PORTB, 1
	BRTC NO_SE_TERMINO_VENTANA								;Si el flag T está en 0, se continua con la ventana
	CLT														;Si no, es porque se terminó una ventana, y por una interrupción, se pone en 1


	; VENTANA TERMINADA:
	


	LDS MUL_DE_VENTANA, MUL_DE_VENTANA_RAM					;Se recupera el dato del multiplicador de ventana, para continuar con la siguiente ventana


	CALL ACUMULAR_PULSOS_DETECTADOS							;Se guardan los pulsos que se contaron en la ventana, en RAM

	; Chequear umbral, y si se ha superado el valor establecido encender el LED/BUZZER
	CALL VERIFICAR_UMBRAL

	SBRS ESTADO, EST_MEDIR_DEVOLVER_TOTAL
	RJMP _CONTINUAR_ESTADO_MEDIR_CHEQUEAR_FIN_VENTANA

	MOV R16, CONTADOR_DE_PULSOS
	CLR R17
	CLR R29
	CALL CONVERTIR_A_BINARIO_Y_ENVIAR_UART

	RJMP _CONTINUAR_ESTADO_MEDIR_CHEQUEAR_FIN_VENTANA


_CONTINUAR_ESTADO_MEDIR_CHEQUEAR_FIN_VENTANA:

	CLR CONTADOR_DE_PULSOS									;Se limpian los pulsos de la ventana anterior

	;SBR EVENTO, (1<<FIN_VENTANA)							;Se enciende el flag de fin de ventana en ESTADO, para indicarle a la UART que debe enviar los datos medidos
	; TESTEO DE SI SE TERMINÓ DE MEDIR

	PUSH R16
	DEC VENTANAS_A_MEDIR_LOW
	BRNE NO_ES_CERO
	LDI R16, 0x00
	CP VENTANAS_A_MEDIR_MID, R16
	BRNE NO_ES_CERO
	CP VENTANAS_A_MEDIR_HIGH, R16
	BRNE NO_ES_CERO

CERO:
	CALL APAGAR_TIMER_1										;Finalizadas la medición total, se apaga el timer 1.
	;CBI PORTB, 1
	POP R16													;Se apaga el LED para indicar fin de medición
	LDI ESTADOS_LCD, MEDICION_FINALIZADA_LCD
	RJMP MOSTRAR_PROMEDIO
NO_ES_CERO:
	LDI R16, 0xFF
	CP VENTANAS_A_MEDIR_LOW, R16
	BRNE LISTO_COMPARACION
	DEC VENTANAS_A_MEDIR_MID
	CP VENTANAS_A_MEDIR_MID, R16
	BRNE LISTO_COMPARACION
	DEC VENTANAS_A_MEDIR_HIGH
LISTO_COMPARACION:

	POP R16

NO_SE_TERMINO_VENTANA:

	

	; Si se ha recibido un comando (por UART o teclado) de abortar
	; una medicion, entonces abortar y
	; cambiar al estado ESTADO_OSCIOSO_MEDICION
	SBRC EVENTO, DETENER_MEDICION
	RJMP _ESTADO_MEDIR_ABORTAR
	
	RET

;************************************************************************************************
;************************************************************************************************

MOSTRAR_PROMEDIO:
	; Se muestra el promedio por pantalla al usuario
	COMANDO_LCD LCD_HOME_SCREEN			; Se posiciona en el extremo superior izquierdo

	BORRAR_RENGLON						; Se borra el renglon
	
	COMANDO_LCD LCD_HOME_SCREEN			; Se posiciona en el extremos superior izquierdo

	CADENA_FLASH_LCD MENSAJE_PROMEDIO_LCD


	LDI ZL, LOW(CONTADOR_DE_PULSOS_RAM)				;Se carga el puntero a donde se guardan los pulsos
	LDI ZH, HIGH(CONTADOR_DE_PULSOS_RAM)			
	LDI XL, LOW(VENTANAS_A_MEDIR_RAM)				;Se carga el puntero a donde se guardan las ventanas a medir
	LDI XH, HIGH(VENTANAS_A_MEDIR_RAM)
	CALL PROMEDIO									;Se realiza elpromedio y se guarda en PROMEDIO_RAM [16 bits]
	LDS R16, PROMEDIO_RAM							;Se cargan los bytes del promedio en dos registros para hacer promedio
	LDS R17, PROMEDIO_RAM+1
	LDS R29, PROMEDIO_RAM+2
	LDI XL, LOW(NUMERO_ASCII)
	LDI XH, HIGH(NUMERO_ASCII)

	CALL DEC_TO_ASCII_24_BITS

	COMANDO_LCD LCD_CAMBIAR_RENGLON
	BORRAR_RENGLON
	COMANDO_LCD LCD_CAMBIAR_RENGLON

	LDI ZL, LOW(NUMERO_ASCII)						;Se carga el puntero a NUMERO_ASCII, que es donde se guardo el promedio
	LDI ZH, HIGH(NUMERO_ASCII)
	CALL STRING_WRT_LCD								;Se escriben los numeros en el LCD
	; **********************************************************************************

	; ===================================================
	CBR ESTADO, (1<<EST_MEDIR_DEVOLVER_TIEMPOS)
	CBR ESTADO, (1<<EST_MEDIR_DEVOLVER_TOTAL)
	SBR ESTADO, (1<<EST_OSCIOSO_MEDICION)

	; Apagar LED/buzzer si es que se encuentra activado
	CBI PORTB, PIN_PORTB_BUZZER ; Apagar buzzer
	CBI PORTB, PIN_PORTB_LED ; Apagar LED

	; Enviar codigo avisando que se termino una medicion
	LDI R18, LOW(MENSAJE_FIN_MEDICION)
	LDI R19, HIGH(MENSAJE_FIN_MEDICION)
	CALL CARGAR_BUFFER
	CALL ACTIVAR_INT_TX_UDRE0

	RET

;************************************************************************************************

_ESTADO_MEDIR_ABORTAR:
	; Limpiar el evento asociado a abortar una medicion
	CBR EVENTO, (1<<DETENER_MEDICION)

	CALL APAGAR_TIMER_1								; Se apaga el timer 1

	;CBI PORTB, 1

	CBR ESTADO, (1<<EST_MEDIR_DEVOLVER_TIEMPOS)
	CBR ESTADO, (1<<EST_MEDIR_DEVOLVER_TOTAL)
	SBR ESTADO, (1<<EST_OSCIOSO_MEDICION)

	; Apagar LED/buzzer si es que se encuentra activado
	CBI PORTB, PIN_PORTB_BUZZER ; Apagar buzzer
	CBI PORTB, PIN_PORTB_LED ; Apagar LED

	; Enviar codigo avisando que se termino una medicion
	LDI R18, LOW(MENSAJE_FIN_MEDICION)
	LDI R19, HIGH(MENSAJE_FIN_MEDICION)
	CALL CARGAR_BUFFER
	CALL ACTIVAR_INT_TX_UDRE0

	RET

