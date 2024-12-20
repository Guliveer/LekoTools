#!/bin/bash
# Menu > ext

		connect 191

		if [ -n "$2" ]; then
			choice2=$2
		fi

		clear && $title
		echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} ]"
		echo
		echo -e "= Wybierz czynność ="
		option 1 "Pokaż dane urządzenia"
		option 2 "Zmień nazwę urządzenia"
		option 3 "Restart usług NTPD i UCM"
		if ssh root@$ip 'ls /etc/config/ccs' | grep -q 'attenuation.atn'; then
			option 4 "Prześlij plik \"attenuation.atn\" (${p_color}+${d_color})"
		else
			option 4 "Prześlij plik \"attenuation.atn\" (${e_color}-${d_color})"
		fi
		option 5 "Ustaw adres licznika LEM"
		option R "Uruchom ponownie urządzenie"
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
				# Menu > ext > 1
				clear && $title
				echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} > ${c_color}Pokaż dane urządzenia${d_color} ]"
				echo

				qp_update=$(ssh root@$ip '/bin/hostname')
				qp_update=$(echo $qp_update | xargs)
				echo -e "[ ${p_color}Nazwa urządzenia${d_color} ]\n"$qp_update
				echo

				pack=${dev_ver}"echo ;"${dev_time}"echo ;"${svc_status} # Paczka komend
				ssh -t -o LogLevel=QUIET root@$ip $pack # Wykonaj paczkę poleceń na zdalnym urządzeniu

				echo
				pause
				run_script $ext
				;;
				# EO Menu > ext > 1
			2)
				# Menu > ext > 2
				change_name $ip $ext
				;;
				# EO Menu > ext > 2
			3)
				# Menu > ext > 3
				clear && $title
				echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} > ${c_color}Restart NTPD i UCM${d_color} ]"
				echo
				pack=${svc_ntpds_restart}"echo ;"${svc_ucm_restart}
				ssh -t -o LogLevel=QUIET root@$ip $pack
				echo
				sleep 2
				run_script $ext
				;;
				# EO Menu > ext > 3
			4)
				# Menu > ext > 4
				clear && $title
				echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} > ${c_color}Prześlij \"attenuation.atn\"${d_color} ]"
				echo

				send_attenuation

				run_script $ext
				;;
				# EO Menu > ext > 4
			5)
				# Menu > ext > 5
				clear && $title
				echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} > ${c_color}<Ionity> Ustaw adres licznika LEM${d_color} ]"
				echo

				SOURCE_IP=192.168.1.2
				DEST_IP=192.168.14.240

				curl -d '{"ipAddress":"'${DEST_IP}'"}' -H 'Content-Type:application/json' -X PUT http://${SOURCE_IP}/v1/settings -v
				echo; echo
				pause
				run_script $ext
				;;
				# EO Menu > ext > 5
			r)
				# Menu > ext > r
				clear && $title
				echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} > ${c_color}Uruchom ponownie urządzenie${d_color} ]"
				echo
				dev_restart 25
				run_script $ext
				;;
				# EO Menu > ext > r
			ssh)
				# Menu > display > ssh
				clear && $title
				echo -e "[ ${c_color}Satelitka / ext (${qp})${d_color} > ${c_color}SSH${d_color} ]"
				echo
				start_ssh
				run_script $ext
				# EO Menu > ext > ssh
				;;
			0)
				# Menu > ext > 0
				run_script
				;;
				# EO Menu > ext > 0
			00)
				# Menu > ext > 00
				rm $path_pw_stored
				ctrl_c
				;;
				# EO Menu > ext > 00
			*)
				# Menu > ext > *
				bad_choice
				run_script $ext
				;;
				# EO Menu > ext > *
		esac