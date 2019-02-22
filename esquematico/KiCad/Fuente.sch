EESchema Schematic File Version 4
LIBS:Contador_Geiger-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 5
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
L Connector:Screw_Terminal_01x02 J1
U 1 1 5B9D227E
P 2750 1400
F 0 "J1" H 2750 1650 50  0000 C CNN
F 1 "6V/0.5AMP" H 2750 1550 50  0000 C CNN
F 2 "" H 2750 1400 50  0001 C CNN
F 3 "~" H 2750 1400 50  0001 C CNN
	1    2750 1400
	-1   0    0    -1  
$EndComp
$Comp
L Device:D_Bridge_+-AA D1
U 1 1 5B9D2454
P 3800 1450
F 0 "D1" H 4000 1750 50  0000 L CNN
F 1 "1AMP" H 4000 1650 50  0000 L CNN
F 2 "" H 3800 1450 50  0001 C CNN
F 3 "~" H 3800 1450 50  0001 C CNN
	1    3800 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 1150 3800 1050
Wire Wire Line
	3800 1050 3150 1050
Wire Wire Line
	3150 1050 3150 1400
Wire Wire Line
	3150 1400 2950 1400
Wire Wire Line
	2950 1500 3150 1500
Wire Wire Line
	3150 1500 3150 1950
Wire Wire Line
	3150 1950 3800 1950
Wire Wire Line
	3800 1950 3800 1750
$Comp
L power:GNDREF #PWR04
U 1 1 5B9D2564
P 3450 1600
F 0 "#PWR04" H 3450 1350 50  0001 C CNN
F 1 "GNDREF" H 3455 1427 50  0000 C CNN
F 2 "" H 3450 1600 50  0001 C CNN
F 3 "" H 3450 1600 50  0001 C CNN
	1    3450 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 1450 3450 1450
Wire Wire Line
	3450 1450 3450 1600
$Comp
L Device:CP1_Small C6
U 1 1 5B9D2651
P 4300 1700
F 0 "C6" H 4391 1746 50  0000 L CNN
F 1 "330uFX10V" H 4391 1655 50  0000 L CNN
F 2 "" H 4300 1700 50  0001 C CNN
F 3 "~" H 4300 1700 50  0001 C CNN
	1    4300 1700
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR06
U 1 1 5B9D26BB
P 4300 1900
F 0 "#PWR06" H 4300 1650 50  0001 C CNN
F 1 "GNDREF" H 4305 1727 50  0000 C CNN
F 2 "" H 4300 1900 50  0001 C CNN
F 3 "" H 4300 1900 50  0001 C CNN
	1    4300 1900
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C7
U 1 1 5B9D26EC
P 4950 1700
F 0 "C7" H 5042 1746 50  0000 L CNN
F 1 "0.1uF" H 5042 1655 50  0000 L CNN
F 2 "" H 4950 1700 50  0001 C CNN
F 3 "~" H 4950 1700 50  0001 C CNN
	1    4950 1700
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR08
U 1 1 5B9D2744
P 4950 1900
F 0 "#PWR08" H 4950 1650 50  0001 C CNN
F 1 "GNDREF" H 4955 1727 50  0000 C CNN
F 2 "" H 4950 1900 50  0001 C CNN
F 3 "" H 4950 1900 50  0001 C CNN
	1    4950 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 1450 4300 1450
Wire Wire Line
	4950 1450 4950 1600
Wire Wire Line
	4300 1600 4300 1450
Connection ~ 4300 1450
Wire Wire Line
	4300 1450 4950 1450
Wire Wire Line
	4300 1800 4300 1900
Wire Wire Line
	4950 1800 4950 1900
$Comp
L Device:CP1_Small C11
U 1 1 5B9D2D85
P 7050 1650
F 0 "C11" H 7141 1696 50  0000 L CNN
F 1 "330uFX10V" H 7141 1605 50  0000 L CNN
F 2 "" H 7050 1650 50  0001 C CNN
F 3 "~" H 7050 1650 50  0001 C CNN
	1    7050 1650
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR017
U 1 1 5B9D2DFA
P 7050 1850
F 0 "#PWR017" H 7050 1600 50  0001 C CNN
F 1 "GNDREF" H 7055 1677 50  0000 C CNN
F 2 "" H 7050 1850 50  0001 C CNN
F 3 "" H 7050 1850 50  0001 C CNN
	1    7050 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	7050 1450 7050 1550
$Comp
L Device:LED_Small D5
U 1 1 5B9D34DF
P 7750 1600
F 0 "D5" V 7796 1532 50  0000 R CNN
F 1 "LED_RO_5MM" V 7705 1532 50  0000 R CNN
F 2 "" V 7750 1600 50  0001 C CNN
F 3 "~" V 7750 1600 50  0001 C CNN
	1    7750 1600
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_Small R15
U 1 1 5B9D35AC
P 7750 1850
F 0 "R15" H 7809 1896 50  0000 L CNN
F 1 "330" H 7809 1805 50  0000 L CNN
F 2 "" H 7750 1850 50  0001 C CNN
F 3 "~" H 7750 1850 50  0001 C CNN
	1    7750 1850
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR021
U 1 1 5B9D35F6
P 7750 2000
F 0 "#PWR021" H 7750 1750 50  0001 C CNN
F 1 "GNDREF" H 7755 1827 50  0000 C CNN
F 2 "" H 7750 2000 50  0001 C CNN
F 3 "" H 7750 2000 50  0001 C CNN
	1    7750 2000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 2000 7750 1950
Wire Wire Line
	7750 1750 7750 1700
Wire Wire Line
	7750 1500 7750 1450
Wire Wire Line
	7750 1450 7050 1450
$Comp
L Connector:TestPoint TP7
U 1 1 5B9D3D53
P 7750 1350
F 0 "TP7" H 7808 1470 50  0000 L CNN
F 1 "VCC" H 7808 1379 50  0000 L CNN
F 2 "" H 7950 1350 50  0001 C CNN
F 3 "~" H 7950 1350 50  0001 C CNN
	1    7750 1350
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP8
U 1 1 5B9D3D99
P 9300 1300
F 0 "TP8" H 9358 1420 50  0000 L CNN
F 1 "GND" H 9358 1329 50  0000 L CNN
F 2 "" H 9500 1300 50  0001 C CNN
F 3 "~" H 9500 1300 50  0001 C CNN
	1    9300 1300
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP9
U 1 1 5B9D3E01
P 9800 1300
F 0 "TP9" H 9858 1420 50  0000 L CNN
F 1 "GND" H 9858 1329 50  0000 L CNN
F 2 "" H 10000 1300 50  0001 C CNN
F 3 "~" H 10000 1300 50  0001 C CNN
	1    9800 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 1350 7750 1450
Connection ~ 7750 1450
$Comp
L power:GNDREF #PWR024
U 1 1 5B9D413E
P 9300 1450
F 0 "#PWR024" H 9300 1200 50  0001 C CNN
F 1 "GNDREF" H 9305 1277 50  0000 C CNN
F 2 "" H 9300 1450 50  0001 C CNN
F 3 "" H 9300 1450 50  0001 C CNN
	1    9300 1450
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR025
U 1 1 5B9D4163
P 9800 1450
F 0 "#PWR025" H 9800 1200 50  0001 C CNN
F 1 "GNDREF" H 9805 1277 50  0000 C CNN
F 2 "" H 9800 1450 50  0001 C CNN
F 3 "" H 9800 1450 50  0001 C CNN
	1    9800 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9800 1450 9800 1300
Wire Wire Line
	9300 1450 9300 1300
$Comp
L Device:C_Small C2
U 1 1 5B9D5603
P 2650 4300
F 0 "C2" H 2742 4346 50  0000 L CNN
F 1 "0.1uF" H 2742 4255 50  0000 L CNN
F 2 "" H 2650 4300 50  0001 C CNN
F 3 "~" H 2650 4300 50  0001 C CNN
	1    2650 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1_Small C3
U 1 1 5B9D5609
P 3050 4300
F 0 "C3" H 3141 4346 50  0000 L CNN
F 1 "100uFX25V" H 3141 4255 50  0000 L CNN
F 2 "" H 3050 4300 50  0001 C CNN
F 3 "~" H 3050 4300 50  0001 C CNN
	1    3050 4300
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR02
U 1 1 5B9D560F
P 2650 4500
F 0 "#PWR02" H 2650 4250 50  0001 C CNN
F 1 "GNDREF" H 2655 4327 50  0000 C CNN
F 2 "" H 2650 4500 50  0001 C CNN
F 3 "" H 2650 4500 50  0001 C CNN
	1    2650 4500
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR03
U 1 1 5B9D5615
P 3050 4500
F 0 "#PWR03" H 3050 4250 50  0001 C CNN
F 1 "GNDREF" H 3055 4327 50  0000 C CNN
F 2 "" H 3050 4500 50  0001 C CNN
F 3 "" H 3050 4500 50  0001 C CNN
	1    3050 4500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2650 4400 2650 4500
Wire Wire Line
	3050 4400 3050 4500
Wire Wire Line
	3050 4200 3050 4100
Wire Wire Line
	3050 4100 3750 4100
Wire Wire Line
	3050 4100 2650 4100
Wire Wire Line
	2650 4100 2650 4200
Connection ~ 3050 4100
$Comp
L power:GNDREF #PWR05
U 1 1 5B9D6762
P 3500 4800
F 0 "#PWR05" H 3500 4550 50  0001 C CNN
F 1 "GNDREF" H 3505 4627 50  0000 C CNN
F 2 "" H 3500 4800 50  0001 C CNN
F 3 "" H 3500 4800 50  0001 C CNN
	1    3500 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	3500 4400 3500 4700
Wire Wire Line
	3500 4400 3750 4400
Connection ~ 3500 4700
Wire Wire Line
	3500 4700 3500 4800
Wire Wire Line
	3500 4700 3750 4700
Text Label 3400 4100 0    50   ~ 0
VIN
$Comp
L Device:Transformer_1P_1S T1
U 1 1 5B9D8223
P 5300 3400
F 0 "T1" H 5300 3850 50  0000 C CNN
F 1 "7:770" H 5300 3750 50  0000 C CNN
F 2 "" H 5300 3400 50  0001 C CNN
F 3 "~" H 5300 3400 50  0001 C CNN
	1    5300 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4900 3600 4800 3600
Wire Wire Line
	4800 3600 4800 4100
Wire Wire Line
	4800 4100 4750 4100
Text Label 4500 3200 0    50   ~ 0
VIN
$Comp
L Device:D_Small D2
U 1 1 5B9D92D5
P 4600 3600
F 0 "D2" H 4600 3805 50  0000 C CNN
F 1 "1N4148" H 4600 3714 50  0000 C CNN
F 2 "" V 4600 3600 50  0001 C CNN
F 3 "~" V 4600 3600 50  0001 C CNN
	1    4600 3600
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C5
U 1 1 5B9D94D6
P 4100 3400
F 0 "C5" H 4192 3446 50  0000 L CNN
F 1 "0.22uF" H 4192 3355 50  0000 L CNN
F 2 "" H 4100 3400 50  0001 C CNN
F 3 "~" H 4100 3400 50  0001 C CNN
	1    4100 3400
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R2
U 1 1 5B9D974A
P 3100 3400
F 0 "R2" H 3159 3446 50  0000 L CNN
F 1 "2.2K 1/2W" H 3159 3355 50  0000 L CNN
F 2 "" H 3100 3400 50  0001 C CNN
F 3 "~" H 3100 3400 50  0001 C CNN
	1    3100 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4500 3600 4100 3600
Wire Wire Line
	4100 3600 4100 3500
Wire Wire Line
	4100 3600 3650 3600
Wire Wire Line
	3100 3600 3100 3500
Connection ~ 4100 3600
Wire Wire Line
	4100 3200 4100 3300
Wire Wire Line
	4100 3200 4900 3200
Wire Wire Line
	3100 3200 3100 3300
Wire Wire Line
	3100 3200 3650 3200
Connection ~ 4100 3200
Wire Wire Line
	4700 3600 4800 3600
Connection ~ 4800 3600
$Comp
L Connector:TestPoint TP1
U 1 1 5B9DD460
P 5050 4000
F 0 "TP1" H 5108 4120 50  0000 L CNN
F 1 "SWITCH" H 5108 4029 50  0000 L CNN
F 2 "" H 5250 4000 50  0001 C CNN
F 3 "~" H 5250 4000 50  0001 C CNN
	1    5050 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5050 4000 5050 4100
Wire Wire Line
	5050 4100 4800 4100
Connection ~ 4800 4100
Text Label 4900 4100 0    50   ~ 0
SW
$Comp
L power:GNDREF #PWR010
U 1 1 5B9DE2D7
P 5800 3700
F 0 "#PWR010" H 5800 3450 50  0001 C CNN
F 1 "GNDREF" H 5805 3527 50  0000 C CNN
F 2 "" H 5800 3700 50  0001 C CNN
F 3 "" H 5800 3700 50  0001 C CNN
	1    5800 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 3600 5800 3600
Wire Wire Line
	5800 3600 5800 3700
Wire Wire Line
	5700 3200 5800 3200
$Comp
L Device:D_Small D3
U 1 1 5B9DFBB0
P 5900 3200
F 0 "D3" H 5900 2995 50  0000 C CNN
F 1 "UF4007" H 5900 3086 50  0000 C CNN
F 2 "" V 5900 3200 50  0001 C CNN
F 3 "~" V 5900 3200 50  0001 C CNN
	1    5900 3200
	-1   0    0    1   
$EndComp
$Comp
L Device:D_Small D4
U 1 1 5B9DFD43
P 6250 3200
F 0 "D4" H 6250 2995 50  0000 C CNN
F 1 "UF4007" H 6250 3086 50  0000 C CNN
F 2 "" V 6250 3200 50  0001 C CNN
F 3 "~" V 6250 3200 50  0001 C CNN
	1    6250 3200
	-1   0    0    1   
$EndComp
Wire Wire Line
	6000 3200 6150 3200
$Comp
L Device:C_Small C13
U 1 1 5B9E30E8
P 7550 3400
F 0 "C13" H 7642 3446 50  0000 L CNN
F 1 "0.1uF X 630V" H 7642 3355 50  0000 L CNN
F 2 "" H 7550 3400 50  0001 C CNN
F 3 "~" H 7550 3400 50  0001 C CNN
	1    7550 3400
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR020
U 1 1 5B9E32E3
P 7550 3600
F 0 "#PWR020" H 7550 3350 50  0001 C CNN
F 1 "GNDREF" H 7555 3427 50  0000 C CNN
F 2 "" H 7550 3600 50  0001 C CNN
F 3 "" H 7550 3600 50  0001 C CNN
	1    7550 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 3500 7550 3600
Wire Wire Line
	7550 3300 7550 3200
$Comp
L Device:R_Small R9
U 1 1 5B9E5EF9
P 7000 3400
F 0 "R9" H 7059 3446 50  0000 L CNN
F 1 "470K MF" H 7059 3355 50  0000 L CNN
F 2 "" H 7000 3400 50  0001 C CNN
F 3 "~" H 7000 3400 50  0001 C CNN
	1    7000 3400
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R10
U 1 1 5B9E6F53
P 7000 3750
F 0 "R10" H 7059 3796 50  0000 L CNN
F 1 "470K MF" H 7059 3705 50  0000 L CNN
F 2 "" H 7000 3750 50  0001 C CNN
F 3 "~" H 7000 3750 50  0001 C CNN
	1    7000 3750
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R11
U 1 1 5B9E7D14
P 7000 4050
F 0 "R11" H 7059 4096 50  0000 L CNN
F 1 "470K MF" H 7059 4005 50  0000 L CNN
F 2 "" H 7000 4050 50  0001 C CNN
F 3 "~" H 7000 4050 50  0001 C CNN
	1    7000 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 3300 7000 3200
Connection ~ 7000 3200
$Comp
L Device:R_Small R12
U 1 1 5B9F87CE
P 7000 4800
F 0 "R12" H 7059 4846 50  0000 L CNN
F 1 "47K MF" H 7059 4755 50  0000 L CNN
F 2 "" H 7000 4800 50  0001 C CNN
F 3 "~" H 7000 4800 50  0001 C CNN
	1    7000 4800
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR016
U 1 1 5B9F88AD
P 7000 4950
F 0 "#PWR016" H 7000 4700 50  0001 C CNN
F 1 "GNDREF" H 7005 4777 50  0000 C CNN
F 2 "" H 7000 4950 50  0001 C CNN
F 3 "" H 7000 4950 50  0001 C CNN
	1    7000 4950
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV1
U 1 1 5B9F8A28
P 7000 4400
F 0 "RV1" H 6931 4446 50  0000 R CNN
F 1 "1K" H 6931 4355 50  0000 R CNN
F 2 "" H 7000 4400 50  0001 C CNN
F 3 "~" H 7000 4400 50  0001 C CNN
	1    7000 4400
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7000 4550 7000 4600
Connection ~ 7000 4600
Wire Wire Line
	7000 4600 7000 4700
Wire Wire Line
	7000 4900 7000 4950
Wire Wire Line
	4750 4400 5500 4400
$Comp
L Connector:TestPoint TP3
U 1 1 5BA26C10
P 5500 4300
F 0 "TP3" H 5558 4420 50  0000 L CNN
F 1 "FB_1V24" H 5558 4329 50  0000 L CNN
F 2 "" H 5700 4300 50  0001 C CNN
F 3 "~" H 5700 4300 50  0001 C CNN
	1    5500 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 4300 5500 4400
Connection ~ 5500 4400
$Comp
L Connector:TestPoint TP2
U 1 1 5BA29171
P 5100 4600
F 0 "TP2" H 4950 4750 50  0000 C CNN
F 1 "VC" H 4950 4650 50  0000 C CNN
F 2 "" H 5300 4600 50  0001 C CNN
F 3 "~" H 5300 4600 50  0001 C CNN
	1    5100 4600
	1    0    0    -1  
$EndComp
Wire Wire Line
	4750 4700 4800 4700
Wire Wire Line
	5100 4700 5100 4600
$Comp
L Device:R_Small R4
U 1 1 5BA2B99A
P 5650 4700
F 0 "R4" V 5750 4800 50  0000 C CNN
F 1 "39K" V 5750 4600 50  0000 C CNN
F 2 "" H 5650 4700 50  0001 C CNN
F 3 "~" H 5650 4700 50  0001 C CNN
	1    5650 4700
	0    -1   -1   0   
$EndComp
$Comp
L Device:C_Small C9
U 1 1 5BA2BC85
P 6050 4900
F 0 "C9" H 6142 4946 50  0000 L CNN
F 1 "1uF" H 6142 4855 50  0000 L CNN
F 2 "" H 6050 4900 50  0001 C CNN
F 3 "~" H 6050 4900 50  0001 C CNN
	1    6050 4900
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR013
U 1 1 5BA2BD78
P 6050 5050
F 0 "#PWR013" H 6050 4800 50  0001 C CNN
F 1 "GNDREF" H 6055 4877 50  0000 C CNN
F 2 "" H 6050 5050 50  0001 C CNN
F 3 "" H 6050 5050 50  0001 C CNN
	1    6050 5050
	1    0    0    -1  
$EndComp
Connection ~ 5100 4700
Wire Wire Line
	6050 4700 6050 4800
Wire Wire Line
	6050 5000 6050 5050
$Comp
L Connector:TestPoint TP6
U 1 1 5BA384FB
P 7000 3100
F 0 "TP6" H 7058 3220 50  0000 L CNN
F 1 "HV" H 7058 3129 50  0000 L CNN
F 2 "" H 7200 3100 50  0001 C CNN
F 3 "~" H 7200 3100 50  0001 C CNN
	1    7000 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 3100 7000 3200
Text Label 4900 4700 0    50   ~ 0
VC
Text Notes 5100 3300 0    50   ~ 0
*
Text Notes 5450 3600 0    50   ~ 0
*
$Comp
L Device:C_Small C1
U 1 1 5BA644F0
P 2250 4300
F 0 "C1" H 2342 4346 50  0000 L CNN
F 1 "0.22uF" H 2342 4255 50  0000 L CNN
F 2 "" H 2250 4300 50  0001 C CNN
F 3 "~" H 2250 4300 50  0001 C CNN
	1    2250 4300
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR01
U 1 1 5BA6460C
P 2250 4500
F 0 "#PWR01" H 2250 4250 50  0001 C CNN
F 1 "GNDREF" H 2255 4327 50  0000 C CNN
F 2 "" H 2250 4500 50  0001 C CNN
F 3 "" H 2250 4500 50  0001 C CNN
	1    2250 4500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2250 4500 2250 4400
Wire Wire Line
	2250 4200 2250 4100
Wire Wire Line
	2250 4100 2650 4100
Connection ~ 2650 4100
$Comp
L Device:R_Small R1
U 1 1 5BA6A964
P 2550 3400
F 0 "R1" H 2609 3446 50  0000 L CNN
F 1 "2.2K 1/2W" H 2609 3355 50  0000 L CNN
F 2 "" H 2550 3400 50  0001 C CNN
F 3 "~" H 2550 3400 50  0001 C CNN
	1    2550 3400
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 5BA70CDA
P 3650 3400
F 0 "C4" H 3742 3446 50  0000 L CNN
F 1 "0.22uF" H 3742 3355 50  0000 L CNN
F 2 "" H 3650 3400 50  0001 C CNN
F 3 "~" H 3650 3400 50  0001 C CNN
	1    3650 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 3200 2550 3200
Wire Wire Line
	2550 3200 2550 3300
Connection ~ 3100 3200
Wire Wire Line
	3100 3600 2550 3600
Wire Wire Line
	2550 3600 2550 3500
Connection ~ 3100 3600
Wire Wire Line
	3650 3300 3650 3200
Connection ~ 3650 3200
Wire Wire Line
	3650 3200 4100 3200
Wire Wire Line
	3650 3500 3650 3600
Connection ~ 3650 3600
Wire Wire Line
	3650 3600 3100 3600
$Comp
L Device:R_Small R14
U 1 1 5BA8E5BB
P 7500 4800
F 0 "R14" H 7559 4846 50  0000 L CNN
F 1 "330 MF" H 7559 4755 50  0000 L CNN
F 2 "" H 7500 4800 50  0001 C CNN
F 3 "~" H 7500 4800 50  0001 C CNN
	1    7500 4800
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR019
U 1 1 5BA8E757
P 7500 4950
F 0 "#PWR019" H 7500 4700 50  0001 C CNN
F 1 "GNDREF" H 7505 4777 50  0000 C CNN
F 2 "" H 7500 4950 50  0001 C CNN
F 3 "" H 7500 4950 50  0001 C CNN
	1    7500 4950
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 4950 7500 4900
Wire Wire Line
	7500 4600 7000 4600
Wire Wire Line
	7500 4600 7500 4700
$Comp
L Device:R_Small R5
U 1 1 5BA9E4BA
P 5650 4900
F 0 "R5" V 5750 5000 50  0000 C CNN
F 1 "39K" V 5750 4800 50  0000 C CNN
F 2 "" H 5650 4900 50  0001 C CNN
F 3 "~" H 5650 4900 50  0001 C CNN
	1    5650 4900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5750 4700 5850 4700
Wire Wire Line
	5850 4700 5850 4900
Wire Wire Line
	5850 4900 5750 4900
Wire Wire Line
	5450 4700 5450 4900
Wire Wire Line
	5450 4900 5550 4900
Wire Wire Line
	5450 4700 5550 4700
Wire Wire Line
	5850 4700 6050 4700
Connection ~ 5850 4700
Wire Wire Line
	5100 4700 5450 4700
Connection ~ 5450 4700
$Comp
L Device:Jumper JP1
U 1 1 5BAB40F4
P 4800 5100
F 0 "JP1" V 4850 5400 50  0000 C CNN
F 1 "DESHABILITA" V 4750 5500 50  0000 C CNN
F 2 "" H 4800 5100 50  0001 C CNN
F 3 "~" H 4800 5100 50  0001 C CNN
	1    4800 5100
	0    -1   -1   0   
$EndComp
$Comp
L power:GNDREF #PWR07
U 1 1 5BAB45FB
P 4800 5500
F 0 "#PWR07" H 4800 5250 50  0001 C CNN
F 1 "GNDREF" H 4805 5327 50  0000 C CNN
F 2 "" H 4800 5500 50  0001 C CNN
F 3 "" H 4800 5500 50  0001 C CNN
	1    4800 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4800 5500 4800 5400
Wire Wire Line
	4800 4800 4800 4700
Connection ~ 4800 4700
Text Notes 3050 5450 0    50   ~ 0
El jumper puesto cortocircuita VC\ndeshabilitando el driver, y la salida\nde alta tensión es cero.
Text Notes 6100 1300 0    50   ~ 0
VIN = 1.25(1+R21/R20)=4.5V
Wire Wire Line
	5500 4400 6850 4400
Text Notes 7250 4450 0    50   ~ 0
Girar en sentido HORARIO para\nAUMENTAR la tensión de salida.
$Comp
L Device:C_Small C8
U 1 1 5B9F1EA4
P 5850 5600
F 0 "C8" H 5942 5646 50  0000 L CNN
F 1 "0.1uF" H 5942 5555 50  0000 L CNN
F 2 "" H 5850 5600 50  0001 C CNN
F 3 "~" H 5850 5600 50  0001 C CNN
	1    5850 5600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 5500 5850 5450
Wire Wire Line
	5850 5450 6150 5450
Wire Wire Line
	6250 5450 6250 5700
Wire Wire Line
	6250 5850 6150 5850
Wire Wire Line
	6150 5850 6150 5450
Connection ~ 6150 5450
Wire Wire Line
	6150 5450 6250 5450
$Comp
L power:GNDREF #PWR011
U 1 1 5B9FA9E7
P 5850 5750
F 0 "#PWR011" H 5850 5500 50  0001 C CNN
F 1 "GNDREF" H 5850 5600 50  0000 C CNN
F 2 "" H 5850 5750 50  0001 C CNN
F 3 "" H 5850 5750 50  0001 C CNN
	1    5850 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 5750 5850 5700
$Comp
L Device:R_Small R6
U 1 1 5BA03B27
P 5650 5650
F 0 "R6" H 5500 5700 50  0000 L CNN
F 1 "4K7" H 5450 5600 50  0000 L CNN
F 2 "" H 5650 5650 50  0001 C CNN
F 3 "~" H 5650 5650 50  0001 C CNN
	1    5650 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 5550 5650 5450
Wire Wire Line
	5650 5450 5850 5450
Connection ~ 5850 5450
Wire Wire Line
	5650 5750 5650 5950
Wire Wire Line
	5650 5950 6250 5950
$Comp
L Device:R_Small R3
U 1 1 5BA0D5C0
P 5450 5950
F 0 "R3" V 5350 5950 50  0000 C CNN
F 1 "1K" V 5250 5950 50  0000 C CNN
F 2 "" H 5450 5950 50  0001 C CNN
F 3 "~" H 5450 5950 50  0001 C CNN
	1    5450 5950
	0    -1   -1   0   
$EndComp
$Comp
L Transistor_BJT:2N3904 Q1
U 1 1 5BA0D71B
P 5100 5950
F 0 "Q1" H 5291 5996 50  0000 L CNN
F 1 "2N3904" H 5291 5905 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline" H 5300 5875 50  0001 L CIN
F 3 "https://www.fairchildsemi.com/datasheets/2N/2N3904.pdf" H 5100 5950 50  0001 L CNN
	1    5100 5950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	5000 5750 5000 4700
Wire Wire Line
	4800 4700 5000 4700
Connection ~ 5000 4700
Wire Wire Line
	5000 4700 5100 4700
$Comp
L power:GNDREF #PWR09
U 1 1 5BA20825
P 5000 6200
F 0 "#PWR09" H 5000 5950 50  0001 C CNN
F 1 "GNDREF" H 5000 6050 50  0000 C CNN
F 2 "" H 5000 6200 50  0001 C CNN
F 3 "" H 5000 6200 50  0001 C CNN
	1    5000 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5000 6200 5000 6150
Wire Wire Line
	5300 5950 5350 5950
Wire Wire Line
	5550 5950 5650 5950
Connection ~ 5650 5950
$Comp
L power:GNDREF #PWR014
U 1 1 5BA2FB5B
P 6150 6200
F 0 "#PWR014" H 6150 5950 50  0001 C CNN
F 1 "GNDREF" H 6150 6050 50  0000 C CNN
F 2 "" H 6150 6200 50  0001 C CNN
F 3 "" H 6150 6200 50  0001 C CNN
	1    6150 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6150 6200 6150 6100
Wire Wire Line
	6150 6100 6250 6100
Wire Wire Line
	6850 5800 7000 5800
Wire Wire Line
	7000 5800 7000 5450
$Comp
L Device:C_Small C12
U 1 1 5BA3AE15
P 7150 5650
F 0 "C12" H 7242 5696 50  0000 L CNN
F 1 "0.1uF" H 7242 5605 50  0000 L CNN
F 2 "" H 7150 5650 50  0001 C CNN
F 3 "~" H 7150 5650 50  0001 C CNN
	1    7150 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 5450 7150 5450
Wire Wire Line
	7150 5450 7150 5550
$Comp
L power:GND #PWR018
U 1 1 5BA40685
P 7150 5800
F 0 "#PWR018" H 7150 5550 50  0001 C CNN
F 1 "GND" H 7250 5700 50  0000 C CNN
F 2 "" H 7150 5800 50  0001 C CNN
F 3 "" H 7150 5800 50  0001 C CNN
	1    7150 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	7150 5800 7150 5750
Wire Wire Line
	6850 6000 7350 6000
$Comp
L Device:R_Small R13
U 1 1 5BA4BAF1
P 7450 6000
F 0 "R13" V 7550 6000 50  0000 C CNN
F 1 "470" V 7350 6000 50  0000 C CNN
F 2 "" H 7450 6000 50  0001 C CNN
F 3 "~" H 7450 6000 50  0001 C CNN
	1    7450 6000
	0    -1   -1   0   
$EndComp
Text Label 7050 5450 0    50   ~ 0
VCC_MCU
Text Label 5900 5450 0    50   ~ 0
VIN
$Comp
L Device:C_Small C10
U 1 1 5BA5993C
P 6650 1650
F 0 "C10" H 6742 1696 50  0000 L CNN
F 1 "0.1uF" H 6742 1605 50  0000 L CNN
F 2 "" H 6650 1650 50  0001 C CNN
F 3 "~" H 6650 1650 50  0001 C CNN
	1    6650 1650
	1    0    0    -1  
$EndComp
Connection ~ 4950 1450
Connection ~ 7050 1450
Wire Wire Line
	6650 1550 6650 1450
Connection ~ 6650 1450
Wire Wire Line
	6650 1450 7050 1450
Wire Wire Line
	5550 1750 5550 1800
Text Label 7250 1450 0    50   ~ 0
VIN
Wire Wire Line
	4950 1450 5250 1450
$Comp
L Regulator_Linear:LM317_TO39 U2
U 1 1 5BECF5F5
P 5550 1450
F 0 "U2" H 5550 1692 50  0000 C CNN
F 1 "LM317_TO39" H 5550 1601 50  0000 C CNN
F 2 "Package_TO_SOT_THT:TO-39-3" H 5550 1675 50  0001 C CIN
F 3 "http://www.ti.com/lit/ds/symlink/lm317.pdf" H 5550 1450 50  0001 C CNN
	1    5550 1450
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R7
U 1 1 5BEDC4C5
P 6050 1650
F 0 "R7" H 6109 1696 50  0000 L CNN
F 1 "390 MF" H 6109 1605 50  0000 L CNN
F 2 "" H 6050 1650 50  0001 C CNN
F 3 "~" H 6050 1650 50  0001 C CNN
	1    6050 1650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R8
U 1 1 5BEE2CE8
P 6050 1950
F 0 "R8" H 6109 1996 50  0000 L CNN
F 1 "1K MF" H 6109 1905 50  0000 L CNN
F 2 "" H 6050 1950 50  0001 C CNN
F 3 "~" H 6050 1950 50  0001 C CNN
	1    6050 1950
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR012
U 1 1 5BEE2D86
P 6050 2100
F 0 "#PWR012" H 6050 1850 50  0001 C CNN
F 1 "GNDREF" H 6055 1927 50  0000 C CNN
F 2 "" H 6050 2100 50  0001 C CNN
F 3 "" H 6050 2100 50  0001 C CNN
	1    6050 2100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 1450 6050 1450
Wire Wire Line
	6050 1550 6050 1450
Connection ~ 6050 1450
Wire Wire Line
	6050 1450 6650 1450
Wire Wire Line
	6050 1750 6050 1800
Wire Wire Line
	6050 2050 6050 2100
Wire Wire Line
	6050 1800 5550 1800
Connection ~ 6050 1800
Wire Wire Line
	6050 1800 6050 1850
Wire Wire Line
	7050 1750 7050 1850
$Comp
L power:GNDREF #PWR015
U 1 1 5BF0427E
P 6650 1900
F 0 "#PWR015" H 6650 1650 50  0001 C CNN
F 1 "GNDREF" H 6655 1727 50  0000 C CNN
F 2 "" H 6650 1900 50  0001 C CNN
F 3 "" H 6650 1900 50  0001 C CNN
	1    6650 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 1750 6650 1900
Wire Wire Line
	6350 3200 7000 3200
Wire Wire Line
	7000 4150 7000 4250
Wire Wire Line
	7000 3850 7000 3900
Wire Wire Line
	7000 3500 7000 3600
$Comp
L Connector:TestPoint TP4
U 1 1 5BF0C4B2
P 6650 3550
F 0 "TP4" H 6708 3670 50  0000 L CNN
F 1 "HV*2/3" H 6708 3579 50  0000 L CNN
F 2 "" H 6850 3550 50  0001 C CNN
F 3 "~" H 6850 3550 50  0001 C CNN
	1    6650 3550
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP5
U 1 1 5BF0C5CA
P 6650 3850
F 0 "TP5" H 6708 3970 50  0000 L CNN
F 1 "HV/3" H 6708 3879 50  0000 L CNN
F 2 "" H 6850 3850 50  0001 C CNN
F 3 "~" H 6850 3850 50  0001 C CNN
	1    6650 3850
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 3550 6650 3600
Wire Wire Line
	6650 3600 7000 3600
Connection ~ 7000 3600
Wire Wire Line
	7000 3600 7000 3650
Wire Wire Line
	6650 3850 6650 3900
Wire Wire Line
	6650 3900 7000 3900
Connection ~ 7000 3900
Wire Wire Line
	7000 3900 7000 3950
Wire Wire Line
	7000 3200 7550 3200
$Comp
L Connector:Screw_Terminal_01x02 J2
U 1 1 5BF20BDF
P 8500 3200
F 0 "J2" H 8500 3450 50  0000 C CNN
F 1 "TUBO" H 8500 3350 50  0000 C CNN
F 2 "" H 8500 3200 50  0001 C CNN
F 3 "~" H 8500 3200 50  0001 C CNN
	1    8500 3200
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR022
U 1 1 5BF211F3
P 8250 3900
F 0 "#PWR022" H 8250 3650 50  0001 C CNN
F 1 "GNDREF" H 8255 3727 50  0000 C CNN
F 2 "" H 8250 3900 50  0001 C CNN
F 3 "" H 8250 3900 50  0001 C CNN
	1    8250 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 3300 8250 3300
$Comp
L Device:R_Small R16
U 1 1 5BF37271
P 7950 3200
F 0 "R16" V 8050 3300 50  0000 C CNN
F 1 "10MEG" V 8050 3100 50  0000 C CNN
F 2 "" H 7950 3200 50  0001 C CNN
F 3 "~" H 7950 3200 50  0001 C CNN
	1    7950 3200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_Small R17
U 1 1 5BF467A5
P 8250 3650
F 0 "R17" H 8309 3696 50  0000 L CNN
F 1 "100K" H 8309 3605 50  0000 L CNN
F 2 "" H 8250 3650 50  0001 C CNN
F 3 "~" H 8250 3650 50  0001 C CNN
	1    8250 3650
	1    0    0    -1  
$EndComp
$Comp
L Device:D_Zener_Small D6
U 1 1 5BF46B1A
P 8700 3650
F 0 "D6" V 8654 3718 50  0000 L CNN
F 1 "2V7" V 8745 3718 50  0000 L CNN
F 2 "" V 8700 3650 50  0001 C CNN
F 3 "~" V 8700 3650 50  0001 C CNN
	1    8700 3650
	0    1    1    0   
$EndComp
Wire Wire Line
	8250 3300 8250 3500
Wire Wire Line
	8250 3750 8250 3850
Wire Wire Line
	8700 3550 8700 3500
Wire Wire Line
	8700 3500 8250 3500
Connection ~ 8250 3500
Wire Wire Line
	8250 3500 8250 3550
Wire Wire Line
	8700 3750 8700 3850
Wire Wire Line
	8700 3850 8250 3850
Connection ~ 8250 3850
Wire Wire Line
	8250 3850 8250 3900
$Comp
L Transistor_BJT:2N3904 Q2
U 1 1 5BF5BAAC
P 9050 3500
F 0 "Q2" H 9241 3546 50  0000 L CNN
F 1 "2N3904" H 9241 3455 50  0000 L CNN
F 2 "Package_TO_SOT_THT:TO-92_Inline" H 9250 3425 50  0001 L CIN
F 3 "https://www.fairchildsemi.com/datasheets/2N/2N3904.pdf" H 9050 3500 50  0001 L CNN
	1    9050 3500
	1    0    0    -1  
$EndComp
Connection ~ 7550 3200
Wire Wire Line
	7550 3200 7850 3200
Wire Wire Line
	8050 3200 8300 3200
$Comp
L Device:R_Small R18
U 1 1 5BF87851
P 9150 3050
F 0 "R18" H 9209 3096 50  0000 L CNN
F 1 "47K" H 9209 3005 50  0000 L CNN
F 2 "" H 9150 3050 50  0001 C CNN
F 3 "~" H 9150 3050 50  0001 C CNN
	1    9150 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 3500 8700 3500
Connection ~ 8700 3500
Wire Wire Line
	9150 3700 9150 3850
Wire Wire Line
	9150 3850 8700 3850
Connection ~ 8700 3850
Wire Wire Line
	9150 3150 9150 3250
Text Label 9150 2750 0    50   ~ 0
VIN
Wire Wire Line
	9150 2950 9150 2850
$Comp
L Device:C_Small C14
U 1 1 5BF9E919
P 8900 3000
F 0 "C14" H 8700 3050 50  0000 L CNN
F 1 "0.1uF" H 8750 2900 50  0000 C CNN
F 2 "" H 8900 3000 50  0001 C CNN
F 3 "~" H 8900 3000 50  0001 C CNN
	1    8900 3000
	1    0    0    -1  
$EndComp
$Comp
L power:GNDREF #PWR023
U 1 1 5BF9EDDC
P 8900 3150
F 0 "#PWR023" H 8900 2900 50  0001 C CNN
F 1 "GNDREF" H 8905 2977 50  0000 C CNN
F 2 "" H 8900 3150 50  0001 C CNN
F 3 "" H 8900 3150 50  0001 C CNN
	1    8900 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 2850 9150 2850
Connection ~ 9150 2850
Wire Wire Line
	9150 2850 9150 2750
Wire Wire Line
	8900 2900 8900 2850
Wire Wire Line
	8900 3150 8900 3100
$Comp
L Device:R_Small R19
U 1 1 5BFB6D75
P 9400 2850
F 0 "R19" V 9200 2850 50  0000 C CNN
F 1 "470" V 9300 2850 50  0000 C CNN
F 2 "" H 9400 2850 50  0001 C CNN
F 3 "~" H 9400 2850 50  0001 C CNN
	1    9400 2850
	0    1    1    0   
$EndComp
Wire Wire Line
	9300 2850 9150 2850
Wire Wire Line
	9500 2850 9600 2850
Wire Wire Line
	9500 3050 9500 3250
Wire Wire Line
	9500 3250 9150 3250
Wire Wire Line
	9500 3050 9600 3050
Connection ~ 9150 3250
Wire Wire Line
	9150 3250 9150 3300
Text Label 10550 2650 0    50   ~ 0
VCC_MCU
Wire Wire Line
	10200 2900 10250 2900
$Comp
L Device:C_Small C15
U 1 1 5BFE4960
P 10950 2900
F 0 "C15" H 10750 2950 50  0000 L CNN
F 1 "0.1uF" H 10700 2800 50  0000 L CNN
F 2 "" H 10950 2900 50  0001 C CNN
F 3 "~" H 10950 2900 50  0001 C CNN
	1    10950 2900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR027
U 1 1 5BFE4FE8
P 10950 3050
F 0 "#PWR027" H 10950 2800 50  0001 C CNN
F 1 "GND" H 11050 3050 50  0000 C CNN
F 2 "" H 10950 3050 50  0001 C CNN
F 3 "" H 10950 3050 50  0001 C CNN
	1    10950 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	10950 2800 10950 2650
Wire Wire Line
	10950 3000 10950 3050
Wire Wire Line
	10250 2650 10500 2650
$Comp
L power:GND #PWR026
U 1 1 5C0003D7
P 10250 3200
F 0 "#PWR026" H 10250 2950 50  0001 C CNN
F 1 "GND" H 10350 3100 50  0000 C CNN
F 2 "" H 10250 3200 50  0001 C CNN
F 3 "" H 10250 3200 50  0001 C CNN
	1    10250 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	10200 3150 10250 3150
Wire Wire Line
	10250 3150 10250 3200
$Comp
L Device:R_Small R20
U 1 1 5C0074B2
P 10500 2850
F 0 "R20" H 10350 2900 50  0000 L CNN
F 1 "4K7" H 10300 2800 50  0000 L CNN
F 2 "" H 10500 2850 50  0001 C CNN
F 3 "~" H 10500 2850 50  0001 C CNN
	1    10500 2850
	1    0    0    -1  
$EndComp
Connection ~ 10250 2750
Wire Wire Line
	10250 2650 10250 2750
Wire Wire Line
	10200 2750 10250 2750
Wire Wire Line
	10250 2750 10250 2900
Wire Wire Line
	10200 3000 10500 3000
Wire Wire Line
	10500 3000 10500 2950
Wire Wire Line
	10500 2750 10500 2650
Connection ~ 10500 2650
Wire Wire Line
	10500 2650 10950 2650
Wire Wire Line
	10500 3000 10500 3550
Connection ~ 10500 3000
Wire Wire Line
	7550 6000 8250 6000
$Comp
L Contador_Geiger-rescue:6N137-arias2018-contador-rescue U?
U 1 1 5BEF9F0D
P 6550 5900
F 0 "U?" H 6550 5483 50  0000 C CNN
F 1 "6N137-arias2018" H 6550 5574 50  0000 C CNN
F 2 "Housings_SOIC:SOIJ-8_5.3x5.3mm_Pitch1.27mm" H 5720 5585 50  0001 L CIN
F 3 "" H 6480 5900 50  0000 L CNN
	1    6550 5900
	-1   0    0    -1  
$EndComp
$Comp
L Contador_Geiger-rescue:6N137-arias2018-contador-rescue U?
U 1 1 5BEFBE83
P 9900 2950
F 0 "U?" H 9900 3375 50  0000 C CNN
F 1 "6N137-arias2018" H 9900 3284 50  0000 C CNN
F 2 "Housings_SOIC:SOIJ-8_5.3x5.3mm_Pitch1.27mm" H 9070 2635 50  0001 L CIN
F 3 "" H 9830 2950 50  0000 L CNN
	1    9900 2950
	1    0    0    -1  
$EndComp
$Comp
L Contador_Geiger-rescue:arias2018_LT1072_TO-Fuente-cache U?
U 1 1 5BEFC110
P 4250 4400
F 0 "U?" H 4250 4965 50  0000 C CNN
F 1 "arias2018_LT1072_TO" H 4250 4874 50  0000 C CNN
F 2 "" H 4250 4400 50  0001 C CNN
F 3 "" H 4250 4400 50  0001 C CNN
	1    4250 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	10500 3550 10600 3550
Text HLabel 10600 3550 2    50   Output ~ 0
#DESCARGA
Text HLabel 8250 6000 2    50   Input ~ 0
#HABILITA_ALTA_TENSIÓN
Text HLabel 10200 4750 0    50   Input ~ 0
VCC_MCU
Wire Wire Line
	10200 4750 10600 4750
Text Label 10600 4750 0    50   ~ 0
VCC_MCU
$Comp
L power:GND #PWR?
U 1 1 5C006053
P 10600 4900
F 0 "#PWR?" H 10600 4650 50  0001 C CNN
F 1 "GND" H 10700 4900 50  0000 C CNN
F 2 "" H 10600 4900 50  0001 C CNN
F 3 "" H 10600 4900 50  0001 C CNN
	1    10600 4900
	1    0    0    -1  
$EndComp
Text HLabel 10200 4900 0    50   Input ~ 0
GND_MCU
Wire Wire Line
	10200 4900 10600 4900
$EndSCHEMATC
