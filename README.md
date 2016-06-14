# WS2811_LED_Controler

## Synopsis

STM_LED_tech is a simple solution to control LED strips via Bluetooth. Thanks to LedTech_App you can pilot LED system on all popular platforms (Windows, Android, IOS).
This code is prepared for STM32F411E-Disco (100 MHz clock), To use it on another board you schould reconfigure system_stm32f4xx.c file.

##Contents

./LEDTech_App - Application code to control LED Strip (Delphi XE8)
./WS2811_LED_Controler - Application code for STM32 (CooCox CoIDE).


##Tools
	1.CooCox CoIDE, Version 1.7.8
	2.Delphi XE 8


##Obligatory equipment:
- Microcontroler STM32F4xxx
- Bluetooth adapter (HC-06)
- WS2811 LED Strip


##Connection
	Bluetooth Rx - PC06
	Bluetooth Tx - PC07
	Bluetooth Power - VDD (3,3 V)
	LED Strip Signal - PC09
	
	
##Using
	1.Compile and flash STM32.
	2.Pair computer with STM via Bluetooth.
	3. Compile app controler in Delphi XE 8
	4. Cotrol LED via app.

## Malpfunctions

Everything works fine.


## License
Created by Jakub Drapiewski.
This project is based on https://github.com/C3MA/stm-ledstrip.