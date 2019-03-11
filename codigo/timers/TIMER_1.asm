; ==================================================================
; Archivo: TIMER_1.asm
; Descripcion: biblioteca con funciones para manejo del timer 1

; Usos del timer 1:
; 1) Guardar los instantes de tiempo de los pulsos capturados
;
; ==================================================================

; ====================== REGISTROS TIMER 1 =========================

;REGISTRO TCCR1B:
;[ICNC1][ICES1][-][WGM13][WGM12][CS12][CS11][CS10]

;ICNC1: Si está seteado se filtra la entrada del pin ICP1
;ICES1: Si está seteado, se captura por flanco ascendente en ICP1

;CS12|CS11|CS10: Definen el prescaler del TIMER2.
;000 -> Timer apagado
;001 -> Encendido, sin prescaler
;010 -> clk/8
;011 -> clk/64
;100 -> clk/256
;101 -> clk/1024
;110 -> Se utiliza para configurar un clock externo, por el pin T1
;111 -> Idem 110

;
; ==================================================================
;REGISTROS: ICR1H|ICR1L
;En ellos se guarda el dato capturado del instante de tiempo del timer 1. Para sacar el valor de este registro y guardarlo
;en otro lado, se debe leer primero el ICR1L. Cuando se lee este primer registro automáticamente se guarda el valor de
;ICR1H en un registro temporario TEMP, de donde se puede levantar el dato.


; ==================================================================
;REGISTRO TIMSK1:

;[-][-][ICIE1][-][-][OCIE1B][OCIE1A][TOIE1]

;ICIE1: Si está seteado y las interrupciones globales están activadas, se activa la interrupción por detección
;de flanco en ICP1.

;TOIE1: Si se setea, se habilita la interrupción por overflow del TIMER1.


; =================================================================
;REGISTRO TIFR1:
;[-][-][ICF1][-][-][OCF1B][OCF1A][TOV1]

;ICF1: Cuando se detecta un flanco en ICP1, se setea automáticamente. Luego de ejectudada la interrupción, se vuelve a poner en 0
;automáticamente.

;TOV1: Cuando hay overflow en el TIEMER1, se setea. Si están habilitadas las interrupciones globales y la interrupción por 
;overflow, se ejecuta la interrupción.

; ====================== FIN REGISTROS TIMER 1 ======================


; ===================================================================
; ==================== Funciones generales ==========================
; ===================================================================

; Interrupcion: flanco detectado en ICP1  
; Descripcion: se incrementa el contador de pulsos en 1 y 
;              se guarda el instante de tiempo en RAM.
; Recibe: -
; Devuelve: MUL_DE_VENTANA
INTERRUPCION_PULSO_DETECTADO:
	PUSH R16
	IN R16, SREG
	PUSH R16

	INC CONTADOR_DE_PULSOS			;SE INCREMENTA EL CONTADOR DE PULSOS EN 1

	SBR EVENTO, (1<<PULSO_RECIBIDO) ; ACTIVAR EL BIT DEL EVENTO INDICADOR DE QUE SE RECIBIO UN PULSO 

	POP R16
	OUT SREG, R16
	POP R16
			
	RETI

; ==================================================================
; Interrupcion: Interrupción por comparación del TIMER 1 
; Descripcion: Se decrementa la cantidad de veces a medir en 1
; Recibe: VENTANAS_A_MEDIR
; Devuelve: MUL_DE_VENTANA
INTERRUPCION_FIN_VENTANA:
	PUSH R16
	IN R16, SREG
	PUSH R16

	; CONFIGURAR EVENTO DE DISMINUCION DE MUL DE VENTANA
	LDS R16, EVENTO2
	SBR R16, (1<<BIT_MUL_VENTANA_DEC)
	STS EVENTO2, R16
	; ======

	DEC MUL_DE_VENTANA
	BRNE FIN_ISR_VENTANA
	POP R16
	ORI R16, (1<<SREG_T)
	OUT SREG, R16
	POP R16
	RETI
FIN_ISR_VENTANA:

	POP R16
	OUT SREG, R16
	POP R16

	RETI

; ==================================================================
; Decripcion: se inicializa el TIMER1, 
; que se utiliza para capturar el instante de tiempo de los pulsos. 
; Se setea su prescaler, y se habilitan las interrupciones por flanco en el pin ICP1 
; y detección por flanco ascendente.
; Recibe: -
; Devuelve: -
INIT_TIMER_1:

	PUSH R17
	LDS R17, TCCR1B						;SE CARGA EL DATO DEL TCCR1B EN R17
	ANDI R17, ~((1<<ICES1)|(1<<CS11)|(1<<CS12)|(1<<CS10))
	ORI R17, (1<<ICNC1)|(1<<WGM12)
	STS TCCR1B, R17						;SE GUARDA LA CONFIGURACIÓN EN LA POSICIÓN DEL REGISTRO
	
	LDS R17, TIMSK1						;SE CARGA EL DATO DE LA CONFIGURACIÓN DE INTERRUPCIONES DEL TIMER 1
	ORI R17, (1<<ICIE1)|(1<<OCIE1A)		;SE HABILITA LA INTERRUPCIÓN POR DETECCIÓN DE FLANCO Y POR COMPARACION DEL TIMER 1
	STS TIMSK1, R17						;SE GUARDA LA CONFIGURACIÓN DE INTERRUPCIONES DEL TIMER 1
	POP R17
	RET

; ===================================================================
; Decripcion: se inhabilita el TIMER 1, al finalizar la medición total.
; Recibe: -
; Devuelve: -
APAGAR_TIMER_1:
	PUSH R17

	LDS R17, TCCR1B
	ANDI R17, ~((1<<CS11)|(1<<CS12)|(1<<CS10))
	STS TCCR1B, R17

	POP R17
	RET
