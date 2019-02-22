; timers.asm
; Created: 24/10/2018 9:16
; Author : Juan Pablo Goyret
; Descripcion: biblioteca con macros utiles


; Descripcion: limpia el bit @1 en el resistro @0
.MACRO CLEAR_BIT
.if	@0<0x40
		IN R16, @0
.else
		LDS	R16, @0
.endif
	ANDI R16, ~(1 << @1) 
.if	@0<0x40
		OUT @0,R16
.else
		STS	@0,R16
.endif
.ENDMACRO

; Descripcion: activa el bit @1 en el resistro @0
.MACRO SET_BIT
.if	@0<0x40
		IN R16, @0
.else
		LDS	R16, @0
.endif
	ORI R16, (1 << @1) 
.if	@0<0x40
		OUT @0,R16
.else
		STS	@0,R16
.endif
.ENDMACRO

; Descripcion: pone todo el registro @0 en cero
; salvo por el bit @1
.MACRO WRITE_REG
	LDI R16, @1 
.if	@0<0x40
		OUT @0,R16
.else
		STS	@0,R16
.endif
.ENDMACRO

; Descripcion: hace un push al stack de dos registros @0 y @1
.MACRO PUSH_WORD
	PUSH @0
	PUSH @1
.ENDMACRO

; Descripcion: hace un pop del stack de dos registros @0 y @1
.MACRO POP_WORD
	POP @1
	POP @0
.ENDMACRO

; Descripcion: sumar dos registros de 16 bits
; Parametros: @0 (MSB del primer registro)
;             @1 (LSB del primer registro)
;             @2 (MSB del segundo registro)
;             @3 (LSB del segundo registro)
.MACRO SUMAR_REGISTROS_16_BITS
	ADD @1, @3
	ADC @0, @2 
.ENDMACRO


; Descripcion: sumar dos registros de 24 bits
; Parametros: @0 (MSB del primer registro)
;             @1 (byte intermedio del primer registro)
;             @2 (LSB del primer registro)
;             @3 (MSB del segundo registro)
;             @4 (byte intermedio del segundo registro)
;             @5 (LSB del segundo registro)
.MACRO SUMAR_REGISTROS_24_BITS
	ADD @2, @5
	ADC @1, @4
	ADC @0, @3 
.ENDMACRO

; ===================================================================
; ==================== Macros de debugging ==========================
; ===================================================================

; Descripcion: hacer un toggle del led del Arduino
.MACRO TOGGLE_LED_ARDUINO
	PUSH R16
	PUSH R17

	IN  R16, PORTB
	LDI R17, (1 << 5)
	EOR R16, R17
	OUT PORTB, R16

	POP R17
	POP R16
.ENDMACRO


; Descripcion: encender LED del Arduino
.MACRO ENCENDER_LED_ARDUINO
	PUSH R16

	IN  R16, PORTB
	ORI R16, (1 << 5)
	OUT PORTB, R16

	POP R16
.ENDMACRO

; Descripcion: encender LED del Arduino
.MACRO APAGAR_LED_ARDUINO
	PUSH R16

	IN  R16, PORTB
	ANDI R16, ~(1 << 5)
	OUT PORTB, R16
	
	POP R16
.ENDMACRO

; Descripcion: configurar pin del Arduino que posee un LED conectado
; para encenderlo a gusto
.MACRO CONF_LED_ARDUINO
	PUSH R16

/*	IN R16, DDRB
	SBR R16, 5*/

	SBI DDRB, 5
	CBI PORTB, 5 

/*	LDI R16, (1 << 5)
	OUT DDRB, R16
	LDI R16, ~(1 << 5)
	OUT PORTB, R16*/

	POP R16
.ENDMACRO