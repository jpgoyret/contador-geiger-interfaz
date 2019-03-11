; ==================================================================
; Archivo: Mediciones.asm
; Descripcion: biblioteca con funciones de uso general 
; ==================================================================

; ===================================================================
; ========================= Constantes ==============================
; ===================================================================

.EQU CANTIDAD_DE_DIGITOS = 5

; ===================================================================
; ========================= Variables ===============================
; ===================================================================
.dseg

; NUMERO_ASCII: Se piden 6 espacios de RAM para guardar los 5 dígitos del número convertido, 
; seguido de un potencial indicador de fin de trama (\n) y un caracter nulo
NUMERO_ASCII: .byte 7

;PROMEDIO_RAM: Se guarda el resultado del promedio	[nibble_bajo:nibble_medio:nibble_alto]
PROMEDIO_RAM: .byte 3


; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

; =================== LISTADO DE FUNCIONES ==========================
; --> DEC_TO_ASCII_16_BITS
; --> DEC_TO_ASCII_24_BITS
; --> TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR
; --> AUX_TRANSF_ASCII_A_BIN
; --> TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR_5_DIGITOS
; --> PROMEDIO
; =================== FIN LISTADO DE FUNCIONES ======================

.cseg

; ===================================================================
; Descripcion: convierte un numero alojado en R17:R16 en sus caracteres ASCII 
; y se guardan en la RAM como una string, uno a continuación del otro. 
; Se realiza una comparación con una tabla alojada en flash 
; para separar los digitos y convertir cada uno por separado.
; Recibe: -
; Devuelve: -
DEC_TO_ASCII_16_BITS:
	PUSH ZL
	PUSH ZH
	PUSH R19
	PUSH R4
	PUSH R5
	PUSH R21

	LDI R21, 0x01

	LDI	ZL, LOW(TABLA_DEC_TO_ASCII*2)			; PUNTERO A LA PRIMER POSICION DE LA TABLA DE COMPARACION
	LDI	ZH, HIGH(TABLA_DEC_TO_ASCII*2)

_SIGUIENTE_DIGITO:
	LDI	R19,'0'-1								; ESTE REGISTRO SE UTILIZA PARA CONVERTIR CADA DIGITO A ASCII

	LPM	R4, Z+									; SE LEVANTA EL NUMERO DE LA TABLA, QUE SE CORRESPONDE CON EL DIGITO A CONVERTIR DEL NUMERO ORIGINAL
	LPM	R5, Z+

_SEGUIR_DIGITO:
	INC	R19										; SE INCREMENTA EN UNO CADA VEZ QUE SE LE RESTA EN NUMERO DE COMPARACIÓN, AL NÚMERO ORIGIANL

	SUB	R16, R4									; SE LE RESTA AL NUMERO ORIGINAL, EL NUMERO DE LA TABLA DE COMPARACIÓN
	SBC	R17, R5
	BRSH _SEGUIR_DIGITO							; SI EL NUMERO ORIGINAL SIGUE SIENDO MAYOR AL NUMERO DE COMPARACIÓN, SE SIGUE RESTANDO HASTA QUE SUCEDA 
												; LO CONTRARIO

	ADD	R16, R4									; SI EL NUMERO ORIGINAL ES MENOR AL NUMERO DE COMPARACIÓN, SE LE VUELVE A SUMAR EL NÚMERO DE COMPARACIÓN
	ADC	R17, R5

	ST X+, R19									; SE GUARDA LA CANTIDAD DE VECES QUE SE RESTÓ EL NUMERO DE COMPARACIÓN, QUE CORRESPONDE CON EL DÍGITO
												; MÁS SIGNIFICATIVO DEL NÚMERO ORIGINAL
	;CPI	ZL,LOW(TABLA_DEC_TO_ASCII*2)+CANTIDAD_DE_DIGITOS	; SI SE ALCANZÓ EL FIN DE TABLA DE COMPARACIÓN, SE TERMINA LA CONVERSIÓN
	CP	R4,R21
	BRNE _SIGUIENTE_DIGITO						; SI NO SE ALCANZÓ EL FIN DE TABLA, SE CONTINÚA CON LA COMPARACIÓN

	LDI R19, 0x00
	ST X, R19

	POP R21
	POP R5
	POP R4
	POP R19
	POP ZH
	POP ZL

	RET


; ===================================================================
; Descripcion: Se convierte un numero alojado en R29:R17:R16 en sus caracteres ASCII 
; y se guardan en la RAM como una string, uno a continuación del otro. Se realiza una 
; comparación con una tabla alojada en flash para separar los digitos 
; y convertir cada uno por separado.
; Recibe: -
; Devuelve: -
DEC_TO_ASCII_24_BITS:
	PUSH ZL
	PUSH ZH
	PUSH R19
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R21

	LDI R21, 0x01

	LDI	ZL, LOW(TABLA_DEC_TO_ASCII_5_DIGITOS*2)			; PUNTERO A LA PRIMER POSICION DE LA TABLA DE COMPARACION
	LDI	ZH, HIGH(TABLA_DEC_TO_ASCII_5_DIGITOS*2)

_SIGUIENTE_DIGITO_24_BITS:
	LDI	R19,'0'-1								; ESTE REGISTRO SE UTILIZA PARA CONVERTIR CADA DIGITO A ASCII

	LPM	R6, Z+									; SE LEVANTA EL NUMERO DE LA TABLA, QUE SE CORRESPONDE CON EL DIGITO A CONVERTIR DEL NUMERO ORIGINAL
	LPM	R5, Z+
	LPM R4, Z+

_SEGUIR_DIGITO_24_BITS:
	INC	R19										; SE INCREMENTA EN UNO CADA VEZ QUE SE LE RESTA EN NUMERO DE COMPARACIÓN, AL NÚMERO ORIGIANL

	SUB	R16, R4									; SE LE RESTA AL NUMERO ORIGINAL, EL NUMERO DE LA TABLA DE COMPARACIÓN
	SBC	R17, R5
	SBC R29, R6
	BRSH _SEGUIR_DIGITO_24_BITS							; SI EL NUMERO ORIGINAL SIGUE SIENDO MAYOR AL NUMERO DE COMPARACIÓN, SE SIGUE RESTANDO HASTA QUE SUCEDA 
												; LO CONTRARIO

	ADD	R16, R4									; SI EL NUMERO ORIGINAL ES MENOR AL NUMERO DE COMPARACIÓN, SE LE VUELVE A SUMAR EL NÚMERO DE COMPARACIÓN
	ADC	R17, R5
	ADC R29, R6

	ST X+, R19									; SE GUARDA LA CANTIDAD DE VECES QUE SE RESTÓ EL NUMERO DE COMPARACIÓN, QUE CORRESPONDE CON EL DÍGITO
												; MÁS SIGNIFICATIVO DEL NÚMERO ORIGINAL
	CP	R4, R21									; SI SE ALCANZÓ EL FIN DE TABLA DE COMPARACIÓN, SE TERMINA LA CONVERSIÓN
	BRNE _SIGUIENTE_DIGITO_24_BITS						; SI NO SE ALCANZÓ EL FIN DE TABLA, SE CONTINÚA CON LA COMPARACIÓN

	LDI R19, 0x00

	ST X, R19

	POP R21
	POP R6
	POP R5
	POP R4
	POP R19
	POP ZH
	POP ZL

	RET

; =======================================================
; Descripcion: transforma un numero ascii de hasta 4 digitos en binario y
; lo guarda en un registro de dos bytes en RAM
; Recibe: 
; -> Posicion de memoria del buffer de RX donde comienza N en el puntero X
; -> Puntero Y con el registro donde guardar el resultado
; Devuelve: -
TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR:
	PUSH_WORD T0, T1
	PUSH_WORD T2, T3
	PUSH_WORD T4, T5

	CLR T0

_BUCLE_CONF_NUM_VENT_CONTAR_DIGITOS:
	LD T1, X+
	CPI T1, '\r';TODO: CAMBIAR POR \n
	BREQ _DETERMINAR_BINARIO
	INC T0
	CPI T0, MAX_NUM_DIGITOS+1
	BREQ _RET_TRANSF_ASCII_A_BIN
	CPI T1, '0'
	BRLO _RET_TRANSF_ASCII_A_BIN
	CPI T1, '9'+1
	BRSH _RET_TRANSF_ASCII_A_BIN
	RJMP _BUCLE_CONF_NUM_VENT_CONTAR_DIGITOS

_DETERMINAR_BINARIO:

	CPI T0, 0
	BREQ _RET_TRANSF_ASCII_A_BIN

	; Regresar el puntero X a su posicion original
	MOV T1, T0
	INC T1
	SUB XL, T1
	IN T2, SREG
	SBRC T2, SREG_C
	SUBI XH, 1 

	; Registros temporales donde almacenar el numero de ventanas
	CLR T1; (LSB)
	CLR T2; (MSB)

_DIGITO_4:
	CPI T0, 4
	BRNE _DIGITO_3
	DEC T0

	LDI T5, 0x03
	LDI T4, 0xE8
	CALL AUX_TRANSF_ASCII_A_BIN

_DIGITO_3:
	CPI T0, 3
	BRNE _DIGITO_2
	DEC T0

	LDI T5, 0
	LDI T4, 0x64
	CALL AUX_TRANSF_ASCII_A_BIN

_DIGITO_2:
	CPI T0, 2
	BRNE _DIGITO_1
	DEC T0

	LDI T5, 0
	LDI T4, 0x0A
	CALL AUX_TRANSF_ASCII_A_BIN

_DIGITO_1:
	CPI T0, 1
	BRNE _GUARDAR_NUMERO_VENTANAS

	LDI T5, 0
	LDI T4, 1
	CALL AUX_TRANSF_ASCII_A_BIN

_GUARDAR_NUMERO_VENTANAS:
	ST Y+, T2
	ST Y, T1
	
	POP_WORD T4, T5
	POP_WORD T2, T3	
	POP_WORD T0, T1
	RET

_RET_TRANSF_ASCII_A_BIN:
	CALL ENVIAR_ERROR_PARSER

	POP_WORD T4, T5
	POP_WORD T2, T3	
	POP_WORD T0, T1
	RET

; ============================================================
; Descripcion: funcion auxiliar de TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR.
; Multiplica una constante por un numero decimal y lo suma a una variable
; Recibe: 
; -> Puntero X con la posicion del caracter que representa al
; numero N.
; -> Registros T4 y T5 con la constante
; -> Registros T2 y T1 con las variable sobre la que se sumara
; Devuelve:
 ; -> Registros T2 y T1 con el nuevo valor de la variable
AUX_TRANSF_ASCII_A_BIN:
	LD T3, X+
	CPI T3, '0'
	BREQ _RET_AUX_TRANSF_ASCII_A_BIN
	SUBI T3, '0'
_BUCLE_AUX_TRANSF_ASCII_A_BIN:
	SUMAR_REGISTROS_16_BITS T2, T1, T5, T4
	DEC T3
	BRNE _BUCLE_AUX_TRANSF_ASCII_A_BIN

_RET_AUX_TRANSF_ASCII_A_BIN:
	RET


; =======================================================
; Descripcion: transforma un numero ascii de hasta 5 digitos en binario y
; lo guarda en un registro de dos bytes en RAM
; Recibe: 
; -> Posicion de memoria del buffer de RX donde comienza N en el puntero X
; -> Puntero Y con el registro donde guardar el resultado
; -> R16 con la cantidad de digitos a convertir
; Devuelve: -
TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR_5_DIGITOS:
	PUSH T1
	PUSH_WORD T2, T3
	PUSH_WORD T4, T5
	PUSH_WORD R4, R5

	; Registros temporales donde almacenar el numero de ventanas
	CLR R5; (MSB)
	CLR T2;
	CLR T1; (LSB)

_DIGITO_5_5:
	CPI R16, 5
	BRNE _DIGITO_4_5
	DEC R16

	LDI T5, 0x27
	LDI T4, 0x10
	CALL AUX_TRANSF_ASCII_A_BIN_5_DIGITOS

_DIGITO_4_5:
	CPI R16, 4
	BRNE _DIGITO_3_5
	DEC R16

	LDI T5, 0x03
	LDI T4, 0xE8
	CALL AUX_TRANSF_ASCII_A_BIN_5_DIGITOS

_DIGITO_3_5:
	CPI R16, 3
	BRNE _DIGITO_2_5
	DEC R16

	LDI T5, 0
	LDI T4, 0x64
	CALL AUX_TRANSF_ASCII_A_BIN_5_DIGITOS

_DIGITO_2_5:
	CPI R16, 2
	BRNE _DIGITO_1_5
	DEC R16

	LDI T5, 0
	LDI T4, 0x0A
	CALL AUX_TRANSF_ASCII_A_BIN_5_DIGITOS

_DIGITO_1_5:
	CPI R16, 1
	BRNE _GUARDAR_NUMERO_VENTANAS_5_DIGITOS

	CLR R4
	LDI T5, 0
	LDI T4, 1
	CALL AUX_TRANSF_ASCII_A_BIN_5_DIGITOS

_GUARDAR_NUMERO_VENTANAS_5_DIGITOS:
	ST Y+, R5
	ST Y+, T2
	ST Y, T1
	
	POP_WORD R4, R5
	POP_WORD T4, T5
	POP_WORD T2, T3	
	POP T1
	RET

; ============================================================
; Descripcion: funcion auxiliar de TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR.
; Multiplica una constante por un numero decimal y lo suma a una variable
; Recibe: 
; -> Puntero X con la posicion del caracter que representa al
; numero N.
; -> Registros T4 y T5 con la constante
; -> Registros T2 y T1 con las variable sobre la que se sumara
; Devuelve:
 ; -> Registros T2 y T1 con el nuevo valor de la variable
AUX_TRANSF_ASCII_A_BIN_5_DIGITOS:
	LD T3, X+
	CPI T3, '0'
	BREQ _RET_AUX_TRANSF_ASCII_A_BIN_5_DIGITOS
	SUBI T3, '0'
	CLR R4
_BUCLE_AUX_TRANSF_ASCII_A_BIN_5_DIGITOS:
	SUMAR_REGISTROS_24_BITS R5, T2, T1, R4, T5, T4
	DEC T3
	BRNE _BUCLE_AUX_TRANSF_ASCII_A_BIN_5_DIGITOS

_RET_AUX_TRANSF_ASCII_A_BIN_5_DIGITOS:
	RET


; ============================================================
; Descripcion: Calcula una división entre un número de 3 bytes, 
; apuntado por Z y un numero apuntado por X, de 3 bytes tambien. 
; Recibe: punteros X y Z
; Devuelve: PROMEDIO_RAM
PROMEDIO:

	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R23
	PUSH R14
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	PUSH R21

	
	LDI R16, 0x00
	MOV R5, R16								; Se inicializa el resultado en 0
	MOV R6, R16
	MOV R7, R16
	; Se carga el dividendo, al que apunta Z: R16:R17:R18
	LD R18, Z+								; Se carga nibble bajo
	LD R17, Z+								; Se carga nibble medio
	LD R16, Z+								; Se carga nibble alto

	; Se carga el divisor, al que apunta X: R21:R20:R19

	LD R19, X+								; Se carga nibble alto
	LD R20, X+								; Se carga nibble medio
	LD R21, X+								; Se carga nibble bajo


	DIVIDIR_24_BITS:
	LDI R23, 0xFF


	SEGUIR_RESTANDO:
		INC R7
		BRNE SIGO
		INC R6
		BRNE SIGO
		INC R5
	SIGO:
		SUB R18, R21
		SBC R17, R20
		SBC R16, R19

		BRCC SEGUIR_RESTANDO					; Si no hay overflow, sigo restando

		DEC R7
		CP R7, R23
		BRNE NO_DECREMENTAR_SUPERIOR
		DEC R6
		CP R6, R23
		BRNE NO_DECREMENTAR_SUPERIOR
		DEC R5
	NO_DECREMENTAR_SUPERIOR:
		LDI ZL, LOW(PROMEDIO_RAM)
		LDI ZH, HIGH(PROMEDIO_RAM)

		ST Z+, R7
		ST Z+, R6
		ST Z+, R5

		POP R21
		POP R20
		POP R19
		POP R18
		POP R17
		POP R16
		POP R14
		POP R23
		POP R7
		POP R6
		POP R5
		
		RET

; ===================================================================
; ========================= Tablas ==================================
; ===================================================================
TABLA_DEC_TO_ASCII:	.dw	10000,1000,100,10,1
TABLA_DEC_TO_ASCII_5_DIGITOS: .db 0x00, 0x27, 0x10, 0x00, 0x03, 0xE8, 0x00, 0x00, 0x64, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x01
