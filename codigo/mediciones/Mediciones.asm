; ==================================================================
; Archivo: Mediciones.asm
; Descripcion: biblioteca con funciones relacionadas 
; con las mediciones a realizar.
; ==================================================================

; ===================================================================
; ========================= Variables ===============================
; ===================================================================
.dseg

MUL_DE_VENTANA_RAM: .byte 1				;Memoria para guardar el mul de ventana en ram

CONTADOR_DE_PULSOS_RAM: .byte 3			;Se irán acumulando el total de pulsos medidos en cada ventana: [nibble bajo];[nibble medio];[nibble alto]

.cseg
; UMBRAL_A_SUPERAR: se guardará la configuración del umbral a superar.
.DEF UMBRAL_A_SUPERAR = R21

; CONTADOR_DE_PULSOS: se lleva la cuenta de la cantidad de pulsos medidos.
.DEF CONTADOR_DE_PULSOS = R23

; VENTANA_DE_TIEMPO: se define la duracion de la ventana de tiempo de las mediciones
; 0 = 1ms, 1 = 10ms, 2 = 100ms, 3 = 1s
.DEF VENTANA_DE_TIEMPO = R26


.DEF VENTANAS_A_MEDIR_LOW = R7
.DEF VENTANAS_A_MEDIR_MID = R5
.DEF VENTANAS_A_MEDIR_HIGH = R13

; ===================================================================
; ========================= Constantes ==============================
; ===================================================================
.cseg

; Si se utiliza una ventana 100 ms, se cuenta 25000 con el timer1, 
; con un prescaler de clk/64 = 250khz.
.EQU VENTANA_LOW = 0xA8	
.EQU VENTANA_HIGH = 0x61

; CANTIDAD DE VECES QUE SE VA A REALIZAR EL REINICIO DEL CLOCK, 
; PARA SEGUIR MIDIENDO: EN ESTE CASO, CON UN
; PRESCALER DE CLK/64, CONTAR 50 VECES ES 5 segundos.
.EQU DURACION_TOTAL = 100

;CONFIGURACIÓN DEL UMBRAL
.EQU PIN_PORTB_LED = 2
.EQU PIN_PORTB_BUZZER = 3


; PUERTO DE ACTIVACION/DESACTIVACION DEL CONTADOR
.EQU PUERTO_ACTIVAR_CONTADOR = 4

; CONFIGURACIÓN DE LA DURACIÓN DE LA VENTANA
.EQU VENTANA_1ms = 0					
.EQU VENTANA_10ms = 1
.EQU VENTANA_100ms = 2
.EQU VENTANA_1000ms = 3

; VALORES DEL COMPARADOR DEL TIMER, DEPENDIENDO DE LA VENTANA SELECCIONADA

.EQU VENTANA_HIGH_1ms = 0x00			;0x00FA = 250
.EQU VENTANA_LOW_1ms = 0xFA

.EQU VENTANA_HIGH_10ms = 0x09			;0x09C4 = 2500
.EQU VENTANA_LOW_10ms = 0xC4

.EQU VENTANA_HIGH_100ms = 0x61			;0x61A8 = 25000
.EQU VENTANA_LOW_100ms = 0xA8

.EQU VENTANA_HIGH_1000ms = 0xC3			;0xC350 = 50000
.EQU VENTANA_LOW_1000ms = 0x50

; REPETIDORES DE OVERFLOW DEL TIMER PARA COMPLETAR UNA VENTANA
.EQU REPETIDOR_OVERFLOW_TIMER_1ms = 0x01
.EQU REPETIDOR_OVERFLOW_TIMER_10ms = 0x01
.EQU REPETIDOR_OVERFLOW_TIMER_100ms = 0x01
.EQU REPETIDOR_OVERFLOW_TIMER_1000ms = 0x05


; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

; Descripcion: configura la ventana de tiempo que se utilizará para las mediciones. 
;              Se utiliza el registro VENTANA_DE_TIEMPO para saber qué ventana se emplea.
; Recibe: -
; Devuelve: -

; SETEO DE LA CONFIGURACIÓN DE LA VENTANA DE TIEMPO: 
; --> Si VENTANA_DE_TIEMPO = 0, entonces 1ms; 
; --> Si VENTANA_DE_TIEMPO = 1, entonces 10ms; 
; --> Si VENTANA_DE_TIEMPO = 2, entonces 100ms;
; -- >Si VENTANA_DE_TIEMPO = 3, entonces 1000ms
; DEPENDIENDO DE CUAL ES EL VALOR DE VENTANA_DE_TIEMPO, 
; SE HACE UN SALTO PARA HACER LA CONFIGURACIÓN ADECUADA

CONFIG_VENTANA_DE_TIEMPO:
	PUSH R19
	PUSH R20
	PUSH R21

	CPI VENTANA_DE_TIEMPO, VENTANA_1ms
	BREQ CONFIG_1ms

	CPI VENTANA_DE_TIEMPO, VENTANA_10ms
	BREQ CONFIG_10ms

	CPI VENTANA_DE_TIEMPO, VENTANA_100ms
	BREQ CONFIG_100ms

	CPI VENTANA_DE_TIEMPO, VENTANA_1000ms
	BREQ CONFIG_1000ms
	
	CONFIG_1ms:
		LDI R20, VENTANA_HIGH_1ms					;ANCHO DE VENTANA (NIBBLE ALTO) 1ms
		LDI R21, VENTANA_LOW_1ms					;ANCHO DE VENTANA (NIBBLE BAJO) 1ms
		LDI R19, REPETIDOR_OVERFLOW_TIMER_1ms		;CANTIDAD DE VECES QUE SE DEBE HACER OVERFLOW AL TIMER 1 PARA QUE SE CUMPLA UNA VENTANA
		RJMP CARGAR_VENTANA							;UNA VEZ CONFIGURADO EL VALOR SE CARGA

	CONFIG_10ms:
		LDI R20, VENTANA_HIGH_10ms
		LDI R21, VENTANA_LOW_10ms
		LDI R19, REPETIDOR_OVERFLOW_TIMER_10ms
		RJMP CARGAR_VENTANA

	CONFIG_100ms:
		LDI R20, VENTANA_HIGH_100ms
		LDI R21, VENTANA_LOW_100ms
		LDI R19, REPETIDOR_OVERFLOW_TIMER_100ms
		RJMP CARGAR_VENTANA

	CONFIG_1000ms:
		LDI R20, VENTANA_HIGH_1000ms
		LDI R21, VENTANA_LOW_1000ms
		LDI R19, REPETIDOR_OVERFLOW_TIMER_1000ms
		RJMP CARGAR_VENTANA

	CARGAR_VENTANA:
		MOV MUL_DE_VENTANA, R19					;SE CARGA EL MULTIPLICADOR DE VENTANA
		STS OCR1AH, R20							;SE CARGA EL VALOR DE COMPARACIÓN DEL TIMER, EN OCR1AH|OCR1AL
		STS OCR1AL, R21							;AUTOMATICAMENTE CUANDO SE CARGA EL LOW NIBBLE, SE CARGAN AMBOS AL MISMO TIEMPO
		RJMP FIN_CONFIG_VENTANA					;SE TERMINÓ DE CONFIGURAR LA VENTANA, SE SALE DE LA FUNCIÓN

	FIN_CONFIG_VENTANA:
		POP R21
		POP R20
		POP R19
		RET

; ==================================================================
; Descripcion: carga la configuración de la cantidad de veces que se va a repetir la ventana.
; Recibe: VENTANAS_A_MEDIR_RAM
; Devuelve: VENTANAS_A_MEDIR_HIGH, VENTANAS_A_MEDIR_MID, VENTANAS_A_MEDIR_LOW
CONFIG_REPETIR_VENTANAS:

	LDS VENTANAS_A_MEDIR_HIGH, VENTANAS_A_MEDIR_RAM+2		;Se carga el nibble bajo de la configuración del usuario, en un registro VENTANAS_A_MEDIR_LOW
	MOV VENTANAS_A_MEDIR_LOW, VENTANAS_A_MEDIR_HIGH
	LDS VENTANAS_A_MEDIR_HIGH, VENTANAS_A_MEDIR_RAM+1		
	MOV VENTANAS_A_MEDIR_MID, VENTANAS_A_MEDIR_HIGH			;Se carga el nibble intermedio de la configuración del usuario, en un registro VENTANAS_A_MEDIR MID
	LDS VENTANAS_A_MEDIR_HIGH, VENTANAS_A_MEDIR_RAM			;Se carga el nibble alto de la configuración del usuario, en un registro VENTANAS_A_MEDIR HIGH

	RET


; ==================================================================
; Descripcion: inicializa el registro CONTADOR_DE_PULSOS, 
; donde se cuenta la cantidad de pulsos totales medidos.
; Recibe: CONTADOR_DE_PULSOS (R23)
; Devuelve: CONTADOR_DE_PULSOS (R23)
CONFIG_CONTADOR_DE_PULSOS:
	LDI CONTADOR_DE_PULSOS, 0x00
	STS CONTADOR_DE_PULSOS_RAM, CONTADOR_DE_PULSOS
	LDI CONTADOR_DE_PULSOS, 0x00
	STS CONTADOR_DE_PULSOS_RAM+1, CONTADOR_DE_PULSOS
	LDI CONTADOR_DE_PULSOS, 0x00
	STS CONTADOR_DE_PULSOS_RAM+2, CONTADOR_DE_PULSOS

	RET


; ==================================================================
; Descripcion: inicializa el timer 1 para realizar las mediciones. 
;              Se inicializa con prescaler dividido 64. 
; donde se cuenta la cantidad de pulsos totales medidos.
; Recibe: -
; Devuelve: CONTADOR_DE_PULSOS (R23)
CONF_TIMER1_MEDICION:
	PUSH R17

	LDS R17, TCCR1B						;SE CARGA EL DATO DEL TCCR1B EN R17
	ORI R17, (1<<CS10)|(1<<CS11)		;SE CONFIGURA EL PRESCALER A 16MHz/64 = 250 kHz == UNA CUENTA HASTA 262.14 ms
	ANDI R17, ~(1<<CS12)				
	STS TCCR1B, R17						;EN ESTE INSTANTE SE INICIA EL TIMER 1, ES DECIR, YA SE EMPEZÓ A MEDIR LOS PULSOS
	
	POP R17								;SE RECUPERA EL DATO GUARDADO PREVIAMENTE
	RET


; ==================================================================
; Descripcion: guarda los pulsos detectados en una variable en RAM.
; donde se cuenta la cantidad de pulsos totales medidos.
; Recibe: CONTADOR_DE_PULSOS
; Devuelve: CONTADOR_DE_PULSOS_RAM
ACUMULAR_PULSOS_DETECTADOS:

	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19

	LDI R19, 0x00

	LDS R16, CONTADOR_DE_PULSOS_RAM
	LDS R17, CONTADOR_DE_PULSOS_RAM+1
	LDS R18, CONTADOR_DE_PULSOS_RAM+2

	ADD R16, CONTADOR_DE_PULSOS					; Se suma el nibble bajo
	ADC R17, R19								; Si hay carry, se suma uno al nibble medio
	ADC R18, R19								; Si vuelve a haber carry se suma uno al nibble alto

	STS CONTADOR_DE_PULSOS_RAM, R16				; Se guardan los datos actualizados
	STS CONTADOR_DE_PULSOS_RAM+1, R17
	STS CONTADOR_DE_PULSOS_RAM+2, R18


	POP R19
	POP R18
	POP R17
	POP R16
	
	RET



; ==================================================================
; Descripcion: carga la configuración seteada por el usuario en los registros determinados 
;              e inicializa el TIMER 1 para realizar las mediciones.
; Recibe: -
; Devuelve: -
INICIAR_MEDICION:

	PUSH VENTANA_DE_TIEMPO
	

	LDS VENTANA_DE_TIEMPO, REGISTRO_VENTANA_TIEMPO		;Se carga la configuración de la duración de la ventana
	CALL CONFIG_VENTANA_DE_TIEMPO						;Se setea la configuración del timer según lo indicado previamente por el usario

	STS MUL_DE_VENTANA_RAM, MUL_DE_VENTANA				;Se guarda la configuración del multiplicador de ventana en RAM.

	CALL CONFIG_REPETIR_VENTANAS						;Se carga la configuración seteada por el usuario, en los registros correspondientes, para iniciar mediciones,
														;de la cantidad de ventanas a medir
	CALL CONFIG_CONTADOR_DE_PULSOS						;Se inicializa el registro R23, donde se guarda la cantidad de pulsos, en 0. Además se inicializa el
														;contador en RAM, en 0

	POP VENTANA_DE_TIEMPO
	RET

; ==================================================================
; Descripcion: Verifica si se ha superado el valor del umbral y 
;              enciende el LED/BUZZER si eso ha ocurrido
; Recibe: CONTADOR_DE_PULSOS, REGISTRO_UMBRAL, REGISTRO_CONF_GENERAL
; Devuelve: -

VERIFICAR_UMBRAL:

	PUSH R16

	; Comparar LSB
	LDS R16, REGISTRO_UMBRAL
	CP R16, CONTADOR_DE_PULSOS

	; Si el valor de CONTADOR_DE_PULSOS es mayor al umbral, encender LED/BUZZER
	; sino, apagarlos y retornar
	BRLO _ENCENDER_SENAL_VERIFICAR_UMBRAL

	; Apagar LED
	CBI PORTB, PIN_PORTB_LED

	; Apagar buzzer
	CBI PORTB, PIN_PORTB_BUZZER

	RJMP _RET_VERIFICAR_UMBRAL

_ENCENDER_SENAL_VERIFICAR_UMBRAL:
	; Encender LED
	SBI PORTB, PIN_PORTB_LED

	; Chequear si se ha configurado el buzzer para encenderse cuando se supera el umbral
	LDS R16, REGISTRO_CONF_GENERAL
	SBRC R16, BIT_SENAL_SONORA
	SBI PORTB, 3

_RET_VERIFICAR_UMBRAL:
	POP R16
	RET

; ==================================================================
; Descripcion: Verifica si se le ha indicado al dispositivo que apague el tubo del contador.
;			   Para eso, chequea REGISTRO_CONF_GENERAL
; Recibe: REGISTRO_CONF_GENERAL
; Devuelve: -
; NOTA: EL TUBO DEL CONTADOR SE ENCIENDE PONIENDO UN '0' EN EL PUERTO DE SALIDA
VERIFICAR_APAGADO_TUBO:
	LDS R16, REGISTRO_CONF_GENERAL
	SBRC R16, BIT_ACTIVAR_FUENTE
	RJMP _DESACTIVAR_FUENTE

	; Encender el tubo del contador
	SBI PORTB, PUERTO_ACTIVAR_CONTADOR

	RET

_DESACTIVAR_FUENTE:
	CBI PORTB, PUERTO_ACTIVAR_CONTADOR
	RET