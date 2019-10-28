; ==================================================================
; Archivo: scpi.asm
; Descripcion: funciones para interpretacion de la informacion recibida mediante UART
; ==================================================================

; ==================== LISTADO DE COMANDOS ==========================
; Comandos de acceso remoto para el control del dispositivo
; 
; Todo comando es una secuencia de carcateres ASCII terminados en '\n'.
; El "controlador" es cualquier ente que se comunica por RS-232 con el dispositivo usando la codificación 1-8-1 
; (start-data-stop) a una velocidad de 76800 bps.
; 
; *IDN?   (El controlador) pide la identificación del dispositivo
; (el dispositivo) devuelve "...."
; 
; *RST  Reestablece los valores por default de ventana de tiempo, tiempo total de medición y umbral
; parar la medición que se estuviera realizando en ese instante, al igual que la transmisión de datos hacia la PC.
; 
; ABORt Abortar una medición en curso
; 
; READ?  --- si va con signo de pregunta, debería devolver un parámetro
; READ --- Hace una (única) medición y retorna el resultado
; Función: comenzar a contar pulsos y devolver a la PC el valor de la cantidad que se detectaron cada vez que 
; finalice una ventana de tiempo. Repetir hasta que haya transcurrido el tiempo total de medición configurado.
;
; CONFigure?    
; Funcion: Devuelve los valores de ventana de tiempo, el intervalo de medición y el umbral.
;
; CONFigure:WINDow N 
; Function: Fija un valor de ventana con N en Segundos
; CONFigure:WINDow? 
; Function: Devuelve el valor de ventana
; 
; CONFigure:COUNt N    
; Funcion: Cambiar el tiempo total de la medición a N segundos
; CONFigure:COUNt?    
; Funcion: Informa el tiempo total fijado para una medición
; 
; CONFigure:TRIGger N		
; Funcion: Configura el umbral de encendido del LED.
; CONFigure:TRIGger?		
; Funcion: Devuelve el umbral de encendido del LED.
;
; CONFigure:DATA <BOOLEAN>
; Funcion: configura el dispositivo para el enviar los valores de los tiempos en vez
; del total por ventana (SOLO PARA UART)
; CONFigure:DATA? 
; Funcion: Informa si el dispositivo se encuentra configurado para enviar los tiempos de los pulsos al medir
; 
; CONTrol:APOWer
; Función: encender o apagar el circuito del tubo.
; CONTrol:APOWer?
; Informa si el tubo del contador Geiger se encuentra encendido
;
; SYSTem:BEEPer:STATe <BOOLEAN>
; Funcion: controla el encendido/apagado de la senal sonora
; Si recibe un 1 (ON), se bloquea el teclado. Si es 0 (OFF), se desbloquea
; SYSTem:BEEPer:STATe?
; Funcion: Informa si el buzzer se encuentra configurado para hacer ruido al superarse un umbral dado
;
; *SAV
; Función: guardar la última configuración de la ventana de tiempo, el tiempo total de medición y el umbral 
; en memoria para que sean automáticamente adoptados una vez que el dispositivo se resetee.
;
; SYSTem:KLOCk <BOOLEAN>
; Funcion: inhabilitar teclado durante la medicion
; Si recibe un 1 (ON), se bloquea el teclado. Si es 0 (OFF), se desbloquea
; SYSTem:KLOCk?
; Funcion: Informa si el teclado se encuentra configurado para bloquearse durante una medicion
;
; CONCEPTOS IMPORTANTES:
; En este archivo se identifican los comandos por niveles. Nivel 0 se corresponde
; con un comando perteneciente a un systema según el estandar SCPI, es decir, 
; el primer comando que podria aparecer en una secuencia de comandos.
; Por ejemplo, en CONFigure:WINDow, CONFigure sería el comando de nivel 0.
; Por otra parte, los comandos que le siguen hacia la derecha se identifican como
; de nivel 1,2,3...,N. En el ejemplo, WINDow sería un comando de nivel 1.
;
; Se entiende por una cadena de comandos a una secuencia de comandos
; separada por el caracter ':'. Por ejemplo: CONTrol:APOWer es una cadena
; de 2 comandos, siendo CONTrol y APOWer el segundo

; ===================================================================
; ========================= Constantes  =============================
; ===================================================================

; Valor asociado a cada comando para las opciones de lo switches
; --> Comandos de nivel 0:
.equ COMANDO_IDN = 0
.equ COMANDO_RST = 1
.equ COMANDO_SAV = 2
.equ COMANDO_ABORT_1 = 3 
.equ COMANDO_ABORT_2 = 4
.equ COMANDO_READ = 5
.equ COMANDO_CONF_1 = 6
.equ COMANDO_CONF_2 = 8
.equ COMANDO_CONF_QUERY_1 = 7
.equ COMANDO_CONF_QUERY_2 = 9
.equ COMANDO_MEMORY_1 = 10
.equ COMANDO_MEMORY_2 = 11
.equ COMANDO_CONTROL_1 = 12
.equ COMANDO_CONTROL_2 = 13
.equ COMANDO_STATUS_1 = 14
.equ COMANDO_STATUS_2 = 15
.equ COMANDO_SYSTEM_1 = 16
.equ COMANDO_SYSTEM_2 = 17

; -> Comandos de nivel 1 de CONFigure:
.equ COMANDO_WINDOW_1 = 0
.equ COMANDO_WINDOW_2 = 1
.equ COMANDO_WINDOW_QUERY_1 = 2
.equ COMANDO_WINDOW_QUERY_2 = 3
.equ COMANDO_COUNT_1 = 4
.equ COMANDO_COUNT_2 = 5
.equ COMANDO_COUNT_QUERY_1 = 6
.equ COMANDO_COUNT_QUERY_2 = 7
.equ COMANDO_TRIGGER_1 = 8
.equ COMANDO_TRIGGER_2 = 9
.equ COMANDO_TRIGGER_QUERY_1 = 10
.equ COMANDO_TRIGGER_QUERY_2 = 11
.equ COMANDO_DATA = 12
.equ COMANDO_DATA_QUERY = 13

; -> Comandos de nivel 1 de CONTrol:
.equ COMANDO_APOWER_1 = 0
.equ COMANDO_APOWER_2 = 1
.equ COMANDO_APOWER_QUERY_1 = 2
.equ COMANDO_APOWER_QUERY_2 = 3

; -> Comandos de nivel 1 de CONDition:
.equ COMANDO_CONDITION_QUERY_1 = 0
.equ COMANDO_CONDITION_QUERY_2 = 1

; -> Comandos de nivel 1 de SYSTem:
.equ COMANDO_SYSTEM_BEEPER_1 = 0
.equ COMANDO_SYSTEM_BEEPER_2 = 1
.equ COMANDO_SYSTEM_BEEPER_QUERY_1 = 2
.equ COMANDO_SYSTEM_BEEPER_QUERY_2 = 3
.equ COMANDO_SYSTEM_KLOCK_1 = 4
.equ COMANDO_SYSTEM_KLOCK_2 = 5
.equ COMANDO_SYSTEM_KLOCK_QUERY_1 = 6
.equ COMANDO_SYSTEM_KLOCK_QUERY_2 = 7

; -> Comandos de nivel 2 de BEEPer:
.equ COMANDO_SYSTEM_STATE_1 = 0
.equ COMANDO_SYSTEM_STATE_2 = 1
.equ COMANDO_SYSTEM_STATE_QUERY_1 = 2
.equ COMANDO_SYSTEM_STATE_QUERY_2 = 3

; Numero de comandos por nivel 
.equ TOTAL_COMANDOS_NIVEL_0 = 18
.equ TOTAL_COMANDOS_NIVEL_1_CONFIGURE = 14
.equ TOTAL_COMANDOS_NIVEL_1_MEMORY = 1
.equ TOTAL_COMANDOS_NIVEL_1_CONTROL = 4
.equ TOTAL_COMANDOS_NIVEL_1_STATUS = 2
.equ TOTAL_COMANDOS_NIVEL_1_SYSTEM = 8
.equ TOTAL_COMANDOS_NIVEL_2_BEEPER = 4

; Largo en caracteres de comando mas largo
; NOTA: debe ser actualizado a un nuevo valor
; cuando se incorpore un comando con un largo mayor
; al maximo preexistente
.equ MAX_TAMANO_COMANDO = 10

; ===================================================================
; ========================= Registros auxiliares ====================
; ===================================================================
.undef T0
.undef T1
.undef T2
.undef T3
.undef T4
.undef T5
.def T0 = R16
.def T1 = R17
.def T2 = R18
.def T3 = R19
.def T4 = R20
.def T5 = R21

; ===================================================================
; ========================= Macros ==================================
; ===================================================================
; Macro para reducir el tamano de cada switch
; Parametros: 
; -> @0 valor a comparar con @1
; -> @1 valor a comparar con @0
; -> @2 label del espacio de memoria a donde saltar mediante JMP
.MACRO JMP_IF_EQUAL
	CPI @0, @1
	IN T3, SREG
	SBRC T3, SREG_Z
	JMP @2
.ENDMACRO


; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

INTERPRETAR_CADENA_COMANDOS:

	PUSH_WORD  T0, T1
	PUSH_WORD  T2, T3
	PUSH_WORD  T4, T5
	
	PUSH_WORD XL, XH
	PUSH_WORD YL, YH
	PUSH_WORD ZL, ZH

	; Cargar parámetros de la funcion INTERPRETAR_COMANDO para parsear
	; el primer comando de la cadena
	MOVW XH:XL, PTR_RX_H:PTR_RX_L
	LDI T4, LOW(COMANDOS_NIVEL_0)
	LDI T5, HIGH(COMANDOS_NIVEL_0)
	LDI T2, TOTAL_COMANDOS_NIVEL_0

	CALL INTERPRETAR_COMANDO

	; Recuperar en T0 el indice de la tabla en memoria flash del comando recibido
	LDI T0, TOTAL_COMANDOS_NIVEL_0
	SUB T0, T2

	; Verificar que no se este midiendo
	SBRC ESTADO, EST_MEDIR_DEVOLVER_TIEMPOS
	RJMP _CHEQUEAR_ABORT
	SBRC ESTADO, EST_MEDIR_DEVOLVER_TOTAL
	RJMP _CHEQUEAR_ABORT

	; Si el indice el valor devuelto en T2 es 0,
	; entonces no se ha recibido un comando correcto
	; emitir un mensaje de error
	JMP_IF_EQUAL T2, 0, _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

	; ==========================
	; Iniciar switch para identificar cual fue el primer comando

_OPCION_COMANDO_IDN:
	JMP_IF_EQUAL T0, COMANDO_IDN, _COMANDO_IDN

_OPCION_COMANDO_RST:
	JMP_IF_EQUAL T0, COMANDO_RST, _COMANDO_RST

_OPCION_COMANDO_SAV:
	JMP_IF_EQUAL T0, COMANDO_SAV, _COMANDO_SAV

_OPCION_COMANDO_READ:
	JMP_IF_EQUAL T0, COMANDO_READ, _COMANDO_READ

_OPCION_COMANDO_CONF:
	JMP_IF_EQUAL T0, COMANDO_CONF_1, _SWITCH_COMANDO_CONF
	JMP_IF_EQUAL T0, COMANDO_CONF_2, _SWITCH_COMANDO_CONF

_OPCION_COMANDO_CONF_QUERY:
	JMP_IF_EQUAL T0, COMANDO_CONF_QUERY_1, _COMANDO_CONF_QUERY
	JMP_IF_EQUAL T0, COMANDO_CONF_QUERY_2, _COMANDO_CONF_QUERY

_OPCION_COMANDO_CONTROL:
	JMP_IF_EQUAL T0, COMANDO_CONTROL_1, _SWITCH_COMANDO_CONTROL
	JMP_IF_EQUAL T0, COMANDO_CONTROL_2, _SWITCH_COMANDO_CONTROL

_OPCION_COMANDO_SYSTEM:
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_1, _SWITCH_COMANDO_SYSTEM
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_2, _SWITCH_COMANDO_SYSTEM

_OPCION_COMANDO_ABORT:
	JMP_IF_EQUAL T0, COMANDO_ABORT_1, _COMANDO_ABORT
	JMP_IF_EQUAL T0, COMANDO_ABORT_2, _COMANDO_ABORT

	JMP _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

_CHEQUEAR_ABORT:
	JMP_IF_EQUAL T0, COMANDO_ABORT_1, _COMANDO_ABORT
	JMP_IF_EQUAL T0, COMANDO_ABORT_2, _COMANDO_ABORT
	
	JMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

; =============================================================================================
; =============================================================================================
; Switches individuales para reconocer los comandos de nivel 1 asociados a cada comando de nivel 0

; Switch del comando CONFigure
_SWITCH_COMANDO_CONF:

	; Cargar los parametros para la funcion INTERPRETAR_COMANDO
	LDI T4, LOW(COMANDOS_NIVEL_1_CONFIGURE)
	LDI T5, HIGH(COMANDOS_NIVEL_1_CONFIGURE)
	LDI T2, TOTAL_COMANDOS_NIVEL_1_CONFIGURE

	CALL INTERPRETAR_COMANDO

	; Si el indice el valor devuelto en T2 es 0,
	; entonces no se ha recibido un comando correcto
	; emitir un mensaje de error
	JMP_IF_EQUAL T2, 0, _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

	; Recuperar en T0 el indice de la tabla en memoria flash del comando recibido
	LDI T0, TOTAL_COMANDOS_NIVEL_1_CONFIGURE
	SUB T0, T2

_OPCION_COMANDO_CONF_WINDOW:
	JMP_IF_EQUAL T0, COMANDO_WINDOW_1, _COMANDO_CONF_WINDOW
	JMP_IF_EQUAL T0, COMANDO_WINDOW_2, _COMANDO_CONF_WINDOW

_OPCION_COMANDO_CONF_WINDOW_QUERY:
	JMP_IF_EQUAL T0, COMANDO_WINDOW_QUERY_1, _COMANDO_CONF_WINDOW_QUERY
	JMP_IF_EQUAL T0, COMANDO_WINDOW_QUERY_2, _COMANDO_CONF_WINDOW_QUERY

_OPCION_COMANDO_CONF_COUNT:
	JMP_IF_EQUAL T0, COMANDO_COUNT_1, _COMANDO_CONF_COUNT
	JMP_IF_EQUAL T0, COMANDO_COUNT_2, _COMANDO_CONF_COUNT

_OPCION_COMANDO_CONF_COUNT_QUERY:
	JMP_IF_EQUAL T0, COMANDO_COUNT_QUERY_1, _COMANDO_CONF_COUNT_QUERY
	JMP_IF_EQUAL T0, COMANDO_COUNT_QUERY_2, _COMANDO_CONF_COUNT_QUERY

_OPCION_COMANDO_CONF_TRIGGER:
	JMP_IF_EQUAL T0, COMANDO_TRIGGER_1, _COMANDO_CONF_TRIGGER
	JMP_IF_EQUAL T0, COMANDO_TRIGGER_2, _COMANDO_CONF_TRIGGER

_OPCION_COMANDO_CONF_TRIGGER_QUERY:
	JMP_IF_EQUAL T0, COMANDO_TRIGGER_QUERY_1, _COMANDO_CONF_TRIGGER_QUERY
	JMP_IF_EQUAL T0, COMANDO_TRIGGER_QUERY_2, _COMANDO_CONF_TRIGGER_QUERY

_OPCION_COMANDO_CONF_DATA:
	JMP_IF_EQUAL T0, COMANDO_DATA, _COMANDO_CONF_DATA

_OPCION_COMANDO_CONF_DATA_QUERY:
	JMP_IF_EQUAL T0, COMANDO_DATA_QUERY, _COMANDO_CONF_DATA_QUERY

	RJMP _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

; ===============================================================================
; Switch del comando CONTrol
_SWITCH_COMANDO_CONTROL:

	; Cargar los parametros para la funcion INTERPRETAR_COMANDO
	LDI T4, LOW(COMANDOS_NIVEL_1_CONTROL)
	LDI T5, HIGH(COMANDOS_NIVEL_1_CONTROL)
	LDI T2, TOTAL_COMANDOS_NIVEL_1_CONTROL

	CALL INTERPRETAR_COMANDO

	; Si el indice el valor devuelto en T2 es 0,
	; entonces no se ha recibido un comando correcto
	; emitir un mensaje de error
	JMP_IF_EQUAL T2, 0, _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

	; Recuperar en T0 el indice de la tabla en memoria flash del comando recibido
	LDI T0, TOTAL_COMANDOS_NIVEL_1_CONTROL
	SUB T0, T2

_OPCION_COMANDO_CONTROL_APOWER:
	JMP_IF_EQUAL T0, COMANDO_APOWER_1, _COMANDO_CONTROL_APOWER
	JMP_IF_EQUAL T0, COMANDO_APOWER_2, _COMANDO_CONTROL_APOWER

_OPCION_COMANDO_CONTROL_APOWER_QUERY:
	JMP_IF_EQUAL T0, COMANDO_APOWER_QUERY_1, _COMANDO_CONTROL_APOWER_QUERY
	JMP_IF_EQUAL T0, COMANDO_APOWER_QUERY_2, _COMANDO_CONTROL_APOWER_QUERY

	RJMP _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS


; ===============================================================================================
; Switch del comando SYSTem
_SWITCH_COMANDO_SYSTEM:

	; Cargar los parametros para la funcion INTERPRETAR_COMANDO
	LDI T4, LOW(COMANDOS_NIVEL_1_SYSTEM)
	LDI T5, HIGH(COMANDOS_NIVEL_1_SYSTEM)
	LDI T2, TOTAL_COMANDOS_NIVEL_1_SYSTEM

	CALL INTERPRETAR_COMANDO

	; Si el indice el valor devuelto en T2 es 0,
	; entonces no se ha recibido un comando correcto
	; emitir un mensaje de error
	CPI T2, 0
	IN T3, SREG
	SBRC T3, SREG_Z
	JMP _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

	; Recuperar en T0 el indice de la tabla en memoria flash del comando recibido
	LDI T0, TOTAL_COMANDOS_NIVEL_1_SYSTEM
	SUB T0, T2

_OPCION_COMANDO_SYSTEM_BEEPER:
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_BEEPER_1, _SWITCH_COMANDO_BEEPER
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_BEEPER_2, _SWITCH_COMANDO_BEEPER

_OPCION_COMANDO_SYSTEM_KLOCK:
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_KLOCK_1, _COMANDO_SYSTEM_KLOCK
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_KLOCK_2, _COMANDO_SYSTEM_KLOCK

_OPCION_COMANDO_SYSTEM_KLOCK_QUERY:
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_KLOCK_QUERY_1, _COMANDO_SYSTEM_KLOCK_QUERY
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_KLOCK_QUERY_2, _COMANDO_SYSTEM_KLOCK_QUERY

; ===============================================================================================
; Switch del comando SYSTem
_SWITCH_COMANDO_BEEPER:

	; Cargar los parametros para la funcion INTERPRETAR_COMANDO
	LDI T4, LOW(COMANDOS_NIVEL_2_BEEPER)
	LDI T5, HIGH(COMANDOS_NIVEL_2_BEEPER)
	LDI T2, TOTAL_COMANDOS_NIVEL_2_BEEPER

	CALL INTERPRETAR_COMANDO

	; Si el indice el valor devuelto en T2 es 0,
	; entonces no se ha recibido un comando correcto
	; emitir un mensaje de error
	CPI T2, 0
	IN T3, SREG
	SBRC T3, SREG_Z
	JMP _RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS

	; Recuperar en T0 el indice de la tabla en memoria flash del comando recibido
	LDI T0, TOTAL_COMANDOS_NIVEL_2_BEEPER
	SUB T0, T2

_OPCION_COMANDO_SYSTEM_STATE:
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_STATE_1, _COMANDO_SYSTEM_BEEPER_STATE
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_STATE_2, _COMANDO_SYSTEM_BEEPER_STATE

_OPCION_COMANDO_SYSTEM_STATE_QUERY:
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_STATE_QUERY_1, _COMANDO_SYSTEM_BEEPER_STATE_QUERY
	JMP_IF_EQUAL T0, COMANDO_SYSTEM_STATE_QUERY_2, _COMANDO_SYSTEM_BEEPER_STATE_QUERY

; Fin de switches para comandos de nivel 1


; ============================================================================================
; Acciones a realizarse segun con que opcion de cada switch se haya correspondido
; la cadena de comandos

; Acciones asociadas a comandos de nivel 0
_COMANDO_IDN:
	CALL ENVIAR_IDENTIDAD	
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_RST:
	CALL CONFIGURAR_REGISTROS_DEFAULT
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_SAV:
	CALL GUARDAR_CONFIGURACION_EEMPROM ; TODO: incorporar funcion de reset
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_ABORT:
	CALL CONFIGURAR_EVENTO_DETENER_MEDICION
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_READ:
	CALL CONFIGURAR_EVENTO_INICIAR_MEDICION
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

; Acciones asociadas a comandos de nivel 1 del sistema CONFigure
_COMANDO_CONF_QUERY:
	CALL DEVOLVER_CONFIGURACION
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_WINDOW:
	CALL CONFIGURAR_VENTANA_TIEMPO
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_WINDOW_QUERY:
	CALL DEVOLVER_VENTANA_TIEMPO
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_COUNT:
	LDI YL,	LOW(VENTANAS_A_MEDIR_RAM)
	LDI YH, HIGH(VENTANAS_A_MEDIR_RAM)
	
	CALL VALIDAR_ASCII_UART
	BRCS __ERR_COMANDO_CONF_COUNT
	CALL TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR_5_DIGITOS

	; Chequear si el numero de ventanas elegido por el usuario es 0 y, en ese caso
	; configurar el evento que indica que se quieren medir ventanas infinitas
	LDS T0, VENTANAS_A_MEDIR_RAM
	LDS T1, VENTANAS_A_MEDIR_RAM+1
	LDS T2, VENTANAS_A_MEDIR_RAM+2	
	LDI T3, 0
	CPI T0, 0
	CPI T1, 0
	CPC T2, T3
	BRNE __DESCONFIGURAR_VENTANAS_INFINITAS

__CONFIGURAR_VENTANAS_INFINITAS:
	LDS T0, EVENTO2
	SBR T0, (1<<BIT_VENTANAS_INF) 
	STS EVENTO2, T0 	
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

__DESCONFIGURAR_VENTANAS_INFINITAS:
	LDS T0, EVENTO2 
	CBR T0, (1<<BIT_VENTANAS_INF)
	STS EVENTO2, T0 
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

__ERR_COMANDO_CONF_COUNT:
	CALL ENVIAR_ERROR_PARSER
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_COUNT_QUERY:
	CALL DEVOLVER_NUMERO_VENTANAS 
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_TRIGGER:
	LDI YL,	LOW(REGISTRO_UMBRAL)
	LDI YH, HIGH(REGISTRO_UMBRAL)

	CALL VALIDAR_ASCII_UART
	BRCS __ERR_COMANDO_CONF_TRIGGER
	CALL TRANSFORMAR_DE_ASCII_A_BINARIO_Y_GUARDAR_5_DIGITOS
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

__ERR_COMANDO_CONF_TRIGGER:
	CALL ENVIAR_ERROR_PARSER
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_TRIGGER_QUERY:
	CALL DEVOLVER_UMBRAL
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_DATA:
	CALL CONFIGURAR_ENVIO_TIEMPOS_PULSOS
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONF_DATA_QUERY:
	LDI R18, LOW(MENSAJE_ESTADO_ENVIAR_TIEMPOS)
	LDI R19, HIGH(MENSAJE_ESTADO_ENVIAR_TIEMPOS)
	LDI R17, (1<<BIT_ENVIAR_TIEMPO_PULSOS)

	CALL DEVOLVER_CONF_BIT

	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

; Acciones asociadas a comandos de nivel 1 del sistema CONTrol
_COMANDO_SYSTEM_BEEPER_STATE:
	CALL CONFIGURAR_SENAL_SONORA
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_SYSTEM_BEEPER_STATE_QUERY:
	LDI R18, LOW(MENSAJE_ESTADO_SENAL_SONORA)
	LDI R19, HIGH(MENSAJE_ESTADO_SENAL_SONORA)
	LDI R17, (1<<BIT_SENAL_SONORA)

	CALL DEVOLVER_CONF_BIT
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONTROL_APOWER:
	CALL CONFIGURAR_APAGADO_FUENTE ;
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_CONTROL_APOWER_QUERY:
	LDI R18, LOW(MENSAJE_ESTADO_FUENTE)
	LDI R19, HIGH(MENSAJE_ESTADO_FUENTE)
	LDI R17, (1<<BIT_ACTIVAR_FUENTE)

	CALL DEVOLVER_CONF_BIT
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

; Acciones asociadas a comandos de nivel 1 del sistema MEMory
_COMANDO_SYSTEM_KLOCK:
	CALL CONFIGURAR_BLOQUEO_TECLADO
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

_COMANDO_SYSTEM_KLOCK_QUERY:
	LDI R18, LOW(MENSAJE_ESTADO_BLOQUEO_TECLADO)
	LDI R19, HIGH(MENSAJE_ESTADO_BLOQUEO_TECLADO)
	LDI R17, (1<<BIT_BLOQUEO_TECLADO)

	CALL DEVOLVER_CONF_BIT
	RJMP _RETORNAR_INTERPRETAR_CADENA_COMANDOS

; =====================
; Retorno de la funcion INTERPRETAR_CADENA_COMANDOS
_RETORNAR_ERROR_INTERPRETAR_CADENA_COMANDOS:
	CALL ENVIAR_ERROR_PARSER

_RETORNAR_INTERPRETAR_CADENA_COMANDOS:
	POP_WORD ZL, ZH
	POP_WORD YL, YH
	POP_WORD XL, XH

	POP_WORD T4, T5
	POP_WORD T2, T3
	POP_WORD T0, T1

	RET

; Fin INTERPRETAR_CADENA_COMANDOS


; ===================================================================
; =============== Funciones a ejecutar por comando ==================
; ===================================================================
; NOTA: el resto de la funciones a ejecutar por comando permanecen
; en otros archivos

ENVIAR_IDENTIDAD:
	PUSH R18
	PUSH R19

	LDI R18, LOW(MENSAJE_IDENTIDAD)
	LDI R19, HIGH(MENSAJE_IDENTIDAD)
	CALL CARGAR_BUFFER

	; Activar interrupcion por buffer UDR0 vacio para
	; enviar el contenido del buffer
	CALL ACTIVAR_INT_TX_UDRE0	

	POP R19
	POP R18
	RET

; ===================================================================
; ========================= Funciones ===============================
; ===================================================================

; Descripcion: parsea un comando almacenado en el buffer de RX, y ejecuta
; una funcion si este es valido o devuelve un mensaje de error si no lo es
; Entrada: BUFFER_RX, BYTES_RECIBIDOS
; Devuelve: -
INTERPRETAR_COMANDO:

	LSL T4
	ROL T5
	MOV ZL, T4
	MOV ZH, T5

	LPM T3, Z+ ;Adquirir el largo del comando almacenado en memoria

	MOV T4, XL ; Guardar el comienzo del primer caracter almacenado en memoria
	MOV T5, XH 

__BUCLE_INT_COMANDO_IEEE:
	LD T0, X+
	; Si se llego al caracter '\r' o ':', se termino de procesar el comando

	CPI T3, 0; Si el comando recibido tiene un largo mayor a aquel con el que se esta
			 ; comparando, entonces pasar a comparar con el siguiente
	BREQ  _FIN_COMANDO_EN_MEMORIA

	DEC T3

	LPM T1, Z+

	; Comparar caracter de los comandos, si son distintos saltar a la posicion 
	; en memoria del siguiente comando almacenado en FLASH
	CP T0, T1
	BRNE ___SIGUIENTE_COMANDO
	RJMP __BUCLE_INT_COMANDO_IEEE

_FIN_COMANDO_EN_MEMORIA:
	CPI T0, '\r'
	BREQ _RET_INTERPRETAR_COMANDO
	CPI T0, ':'
	BREQ _RET_INTERPRETAR_COMANDO
	CPI T0, ' '
	BREQ _RET_INTERPRETAR_COMANDO

___SIGUIENTE_COMANDO:
	DEC T2
	BREQ _RET_INTERPRETAR_COMANDO



	ADD ZL, T3
	LDI T3, 0
	ADC ZH, T3

	LPM T3, Z+

	; Volver al inicio del comando
	MOVW XH:XL, T5:T4

	RJMP __BUCLE_INT_COMANDO_IEEE

; Fin ___SIGUIENTE_COMANDO
; Fin __BUCLE_INT_COMANDO_IEEE

_RET_ERROR_INTERPRETAR_COMANDO:
	LDI T2, 0
	RET

_RET_INTERPRETAR_COMANDO:
	RET

; ===================================================================
; ========================= Tabla de comandos =======================
; ===================================================================

COMANDOS_NIVEL_0: .db   5, "*IDN?", 4 ,"*RST", 4, "*SAV", \
						4, "ABOR", 5, "ABORt", \
						5, "READ?", \
						4, "CONF", 5, "CONF?", \
						9, "CONFigure", 10, "CONFigure?", \
						3, "MEM", 6, "MEMory", \
						4, "CONT", 7, "CONTrol", \
						4, "STAT", 6, "STATus", \
						4, "SYST", 6, "SYSTem"

COMANDOS_NIVEL_1_CONFIGURE: .db 4, "WIND", 6, "WINDow", 5, "WIND?", 7, "WINDow?", \
								4, "COUN", 5, "COUNt", 5, "COUN?", 6, "COUNt?", \
								4, "TRIG", 7, "TRIGger", 5, "TRIG?", 8, "TRIGger?", \
								4, "DATA", 5, "DATA?"

COMANDOS_NIVEL_1_MEMORY: .db 5, "DATA?" 

COMANDOS_NIVEL_1_CONTROL: .db 4, "APOW", 6, "APOWer", \
							  5, "APOW?", 7, "APOWer?"

COMANDOS_NIVEL_1_STATUS: .db  5, "COND?", 10, "CONDition?"

COMANDOS_NIVEL_1_SYSTEM: .db  4, "BEEP", 6, "BEEPer", \
							  5, "BEEP?", 7, "BEEPer?", \
						      4, "KLOC", 5, "KLOCk", \
							  5, "KLOC?", 6, "KLOCk?"

COMANDOS_NIVEL_2_BEEPER: .db  4, "STAT", 5, "STATe", \
							  5, "STAT?", 6, "STATe?"

MENSAJE_IDENTIDAD: .db "Contador Geiger - FIUBA - 2018 - Nuñez Frau, Goyret, Vidal ", '\n', 0
