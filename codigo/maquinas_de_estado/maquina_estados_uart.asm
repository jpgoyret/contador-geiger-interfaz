; ==================================================================
; Archivo: maquina_estados_uart.asm
; Descripcion: maquina de estados perteneciente a la gestion
; de la comunicacion por UART
; NOTA: Utiliza los registros EVENTO y ESTADO descriptos en main.asm
; ==================================================================


MAQUINA_ESTADOS_UART:

	; Verificar estado oscioso
	SBRC ESTADO, EST_OSCIOSO_UART
	RJMP ESTADO_OSCIOSO_UART

	; Verificar estado de recepcion de cadena
	SBRC ESTADO, EST_RECIBIENDO_CADENA
	RJMP ESTADO_RECIBIENDO_CADENA

	; Verificar estado de interpretacion de cadena
	SBRC ESTADO, EST_INTERPRETANDO_CADENA
	RJMP ESTADO_INTERPRETANDO_CADENA

	; Verificar estado de error
	SBRC ESTADO, EST_ERROR_UART
	RJMP ESTADO_ERROR

	RET

ESTADO_OSCIOSO_UART:

	; Chequear si se recibio un caracter, y si es asi, ir al estado de recepcion de cadena
	LDS R16, EVENTO2
	SBRS R16, BIT_CARACTER_RECIBIDO
	RET

	; Verificar si el teclado se encuentra en uso. Si es asi, enviar un error al usuario
	; indicando que el sistema se encuentra ocupado
	CALL CHEQUEAR_TECLADO_EN_USO
	BRCS _ESTADO_OSCIOSO_ERROR_TECLADO_EN_USO

	; Indicar que el sistema no se encuentra ocupado
	LDS T0, EVENTO2
	CBR T0, (1<<SISTEMA_OCUPADO)
	STS EVENTO2, T0

	CBR ESTADO, (1<<EST_OSCIOSO_UART)
	SBR ESTADO, (1<<EST_RECIBIENDO_CADENA)

	; Encender timer0 y activar sus interrupciones por overflow
	; para corroborar cuando se produjo un timeout
	LDS R16, MOTIVO_TIMER0
	SBR R16, (1<<MOTIVO_TIMER0_UART) ; Indicar al timer el motivo de su ejecucion 
	STS MOTIVO_TIMER0, R16
	CALL ENCENDER_TIMER_0

	RET

_ESTADO_OSCIOSO_ERROR_TECLADO_EN_USO:
	LDS T0, EVENTO2
	CBR T0, (1<<BIT_CARACTER_RECIBIDO)
	SBR T0, (1<<SISTEMA_OCUPADO)
	STS EVENTO2, T0

	; Configurar puntero al comienzo del buffer de recepcion
	LDI T0, LOW(BUFFER_RX)
	MOV PTR_RX_L, T0
	LDI T0, HIGH(BUFFER_RX)
	MOV PTR_RX_H, T0
	RET


ESTADO_RECIBIENDO_CADENA:
	; Si se ha terminado de recibir una cadena correctamente, ir al estado para interpretar la cadena
	LDS R16, EVENTO2
	SBRC R16, BIT_FIN_CADENA
	RJMP _IR_A_ESTADO_INTERPRETAR_CADENA
	; Si se produjo un error por overflow del buffer o timeout en la recepcion de datos;
	; pasar al estado de error
	SBRC EVENTO, TIMEOUT_UART 
	RJMP _IR_A_ESTADO_ERROR
	SBRC EVENTO, OV_BUFFER_RX_UART 
	RJMP _IR_A_ESTADO_ERROR

	RET

_IR_A_ESTADO_INTERPRETAR_CADENA:

	; Limpiar el bit de evento de timer0 que corresponde a la UART
	; Esto permite que otra funcionalidad, como el teclado, pueda usar el timer0 
	; mediante otros eventos
	LDS R16, MOTIVO_TIMER0
	CBR R16, (1<<MOTIVO_TIMER0_UART)
	STS MOTIVO_TIMER0, R16

	CALL APAGAR_TIMER_0

	CBR R16, (1<<BIT_CARACTER_RECIBIDO)
	STS EVENTO2, R16

	CBR R16, (1<<BIT_CARACTER_RECIBIDO)
	STS EVENTO2, R16

	CBR ESTADO, (1<<EST_RECIBIENDO_CADENA)
	SBR ESTADO, (1<<EST_INTERPRETANDO_CADENA) 
	RET

_IR_A_ESTADO_ERROR:
	; Limpiar el bit de evento de timer0 que corresponde a la UART
	; Esto permite que otra funcionalidad, como el teclado, pueda usar el timer0 
	; mediante otros eventos
	LDS R16, MOTIVO_TIMER0
	CBR R16, (1<<MOTIVO_TIMER0_UART)
	STS MOTIVO_TIMER0, R16

	CALL APAGAR_TIMER_0

	CBR R16, (1<<BIT_CARACTER_RECIBIDO)
	STS EVENTO2, R16

	CBR ESTADO, (1<<EST_RECIBIENDO_CADENA)
	SBR ESTADO, (1<<EST_ERROR_UART)
	RET

ESTADO_INTERPRETANDO_CADENA:
	CALL INTERPRETAR_CADENA_COMANDOS
	
	CLR BYTES_RECIBIDOS

	; Volver a estado oscioso
	CBR ESTADO, (1<<EST_INTERPRETANDO_CADENA)
	SBR ESTADO, (1<<EST_OSCIOSO_UART)
	RET

; =========================
; Estado de error: aqui se realiza un switch donde se interpreta cada error
; y se toma una medida en consecuencia
ESTADO_ERROR:

	SBRC EVENTO, OV_BUFFER_RX_UART

	SBRC EVENTO, TIMEOUT_UART
	RJMP _ERROR_TIMEOUT_RX

	SBRC EVENTO, OV_BUFFER_RX_UART
	RJMP _ERROR_OVERFLOW_RX

	; Volver a estado oscioso
	CBR ESTADO, (1<<EST_ERROR_UART)
	SBR ESTADO, (1<<EST_OSCIOSO_UART)
	RET

_ERROR_TIMEOUT_RX:
	CLR BYTES_RECIBIDOS

	CALL ENVIAR_ERROR_TIMEOUT

	; Reiniciar el buffer de RX
	CALL LIMPIAR_BUFFER_RX

	; Limpiar el bit asociado al evento de un timeout
	CBR EVENTO, (1<<TIMEOUT_UART)
	
	; Volver a estado oscioso
	CBR ESTADO, (1<<EST_ERROR_UART)
	SBR ESTADO, (1<<EST_OSCIOSO_UART)
	RET

_ERROR_OVERFLOW_RX:
	;TODO: ver como gestionar cuando hay un overflow y despues un \n

	CALL LIMPIAR_BUFFER_RX

	CALL ENVIAR_ERROR_OVERFLOW

	; Limpiar el bit asociado al evento de un overflow
	CBR EVENTO, (1<<OV_BUFFER_RX_UART)

	; Volver a estado oscioso
	CBR ESTADO, (1<<EST_ERROR_UART)
	SBR ESTADO, (1<<EST_OSCIOSO_UART)
	RET