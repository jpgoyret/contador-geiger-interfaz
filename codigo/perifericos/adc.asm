; ==================================================================
; Archivo: adc.asm
; Descripcion: funciones asociadas al ADC

; Usos del ADC:
; 1) Identificar que tecla fue presionada en el teclado de la pantalla
;    LDC
; ==================================================================

; ============================ REGISTROS ADC =======================
; REGISTRO ADCSRA:
; ADEN | ADSC | ADATE | ADIF | ADIE | ADPS2 | ADPS1 | ADPS0
; ADEN =1 habilita el ADC; 
; ADSC = 1 empieza la conversion; 
; ADATE = 1 auto trigger, 
; ADIF = 1 flag de ADC completado y actalizado; 
; ADIE = 1 seta la interrupcion del ADC cuando se completó la conversión; 
; ADPS2 a ADPS0: configuracion de prescaler
; ========================= FIN REGISTROS ADC =======================

; ===================================================================
; Interrupcion: ADC
; Descripcion: se activa cuando el ADC ha finalizado de convertir un valor
; analogico a su entrada
; Recibe: -
; Devuelve: -
ADC_ISR:
	PUSH aux_1
	IN aux_1, SREG
	PUSH aux_1

	; Activar evento de que se ha presionado una tecla
	SBR EVENTO, (1<<TECLA_PRESIONADA)

	POP aux_1
	OUT SREG, aux_1
	POP aux_1

	RETI



; ===================================================================
; Descripcion: configurar teclado
; Recibe: -
; Devuelve: -
CONF_ADC:
	; Configurar la AVCC como la referencia externa del ADC
	SET_BIT ADMUX, REFS0
	CLEAR_BIT ADMUX, ADLAR

	; Activar la interrupcion del ADC
	SET_BIT ADCSRA, ADIE

	; Configurar el prescaler en 128
	SET_BIT ADCSRA, ADPS0
	SET_BIT ADCSRA, ADPS1
	SET_BIT ADCSRA, ADPS2
		
	RET
