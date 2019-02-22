;Fede: En este archivo pongo la inicializaci�n del TIMER1, que se usa para guardar los instantes de tiempo de los pulsos capturados

;REGISTRO TCCR1B:

;[ICNC1][ICES1][-][WGM13][WGM12][CS12][CS11][CS10]

;ICNC1: Si est� seteado se filtra la entrada del pin ICP1
;ICES1: Si est� seteado, se captura por flanco ascendente en ICP1

;CS12|CS11|CS10: Definen el prescaler del TIMER2.
;000 -> Timer apagado
;001 -> Encendido, sin prescaler
;010 -> clk/8
;011 -> clk/64
;100 -> clk/256
;101 -> clk/1024
;110 -> Se utiliza para configurar un clock externo, por el pin T1
;111 -> Idem 110
;************************************************************************************************
;REGISTROS: ICR1H|ICR1L

;En ellos se guarda el dato capturado del instante de tiempo del timer 1. Para sacar el valor de este registro y guardarlo
;en otro lado, se debe leer primero el ICR1L. Cuando se lee este primer registro autom�ticamente se guarda el valor de
;ICR1H en un registro temporario TEMP, de donde se puede levantar el dato.

;************************************************************************************************

;REGISTRO TIMSK1:

;[-][-][ICIE1][-][-][OCIE1B][OCIE1A][TOIE1]

;ICIE1: Si est� seteado y las interrupciones globales est�n activadas, se activa la interrupci�n por detecci�n
;de flanco en ICP1.

;TOIE1: Si se setea, se habilita la interrupci�n por overflow del TIMER1.

;************************************************************************************************

;REGISTRO TIFR1:

;[-][-][ICF1][-][-][OCF1B][OCF1A][TOV1]

;ICF1: Cuando se detecta un flanco en ICP1, se setea autom�ticamente. Luego de ejectudada la interrupci�n, se vuelve a poner en 0
;autom�ticamente.

;TOV1: Cuando hay overflow en el TIEMER1, se setea. Si est�n habilitadas las interrupciones globales y la interrupci�n por 
;overflow, se ejecuta la interrupci�n.

INIT_TIMER_1:
;Se inicializa el TIMER1, que se utiliza para capturar el instante de tiempo de los pulsos. Se setea el prescaler del mismo,
;y se habilitan las interrupciones por flanco en el pin ICP1 y detecci�n por flanco ascendente.

;NO CONFIGURE EL PRESCALER PORQUE NO SE TODAVIA A QUE VALOR LO VAMOS A PONER

;Registros utilizados: R17
	PUSH R17
	LDS R17, TCCR1B						;SE CARGA EL DATO DEL TCCR1B EN R17
	;ORI R17, (1<<CS10)					;SE CONFIGURA EL PRESCALER
	ANDI R17, ~((1<<ICES1)|(1<<CS11)|(1<<CS12)|(1<<CS10))
	ORI R17, (1<<ICNC1)|(1<<WGM12)
	;ORI R17, (1<<ICES1)|(1<<ICNC1)|(1<<WGM12)					;SE SETEA LA DETECCI�N DE FLANCO ASCENDENTE
	STS TCCR1B, R17						;SE GUARDA LA CONFIGURACI�N EN LA POSICI�N DEL REGISTRO
	
	LDS R17, TIMSK1						;SE CARGA EL DATO DE LA CONFIGURACI�N DE INTERRUPCIONES DEL TIMER 1
	ORI R17, (1<<ICIE1)|(1<<OCIE1A)		;SE HABILITA LA INTERRUPCI�N POR DETECCI�N DE FLANCO Y POR COMPARACION DEL TIMER 1
	STS TIMSK1, R17						;SE GUARDA LA CONFIGURACI�N DE INTERRUPCIONES DEL TIMER 1
	POP R17
	RET

APAGAR_TIMER_1:
; Se inhabiluta el TIMER 1, al finalizar la medici�n total.
; Registros utilizados: R17
	PUSH R17
	LDS R17, TCCR1B
	ANDI R17, ~((1<<CS11)|(1<<CS12)|(1<<CS10))
	STS TCCR1B, R17
	POP R17
	RET