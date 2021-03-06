#!/bin/bash

# Сценарий для выполнения ручной процедуры регулировки стола
# ----------------------------------------------------------

# Параметры

usb=/dev/ttyUSB0		# Путь для обращения к плате (обычно /dev/ttyUSB0).
uart_speed=115200		# Скорость порта UART (для LERDGE 115200).
timeout=300				# Время отключения драйверов при бездействии. Задать достаточным, чтобы во время процедуры калировки не происходило отключение драйверов.

Z_top=0					# Позиция Z для регулировки стола.

# ----------------------------------------------------------

if ! [ -c "$usb" ]
	then
		echo "Устройство $usb не подключено. Проверьте параметры."
		echo
		echo "Подключены следующие устройства ttyUSBx"
		ls /dev/ttyUSB*
		echo ; echo ------------------ ; echo; read -p "Нажмите ENTER чтобы закрыть окно"
		exit
fi

stty $uart_speed -F $usb raw -echo			# Задаем скорость порту
sleep 1

clear

echo "Установлено время отключения драйверов при бездействии: $timeout секунд"
echo "M84 S$timeout" > $usb
echo
sleep 3

echo "Отправлена команда G28 - обнуление осей"
echo "G28" > $usb								# Отправляем команду обнуления осей
grep -m 1 'ok' < $usb >&2						# Дожидаемся завершения обнуления

clear
echo "Обнуление осей завершено"
echo
echo -n "Выполнить процедуру ручной калибровки стола? (y) "
read calibrate

if [ "$calibrate" = "y" ] || [ "$calibrate" = "Y" ]
	then
		while :
			do
				clear
				echo "Введите команду и нажмите Enter для выполнения одного из следующих действий:"
				
				echo
				echo "   Z3.8 - для изменения текущей координаты оси Z без перемещения (G92 Z3.8)."
				
				echo
				echo "   G28 - для обнуления осей."
				
				echo
				echo "   1,2,3,4 или 5 для перемещение в позицию согласно схеме:"
				echo "-----------";echo "|1       2|";echo "|         |";echo "|    5    |";echo "|         |";echo "|3       4|";echo "-----------"
				
				echo
				echo "При вводе любого другого значения произойдет перемещение в безопасную зону и отключение драйверов (M18)."
				
				echo
				echo "Текущие координаты:"
				echo "M114" > /dev/ttyUSB0
				head -n 1 $usb
				
				echo
				echo -n "Выполнить команду: "
				read position
					
				if [ "$position" = 1 ]
					then
						echo "G0 F800 Z10" > $usb
						echo "G0 F1000 X20 Y20" > $usb
						echo "G0 F500 Z$Z_top" > $usb
						
				elif [ "$position" = 2 ]
					then
						echo "G0 F500 Z10" > $usb
						echo "G0 F1000 X200 Y20" > $usb
						echo "G0 F500 Z$Z_top" > $usb
				
				elif [ "$position" = 3 ]
					then
						echo "G0 F500 Z10" > $usb
						echo "G0 F1000 X200 Y175" > $usb
						echo "G0 F500 Z$Z_top" > $usb
						
				elif [ "$position" = 4 ]
					then
						echo "G0 F500 Z10" > $usb
						echo "G0 F1000 X20 Y175" > $usb
						echo "G0 F500 Z$Z_top" > $usb
						
				elif [ "$position" = 5 ]
					then
						echo "G0 F800 Z10" > $usb
						echo "G0 F1000 X110 Y95" > $usb
						echo "G0 F500 Z$Z_top" > $usb
						echo
			
				elif [[ "$position" = Z* ]]
					then echo "G92 $position" > $usb
		
				elif [ "$position" = "G28" ] || [ "$position" = "g28" ]
					then echo "G28" > $usb
					
				else
					echo "G0 F800 Z100 R" > $usb
					echo "G0 F1000 X20 Y20" > $usb
					echo "M18" > $usb
					echo 1
					echo 2
				fi
			
		done
fi





