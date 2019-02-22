EESchema Schematic File Version 4
LIBS:Contador_Geiger-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 5 5
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 3250 1700 2    50   Input ~ 0
RS
Text HLabel 3250 1800 2    50   Input ~ 0
D7
Text HLabel 3250 1900 2    50   Input ~ 0
D6
Text HLabel 3250 2000 2    50   Input ~ 0
D5
Text HLabel 3250 2100 2    50   Input ~ 0
D4
Wire Wire Line
	5850 1750 6200 1750
Text HLabel 6200 1750 2    50   Input ~ 0
5V
Text HLabel 6200 1950 2    50   Input ~ 0
GND
Text HLabel 4100 4050 2    50   Input ~ 0
HABILITADOR
Text HLabel 4100 3850 2    50   Output ~ 0
PULSOS
$Comp
L Connector:Conn_01x14_Male IDC14-MACHO
U 1 1 5BFE53F8
P 3050 2200
F 0 "IDC14-MACHO" H 3156 2978 50  0000 C CNN
F 1 "Conn_01x14_Male" H 3156 2887 50  0000 C CNN
F 2 "" H 3050 2200 50  0001 C CNN
F 3 "~" H 3050 2200 50  0001 C CNN
	1    3050 2200
	1    0    0    -1  
$EndComp
Text Notes 2050 1150 0    50   ~ 0
Puerto IDC 14 lineas \n(no todas van a ser utilizadas para esta version) \npara conexion con la placa de interfaz de usuario
Text Notes 2400 3350 0    50   ~ 0
Puerto X2EHDV-4P para conexión \ncon la placa generadora de pulsos
Wire Wire Line
	4100 4050 3350 4050
$Comp
L Connector:Conn_01x04_Male X2EHDV-4P-MACHO
U 1 1 5BFE56AB
P 3150 3850
F 0 "X2EHDV-4P-MACHO" H 3256 4128 50  0000 C CNN
F 1 "Conn_01x04_Male" H 3256 4037 50  0000 C CNN
F 2 "" H 3150 3850 50  0001 C CNN
F 3 "~" H 3150 3850 50  0001 C CNN
	1    3150 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3350 3850 4100 3850
Wire Wire Line
	3350 3750 5600 3750
Wire Wire Line
	5600 3750 5600 1950
Wire Wire Line
	5600 1950 6200 1950
Wire Wire Line
	5850 1750 5850 3950
Wire Wire Line
	5850 3950 3350 3950
Text HLabel 2000 3850 0    50   Input ~ 0
#PULSOS
$Comp
L Connector:Conn_01x04_Female JX2EHDV-4P-HEMBRA
U 1 1 5BFE70B2
P 2550 3850
F 0 "JX2EHDV-4P-HEMBRA" H 1900 4150 50  0000 L CNN
F 1 "Conn_01x04_Female" H 1900 4050 50  0000 L CNN
F 2 "" H 2550 3850 50  0001 C CNN
F 3 "~" H 2550 3850 50  0001 C CNN
	1    2550 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 3850 2350 3850
Text HLabel 2000 4050 0    50   Output ~ 0
#HABILITADOR
Wire Wire Line
	2000 4050 2350 4050
Text HLabel 2000 3950 0    50   Output ~ 0
VCC_PLACA_PULSOS
Text HLabel 2000 3750 0    50   Output ~ 0
GND_PLACA_PULSOS
Wire Wire Line
	2000 3750 2350 3750
Wire Wire Line
	2000 3950 2350 3950
$Comp
L Connector:Conn_01x14_Female IDC14-HEMBRA
U 1 1 5BFE8226
P 2600 2200
F 0 "IDC14-HEMBRA" H 1900 3050 50  0000 L CNN
F 1 "Conn_01x14_Female" H 1850 2950 50  0000 L CNN
F 2 "" H 2600 2200 50  0001 C CNN
F 3 "~" H 2600 2200 50  0001 C CNN
	1    2600 2200
	1    0    0    -1  
$EndComp
Text HLabel 2400 1800 0    50   Output ~ 0
#D7
Text HLabel 2400 1900 0    50   Output ~ 0
#D6
Text HLabel 2400 2000 0    50   Output ~ 0
#D5
Text HLabel 2400 2100 0    50   Output ~ 0
#D4
Text HLabel 3250 1600 2    50   Input ~ 0
E
Text HLabel 2400 1600 0    50   Output ~ 0
#E
Text HLabel 2400 1700 0    50   Output ~ 0
#RS
Text HLabel 2400 2800 0    50   Output ~ 0
VCC_INTERFAZ_USUARIO
Text HLabel 2400 2900 0    50   Output ~ 0
GND_INTERFAZ_USUARIO
Text HLabel 3250 2200 2    50   Output ~ 0
TECLADO
Text HLabel 3250 2300 2    50   Input ~ 0
LED
Text HLabel 3250 2400 2    50   Input ~ 0
BUZZER
Text HLabel 2400 2200 0    50   Input ~ 0
#TECLADO
Text HLabel 2400 2300 0    50   Output ~ 0
#LED
Text HLabel 2400 2400 0    50   Output ~ 0
#BUZZER
Wire Wire Line
	5850 1750 4700 1750
Wire Wire Line
	4700 1750 4700 2800
Wire Wire Line
	4700 2800 3250 2800
Connection ~ 5850 1750
Wire Wire Line
	5600 1950 4850 1950
Wire Wire Line
	4850 1950 4850 2900
Wire Wire Line
	4850 2900 3250 2900
Connection ~ 5600 1950
$EndSCHEMATC
