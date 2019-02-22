;Fede: En este archivo pongo la inicialización del TIMER2, que voy a usar para los delays del LCD.
;REGISTRO TCCR2B:

;[FOC2A][FOC2B][-][-][WGM22][CS22][CS21][CS20]

;CS22|CS21|CS20: Definen el prescaler del TIMER2.
;000 -> Timer apagado
;001 -> Encendido, sin prescaler
;010 -> clk/8
;011 -> clk/64
;100 -> clk/256
;101 -> clk/1024
;110 -> Se utiliza para configurar un clock externo, por el pin T0
;111 -> Idem 110


;************************************************************************************************

;REGISTRO TIMSK2:

;[-][-][-][-][-][OCIE2B][OCIE2A][TOIE2]

;TOIE2: Si se setea, se habilita la interrupción por overflow del TIMER2.

;************************************************************************************************

;REGISTRO TIFR2:

;[-][-][-][-][-][OCF2B][OCF2A][TOV2]

;TOV2: Cuando hay overflow en el TIEMER2, se setea. Si están habilitadas las interrupciones globales y la interrupción por 
;overflow, se ejecuta la interrupción.

INIT_TIMER_2:
;Se inicializa el timer 2. Particularmente se utiliza para funciones de delay para la pantallita LCD.
;Se utiliza un prescaler de clk/8, y dado que el clock es de 16MHz -> este timer cuenta hasta 127 us.
;REGISTROS UTILIZADOS: R17

	PUSH R17							;Se pushea en el stack, el dato del registro R17, para no perderlo	
	LDS R17, TCCR2B						;Se carga el registro TCCR2B para modificarlo
	ORI R17, (1<<CS21)					;CS21 = 1
	ANDI R17, ~((1<<CS20)|(1<<CS22))	;CS20 = CS22 = 0, con esta configuración el prescaler se encuentra en clk/8
	STS  TCCR2B, R17				;Se carga la configuración en el registro del TIMER2
	
	LDS R17, TIMSK2						;Se carga el registro TIMSK2, para modificarlo
	ORI R17, (1<<TOIE2)					;Se setea el bit para habilitar las interrupciones por overflow del TIMER2
	STS TIMSK2, R17						;Se carga la configuración en el registro TIMSK0
	POP R17								;Se recupera el dato precargado
	RET

;************************************************************************************************
PRENDER_TIMER_2:
	
	PUSH R17							;Se pushea en el stack, el dato del registro R17, para no perderlo	
	LDS R17, TCCR2B						;Se carga el registro TCCR2B para modificarlo
	ORI R17, (1<<CS21)					;CS21 = 1
	ANDI R17, ~((1<<CS20)|(1<<CS22))	;CS20 = CS22 = 0, con esta configuración el prescaler se encuentra en clk/8
	STS  TCCR2B, R17				;Se carga la configuración en el registro del TIMER2
	POP R17
	RET