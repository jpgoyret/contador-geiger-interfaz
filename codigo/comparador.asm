; Descripcion: funciones para configurar el comparador

; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

; Descripcion: configurar comparador para utilizando para el teclado
; Recibe: -
; Devuelve: -
CONF_COMPARADOR:

	CONF_LED_ARDUINO ; TODO: ES UNA LINEA DE PRUEBA. REMOVER

	; Activar multiplexor para elegir el puerto negativo del comparador
	SET_BIT ADCSRB, ACME
	
	; Desactivar el ADC para poder realizar una comparacion recibiendo datos por el puerto PC0
	CLEAR_BIT ADCSRA, ADEN

	; Configurer como puerto negativo al PC0
	CLEAR_BIT ADMUX, MUX0
	CLEAR_BIT ADMUX, MUX1
	CLEAR_BIT ADMUX, MUX2
	CLEAR_BIT ADMUX, MUX3

	; Configurar la interrupcion del comparador para que
	; salte cuando este saca un 1 logico
	SET_BIT ACSR, ACIS1
	CLEAR_BIT ACSR, ACIS0

	; Configurar el bandgap
	SET_BIT ACSR, ACBG

	; Activar la interrupcion del comparador
	SET_BIT ACSR, ACIE

	RET

; Descripcion: interrupcion del comparador
INTERRUPCION_COMPARADOR:

	PUSH R16
	IN	R16, SREG
	PUSH R16	; salva en la pila el estado actual de los flags (C, N, V y Z)

	; Chequear si el timer0 se encuentra en uso por parte de la UART. Si es asi, no realizar
	; ninguna accion para evitar una colision
	CALL CHEQUEAR_UART_EN_USO
	BRCS _RET_INTERRUPCION_COMPARADOR

	; Encender timer0 para esperar cierto tiempo hasta realizar la conversion 
	LDS R16, MOTIVO_TIMER0
	SBR R16, (1<<MOTIVO_TIMER0_TECLADO)
	STS MOTIVO_TIMER0, R16
	CALL ENCENDER_TIMER_0

	; Encender el ADC (esto impedirá recibir datos por el puerto PC0 durante la conversion)
	SET_BIT ADCSRA, ADEN

	POP R16
	OUT	SREG, R16
	POP R16	; salva en la pila el estado actual de los flags (C, N, V y Z)

_RET_INTERRUPCION_COMPARADOR:
	RETI