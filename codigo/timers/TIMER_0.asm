; ==================================================================
; Archivo: TIMER_0.asm
; Descripcion: biblioteca con funciones para manejo del timer 0

; Usos del timer 0:
; 1) Identificar un timeout (o exceso de tiempo)
; en la recepcion de una cadena de caracteres por UART.
; Este genera una interrupcion si ha transcurrido un cierto tiempo
; desde la llegada de un primer caracter sin que se haya recibido un
; caracter de fin de trama
;
; 2) Debouncer para detectar la pulsaci�n de una tecla en el teclado 
;    mediante el comparador y el ADC
;
; ==================================================================


; ====================== REGISTROS TIMER 0 =========================
; REGISTRO TCCR0B:
; [FOC0A][FOC0B][-][-][WGM02][CS02][CS01][CS00]

;CS12|CS11|CS10: Definen el prescaler del timer 0.
;000 -> Timer apagado
;001 -> Encendido, sin prescaler
;010 -> clk/8
;011 -> clk/64
;100 -> clk/256
;101 -> clk/1024
;110 -> Se utiliza para configurar un clock externo, por el pin CONT_TIMER0_HIGH
;111 -> Idem 110

;**************************************************************
; REGISTRO TIMSK0:
; [-][-][-][-][-][OCIEB][OCIEA][TOIE]

; TOIE1: Si se setea, se habilita la interrupci�n por overflow del TIMER0.

;**************************************************************
; REGISTRO TCNT0: almacena el valor del timer.

; ====================== FIN REGISTROS TIMER 0 ======================


; ===================================================================
; ==================== Variables auxiliares ==========================
; ===================================================================
; R2 Y R3 deben ser reservados para el timer dado que son contadores 
; de la cantidad de overflows que se produjeron hasta un determinado
; instante en el tiempo
.DEF CONT_TIMER0_LOW = R2
.DEF CONT_TIMER0_HIGH = R3

; ===================================================================
; ==================== Registros en RAM =============================
; ===================================================================
.dseg
; Descripcion: registro que almacena el motivo por el cual se ha iniciado
; el timer0
MOTIVO_TIMER0: .BYTE 1
; Cada bit posee asociado un motivo:
; 0 = overflow uart
; 1 = teclado

.cseg

; ===================================================================
; ==================== Constantes ===================================
; ===================================================================
; Motivos de activacion del timer 0
.equ MOTIVO_TIMER0_UART = 0
.equ MOTIVO_TIMER0_TECLADO = 1
.equ MOTIVO_TIMER0_TECLADO_POST_PRESION = 2

; Clock interno, prescaler = 64
; --> con clk=16MHz, aproximadamente 1ms hasta que se llega a MAX 
.equ CLOCK_TIMER = 3

; Numero de ocurrencias de overflow del timer0 que tiene que ocurrir
; para que se produzca un timeout
.equ TIMEOUT_CONT_TIMER0_LOW_UMBRAL = 130
; Con el prescaler configurado en 64, transcurren aproximadamente 62ms
; desde la recepcion del primer caracter hasta el timeout.
; Dado que para un buffer de 60 caracteres con transmision serie
; de 76800 baudios el tiempo aproximado desde la recepcion del primer caracter
; hasta el n�mero 60 (suponiendo que la transmsion entre la PC y
; el microcontrolador no sufre interrupciones durante todo el proceso) 
; es de: 60*8/76800 = 6ms, entonces el tiempo
; transcurrido hasta un timeout es aproximadamente 10 ese valor 

; ===================================================================
; ==================== Interrupciones ===============================
; ===================================================================

; Interrupcion: Timer/Counter0 Overflow
; Descripcion: se dispara cuando el timer0 ha superado 0xFF y se ha
; limpiado.
; Recibe: -
; Devuelve: -
OVERFLOW_TIMER0:

	PUSH R16
	IN	R16, SREG
	PUSH R16	; salva en la pila el estado actual de los flags (C, N, V y Z)

	LDI R16, 1
	ADD CONT_TIMER0_LOW, R16
	LDI R16, 0
	ADC CONT_TIMER0_HIGH, R16

	LDI R16, HIGH(TIMEOUT_CONT_TIMER0_LOW_UMBRAL)
	CP CONT_TIMER0_HIGH, R16
	BRNE _RETORNAR_OVERFLOW_TIMER0

	LDI R16, LOW(TIMEOUT_CONT_TIMER0_LOW_UMBRAL)
	CP CONT_TIMER0_LOW, R16
	BRNE _RETORNAR_OVERFLOW_TIMER0

	; Analizar el motivo por el cual se llamo al timer0 en un principio
	LDS R16, MOTIVO_TIMER0

	SBRC R16, MOTIVO_TIMER0_UART
	RJMP _TIMEOUT_OVERFLOW_TIMER0

	SBRC R16, MOTIVO_TIMER0_TECLADO
	RJMP _TECLADO_OVERFLOW_TIMER0

	SBRC R16, MOTIVO_TIMER0_TECLADO_POST_PRESION
	RJMP _TECLADO_OVERFLOW_TIMER0_POST_PRESION

	RJMP _RETORNAR_OVERFLOW_TIMER0

_TIMEOUT_OVERFLOW_TIMER0:

	; Limpiar motivo del evento
	CBR R16, (1<<MOTIVO_TIMER0_UART)
	STS MOTIVO_TIMER0, R16

	; Indicar que se produjo un error de timeout en el registro de eventos
	SBR EVENTO, (1<<TIMEOUT_UART)

	CALL APAGAR_TIMER_0
	RJMP _RETORNAR_OVERFLOW_TIMER0

_TECLADO_OVERFLOW_TIMER0:
	
	; Limpiar motivo del evento
	CBR R16, (1<<MOTIVO_TIMER0_TECLADO)
	STS MOTIVO_TIMER0, R16
		
	; Hacer una conversion
	SET_BIT ADCSRA, ADSC 

	CALL APAGAR_TIMER_0
	RJMP _RETORNAR_OVERFLOW_TIMER0

_TECLADO_OVERFLOW_TIMER0_POST_PRESION:

	; Limpiar motivo del evento
	CBR R16, (1<<MOTIVO_TIMER0_TECLADO_POST_PRESION)
	STS MOTIVO_TIMER0, R16
		
	; Desactivar el ADC para activar el comparador
	CLEAR_BIT ADCSRA, ADEN

	CALL APAGAR_TIMER_0
	RJMP _RETORNAR_OVERFLOW_TIMER0

_RETORNAR_OVERFLOW_TIMER0:
	POP	R16
	OUT	SREG, R16	; Reestablece los flags 
	POP R16	
	RETI

; ===================================================================
; ==================== Funciones generales ==========================
; ===================================================================

; Descripcion: encender timer0 con una configuracion determinada de clock
; Recibe: -
; Devuelve: -
ENCENDER_TIMER_0:
	; Configurar velocidad de funcionamiento del timer
	WRITE_REG TCCR0B,  CLOCK_TIMER
	RET

; ================================================
; Descripcion: apaga timer0
; Recibe: *
; Devuelve: -
APAGAR_TIMER_0:
	; Limpiar los contadores de overflow
	CLR CONT_TIMER0_LOW
	CLR CONT_TIMER0_HIGH
	; Resetear el contador del timer
	WRITE_REG TCNT0, 0 ; TODO: ver si es necesario hacer esto siempre
	WRITE_REG TCCR0B,  0
	RET


; ================================================
; Descripcion: activar interrupcion por overflow
; Recibe: -
; Devuelve: -
ACTIVAR_ISR_TIMER0_OV:
	SET_BIT TIMSK0, TOIE0
	RET

; ================================================
; Descripcion: desactivar interrupcion por overflow
; Recibe: -
; Devuelve: -
DESACTIVAR_ISR_TIMER0_OV:
	CLEAR_BIT TIMSK0, TOIE0
	RET


; ============================================================================
; Descripcion: indica si el teclado se encuentra en uso verificando si el timer
; se encuentra encendido por ese motivo.
; Recibe: -
; Devuelve: bit de carry en 1 si el teclado se encuentra en uso o 0 en caso
; contrario.
CHEQUEAR_TECLADO_EN_USO:
	LDS R16, MOTIVO_TIMER0

	CLC

	SBRC R16, MOTIVO_TIMER0_TECLADO
	SEC

	SBRC R16, MOTIVO_TIMER0_TECLADO_POST_PRESION
	SEC

	RET

; ============================================================================
; Descripcion: indica si el timer 0 se encuentra en uso por la uart.
; Recibe: -
; Devuelve: bit de carry en 1 si el teclado se encuentra en uso o 0 en caso
; contrario.
CHEQUEAR_UART_EN_USO:
	LDS R16, MOTIVO_TIMER0
	
	CLC

	SBRC R16, MOTIVO_TIMER0_UART
	SEC

	RET
