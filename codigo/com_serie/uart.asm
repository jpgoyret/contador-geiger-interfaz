; ==================================================================
; Archivo: uart.asm
; Descripcion: biblioteca con funciones para manejo de la comunicacion UART

; Usos de UART:
; 1) Comunicarse con una PC para ser permitir configurar el dispositivo,
;    ejecutar mediciones, etc. via protocolo SCPI
;
; ==================================================================

; ==================== INSTRUCCIONES DE USO =========================

; Instrucciones:
; ==> Para una cadena armada dinamicamente
; 1- Llamar a IR_COMIENZO_BUFFER_TX, para configurar
; el puntero X en el comienzo del buffer de TX
; 2- Cargar un caracter en R18 (es parametro de CARGAR_BUFFER_TX_CON_CARACTER)
; 3- Llamar a CARGAR_BUFFER_TX_CON_CARACTER.
; 4- Repetir los pasos 2 y 3 para la cantidad de caracteres que se desee
; 5- Agregar el caracter de fin de trama \n por medio
; de los pasos 2 y 3 para cumplir con el estandar SCPI
; 6- Llamar a ENVIAR_DATOS_UART para iniciar el envio de datos
; 
; Ejemplo
;	CALL IR_COMIENZO_BUFFER_TX
;	LDI R18, 'A'
;	CALL CARGAR_BUFFER_TX_CON_CARACTER
;	LDI R18, 'B'
;	CALL CARGAR_BUFFER_TX_CON_CARACTER
;	LDI R18, 'C'
;	CALL CARGAR_BUFFER_TX_CON_CARACTER
;	CALL ENVIAR_DATOS_UART
;
; ==> Para enviar una cadena estatica
; 1- Cargar en R18 y R19 la direccion de memoria de la cadena (son el LSB y el MSB respectivamente)
; 2- Llamar a CARGAR_BUFFER
; 3- Llamar a ACTIVAR_INT_TX_UDRE0 para activar la interrupcione de TX de la UART y comenzar con el envio de datos


; ==================== FIN INSTRUCCIONES DE USO ======================

; ==================== REGISTROS USART/UART ==========================

; REGISTRO UCSR0B:
; [RXCIE0][TXCIE0][UDRIE0][RXEN0][TXEN0][UCSZ02][RXB80][TXB80]
;
; RXCIE0 = 1: habilita la interrupcion por recepción de un byte por 
;             medio de RX completada
; TXCIE0 = 1: habilita la interrupcion por envio competado 
;             de un byte por medio de TX
; RXEN0 = 1: habilita el receptor de UART. Configura el pin RX para servir a UART
; TXEN0 = 1: habilita el envio de datos por UART. 
;             Configura el pin TX para servir a UART

; REGISTRO UCSR0C:
; [UMSEL01][UMSEL00][UPM01][UPM00][USBS0][UCSZ01][UCSZ00][UCPOL0]
;
; UCSZ02|UCSZ01|UCSZ00: configuran el numero de bits enviados por UART 
;                       en un paquete
;000 -> 5 bits
;001 -> 6 bits
;010 -> 7 bits
;011 -> 8 bits
;100 -> Reservado
;101 -> Reservado
;110 -> Reservado
;111 -> 9 bits

; UBRR0H[3:0],UBRR0L: registros para la configuracion del BAUD RATE de UART

; ==================== FIN REGISTROS USART/UART =====================

; ===================================================================
; ========================= Constantes ==============================
; ===================================================================
.equ BUFFER_SIZE = 60

; Baud rate: con 16MHz de system clock
; 12 = 76.8k baudios, 0.2% error
; 103 = 9.6k baudios, 0.2% error
.equ BAUD_RATE = 12  

; Valores posibles del registro R20 para configurar 
; el caracter de fin de trama de CARGAR_BUFFER_DESDE_RAM
.equ NO_FIN_DE_TRAMA = 0
.equ AGREGAR_COMA = 1
.equ AGREGAR_PUNTO_Y_COMA = 2
.equ AGREGAR_NEWLINE = 3

; ===================================================================
; ========================= Registros Reservados ====================
; ===================================================================
; Punteros a los buffer de transmision y recepcion
.def PTR_TX_L = R8
.def PTR_TX_H = R9
.def PTR_RX_L = R10
.def PTR_RX_H = R11
.def BYTES_TRANSMITIR = R12 
.def BYTES_RECIBIDOS = R13

; ===================================================================
; ========================= Registros auxiliares ====================
; ===================================================================
.undef T0
.undef T1
.def T0 = R16
.def T1 = R17

; ===================================================================
; ========================= Interrupciones ==========================
; ===================================================================

; Tipo de interrupcion: Data Register Empty interrupt
; Descripcion: enviar un caracter del buffer de transmision 
; cada vez que el buffer de datos UDR0 se encuentra vacio.
; Una vez que el buffer de transmision se hacia vaciado, se desactiva
; la interrupcion
; Recibe: BUFFER_TX, PTR_TX_L, PTR_TX_H
; Devuelve: -
USART_UDRE:

	PUSH T0
	PUSH XL
	PUSH XH
	IN T0, SREG
	PUSH T0
	
	; Indicar que se esta enviando una cadena
	SBR EVENTO, (1<<ENVIANDO_DATOS_UART); TODO: MOVER ESTO A LA FUNCION QUE ACTIVA EL ENVIO DE DATOS

	; Cargar puntero X con la direccion del buffer de transmision
	MOVW XH:XL, PTR_TX_H:PTR_TX_L
	
	LD T0, X+
	STS UDR0, T0

	DEC BYTES_TRANSMITIR
	BREQ _FIN_TRANSMISION_UART

	MOVW PTR_TX_H:PTR_TX_L, XH:XL

	POP T0
	OUT SREG, T0
	POP XH
	POP XL
	POP T0
	RETI

_FIN_TRANSMISION_UART:

	; Deshabilitar las interrupciones de TX
	CALL DESACTIVAR_INT_TX_UDRE0

	; Indicar que no se estan enviando datos por UART
	CBR EVENTO, (1<<ENVIANDO_DATOS_UART)

	; Configurar puntero al comienzo del buffer de transmision
	LDI T0, LOW(BUFFER_TX)
	MOV PTR_TX_L, T0
	LDI T0, HIGH(BUFFER_TX)
	MOV PTR_TX_H, T0

	POP T0
	OUT SREG, T0
	POP XH
	POP XL
	POP T0
	RETI

; ===================================================================
; Tipo de interrupcion: Receive Complete interrupt
; Descripcion: guarda un caracter en el buffer de RX cuando
; se dispara la interrupcion que indica que el buffer UDR0 
; esta lleno.
; Cuando se termina de recibir una cadena, se llama a la funcion FUNCION
; para interpretarla
; Se interpreta que se ha dejado de recibir una cadena cuando:
; --> Esta termina con un caracter nulo
; --> Su largo es igual o mayor al del buffer de lectura
;
; Recibe: -
; Devuelve: BUFFER_RX, BYTES_RECIBIDOS
USART_RX:

	PUSH T0
	PUSH XL
	PUSH XH
	IN T0, SREG
	PUSH T0

	; Entrar en estado de recepcion de cadena
	LDS T0, EVENTO2
	SBR T0, (1<<BIT_CARACTER_RECIBIDO)
	STS EVENTO2, T0
	;CBR ESTADO, (1<<EST_OSCIOSO_UART)
	;SBR ESTADO, (1<<EST_RECIBIENDO_CADENA)

	MOVW XH:XL, PTR_RX_H:PTR_RX_L

	; Leer caracter que llego por UART
	LDS T0, UDR0

	; Sumar caracter al buffer
	ST X+, T0
	INC BYTES_RECIBIDOS
	
	; Verificar si el caracter recibido es el de fin de trama
	CPI T0, '\r'
	BREQ _FIN_CADENA

	; Verificar si la cantidad de bytes recibidos ha excedido
	; el tamano del buffer de RX
	MOV T0, BYTES_RECIBIDOS
	CPI T0, BUFFER_SIZE
	BREQ _OVERFLOW_BUFFER

	MOVW PTR_RX_H:PTR_RX_L, XH:XL

	POP T0
	OUT SREG, T0
	POP XH
	POP XL
	POP T0
	RETI

_FIN_CADENA:
	; Salir del estado de recepcion de cadena y entrar al
	; de procesamiento de cadena
	LDS T0, EVENTO2

	SBRC T0, SISTEMA_OCUPADO
	RJMP __ERR_SISTEMA_OCUPADO

	SBR T0, (1<<BIT_FIN_CADENA)
	STS EVENTO2, T0
	RJMP __SEGUIR_FIN_CADENA

__ERR_SISTEMA_OCUPADO:
	CALL ENVIAR_ERROR_OCUPADO

	; Limpiar el bit que indica que el sistema se encuentra ocupado
	CBR T0, (1<<SISTEMA_OCUPADO)
	STS EVENTO2, T0	 

__SEGUIR_FIN_CADENA:
	; Configurar puntero al comienzo del buffer de recepcion
	LDI T0, LOW(BUFFER_RX)
	MOV PTR_RX_L, T0
	LDI T0, HIGH(BUFFER_RX)
	MOV PTR_RX_H, T0

	POP T0
	OUT SREG, T0
	POP XH
	POP XL
	POP T0
	RETI

_OVERFLOW_BUFFER:
	; Indicar en el registro de eventos que se produjo un error
	; de overflow de buffer
	SBR EVENTO, (1<<OV_BUFFER_RX_UART)

	; Configurar puntero al comienzo del buffer de recepcion
	LDI T0, LOW(BUFFER_RX)
	MOV PTR_RX_L, T0
	LDI T0, HIGH(BUFFER_RX)
	MOV PTR_RX_H, T0

	POP T0
	OUT SREG, T0
	POP XH
	POP XL
	POP T0
	RETI

; =========================== Fin USART_RX =========================

; ===================================================================
; ==================== Funciones generales ==========================
; ===================================================================

; Descripcion: encargada de inicializar UART
; Entradas: ninguna
; Devuelve: -
INICIALIZAR_UART:

	PUSH T0
	PUSH T1
	PUSH XL
	PUSH XH
	PUSH YL
	PUSH YH

	; Comunicacion asincronica
	; 8 bits de data frame
	; 1 solo bit de stop
	; Sin bit de paridad
	LDI T0, (1 << UCSZ01 | 1 << UCSZ00)
	STS UCSR0C, T0

	; Velocidad de 9600 baudios teniendo en cuenta
	; un clock de 16MHz
	LDI T0, 0
	STS UBRR0H, T0
	LDI T0, BAUD_RATE
	STS UBRR0L, T0

	 
	; Configurar puntero al comienzo del buffer de transmision
	LDI T0, LOW(BUFFER_TX)
	MOV PTR_TX_L, T0
	LDI T0, HIGH(BUFFER_TX)
	MOV PTR_TX_H, T0

	; Configurar puntero al comienzo del buffer de recepcion
	LDI T0, LOW(BUFFER_RX)
	MOV PTR_RX_L, T0
	LDI T0, HIGH(BUFFER_RX)
	MOV PTR_RX_H, T0

	; ====================================
	; Subrutina para limpiar los buffers

	CLR BYTES_RECIBIDOS

	CLR T0
	LDI T1, BUFFER_SIZE

	; Cargar puntero X con la direccion del buffer de transmision
	MOVW XH:XL, PTR_TX_H:PTR_TX_L
	MOVW YH:YL, PTR_RX_H:PTR_RX_L

_LOOP_LIMPIAR_BUFFER:
	ST X+, T0
	ST Y+, T0
	DEC T1
	BRNE _LOOP_LIMPIAR_BUFFER


	POP YH
	POP YL
	POP XH
	POP XL
	POP T1
	POP T0
	RET


; =============================
; Descripcion: ubicar los punteros PTR_RX_L y PTR_RX_H
; al comienzo del buffer de RX y limpiar el contador
; de bits recibidos
; Entradas: ninguna
; Devuelve: -
LIMPIAR_BUFFER_RX:
	PUSH T0

	LDI T0, LOW(BUFFER_RX)
	MOV PTR_RX_L, T0
	LDI T0, HIGH(BUFFER_RX)
	MOV PTR_RX_H, T0
	
	CLR BYTES_RECIBIDOS

	POP T0
	RET	

; ===================================================================
; ======= Funciones de activacion de recepcion o transmision ========
; ===================================================================

; Descripcion: habilitar la recepcion de datos por puerto serie
; Entradas: ninguna
; Devuelve: -
ACTIVAR_RX:
	PUSH T0
	LDS T0, UCSR0B 
	ORI T0, 1 << RXEN0
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: habilitar la transmision de datos por puerto serie
; Entradas: ninguna
; Devuelve: -
ACTIVAR_TX:
	PUSH T0
	LDS T0, UCSR0B	
	ORI T0, 1 << TXEN0
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: habilitar la transmision y recepcion de datos por puerto serie
; Entradas: ninguna
; Devuelve: -
ACTIVAR_TX_RX:
	PUSH T0
	LDS T0, UCSR0B	
	ORI T0, (1 << RXEN0 | 1 << TXEN0) 
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: deshabilitar la recepcion de datos por puerto serie
; Entradas: ninguna
; Devuelve: -
DESACTIVAR_RX:
	PUSH T0
	LDS T0, UCSR0B	
	ANDI T0, ~(1 << RXEN0)
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: deshabilitar la recepcion de datos por puerto serie
; Entradas: ninguna
; Devuelve: -
DESACTIVAR_TX:
	PUSH T0
	LDS T0, UCSR0B	
	ANDI T0, ~(1 << TXEN0)
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: deshabilitar la recepcion de datos por puerto serie
; Entradas: ninguna
; Devuelve: -
DESACTIVAR_TX_RX:
	PUSH T0
	LDS T0, UCSR0B	
	ANDI T0, ~(1 << RXEN0 | 1 << TXEN0) 
	STS UCSR0B, T0
	POP T0
	RET

; ==============================================================
; ========== Funciones de activacion de interrupciones =========
; ==============================================================

; Descripcion: activar la interrupcion generada cuando el registro de TX de UART se encuentra vacio
; Entradas: ninguna
; Devuelve: -
ACTIVAR_INT_TX_UDRE0:
	PUSH T0
	LDS T0, UCSR0B
	ORI T0, 1 << UDRIE0
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: activar la interrupcion generada cuando se ha terminado una transmision por UART
; Entradas: ninguna
; Devuelve: -
ACTIVAR_INT_TX_TXC0:
	PUSH T0
	LDS T0, UCSR0B	
	ORI T0, 1 << TXCIE0
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: activar la interrupcion generada cuando un dato recibido por UART se encuentra disponible
; para ser leido
; Entradas: ninguna
; Devuelve: -
ACTIVAR_INT_RX:
	PUSH T0
	LDS T0, UCSR0B	
	ORI T0, 1 << RXCIE0
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: activar la interrupcion generada cuando el registro de TX de UART se encuentra vacio
; Entradas: ninguna
; Devuelve: -
DESACTIVAR_INT_TX_UDRE0:
	PUSH T0
	LDS T0, UCSR0B	
	ANDI T0, ~(1 << UDRIE0)
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: activar la interrupcion generada cuando se ha terminado una transmision por UART
; Entradas: ninguna
; Devuelve: -
DESACTIVAR_INT_TX_TXC0:
	PUSH T0
	LDS T0, UCSR0B	
	ANDI T0, ~(1 << TXCIE0)
	STS UCSR0B, T0
	POP T0
	RET

; =============================================================
; Descripcion: activar la interrupcion generada cuando un dato recibido por UART se encuentra disponible
; para ser leido
; Entradas: ninguna
; Devuelve: -
DESACTIVAR_INT_RX:
	PUSH T0
	LDS T0, UCSR0B	
	ANDI T0, ~(1 << RXCIE0)
	STS UCSR0B, T0
	POP T0
	RET

; ================================================================
; ========== Funciones de manejo de cadenas o caracteres =========
; ================================================================

; =============================================================
; Descripcion: recibe una cadena de caracteres almacenada en memoria
; flash y la carga en el buffer
; Entradas: direccion de una tabla almacenada en R18(LSB) y R19(MSB)
; Devuelve: -
CARGAR_BUFFER:
	PUSH T0
	PUSH T1
	PUSH ZL
	PUSH ZH

	CLR BYTES_TRANSMITIR

; Cargar puntero X con la direccion del buffer de transmision
	MOVW XH:XL, PTR_TX_H:PTR_TX_L

; Cargar puntero Z con la direccion de memoria provista por R18(LSB) y R19(MSB)
	MOV ZL, R18
	MOV ZH, R19
	LSL ZL
	ROL ZH

; Varible auxiliar
	LDI T1, BUFFER_SIZE

_LOOP_CARGAR_BUFFER:

	LPM T0, Z+
	CPI T0, 0
	BREQ _RETORNAR_CARGAR_BUFFER

	ST X+, T0
	INC BYTES_TRANSMITIR
	DEC T1
	BREQ _RETORNAR_CARGAR_BUFFER
	RJMP _LOOP_CARGAR_BUFFER

_RETORNAR_CARGAR_BUFFER:
	POP ZH
	POP ZL
	POP T1
	POP T0
	RET

; =============================================================
; Descripcion: carga el buffer de TX con los datos almacenados en el buffer de RX
; para hacer un echo de lo recibido.
; Recibe: BUFFER_RX
; Devuelve: BUFFER_TX

UART_ECHO:
	PUSH T0
	PUSH T1
	PUSH XL
	PUSH XH
	PUSH YL
	PUSH YH

	CLR BYTES_TRANSMITIR

; Cargar puntero X con la direccion del buffer de transmision
	MOVW XH:XL, PTR_TX_H:PTR_TX_L

; Cargar puntero Y con la direccion del buffer de recepcion
	MOVW YH:YL, PTR_RX_H:PTR_RX_L

; Varible auxiliar
	MOV T1, BYTES_RECIBIDOS

_LOOP_UART_ECHO:

	LD T0, Y+
	CPI T0, 0
	BREQ _RETORNAR_CARGAR_BUFFER

	ST X+, T0
	INC BYTES_TRANSMITIR
	DEC T1
	BREQ _RETORNAR_CARGAR_BUFFER
	RJMP _LOOP_UART_ECHO

_RETORNAR_UART_ECHO: 

	POP YH
	POP YL
	POP XH
	POP XL
	POP T1
	POP T0
	RET

; =================================================
; Descripcion: carga en el buffer de TX una cadena de texto almacenada en una
; tabla en memoria RAM
; Recibe: 
; -> puntero a cadena en RAM (registros R18 y R19)
; -> registro R20 indicando que tipo de caracter se quiere enviar al final de la cadena 
; (a modo de caracter de fin de trama)
; -- R20 = 0x00 : no colocar ningun caracter
; -- R20 = 0x01 : agregar ','
; -- R20 = 0x02 : agregar ';'
; Devuelve: -

CARGAR_BUFFER_DESDE_RAM:
	PUSH T0
	PUSH T1
	PUSH XL
	PUSH XH
	PUSH YL
	PUSH YH

	CLR BYTES_TRANSMITIR

; Cargar puntero X con la direccion del buffer de transmision
	MOVW XH:XL, PTR_TX_H:PTR_TX_L

; Cargar puntero Z con la direccion de memoria provista por R18(LSB) y R19(MSB)
	MOV YL, R18
	MOV YH, R19

; Varible auxiliar
	LDI T1, BUFFER_SIZE

_LOOP_CARGAR_BUFFER_RAM:

	LD T0, Y+
	CPI T0, 0
	BREQ _CARGAR_CARACTER_FIN_TRAMA

	ST X+, T0
	INC BYTES_TRANSMITIR
	DEC T1
	BREQ _CARGAR_CARACTER_FIN_TRAMA
	RJMP _LOOP_CARGAR_BUFFER_RAM

_CARGAR_CARACTER_FIN_TRAMA: 

	CPI R20, NO_FIN_DE_TRAMA
	BREQ _RET_CARGAR_BUFFER_DESDE_RAM

	CPI R20, AGREGAR_COMA
	BREQ _AGREGAR_COMA

	CPI R20, AGREGAR_PUNTO_Y_COMA
	BREQ _AGREGAR_PUNTO_Y_COMA

	CPI R20, AGREGAR_NEWLINE
	BREQ _AGREGAR_NEWLINE

	RJMP _RET_CARGAR_BUFFER_DESDE_RAM

_AGREGAR_NEWLINE:
	LDI T0, '\n'
	ST X+, T0
	INC BYTES_TRANSMITIR
	RJMP _RET_CARGAR_BUFFER_DESDE_RAM

_AGREGAR_COMA:
	LDI T0, ','
	ST X+, T0
	INC BYTES_TRANSMITIR
	RJMP _RET_CARGAR_BUFFER_DESDE_RAM

_AGREGAR_PUNTO_Y_COMA:
	LDI T0, 0X3B ; En ASCII 0x3B = ';'
	ST X+, T0
	INC BYTES_TRANSMITIR
	RJMP _RET_CARGAR_BUFFER_DESDE_RAM

_RET_CARGAR_BUFFER_DESDE_RAM:

	POP YH
	POP YL
	POP XH
	POP XL
	POP T1
	POP T0
	RET


; =========================================================
; Descripcion: coloca el puntero X al comienzo del buffer de transmision
; Recibe: -
; Devuelve: puntero X con la direccion del comienzo del buffer de transmision
IR_COMIENZO_BUFFER_TX:
	PUSH T0

	LDI XL, LOW(BUFFER_TX)
	LDI XH, HIGH(BUFFER_TX)
	
	CLR BYTES_TRANSMITIR

	POP T0
	RET	

; =====================================================
; Descripcion: cargar el buffer de tx con un caracter
; Recibe: R18
; Devuelve: -
CARGAR_BUFFER_TX_CON_CARACTER:
	; Cargar puntero X con la direccion del buffer de transmision
	INC BYTES_TRANSMITIR
	ST X+, R18

	RET

; Descripcion: comenzar con el envio de datos almacenados en el buffer de TX
; Entradas: ninguna
; Salidas: -
ENVIAR_DATOS_UART:
	CALL ACTIVAR_INT_TX_UDRE0
	RET

; =====================================================
; Descripcion: transformar un numero binario a ASCII y enviar por UART
; Recibe: registros R17 y R16 con el valor de 16 bits a convertir
; Devulve: -
CONVERTIR_A_BINARIO_Y_ENVIAR_UART:

	CALL IR_COMIENZO_BUFFER_TX

	; Convertir los bits de la cantidad de cuentas a ASCII
	;CALL DEC_TO_ASCII_16_BITS
	CALL DEC_TO_ASCII_24_BITS

	; Reemplazar caracter \0 por \n\0
	LDI XL, LOW(BUFFER_TX + CANTIDAD_DE_DIGITOS)
	LDI XH, HIGH(BUFFER_TX + CANTIDAD_DE_DIGITOS)
	LDI R18, '\n'
	ST X+, R18
	LDI R18, 0
	ST X, R18
	
	; Setear los registros R19 y R18 con la direccion de memoria
	; del buffer donde DEC_TO_ASCII_16_BITS guarda el resultado
	; de la conversion
	;LDI R19, HIGH(NUMERO_ASCII)
	;LDI R18, LOW(NUMERO_ASCII)

	; Transferir los datos del registro donde DEC_TO_ASCII_16_BITS
	; guarda el resultado de la conversion al buffer de tx
	;CALL CARGAR_BUFFER_DESDE_RAM

	LDI T0, CANTIDAD_DE_DIGITOS+1 ; Se incluye un +1 por el agregado del caracter de fin trama
	MOV BYTES_TRANSMITIR, T0
	CALL ENVIAR_DATOS_UART

	RET

; ===================================================================
; ========================= Envio de mensajes de error ==============
; ===================================================================
; Descripcion: funciones que envian mensajes de error por UART en base
; a los comandos recibidos

; CODIGOS DE ERROR:
; 100 - Error de comando
; 363 - Overflow del buffer
; 365 - Error de timeout

ENVIAR_ERROR_PARSER:
	PUSH R18
	PUSH R19

	LDI R18, LOW(MENSAJE_ERROR_COMANDO)
	LDI R19, HIGH(MENSAJE_ERROR_COMANDO)
	CALL CARGAR_BUFFER

	; Activar interrupcion por buffer UDR0 vacio para
	; enviar el contenido del buffer
	CALL ACTIVAR_INT_TX_UDRE0	

	POP R19
	POP R18
	RET

ENVIAR_ERROR_TIMEOUT:
	PUSH R18
	PUSH R19

	LDI R18, LOW(MENSAJE_ERROR_RECEPCION_TIMEOUT)
	LDI R19, HIGH(MENSAJE_ERROR_RECEPCION_TIMEOUT)
	CALL CARGAR_BUFFER

	; Activar interrupcion por buffer UDR0 vacio para
	; enviar el contenido del buffer
	CALL ACTIVAR_INT_TX_UDRE0	

	POP R19
	POP R18
	RET

ENVIAR_ERROR_OVERFLOW:
	PUSH R18
	PUSH R19

	LDI R18, LOW(MENSAJE_ERROR_RECEPCION_OV)
	LDI R19, HIGH(MENSAJE_ERROR_RECEPCION_OV)
	CALL CARGAR_BUFFER

	; Activar interrupcion por buffer UDR0 vacio para
	; enviar el contenido del buffer
	CALL ACTIVAR_INT_TX_UDRE0	

	POP R19
	POP R18
	RET

ENVIAR_ERROR_OCUPADO:
	PUSH R18
	PUSH R19

	LDI R18, LOW(MENSAJE_ERROR_RECEPCION_OCUPADO)
	LDI R19, HIGH(MENSAJE_ERROR_RECEPCION_OCUPADO)
	CALL CARGAR_BUFFER

	; Activar interrupcion por buffer UDR0 vacio para
	; enviar el contenido del buffer
	CALL ACTIVAR_INT_TX_UDRE0	

	POP R19
	POP R18
	RET

; ===================================================================
; ================ Espacios de memoria reservados ===================
; ===================================================================
.dseg
BUFFER_TX: .BYTE BUFFER_SIZE
BUFFER_RX: .BYTE BUFFER_SIZE

; ===================================================================
; ======================== MENSAJES =================================
; ===================================================================
.cseg
; Mensaje a enviar al iniciarse el sistema
MENSAJE_UART_INICIAL: .DB '\n',"Interfaz de manejo por PC del contador Geiger",'\n',0

; Mensaje indicando la disminucion del multiplicador
MENSAJE_DEC_MUL: .DB "END  ",0 ; Debe tener 6 caracteres de largo incluyendo el nulo

; ===================================================================
; ======================== CODIGOS ==================================
; ===================================================================
; Codigos de error
MENSAJE_ERROR_COMANDO: .db "-100", '\n', 0
MENSAJE_ERROR_RECEPCION_OV: .DB "-363",'\n',0
MENSAJE_ERROR_RECEPCION_TIMEOUT: .DB "-365",'\n',0
MENSAJE_ERROR_RECEPCION_OCUPADO: .DB "-284",'\n',0

; Otros codigos
MENSAJE_FIN_MEDICION: .db "-800", '\n', 0