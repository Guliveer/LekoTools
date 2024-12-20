#!/bin/bash
# Menu > main

		connect 190

		if [ -n "$2" ]; then
			choice2=$2
		fi

		clear && $title
		echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} ]"
		echo
		
		if [ $(echo $qp | grep -c "QP-") -eq 1 ]; then
			echo -e "EOS: $(hyperlink https://test1.ocpps.ekoenergetyka.com.pl/management/chargepoint?chargePointId=${qp} '[test1]') $(hyperlink https://sm-eos.ocpps.ekoenergetyka.com.pl/management/chargepoint?chargePointId=${qp} '[sm-eos]') (Ctrl + Klik)"
			echo
		fi

		echo -e "= Wybierz czynność ="
		option 1 "Pokaż dane urządzenia"
		option 2 "Zmień nazwę urządzenia"
		option 3 "Restart usług NTPD i UCM"
		if ssh root@$ip 'ls /etc/config/ccs' | grep -q 'attenuation.atn'; then
			option 4 "Prześlij plik \"attenuation.atn\" (${p_color}+${d_color})"
		else
			option 4 "Prześlij plik \"attenuation.atn\" (${e_color}-${d_color})"
		fi
		option 5 "Zapnij moduły"
		option 6 "Statystyki CAN"
		option 7 "Ustaw prędkość CAN"
		option 8 "<Ionity> Konfiguracja TILL"
		option 9 "<Ionity> Spróbuj naprawić połączenie z EOS"
		option 10 "<Daimler> Ustaw licznik Lovato"
		option R "Uruchom ponownie urządzenie"
		option RR "Wykonaj Hard Reset"
		option SSH "Połącz się z urządzeniem przez SSH"
		echo
		option 0 "Powrót"
		option 00 "Wyloguj i wyjdź"

		if [ -z "$choice2" ]; then
			echo -e "\n------\n"
			echo -ne "Wybór: ${p_color}"; read choice2; echo -ne "${d_color}"
			choice2=$(echo $choice2 | tr '[:upper:]' '[:lower:]')
		fi

		case $choice2 in
			1)
				# Menu > main > 1
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Pokaż dane urządzenia${d_color} ]"
				echo

				qp_update=$(ssh root@$ip '/bin/hostname')
				qp_update=$(echo $qp_update | xargs)
				echo -e "[ ${p_color}Nazwa urządzenia${d_color} ]\n"$qp_update
				echo

				pack=${dev_ver}"echo ;"${dev_time}"echo ;"${svc_status} # Paczka komend
				ssh -t -o LogLevel=QUIET root@$ip $pack # Wykonaj polecenia na zdalnym urządzeniu

				echo
				pause
				run_script $main
				;;
				# EO Menu > main > 1
			2)
				# Menu > main > 2
				change_name $ip $main
				;;
				# EO Menu > main > 2
			3)
				# Menu > main > 3
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Restart NTPD i UCM${d_color} ]"
				echo
				pack=${svc_ntpds_restart}"echo ;"${svc_ucm_restart}
				ssh -t -o LogLevel=QUIET root@$ip $pack
				run_script $main
				;;
				# EO Menu > main > 3
			4)
				# Menu > main > 4
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Prześlij \"attenuation.atn\"${d_color} ]"
				echo

				send_attenuation

				run_script $main
				;;
				# EO Menu > main > 4
			5)
				# Menu > main > 5
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Zapnij moduły${d_color} ]"
				echo
				warn "Zapinanie modułów..."
				pack="
					echo -e '[ ${p_color}+${d_color} ] Moduły mocy gotowe';
					echo ;
					$close_info;
					monit unmonitor all && /usr/sbin/service CLC stop >/dev/null;
					while [ 1 ];do cansend vcan0 00000820#CF0001FFFF;done
				"
				ssh -t -o LogLevel=QUIET root@$ip $pack
				ssh root@$ip 'monit start all; /usr/sbin/service CLC start >/dev/null'
				run_script $main
				;;
				# EO Menu > main > 5
			6)
				# Menu > main > 6
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Statystyki CAN${d_color} ]"
				echo
				pack="sh listen_can.sh any"
				ssh -t -o LogLevel=QUIET root@$ip $pack
				run_script $main
				;;
				# EO Menu > main > 6
			7)
				# Menu > main > 7
				# Sprawdź dostępne interfejsy CAN w /etc/can/interfaces
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Zmiana prędkości CAN${d_color} ]"
				echo
				interfaces=$(ssh root@$ip "grep -E '^iface [a-z0-9]+' /etc/can/interfaces | awk '{print \$2}'")

				# Sprawdź liczbę dostępnych interfejsów CAN
				num_interfaces=$(echo -e "$interfaces" | grep -v "vcan" | wc -l)

				# Jeżeli jest tylko jeden interfejs CAN, wybierz go automatycznie
				# Ignoruj interfejsy vcan
				if [ "$num_interfaces" -eq 1 ]; then
					warn "Wybrano jedyny interfejs CAN: $chosen_interface"
				else
					# Wyświetl listę dostępnych interfejsów CAN
					interfaces=$(echo -e "$interfaces" | grep -v "vcan")
					echo -e "Lista dostępnych interfejsów CAN:"
					# Ponumeruj interfejsy CAN
					i=1
					printf "%s\n" "$interfaces" | while IFS= read -r line; do
						echo -e "[${p_color}$i${d_color}] $line"
						i=$((i+1))
					done
					echo
					echo -e "Wybierz interfejs CAN: ${p_color}"
					read -r interface_number
					echo -ne "${d_color}"
					# Sprawdź poprawność wyboru
					chosen_interface=$(echo -e "$interfaces" | sed -n "${interface_number}p")
					if [ -z "$chosen_interface" ]; then
						bad_choice
						run_script $main 7
					fi
				fi

				#  Odczytaj aktualny bitrate
				current_bitrate=$(ssh root@$ip "grep -E '^bitrate [0-9]+' /etc/can/interfaces | grep "$chosen_interface" | awk '{print \$2}'")
				clear && $title
				# Pokaż listę wyboru nowego bitrate
				echo -e "${d_color}Lista dostępnych bitrate dla $chosen_interface:"
				echo -e "[ ${p_color}1${d_color} ] 50kb/s"
				echo -e "[ ${p_color}2${d_color} ] 100kb/s"
				echo -e "[ ${p_color}3${d_color} ] 125kb/s"
				echo -e "[ ${p_color}4${d_color} ] 250kb/s"
				echo -e "[ ${p_color}5${d_color} ] 500kb/s"
				echo
				echo -ne "Wybierz żądany bitrate z listy: ${p_color}"; read -r bitrate_number; echo -ne "${d_color}"

				# Sprawdź poprawność wyboru i przypisz nowy bitrate
				case "$bitrate_number" in
					1) new_bitrate="50000" ;;
					2) new_bitrate="100000" ;;
					3) new_bitrate="125000" ;;
					4) new_bitrate="250000" ;;
					5) new_bitrate="500000" ;;
					*)
						bad_choice
						run_script $main 7
						;;
				esac

				# Zmień bitrate w pliku /etc/can/interfaces
				ssh root@$ip "sed -i '/^iface $chosen_interface/{n; s/^bitrate [0-9]\+$/bitrate $new_bitrate/}' /etc/can/interfaces"

				# Zrestartuj usługę canbus
				echo -e "${d_color}[ ${w_color}!${d_color} ] Restartowanie usługi canbus..."
				ssh root@$ip "/usr/sbin/service canbus restart"
				# Sprawdź czy bitrate został zmieniony
				new_bitrate=$(ssh root@$ip "grep -E '^bitrate [0-9]+' /etc/can/interfaces | grep "$chosen_interface" | awk '{print \$2}'")
				echo 'Nowa prędkość dla interfejsu '$chosen_interface': '$new_bitrate' b/s'
				sleep 2
				run_script $main
				;;
				# EO Menu > main > 7
			8)
				# Menu > main > 8
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}<Ionity> Konfiguracja TILL${d_color} ]"

				ssh -t -o LogLevel=QUIET root@$ip "sh /media/data/till-rfid.sh"

				echo
				pause
				run_script $main
				;;
				# EO Menu > main > 8
			9)
				# Menu > main > 9
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Naprawa połączenia z EOS${d_color} ]"
				echo

				pack="
				echo -e '[ ${w_color}!${d_color} ] Usuwanie pliku /etc/config/econf/settings.db...'; rm /etc/config/econf/settings.db;
				echo -e '[ ${w_color}!${d_color} ] Zmienianie adresu serwera ntp...'; echo 'server 192.168.20.150' > /etc/ntp.conf;
				echo -e '[ ${w_color}!${d_color} ] Ponowne uruchamianie usługi ECONF...'; /usr/sbin/service ECONF restart;
				echo -e '[ ${w_color}!${d_color} ] Ponowne uruchamianie usługi CM...'; /usr/sbin/service CM restart;
				echo -e '[ ${w_color}!${d_color} ] Ponowne uruchamianie usługi CLC...'; /usr/sbin/service CLC restart;
				"

				ssh -t -o LogLevel=QUIET root@$ip $pack

				sleep 1
				run_script $main
				;;
				# EO Menu > main > 9
			10)
				# Menu > main > 10
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}<Daimler> Ustaw licznik Lovato${d_color} ]"
				echo

				scp lovato/config.cfg root@$ip:/etc/config/modbus2can/config.cfg

				scp lovato/plc root@$ip:/etc/config/ucm/parameters/plc

				ssh -t -o LogLevel=QUIET root@$ip '/usr/sbin/service UCM restart && /usr/sbin/service Modbus2CAN restart'
				run_script $main
				;;
				# EO Menu > main > 10
			r)
				# Menu > main > r
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Uruchom ponownie urządzenie${d_color} ]"
				echo
				dev_restart
				run_script $main
				;;
				# EO Menu > main > r
			rr)
				# Menu > main > rr
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}Hard Reset${d_color} ]"
				echo
				ssh -o LogLevel=QUIET root@$ip 'bash /etc/config/ucm/scripts/hardReset.sh'
				run_script
				;;
				# EO Menu > main > rr
			ssh)
				# Menu > main > ssh
				clear && $title
				echo -e "[ ${c_color}Ładowarka / main (${qp})${d_color} > ${c_color}SSH${d_color} ]"
				echo
				start_ssh
				run_script $main
				# EO Menu > main > ssh
				;;
			0)
				# Menu > main > 0
				run_script
				;;
				# EO Menu > main > 0
			00)
				# Menu > main > 00
				rm $path_pw_stored
				ctrl_c
				;;
				# EO Menu > main > 00
			*)
				# Menu > main > *
				bad_choice
				run_script $main
				;;
				# EO Menu > main > *
		esac