; Descripcion: registro de desplazamiento destinado a almacenar los tiempos de 
; pulsos que arriban al contador, para luego ser enviados por UART

; ===================================================================
; ========================= Registros reservados ====================
; ===================================================================
.def CANT_CARACTERES_GUARDADOS = R5

; ===================================================================
; ========================= Registros auxiliares ====================
; ===================================================================
.undef T0
.undef T1
.undef T2
.undef T3
.def T0 = R16
.def T1 = R17
.def T2 = R18
.def T3 = R19

; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

; Descripcion: recibe una cadena de 6 caracteres almacenada en FLASH y la 
; carga en el registro de desplazamiento
; Recibe: puntero Z con la direccion de memoria de la cadena de caracteres en FLASH
; Devuelve: -
CARGAR_CADENA_REGISTRO_DESPLAZAMIENTO:
	PUSH T0
	PUSH T1
	PUSH XL
	PUSH XH
	; Cargar comienzo del buffer
	LDI XH, HIGH(REGISTRO_DESPLAZAMIENTO)
	LDI XL, LOW(REGISTRO_DESPLAZAMIENTO)

	;Ir al final del buffer
	CLR T0
	ADD XL, CANT_CARACTERES_GUARDADOS
	ADC XH, T0

	; Cargar cadena en el registro de desplazamiento
	LDI T0, 6
_BUCLE_CARGAR_CADENA_REGISTRO_DESPLAZAMIENTO:
	LPM T1, Z+
	ST X+, T1 
	DEC T0
	BRNE _BUCLE_CARGAR_CADENA_REGISTRO_DESPLAZAMIENTO

	LDI T0, 6
	ADD CANT_CARACTERES_GUARDADOS, T0 ; Se han introducido 6 nuevos caracteres en el registro

	POP XH
	POP XL
	POP T1
	POP T0
	RET

; Descripcion: transforma el tiempo de un pulso a ASCII y 
; lo guarda al final de un registro de desplazamiento
; Recibe: valor del tiempo del pulso (16 bits) en los registros R17 y R16
; Devuelve: -
CARGAR_PULSO_REGISTRO_DESPLAZAMIENTO:
	PUSH T2
	PUSH XL
	PUSH XH
	; Cargar comienzo del buffer
	LDI XH, HIGH(REGISTRO_DESPLAZAMIENTO)
	LDI XL, LOW(REGISTRO_DESPLAZAMIENTO)

	;Ir al final del buffer
	CLR T2
	ADD XL, CANT_CARACTERES_GUARDADOS
	ADC XH, T2

	; Transformar el pulso (que esta guardado en los registros R17 y R16) de binario
	; a ASCII y guardar en (REGISTRO_DESPLAZAMIENTO + CANT_CARACTERES_GUARDADOS)
	; Este ocupara 6 bytes (incluyendo un caracter nulo) 
	CALL DEC_TO_ASCII_16_BITS
	LDI T2, 6
	ADD CANT_CARACTERES_GUARDADOS, T2 ; Se han introducido 6 nuevos caracteres en el registro

	POP XH
	POP XL
	POP T2

	RET

; ===================================================================
; Descripcion: toma 6 bytes del registro de desplazamiento y los
; envia por UART
; Recibe: -
; Devuelve: -
QUITAR_PULSO_REGISTRO_DESP_Y_ENVIAR_UART:

	PUSH T0
	PUSH T1
	PUSH T2
	PUSH T3
	PUSH XL
	PUSH XH
	PUSH YL
	PUSH YH
	; Si no hay pulsos guardados en el registro, entonces retornar
	CLR T0
	CP CANT_CARACTERES_GUARDADOS, T0; 
	BREQ _RET_QUITAR_PULSO_REGISTRO_DESP_Y_ENVIAR_UART

	; Cargar comienzo del buffer
	LDI XH, HIGH(REGISTRO_DESPLAZAMIENTO)
	LDI XL, LOW(REGISTRO_DESPLAZAMIENTO)

	; Enviar un tiempo de pulso
	MOV R19, XH
	MOV R18, XL

	; Enviar el valor del tiempo por UART
	LDI R20, AGREGAR_NEWLINE ; Enviar una coma despues de cada tiempo
	CALL CARGAR_BUFFER_DESDE_RAM
	CALL ENVIAR_DATOS_UART
	
	; Al emitir el tiempo de un pulso, se han removido 6 caracteres del registro
	LDI T0, 6
	SUB CANT_CARACTERES_GUARDADOS, T0

	; Si se han removido todos los tiempo de pulso del registro, entonces regresar
	CLR T0
	CP CANT_CARACTERES_GUARDADOS, T0; 
	BREQ _RET_QUITAR_PULSO_REGISTRO_DESP_Y_ENVIAR_UART

	LDI T0,  6; Cargar en T0 la cantidad de caracteres comprendidos por el tiempo del pulso
		  ; (5 digitos mas \0)
	
_BUCLE_1_QUITAR_PULSO:

	; Ir al comienzo del registro
	LDI XH, HIGH(REGISTRO_DESPLAZAMIENTO)
	LDI XL, LOW(REGISTRO_DESPLAZAMIENTO)
	
	; Ir al comienzo del siguiente tiempo almacenado en el registro
	CLR T2
	ADD XL, T0
	ADC XH, T2


	LDI T2, 1 ; SACAR
	CLR T3
	MOVW YH:YL, XH:XL
	LD T3, -X ; Dummy read para que X apunte a la posicion anterior al comienzo del siguiente tiempo,
			  ; mientras que Y lo haga al primer caracter es este ultimo

	MOV T1, CANT_CARACTERES_GUARDADOS
	; Desplazar cada caracter del buffer una vez hacia arriba en la memoria
_BUCLE_2_QUITAR_PULSO:
	LD T3, Y+
	ST X+, T3
	DEC T1
	BRNE _BUCLE_2_QUITAR_PULSO

	DEC T0
	BRNE _BUCLE_1_QUITAR_PULSO
	; Desplazar el registro segun la cantidad de pulsos que hayan almacenados
	


_RET_QUITAR_PULSO_REGISTRO_DESP_Y_ENVIAR_UART:

	POP YH
	POP YL
	POP XH
	POP XL
	POP T3
	POP T2
	POP T1
	POP T0

	RET

.dseg
; Registro que permite almacenar el tiempo de 60 pulsos, ya que cada uno ocupa
; 6 bytes (tienen un maximo valor de 50.000)
REGISTRO_DESPLAZAMIENTO: .BYTE 60

.cseg