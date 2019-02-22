EESchema Schematic File Version 4
LIBS:Contador_Geiger-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 5
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Display_Character:RC1602A LCD_SCREEN
U 1 1 5BED2EBE
P 5450 2550
F 0 "LCD_SCREEN" H 5200 3250 50  0000 C CNN
F 1 "RC1602A" H 5100 3350 50  0000 C CNN
F 2 "Display:RC1602A" H 5550 1750 50  0001 C CNN
F 3 "http://www.raystar-optronics.com/down.php?ProID=18" H 5550 2450 50  0001 C CNN
	1    5450 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 1550 5450 1850
$Comp
L power:GNDD #PWR?
U 1 1 5BED2EC6
P 5450 3350
F 0 "#PWR?" H 5450 3100 50  0001 C CNN
F 1 "GNDD" H 5454 3195 50  0000 C CNN
F 2 "" H 5450 3350 50  0001 C CNN
F 3 "" H 5450 3350 50  0001 C CNN
	1    5450 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 3350 5450 3300
$Comp
L Device:R_POT 10k
U 1 1 5BED2ECD
P 6350 2350
F 0 "10k" H 6280 2304 50  0000 R CNN
F 1 "R_POT" H 6280 2395 50  0000 R CNN
F 2 "" H 6350 2350 50  0001 C CNN
F 3 "~" H 6350 2350 50  0001 C CNN
	1    6350 2350
	-1   0    0    1   
$EndComp
Wire Wire Line
	6200 2350 5850 2350
Wire Wire Line
	6350 2200 6350 1550
Wire Wire Line
	6350 1550 5850 1550
Wire Wire Line
	5450 3300 6350 3300
Wire Wire Line
	6350 3300 6350 2750
Connection ~ 5450 3300
Wire Wire Line
	5450 3300 5450 3250
$Comp
L power:+5V #PWR?
U 1 1 5BED2EDB
P 5950 2850
F 0 "#PWR?" H 5950 2700 50  0001 C CNN
F 1 "+5V" V 5965 2978 50  0000 L CNN
F 2 "" H 5950 2850 50  0001 C CNN
F 3 "" H 5950 2850 50  0001 C CNN
	1    5950 2850
	0    1    1    0   
$EndComp
Wire Wire Line
	5950 2850 5850 2850
Wire Wire Line
	5850 2750 6350 2750
Connection ~ 6350 2750
Wire Wire Line
	6350 2750 6350 2500
Wire Wire Line
	4850 2050 5050 2050
Wire Wire Line
	5050 2250 4850 2250
Wire Wire Line
	4850 2750 5050 2750
Wire Wire Line
	5050 2850 4850 2850
Wire Wire Line
	4850 2950 5050 2950
Wire Wire Line
	5050 3050 4850 3050
$Comp
L power:GNDD #PWR?
U 1 1 5BED2EF1
P 4550 2200
F 0 "#PWR?" H 4550 1950 50  0001 C CNN
F 1 "GNDD" H 4554 2045 50  0000 C CNN
F 2 "" H 4550 2200 50  0001 C CNN
F 3 "" H 4550 2200 50  0001 C CNN
	1    4550 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5050 2150 4550 2150
Wire Wire Line
	4550 2150 4550 2200
$Comp
L Device:LED D?
U 1 1 5BED2EF9
P 3250 3000
F 0 "D?" H 3242 2745 50  0001 C CNN
F 1 "LED_ROJO" H 3242 2836 50  0000 C CNN
F 2 "" H 3250 3000 50  0001 C CNN
F 3 "~" H 3250 3000 50  0001 C CNN
	1    3250 3000
	0    1    -1   0   
$EndComp
Wire Wire Line
	2550 3400 2650 3400
Wire Wire Line
	5050 2350 4850 2350
Wire Wire Line
	5050 2450 4850 2450
Wire Wire Line
	5050 2550 4850 2550
Wire Wire Line
	5050 2650 4850 2650
Text HLabel 4850 2050 0    50   Input ~ 0
RS
Text HLabel 4850 2250 0    50   Input ~ 0
E
Text HLabel 4850 3050 0    50   Input ~ 0
D7
Text HLabel 4850 2950 0    50   Input ~ 0
D6
Text HLabel 4850 2850 0    50   Input ~ 0
D5
Text HLabel 4850 2750 0    50   Input ~ 0
D4
$Comp
L power:+5V #PWR?
U 1 1 5C76CE05
P 5850 1550
F 0 "#PWR?" H 5850 1400 50  0001 C CNN
F 1 "+5V" H 5865 1678 50  0000 L CNN
F 2 "" H 5850 1550 50  0001 C CNN
F 3 "" H 5850 1550 50  0001 C CNN
	1    5850 1550
	1    0    0    -1  
$EndComp
Connection ~ 5850 1550
Wire Wire Line
	5850 1550 5450 1550
Text HLabel 2550 3400 0    50   Input ~ 0
LED
$Comp
L power:+5V #PWR?
U 1 1 5C76F207
P 3050 1500
F 0 "#PWR?" H 3050 1350 50  0001 C CNN
F 1 "+5V" H 3065 1628 50  0000 L CNN
F 2 "" H 3050 1500 50  0001 C CNN
F 3 "" H 3050 1500 50  0001 C CNN
	1    3050 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	3050 1500 3050 1550
Wire Wire Line
	3050 1550 3400 1550
Text HLabel 3400 1550 2    50   Input ~ 0
5V
$Comp
L power:GNDD #PWR?
U 1 1 5C76F83C
P 3050 1850
F 0 "#PWR?" H 3050 1600 50  0001 C CNN
F 1 "GNDD" H 3054 1695 50  0000 C CNN
F 2 "" H 3050 1850 50  0001 C CNN
F 3 "" H 3050 1850 50  0001 C CNN
	1    3050 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3050 1850 3050 1750
Wire Wire Line
	3050 1750 3400 1750
Text HLabel 3400 1750 2    50   Input ~ 0
GND
$Comp
L Switch:SW_SPST SW1
U 1 1 5C7741D2
P 9150 1650
F 0 "SW1" H 9150 1885 50  0000 C CNN
F 1 "CANCELAR" H 9150 1794 50  0000 C CNN
F 2 "" H 9150 1650 50  0001 C CNN
F 3 "" H 9150 1650 50  0001 C CNN
	1    9150 1650
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW2
U 1 1 5C775EA4
P 9150 2150
F 0 "SW2" H 9150 2385 50  0000 C CNN
F 1 "OK" H 9150 2294 50  0000 C CNN
F 2 "" H 9150 2150 50  0001 C CNN
F 3 "" H 9150 2150 50  0001 C CNN
	1    9150 2150
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW3
U 1 1 5C775F0C
P 9150 2650
F 0 "SW3" H 9150 2885 50  0000 C CNN
F 1 "FLECHA_ABAJO" H 9150 2794 50  0000 C CNN
F 2 "" H 9150 2650 50  0001 C CNN
F 3 "" H 9150 2650 50  0001 C CNN
	1    9150 2650
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW4
U 1 1 5C775F3A
P 9150 3150
F 0 "SW4" H 9150 3385 50  0000 C CNN
F 1 "FLECHA_DERECHA" H 9150 3294 50  0000 C CNN
F 2 "" H 9150 3150 50  0001 C CNN
F 3 "" H 9150 3150 50  0001 C CNN
	1    9150 3150
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW5
U 1 1 5C775F6A
P 9150 3650
F 0 "SW5" H 9150 3885 50  0000 C CNN
F 1 "FLECHA_ARRIBA" H 9150 3794 50  0000 C CNN
F 2 "" H 9150 3650 50  0001 C CNN
F 3 "" H 9150 3650 50  0001 C CNN
	1    9150 3650
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_SPST SW6
U 1 1 5C775F9C
P 9150 4150
F 0 "SW6" H 9150 4385 50  0000 C CNN
F 1 "FLECHA_IZQUIERDA" H 9150 4294 50  0000 C CNN
F 2 "" H 9150 4150 50  0001 C CNN
F 3 "" H 9150 4150 50  0001 C CNN
	1    9150 4150
	1    0    0    -1  
$EndComp
$Comp
L Device:R R8
U 1 1 5C77606F
P 8600 1900
F 0 "R8" H 8670 1946 50  0000 L CNN
F 1 "80k" H 8670 1855 50  0000 L CNN
F 2 "" V 8530 1900 50  0001 C CNN
F 3 "~" H 8600 1900 50  0001 C CNN
	1    8600 1900
	1    0    0    -1  
$EndComp
$Comp
L Device:R R7
U 1 1 5C7760E7
P 8600 2450
F 0 "R7" H 8670 2496 50  0000 L CNN
F 1 "47k" H 8670 2405 50  0000 L CNN
F 2 "" V 8530 2450 50  0001 C CNN
F 3 "~" H 8600 2450 50  0001 C CNN
	1    8600 2450
	1    0    0    -1  
$EndComp
$Comp
L Device:R R6
U 1 1 5C776123
P 8600 2950
F 0 "R6" H 8670 2996 50  0000 L CNN
F 1 "33k" H 8670 2905 50  0000 L CNN
F 2 "" V 8530 2950 50  0001 C CNN
F 3 "~" H 8600 2950 50  0001 C CNN
	1    8600 2950
	1    0    0    -1  
$EndComp
$Comp
L Device:R R5
U 1 1 5C77616B
P 8600 3450
F 0 "R5" H 8670 3496 50  0000 L CNN
F 1 "20k" H 8670 3405 50  0000 L CNN
F 2 "" V 8530 3450 50  0001 C CNN
F 3 "~" H 8600 3450 50  0001 C CNN
	1    8600 3450
	1    0    0    -1  
$EndComp
$Comp
L Device:R R4
U 1 1 5C776249
P 8600 3950
F 0 "R4" H 8670 3996 50  0000 L CNN
F 1 "15k" H 8670 3905 50  0000 L CNN
F 2 "" V 8530 3950 50  0001 C CNN
F 3 "~" H 8600 3950 50  0001 C CNN
	1    8600 3950
	1    0    0    -1  
$EndComp
$Comp
L Device:R R3
U 1 1 5C776299
P 8600 4550
F 0 "R3" H 8300 4600 50  0000 L CNN
F 1 "100k" H 8300 4500 50  0000 L CNN
F 2 "" V 8530 4550 50  0001 C CNN
F 3 "~" H 8600 4550 50  0001 C CNN
	1    8600 4550
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR?
U 1 1 5C7762E3
P 8600 4750
F 0 "#PWR?" H 8600 4500 50  0001 C CNN
F 1 "GNDD" H 8604 4595 50  0000 C CNN
F 2 "" H 8600 4750 50  0001 C CNN
F 3 "" H 8600 4750 50  0001 C CNN
	1    8600 4750
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5C77637E
P 9500 1350
F 0 "#PWR?" H 9500 1200 50  0001 C CNN
F 1 "+5V" H 9515 1478 50  0000 L CNN
F 2 "" H 9500 1350 50  0001 C CNN
F 3 "" H 9500 1350 50  0001 C CNN
	1    9500 1350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9500 1350 9500 1650
Wire Wire Line
	9500 1650 9350 1650
Wire Wire Line
	9500 2150 9350 2150
Wire Wire Line
	9500 1650 9500 2150
Connection ~ 9500 1650
Wire Wire Line
	9350 2650 9500 2650
Wire Wire Line
	9500 2650 9500 2150
Connection ~ 9500 2150
Wire Wire Line
	9350 3150 9500 3150
Wire Wire Line
	9500 3150 9500 2650
Connection ~ 9500 2650
Wire Wire Line
	9350 3650 9500 3650
Wire Wire Line
	9500 3650 9500 3150
Connection ~ 9500 3150
Wire Wire Line
	9350 4150 9500 4150
Wire Wire Line
	9500 4150 9500 3650
Connection ~ 9500 3650
Wire Wire Line
	8600 4400 8600 4150
Connection ~ 8600 4150
Wire Wire Line
	8600 4150 8600 4100
Wire Wire Line
	8600 3800 8600 3650
Wire Wire Line
	8600 3650 8950 3650
Connection ~ 8600 3650
Wire Wire Line
	8600 3650 8600 3600
Wire Wire Line
	8950 3150 8600 3150
Wire Wire Line
	8600 3150 8600 3300
Wire Wire Line
	8600 3150 8600 3100
Connection ~ 8600 3150
Wire Wire Line
	8600 2800 8600 2650
Wire Wire Line
	8600 2650 8950 2650
Connection ~ 8600 2650
Wire Wire Line
	8600 2650 8600 2600
Wire Wire Line
	8950 2150 8600 2150
Wire Wire Line
	8600 2150 8600 2300
Wire Wire Line
	8600 2150 8600 2050
Connection ~ 8600 2150
Wire Wire Line
	8950 1650 8600 1650
Wire Wire Line
	8600 1650 8600 1750
Wire Wire Line
	8600 4700 8600 4750
Wire Wire Line
	8600 4150 7800 4150
Text HLabel 7800 4150 0    50   Output ~ 0
TECLADO
$Comp
L Device:C_Small C1
U 1 1 5C7883B6
P 8850 4550
F 0 "C1" H 8942 4596 50  0000 L CNN
F 1 "0.1u" H 8942 4505 50  0000 L CNN
F 2 "" H 8850 4550 50  0001 C CNN
F 3 "~" H 8850 4550 50  0001 C CNN
	1    8850 4550
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR?
U 1 1 5C78840C
P 8850 4750
F 0 "#PWR?" H 8850 4500 50  0001 C CNN
F 1 "GNDD" H 8854 4595 50  0000 C CNN
F 2 "" H 8850 4750 50  0001 C CNN
F 3 "" H 8850 4750 50  0001 C CNN
	1    8850 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 4750 8850 4650
Wire Wire Line
	8850 4450 8850 4150
Wire Wire Line
	8600 4150 8850 4150
Connection ~ 8850 4150
Wire Wire Line
	8850 4150 8950 4150
$Comp
L Transistor_BJT:BC548 TBJ_LED
U 1 1 5BF872C1
P 3150 3400
F 0 "TBJ_LED" H 3341 3446 50  0000 L CNN
F 1 "BC548/BC547" H 3341 3355 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline" H 3350 3325 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/BC/BC547.pdf" H 3150 3400 50  0001 L CNN
	1    3150 3400
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR?
U 1 1 5BF8D6E4
P 3250 3600
F 0 "#PWR?" H 3250 3350 50  0001 C CNN
F 1 "GNDD" H 3254 3445 50  0000 C CNN
F 2 "" H 3250 3600 50  0001 C CNN
F 3 "" H 3250 3600 50  0001 C CNN
	1    3250 3600
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5BF8DA67
P 3250 2500
F 0 "#PWR?" H 3250 2350 50  0001 C CNN
F 1 "+5V" H 3265 2673 50  0000 C CNN
F 2 "" H 3250 2500 50  0001 C CNN
F 3 "" H 3250 2500 50  0001 C CNN
	1    3250 2500
	1    0    0    -1  
$EndComp
Text HLabel 2650 5500 0    50   Input ~ 0
BUZZER
$Comp
L Device:R R_B_LED
U 1 1 5BF91E13
P 2800 3400
F 0 "R_B_LED" V 2593 3400 50  0000 C CNN
F 1 "10k" V 2684 3400 50  0000 C CNN
F 2 "" V 2730 3400 50  0001 C CNN
F 3 "~" H 2800 3400 50  0001 C CNN
	1    2800 3400
	0    1    1    0   
$EndComp
$Comp
L Device:R R_C_LED
U 1 1 5BF921BF
P 3250 2700
F 0 "R_C_LED" H 3320 2746 50  0000 L CNN
F 1 "220" H 3320 2655 50  0000 L CNN
F 2 "" V 3180 2700 50  0001 C CNN
F 3 "~" H 3250 2700 50  0001 C CNN
	1    3250 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	3250 2550 3250 2500
Wire Wire Line
	3250 3150 3250 3200
Wire Wire Line
	2650 5500 2750 5500
$Comp
L Transistor_BJT:BC548 TBJ_BUZZER
U 1 1 5BF99897
P 3250 5500
F 0 "TBJ_BUZZER" H 3441 5546 50  0000 L CNN
F 1 "BC548/BC547" H 3441 5455 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline" H 3450 5425 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/BC/BC547.pdf" H 3250 5500 50  0001 L CNN
	1    3250 5500
	1    0    0    -1  
$EndComp
$Comp
L power:GNDD #PWR?
U 1 1 5BF9989E
P 3350 5700
F 0 "#PWR?" H 3350 5450 50  0001 C CNN
F 1 "GNDD" H 3354 5545 50  0000 C CNN
F 2 "" H 3350 5700 50  0001 C CNN
F 3 "" H 3350 5700 50  0001 C CNN
	1    3350 5700
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5BF998A4
P 3350 4300
F 0 "#PWR?" H 3350 4150 50  0001 C CNN
F 1 "+5V" H 3365 4473 50  0000 C CNN
F 2 "" H 3350 4300 50  0001 C CNN
F 3 "" H 3350 4300 50  0001 C CNN
	1    3350 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:R R_B_BUZZER
U 1 1 5BF998AA
P 2900 5500
F 0 "R_B_BUZZER" V 2693 5500 50  0000 C CNN
F 1 "10k" V 2784 5500 50  0000 C CNN
F 2 "" V 2830 5500 50  0001 C CNN
F 3 "~" H 2900 5500 50  0001 C CNN
	1    2900 5500
	0    1    1    0   
$EndComp
Wire Wire Line
	3350 5250 3350 5300
$Comp
L Device:Buzzer BUZZER_0
U 1 1 5BF9D38E
P 3450 5150
F 0 "BUZZER_0" H 3850 5050 50  0000 C CNN
F 1 "Buzzer" H 3800 5150 50  0000 C CNN
F 2 "" V 3425 5250 50  0001 C CNN
F 3 "~" V 3425 5250 50  0001 C CNN
	1    3450 5150
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT R_POT_BUZZER
U 1 1 5BFA17E1
P 3350 4550
F 0 "R_POT_BUZZER" H 3281 4504 50  0000 R CNN
F 1 "500" H 3281 4595 50  0000 R CNN
F 2 "" H 3350 4550 50  0001 C CNN
F 3 "~" H 3350 4550 50  0001 C CNN
	1    3350 4550
	-1   0    0    1   
$EndComp
Wire Wire Line
	3100 4550 3200 4550
Wire Wire Line
	3350 4300 3350 4350
Wire Wire Line
	3100 4550 3100 4350
Wire Wire Line
	3100 4350 3350 4350
Connection ~ 3350 4350
Wire Wire Line
	3350 4350 3350 4400
$Comp
L Device:R R_BUZZER
U 1 1 5BFBECAA
P 3350 4850
F 0 "R_BUZZER" H 3420 4896 50  0000 L CNN
F 1 "100" H 3420 4805 50  0000 L CNN
F 2 "" V 3280 4850 50  0001 C CNN
F 3 "~" H 3350 4850 50  0001 C CNN
	1    3350 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3350 5050 3350 5000
Text Notes 7700 1300 0    50   ~ 0
Completar con valores de las resistencias
$EndSCHEMATC
