; ==================================================================
; Archivo: teclado.asm
; Descripcion: funciones para manejo del teclado
; ==================================================================

; ===================================================================
; ========================= Registros auxiliares ====================
; ===================================================================

.UNDEF aux_1
.UNDEF aux_2
.DEF aux_1 = R16
.DEF aux_2 = R17

.UNDEF key_low
.UNDEF key_high
.DEF key_low = R18
.DEF key_high = R19

; ===================================================================
; ========================= Constantes ==============================
; ===================================================================

.EQU KEY_DDR = DDRC
.EQU KEY_PORT = PORTC

.EQU KEY_1_MIN_LOW = 0x33	;	V1_MIN = 1.5 V ; ADC = 307 --> 0x0133
.EQU KEY_1_MIN_HIGH = 0x01

.EQU KEY_1_MAX_LOW = 0x9A	;	V1_MAX = 2 V ; ADC = 410 --> 0x019A
.EQU KEY_1_MAX_HIGH = 0x01
;========================================================================
.EQU KEY_2_MIN_LOW = 0xB8	;	V2_MIN = 2.15 V ; ADC = 440 --> 0x01B8
.EQU KEY_2_MIN_HIGH = 0x01

.EQU KEY_2_MAX_LOW = 0x1F	;	V2_MAX = 2.65 V ; ADC = 543 --> 0x021F
.EQU KEY_2_MAX_HIGH = 0x02
;========================================================================
.EQU KEY_3_MIN_LOW = 0x3D	;	V3_MIN = 2.8V ; ADC = 573 --> 0x023D
.EQU KEY_3_MIN_HIGH = 0x02
	
.EQU KEY_3_MAX_LOW = 0xA4	;	V3_MAX = 3.3 V ; ADC = 676 --> 0x02A4
.EQU KEY_3_MAX_HIGH = 0x02	
;========================================================================
.EQU KEY_4_MIN_LOW = 0xC2	;	V4_MIN = 3.45 V ; ADC = 706 --> 0x02C2
.EQU KEY_4_MIN_HIGH = 0x02

.EQU KEY_4_MAX_LOW = 0x29	;	V4_MAX = 3.95 V ; ADC = 809 --> 0x0329
.EQU KEY_4_MAX_HIGH = 0x03
;========================================================================
.EQU KEY_5_MIN_LOW = 0x47	;	V5_MIN = 4.1 V ; ADC = 839 --> 0x0347
.EQU KEY_5_MIN_HIGH = 0x03

.EQU KEY_5_MAX_LOW = 0xAF	;	V5_MAX = 4.6 V ; ADC = 943 --> 0x03AF
.EQU KEY_5_MAX_HIGH = 0x03
;========================================================================
.EQU KEY_6_MIN_LOW = 0xCC	;	V6_MIN = 4,75V ; ADC = 972,8 --> 0x03CC
.EQU KEY_6_MIN_HIGH = 0x03

.EQU KEY_6_MAX_LOW = 0x34	;	V6_MAX = 5,25V ; ADC = 1075,2 --> 0x0434
.EQU KEY_6_MAX_HIGH = 0x04
;========================================================================
.EQU KEY_1_REG = 0x01
.EQU KEY_2_REG = 0x02
.EQU KEY_3_REG = 0b00000100
.EQU KEY_4_REG = 0b00001000
.EQU KEY_5_REG = 0b00010000
.EQU KEY_6_REG = 0b00100000
.EQU KEY_ERROR_REG = 0b10000000


; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

; Descripcion: leer el resultado de una medicion del ADC y setea un bit
; de acuerdo a la tecla que fue presionada
; Recibe: -
; Devuelve: -
ADC_LEER_TECLA:

	LDS aux_1, ADCL
	LDS aux_2, ADCH

	PUSH R16

	; Encender timer0 para esperar cierto tiempo hasta activar nuevamente el boton 
	LDS R16, MOTIVO_TIMER0
	SBR R16, (1<<MOTIVO_TIMER0_TECLADO_POST_PRESION)
	STS MOTIVO_TIMER0, R16
	CALL ENCENDER_TIMER_0

	POP R16

	; Limpiar el bit de evento asociado a una tecla presionada
	CBR EVENTO, (1<<TECLA_PRESIONADA)
		
	LOWER_OR_EQUAL_KEY_6_MAX:
			LDI key_low, KEY_6_MAX_LOW
			LDI key_high, KEY_6_MAX_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRLO HIGHER_OR_EQUAL_KEY_6_MIN
			RJMP SET_KEY_ERROR_REG
	HIGHER_OR_EQUAL_KEY_6_MIN:
			LDI key_low, KEY_6_MIN_LOW
			LDI key_high, KEY_6_MIN_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRSH SET_KEY_6_REG
	LOWER_OR_EQUAL_KEY_5_MAX:
			LDI key_low, KEY_5_MAX_LOW
			LDI key_high, KEY_5_MAX_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRLO HIGHER_OR_EQUAL_KEY_5_MIN
			RJMP SET_KEY_ERROR_REG
	HIGHER_OR_EQUAL_KEY_5_MIN:
			LDI key_low, KEY_5_MIN_LOW
			LDI key_high, KEY_5_MIN_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRSH SET_KEY_5_REG		
	LOWER_OR_EQUAL_KEY_4_MAX:
			LDI key_low, KEY_4_MAX_LOW
			LDI key_high, KEY_4_MAX_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRLO HIGHER_OR_EQUAL_KEY_4_MIN
			RJMP SET_KEY_ERROR_REG
	HIGHER_OR_EQUAL_KEY_4_MIN:
			LDI key_low, KEY_4_MIN_LOW
			LDI key_high, KEY_4_MIN_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRSH SET_KEY_4_REG
	LOWER_OR_EQUAL_KEY_3_MAX:
			LDI key_low, KEY_3_MAX_LOW
			LDI key_high, KEY_3_MAX_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRLO HIGHER_OR_EQUAL_KEY_3_MIN
			RJMP SET_KEY_ERROR_REG
	HIGHER_OR_EQUAL_KEY_3_MIN:
			LDI key_low, KEY_3_MIN_LOW
			LDI key_high, KEY_3_MIN_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRSH SET_KEY_3_REG
	LOWER_OR_EQUAL_KEY_2_MAX:
			LDI key_low, KEY_2_MAX_LOW
			LDI key_high, KEY_2_MAX_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRLO HIGHER_OR_EQUAL_KEY_2_MIN
			RJMP SET_KEY_ERROR_REG
	HIGHER_OR_EQUAL_KEY_2_MIN:
			LDI key_low, KEY_2_MIN_LOW
			LDI key_high, KEY_2_MIN_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRSH SET_KEY_2_REG
	LOWER_OR_EQUAL_KEY_1_MAX:
			LDI key_low, KEY_1_MAX_LOW
			LDI key_high, KEY_1_MAX_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRLO HIGHER_OR_EQUAL_KEY_1_MIN
			RJMP SET_KEY_ERROR_REG
	HIGHER_OR_EQUAL_KEY_1_MIN:
			LDI key_low, KEY_1_MIN_LOW
			LDI key_high, KEY_1_MIN_HIGH
			CP aux_1, key_low
			CPC aux_2, key_high
			BRSH SET_KEY_1_REG
			RJMP SET_KEY_ERROR_REG

	SET_KEY_6_REG:
			LDI aux_1, KEY_6_REG
			LDI aux_2, 1<<ADSC
			RET

	SET_KEY_5_REG:
			LDI aux_1, KEY_5_REG
			LDI aux_2, 1<<ADSC
			RET

	SET_KEY_4_REG:
			LDI aux_1, KEY_4_REG
			LDI aux_2, 1<<ADSC
			RET

	SET_KEY_3_REG:
			LDI aux_1, KEY_3_REG
			LDI aux_2, 1<<ADSC
			RET

	SET_KEY_2_REG:
			LDI aux_1, KEY_2_REG
			LDI aux_2, 1<<ADSC
			RET

	SET_KEY_1_REG:
			LDI aux_1, KEY_1_REG
			LDI aux_2, 1<<ADSC
			RET

	SET_KEY_ERROR_REG:
			LDI aux_1, KEY_ERROR_REG
			LDI aux_2, 1<<ADSC
			RET
