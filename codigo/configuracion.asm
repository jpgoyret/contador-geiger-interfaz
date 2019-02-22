; Descripcion: funciones que graban registros en RAM
; para la configuracion del dispositivo

; ===================================================================
; ========================= Registros auxiliares ====================
; ===================================================================
.UNDEF T0
.UNDEF T1
.UNDEF T2
.UNDEF T3
.UNDEF T4
.UNDEF T5
.DEF T0 = R16
.DEF T1 = R17 
.DEF T2 = R18
.DEF T3 = R19
.DEF T4 = R20
.DEF T5 = R21

; ===================================================================
; ========================= Constantes ==============================
; ===================================================================
; Define el maximo de numero de digitos que puede tener la cantidad
; de ventanas en las que medir, el tiempo de una ventana y el valor del umbral,
; en sus respectivas unidades
; TODO: dividir esta constante en una para cada parametro
.EQU MAX_NUM_DIGITOS = 4
.EQU MAX_NUM_DIGITOS_5 = 5

; Constantes que contienen la posicion de cada configuracion
; dentro del registro REGISTRO_CONF_GENERAL
.EQU BIT_SENAL_SONORA = 0
.EQU BIT_BLOQUEO_TECLADO = 1
.EQU BIT_ENVIAR_TIEMPO_PULSOS = 2
.EQU BIT_ACTIVAR_FUENTE = 3

; ===================================================================
; ========================= Registros en RAM ========================
; ===================================================================
.dseg

; Registro para guardar la duracion de la ventana de tiempo
; Valores posibles:
; 0 --> 1ms
; 1 --> 10ms
; 2 --> 100ms
; 3 --> 1s
REGISTRO_VENTANA_TIEMPO: .BYTE 1

; Registro para guardar la cantidad de ventanas a medir
VENTANAS_A_MEDIR_RAM: .BYTE 3											;[nibble alto]:[nibble intermedio]:[nibble bajo]
;VENTANAS_A_MEDIR_RAM: .BYTE 1

; Registro para guardar el valor del umbral de pulsos
; por ventana por encima del cual se enciende
; el led/buzzer
REGISTRO_UMBRAL: .BYTE 3												;[nibble alto]:[nibble intermedio]:[nibble bajo]

; Registro para configuraciones generales:
; Un bit en '1' significa que el sistema esta activo
; Bits:
; 0 - Senal sonora
; 1 - Bloqueo del teclado
; 2 - Enviar el tiempo de llegada de cada pulso por UART
; 3 - Apagar fuente de alta tension del tubo del contador Geiger
REGISTRO_CONF_GENERAL: .BYTE 1

; ===================================================================
; ========================= Funciones ===============================
; ===================================================================
.cseg

; Descripcion: configurar los siguientes registros con su valor
; por default:
; REGISTRO_VENTANA_TIEMPO = 2 ---> Duracion de la venta: 100ms
; VENTANAS_A_MEDIR_RAM = 10 ---> Cantidad de ventanas a medir antes de terminar la medicion: 10
; REGISTRO_UMBRAL = 10 ---> Cantidad de pulsos por ventana antes encender el led/buzzer: 10
CONFIGURAR_REGISTROS_DEFAULT:
	LDI T0, 3
	STS REGISTRO_VENTANA_TIEMPO, T0
	LDI T0, 10
	STS VENTANAS_A_MEDIR_RAM+1, T0
	LDI T0, 0
	STS VENTANAS_A_MEDIR_RAM, T0
	LDI T0, 1
	STS REGISTRO_UMBRAL+1, T0
	LDI T0, 0
	STS REGISTRO_UMBRAL, T0
	LDI T0, 0
	STS REGISTRO_CONF_GENERAL, T0
	RET



; Descripcion: parseo del tamano de ventana recibido mediante el comando
; CONFigure:WINDow N, donde N es el tamano de ventana
; Recibe: posicion de memoria del buffer de RX donde comienza N en el puntero X
CONFIGURAR_VENTANA_TIEMPO:
	PUSH T0
	PUSH T1

	CLR T0

	LD T1, X+
	CPI T1, '1'
	BRNE _RETORNAR_ERROR_CONF_COUNT_REGISTER

_BUCLE_CONF_COUNT_REGISTER:
	LD T1, X+
	CPI T1, '0'
	BREQ _DECREMENTAR_AUX_CONF_COUNT_REGISTER
	CPI T1, '\r' ; TODO: CAMBIAR POR UN \n
	BREQ _GUARDAR_REGISTRO_COUNT_REGISTER
	RJMP _RETORNAR_ERROR_CONF_COUNT_REGISTER

_DECREMENTAR_AUX_CONF_COUNT_REGISTER:
	CPI T0, 3; Si el numero ingresado es mayor a 1000, devolver un error
	BREQ _RETORNAR_ERROR_CONF_COUNT_REGISTER
	INC T0
	RJMP _BUCLE_CONF_COUNT_REGISTER

_RETORNAR_ERROR_CONF_COUNT_REGISTER:
	CALL ENVIAR_ERROR_PARSER

	POP T1
	POP T0
	RET

_GUARDAR_REGISTRO_COUNT_REGISTER:
	STS REGISTRO_VENTANA_TIEMPO, T0

	POP T1
	POP T0
	RET

; ==============================================================
; Descripcion: lee el registro donde se encuentra definida la ventana de tiempo y devuelve su valor
; Entradas: -
; Salidas: -
DEVOLVER_VENTANA_TIEMPO:
	PUSH T0
	PUSH R18
	PUSH_WORD XL,XH

	CALL IR_COMIENZO_BUFFER_TX

	LDI R18, '1'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	
	LDS T0, REGISTRO_VENTANA_TIEMPO
	CPI T0, 0

_BUCLE_DEVOLVER_VENTANA_TIEMPO:
	BREQ _ENVIAR_VENTANA_TIEMPO
	LDI R18, '0'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	DEC T0
	RJMP _BUCLE_DEVOLVER_VENTANA_TIEMPO

_ENVIAR_VENTANA_TIEMPO:
	LDI R18, '\n'
	CALL CARGAR_BUFFER_TX_CON_CARACTER

	CALL ENVIAR_DATOS_UART

	POP_WORD XL,XH
	POP R18
	POP T0
	RET

; ==============================================================
; Descripcion: activa el bit para iniciar una medicion en el registro EVENTO
; Entradas: -
; Salidas: -
CONFIGURAR_EVENTO_INICIAR_MEDICION:
	SBR EVENTO, (1<<COMENZAR_MEDICION)
	RET

; ==============================================================
; Descripcion: activa el bit para detener una medicion en el registro EVENTO
; Entradas: -
; Salidas: -
CONFIGURAR_EVENTO_DETENER_MEDICION:
	SBR EVENTO, (1<<DETENER_MEDICION)
	RET

; ==============================================================
; Descripcion: devuelve el valor del registro VENTANAS_A_MEDIR_RAM
; Entradas: -
; Salidas: -
DEVOLVER_NUMERO_VENTANAS:

	LDS R29, VENTANAS_A_MEDIR_RAM
	LDS R17, VENTANAS_A_MEDIR_RAM+1
	LDS R16, VENTANAS_A_MEDIR_RAM+2

	CALL CONVERTIR_A_BINARIO_Y_ENVIAR_UART

	RET

; ==============================================================
; Descripcion: devuelve el valor del registro REGISTRO_UMBRAL
; Entradas: -
; Salidas: -
DEVOLVER_UMBRAL:

	LDS R29, REGISTRO_UMBRAL
	LDS R17, REGISTRO_UMBRAL+1
	LDS R16, REGISTRO_UMBRAL+2

	CALL CONVERTIR_A_BINARIO_Y_ENVIAR_UART
		
	RET

; ==============================================================
; Descripcion: indica si el tubo del contador se encuentra encendido
; Entradas: -
; Salidas: -
/*
DEVOLVER_CONF_ENCENDIDO_TUBO:

	; Cargar primera parte del mensaje en buffer
	LDI R18, LOW(MENSAJE_ESTADO_FUENTE)
	LDI R19, HIGH(MENSAJE_ESTADO_FUENTE)
	CALL CARGAR_BUFFER

	; Chequear si el tubo se encuentra encendido
	LDS R16, REGISTRO_CONF_GENERAL
	SBRC R16, BIT_ACTIVAR_FUENTE
	RJMP _FUENTE_APAGADA

	CALL CARGAR_MENSAJE_ON_UART
	
	CALL ENVIAR_DATOS_UART
	RET
	
_FUENTE_APAGADA:

	CALL CARGAR_MENSAJE_OFF_UART

	CALL ENVIAR_DATOS_UART
	RET
*/

; ==============================================================
; Descripcion: indica si una opcion en el registro REGISTRO_CONF_GENERAL esta activada
; Entradas:
; --> R18 y R19 con la posicion de memoria del mensaje correspondiente a la opcion de configuracion
; --> R17 con el bit asociado a la configuracion en REGISTRO_CONF_GENERAL
; Salidas: -
DEVOLVER_CONF_BIT:

	; Cargar primera parte del mensaje en buffer utilizando los registros R18 y R19
	CALL CARGAR_BUFFER

	; Chequear si el tubo se encuentra encendido
	LDS R16, REGISTRO_CONF_GENERAL
	AND R16, R17
	BRNE _OPCION_ACTIVADA

	CALL CARGAR_MENSAJE_OFF_UART
	
	CALL ENVIAR_DATOS_UART
	RET
	
_OPCION_ACTIVADA:

	CALL CARGAR_MENSAJE_ON_UART

	CALL ENVIAR_DATOS_UART
	RET

; ==============================================================
; Descripcion: cargar el mensaje ON en el buffer de TX
; Recibe: -
; Salidas: -
CARGAR_MENSAJE_ON_UART:
	LDI R18, 'O'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	LDI R18, 'N'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	LDI R18, '\n'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	RET

; ==============================================================
; Descripcion: cargar el mensaje OFF en el buffer
; Recibe: -
; Salidas: -
CARGAR_MENSAJE_OFF_UART:
	LDI R18, 'O'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	LDI R18, 'F'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	LDI R18, 'F'
	CALL CARGAR_BUFFER_TX_CON_CARACTER
	LDI R18, '\n'
	CALL CARGAR_BUFFER_TX_CON_CARACTER	
	RET


; ==============================================================
; Descripcion: devolver la configuracion de todo el dispositivo por UART
; Recibe: -
; Salidas: -
DEVOLVER_CONFIGURACION:

	; Numero de ventanas
	LDI R18, LOW(MENSAJE_CANTIDAD_VENTANAS)
	LDI R19, HIGH(MENSAJE_CANTIDAD_VENTANAS)
	CALL CARGAR_BUFFER
	CALL ENVIAR_DATOS_UART
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)
	
	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	CALL DEVOLVER_NUMERO_VENTANAS
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	; Tiempo de la ventana
	LDI R18, LOW(MENSAJE_VENTANA_DURACION)
	LDI R19, HIGH(MENSAJE_VENTANA_DURACION)
	CALL CARGAR_BUFFER
	CALL ENVIAR_DATOS_UART
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)
	
	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	CALL DEVOLVER_VENTANA_TIEMPO
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	; Valor del umbral
	LDI R18, LOW(MENSAJE_TRIGGER_UMBRAL)
	LDI R19, HIGH(MENSAJE_TRIGGER_UMBRAL)
	CALL CARGAR_BUFFER
	CALL ENVIAR_DATOS_UART
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)
	
	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	CALL DEVOLVER_UMBRAL
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	; Encendido del tubo
	LDI R18, LOW(MENSAJE_ESTADO_FUENTE)
	LDI R19, HIGH(MENSAJE_ESTADO_FUENTE)
	LDI R17, (1<<BIT_ACTIVAR_FUENTE)

	CALL DEVOLVER_CONF_BIT
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	; Envio de tiempos de cada pulso
	LDI R18, LOW(MENSAJE_ESTADO_ENVIAR_TIEMPOS)
	LDI R19, HIGH(MENSAJE_ESTADO_ENVIAR_TIEMPOS)
	LDI R17, (1<<BIT_ENVIAR_TIEMPO_PULSOS)

	CALL DEVOLVER_CONF_BIT
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	; Activacion del buzzer
	LDI R18, LOW(MENSAJE_ESTADO_SENAL_SONORA)
	LDI R19, HIGH(MENSAJE_ESTADO_SENAL_SONORA)
	LDI R17, (1<<BIT_SENAL_SONORA)

	CALL DEVOLVER_CONF_BIT
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	CALL BUCLE_POLLING_DEVOLVER_CONFIGURACION

	; Bloqueo de teclado
	LDI R18, LOW(MENSAJE_ESTADO_BLOQUEO_TECLADO)
	LDI R19, HIGH(MENSAJE_ESTADO_BLOQUEO_TECLADO)
	LDI R17, (1<<BIT_BLOQUEO_TECLADO)

	CALL DEVOLVER_CONF_BIT

	RET


;MENSAJE_CANTIDAD_VENTANAS: .db "Numero de ventanas:", '\n', 0
;MENSAJE_TRIGGER_UMBRAL: .db "Umbral del trigger:", '\n', 0
;MENSAJE_VENTANA_DURACION: .db "Duracion de la ventana:", '\n', 0

BUCLE_POLLING_DEVOLVER_CONFIGURACION:
_BUCLE_POLLING_DEVOLVER_CONFIGURACION:
	SBRC EVENTO, ENVIANDO_DATOS_UART
	RJMP _BUCLE_POLLING_DEVOLVER_CONFIGURACION

	RET

; ==============================================================
; Descripcion: configura la senal sonora
; Recibe: puntero X con la posicion de memoria del buffer de RX donde comienza el dato booleano 
; Salidas: -
CONFIGURAR_SENAL_SONORA:
	
	CALL VERIFICAR_BOOLEANO_UART

	BRCS _RET_CONFIGURAR_SENAL_SONORA
	
	CLR T1

	CPI T0, '0'
	BREQ _DESACTIVAR_SENAL_SONORA
	
	; Activar senal sonora
	ORI T1, (1<<BIT_SENAL_SONORA)
	STS REGISTRO_CONF_GENERAL, T1
	RET

_DESACTIVAR_SENAL_SONORA:
	ANDI T1, ~(1<<BIT_SENAL_SONORA)
	STS REGISTRO_CONF_GENERAL, T1

_RET_CONFIGURAR_SENAL_SONORA:
	RET


; ==============================================================
; Descripcion: configura el bloqueo del teclado
; Recibe: puntero X con la posicion de memoria del buffer de RX donde comienza el dato booleano 
; Salidas: -
CONFIGURAR_BLOQUEO_TECLADO:
	CALL VERIFICAR_BOOLEANO_UART
	BRCS _RET_CONFIGURAR_BLOQUEO_TECLADO
	
	LDS T1, REGISTRO_CONF_GENERAL

	CPI T0, '0'
	BREQ _DESACTIVAR_BLOQUEO_TECLADO
	
	; Bloquear teclado
	ORI T1, (1<<BIT_BLOQUEO_TECLADO)
	STS REGISTRO_CONF_GENERAL, T1
	RET

_DESACTIVAR_BLOQUEO_TECLADO:
	ANDI T1, ~(1<<BIT_BLOQUEO_TECLADO)
	STS REGISTRO_CONF_GENERAL, T1

_RET_CONFIGURAR_BLOQUEO_TECLADO:
	RET

; ==============================================================
; Descripcion: configura el envio de los tiempos de cada pulso por UART
; Recibe: puntero X con la posicion de memoria del buffer de RX donde comienza el dato booleano 
; Salidas: -
CONFIGURAR_ENVIO_TIEMPOS_PULSOS:
	CALL VERIFICAR_BOOLEANO_UART
	BRCS _RET_CONFIGURAR_ENVIO_TIEMPOS_PULSOS
	
	LDS T1, REGISTRO_CONF_GENERAL

	CPI T0, '0'
	BREQ _DESACTIVAR_ENVIO_PULSOS
	
	; Bloquear teclado
	ORI T1, (1<<BIT_ENVIAR_TIEMPO_PULSOS)
	STS REGISTRO_CONF_GENERAL, T1
	RET

_DESACTIVAR_ENVIO_PULSOS:
	ANDI T1, ~(1<<BIT_ENVIAR_TIEMPO_PULSOS)
	STS REGISTRO_CONF_GENERAL, T1

_RET_CONFIGURAR_ENVIO_TIEMPOS_PULSOS:
	RET


; ==============================================================
; Descripcion: configura el envio de los tiempos de cada pulso por UART
; Recibe: puntero X con la posicion de memoria del buffer de RX donde comienza el dato booleano 
; Salidas: -
CONFIGURAR_APAGADO_FUENTE:
	CALL VERIFICAR_BOOLEANO_UART
	BRCS _RET_CONFIGURAR_APAGADO_FUENTE
	
	LDS T1, REGISTRO_CONF_GENERAL

	CPI T0, '0'
	BREQ _DESACTIVAR_APAGADO_FUENTE
	
	; Bloquear teclado
	ORI T1, (1<<BIT_ACTIVAR_FUENTE)
	STS REGISTRO_CONF_GENERAL, T1
	RET

_DESACTIVAR_APAGADO_FUENTE:
	ANDI T1, ~(1<<BIT_ACTIVAR_FUENTE)
	STS REGISTRO_CONF_GENERAL, T1

_RET_CONFIGURAR_APAGADO_FUENTE:
	RET

; ==============================================================
; Descripcion: detecta si se ha recibido un parametro booleano por UART
; Recibe: puntero X con la posicion de memoria del buffer de RX donde comienza el dato booleano 
; Salidas: activa el bit de carry si el dato es no es booleano, sino lo desactiva.
VERIFICAR_BOOLEANO_UART:
	LD T0, X+
	LD T1, X

	CPI T1, '\r' ; TODO: CAMBIAR POR \n, el verdadero caracter de fin de trama
	BRNE _RET_ERROR_VERIFICAR_BOOLEANO_UART

	CPI T0, '0'
	BREQ _RET_VERIFICAR_BOOLEANO_UART

	CPI T0, '1'
	BREQ _RET_VERIFICAR_BOOLEANO_UART

_RET_ERROR_VERIFICAR_BOOLEANO_UART:
	SEC
	CALL ENVIAR_ERROR_PARSER
	RET	

_RET_VERIFICAR_BOOLEANO_UART:
	CLC
	RET


; ==============================================================
; Descripcion: validacion de datos numericos que llegan por UART en formato ASCII
; Recibe: puntero X con la posicion de memoria del buffer de RX donde comienza el numero
; Salidas: R16 con el valor de la cantidad de digitos si no hubo un error
;          ACtiva el bit de carry si se produjo un error
; NOTA: como maximo pueden recibirse 5 digitos en formato ASCII
VALIDAR_ASCII_UART:
	CLR R16

_BUCLE_VALIDAR_ASCII_UART:
	LD T1, X+
	CPI T1, '\r';TODO: CAMBIAR POR \n
	BREQ _FIN_BUCLE_VALIDAR_ASCII_UART
	INC R16
	CPI R16, MAX_NUM_DIGITOS_5+1
	BREQ _RET_ERROR_VALIDAR_ASCII_UART
	CPI T1, '0'
	BRLO _RET_ERROR_VALIDAR_ASCII_UART
	CPI T1, '9'+1
	BRSH _RET_ERROR_VALIDAR_ASCII_UART
	RJMP _BUCLE_VALIDAR_ASCII_UART

_FIN_BUCLE_VALIDAR_ASCII_UART:
	; Chequear si no se detectaron digitos
	CPI R16, 0
	BREQ _RET_ERROR_VALIDAR_ASCII_UART

	; Regresar el puntero X a su posicion original si no hubo errores
	; es necesario para la etapa posterior de transformacion de ASCII a binario
	MOV T1, R16
	INC T1
	SUB XL, T1
	IN T2, SREG
	SBRC T2, SREG_C
	SUBI XH, 1 
	
	; Borrar el bit de carry indicando que todo salio correctamente
	CLC

	RET

_RET_ERROR_VALIDAR_ASCII_UART:
	; Activar el bit de carry indicando que se produjo un error
	SEC

	RET

; ===================================================================
; ========================= Espacios de memoria reservados ==========
; ===================================================================
; Mensajes para reportar configuracion
MENSAJE_ESTADO_FUENTE: .db "Estado de la fuente: ", 0
MENSAJE_ESTADO_SENAL_SONORA: .db "Señal sonora: ", 0
MENSAJE_ESTADO_BLOQUEO_TECLADO: .db "Bloqueo del teclado durante medicion: ", 0
MENSAJE_ESTADO_ENVIAR_TIEMPOS: .db "Envio de tiempos de llegada de cada pulso: ", 0
MENSAJE_CANTIDAD_VENTANAS: .db "Numero de ventanas:", '\n', 0
MENSAJE_TRIGGER_UMBRAL: .db "Umbral del trigger:", '\n', 0
MENSAJE_VENTANA_DURACION: .db "Duracion de la ventana:", '\n', 0