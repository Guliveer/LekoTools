#!/bin/bash
# Menu > router

		connect 254

		if [ -n "$2" ]; then
			choice2=$2
		fi

		clear && $title
		echo -e "[ ${c_color}Router${d_color} ]"
		echo
		echo -e "= Wybierz konfigurację RUT ="
		option 1 "Ekoenergetyka"
		option 2 "PowerDot"
		option R "Uruchom ponownie urządzenie"
		option SSH "Połącz się z urządzeniem przez SSH"
		echo
		option 0 "Powrót"
		option 00 "Wyloguj i wyjdź"
		echo
		help "Aby zastosować zmiany, należy uruchomić ponownie urządzenie"
		if [ -z "$choice2" ]; then
			echo -e "\n------\n"
			echo -ne "Wybór: ${p_color}"; read choice2; echo -ne "${d_color}"
			choice2=$(echo $choice2 | tr '[:upper:]' '[:lower:]')
		fi

		case $choice2 in
			1)
				# Menu > router > 1
				clear && $title
				echo -e "[ ${c_color}Router${d_color} > ${c_color}Ekoenergetyka${d_color} ]"
				echo

				# sprawdź czy wymagane pliki istnieją
				if [ ! -d "router/ekoenergetyka" ]; then
					error "Brak wymaganych plików:"
					echo -e "${c_color}$(readlink -f ekoenergetyka)${d_color}"
					sleep 2
					run_script $router
				fi

				echo -e "[ ${w_color}!{$d_color} ] Kopiowanie plików konfiguracyjnych do ${c_color}${ip}:/etc${d_color}..."
				echo

				scp -r router/ekoenergetyka/etc/* root@$ip:/etc/

				echo
				success "Zakończono przesyłanie plików"
				sleep 2
				run_script $router
				;;
				# EO Menu > router > 1
			2)
				# Menu > router > 2
				clear && $title
				echo -e "[ ${c_color}Router${d_color} > ${c_color}PowerDot${d_color} ]"
				echo

				# sprawdź czy wymagane pliki istnieją
				if [ ! -d "router/powerdot" ]; then
					error "Brak wymaganych plików:"
					echo -e "${c_color}$(readlink -f powerdot)${d_color}"
					sleep 2
					run_script $router
				fi

				echo -e "[ ${w_color}!{$d_color} ] Kopiowanie plików konfiguracyjnych do ${c_color}${ip}:/etc${d_color}..."
				echo

				scp -r router/powerdot/etc/* root@$ip:/etc/

				echo
				success "Zakończono przesyłanie plików"
				sleep 2
				run_script $router
				;;
			r)
				# Menu > router > r
				clear && $title
				echo -e "[ ${c_color}Router${d_color} > ${c_color}Uruchom ponownie urządzenie${d_color} ]"
				echo
				dev_restart 20
				;;
				# EO Menu > router > r
			ssh)
				# Menu > router > ssh
				clear && $title
				echo -e "[ ${c_color}Router${d_color} > ${c_color}SSH${d_color} ]"
				echo
				start_ssh
				run_script $router
				# EO Menu > router > ssh
				;;
			0)
				# Menu > router > 0
				run_script
				;;
				# EO Menu > router > 0
			00)
				# Menu > router > 00
				rm $path_pw_stored
				ctrl_c
				;;
				# EO Menu > router > 00
			*)
				# Menu > router > *
				bad_choice
				run_script $router
				;;
				# EO Menu > router > *
		esac