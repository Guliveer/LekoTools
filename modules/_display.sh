#!/bin/bash
# Menu > display

		connect 205

		if [ -n "$2" ]; then
			choice2=$2
		fi

		clear && $title
		echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} ]"
		echo

		cfg_path1=$(ssh root@$ip "find /media/data -name languages.json -print -quit 2>/dev/null")
		cfg_path2="/etc/config/gui/config.js"
		cfg_find=$(ssh root@$ip 'cat $(find /media/data -name index.html -print -quit 2>/dev/null) | grep "config.js"')
		if [ "$cfg_find" != "" ]; then
			cfg_path="$cfg_path2"
		elif [ -z "$cfg_path1" ]; then # cfg_path1 is empty
			cfg_path="$cfg_path2"
		else
			cfg_path="$cfg_path1"
		fi

		if ssh root@$ip "grep \"deprecated\" $cfg_path &>/dev/null"; then
			error "Błąd wczytywania danych"
			echo
			sleep 2
			run_script
		fi

		# if cfg_path is the same as cfg_path1
		if [ "$cfg_path" = "$cfg_path1" ]; then
			languages_orig=$(ssh root@$ip "cat ${cfg_path} | cut -d '[' -f2 | cut -d ']' -f1") # lista języków
		elif [ "$cfg_path"="$cfg_path2" ]; then
			languages_orig=$(ssh root@$ip "grep \"languages\" $cfg_path | cut -d '[' -f2 | cut -d ']' -f1") # lista języków
		fi

		lang_main=$(echo $languages_orig | cut -d ',' -f1 | sed 's/"//g') # wybierz pierwszy język z listy
		languages=$(echo $languages_orig | sed 's/"//g') # modyfikuj spis listy języków: usuń cudzysłowy
		languages=$(echo $languages | sed "s/$lang_main, //g") # usuń język główny z listy

		echo -e "${p_color}Język główny${d_color}: $lang_main"
		echo -e "${p_color}Pozostałe języki${d_color}: $languages"
		echo
		option 1 "Ustaw język główny"
		option 2 "Dodaj język"
		option 3 "Usuń język"
		option 4 "Sortuj dodatkowe języki"
		option 5 "Ustaw karuzelę pokazową"
		option 6 "Aktualizuj oprogramowanie DISP10TC"
		option 7 "Zmień logo"
		option R "Uruchom ponownie urządzenie"
		option SSH "Połącz się z urządzeniem przez SSH"
		echo
		option 0 "Powrót"
		option 00 "Wyloguj i wyjdź"
		echo
		help "Aby zastosować zmiany, uruchom ponownie urządzenie"
		if [ -z "$choice2" ]; then
			echo -e "\n------\n"
			echo -ne "Wybór: ${p_color}"; read choice2; echo -ne "${d_color}"
			choice2=$(echo $choice2 | tr '[:upper:]' '[:lower:]')
		fi
		
		case $choice2 in
			1)
				# Menu > display > 1
				# zmiana języka głównego
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Ustaw język główny${d_color} ]"
				echo

				languages=$(echo $languages_orig | sed 's/\"//g') # modyfikuj spis listy języków: usuń cudzysłowy
				languages=$(echo $languages | tr ' ' '\n' | sort | tr '\n' ' ') # sortuj języki alfabetycznie
				languages=$(echo $languages | sed 's/, / /g' | sed 's/ /, /g' | sed 's/ $//g' | sed 's/,$//g') # usuń ostatnią spację i przecinek z $languages | dodaj cudzysłów przed spacją między językami

				echo -e "${p_color}Lista języków${d_color}: $languages"
				echo
				echo -ne "Nowy język główny (puste anuluje): ${p_color}"; read choice_lang; echo -ne "${d_color}"
				# w zmiennej $choice_lang zamień litery na małe
				if [ -z "$choice_lang" ]; then
					run_script $display
				fi
				choice_lang=$(echo $choice_lang | tr '[:upper:]' '[:lower:]' | sed 's/ //g' | sed 's/\"//g') # w zmiennej $choice_lang zamień litery na małe | usuń spacje | usuń cudzysłowy

				# sprawdź czy wybrany język jest już językiem głównym
				if [ $lang_main = $choice_lang ]; then
					error "Podany język jest już językiem głównym" 
					sleep 2
					run_script $display
				fi

				# sprawdź czy wybrany język jest na liście - jeśli tak to zamień obecny język główny na wybrany
				if echo $languages | grep -w $choice_lang > /dev/null; then
					clear && $title
					echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Ustaw język główny${d_color} ]"
					echo
					echo -e "Zmienianie języka głównego ${c_color}${lang_main}${d_color} > ${c_color}${choice_lang}${d_color}..."

					languages=$(echo $languages_orig | sed "s/${choice_lang}/${choice_lang}_temp/g") # modyfikuj spis listy języków: usuń cudzysłowy
					languages=$(echo $languages | sed "s/${lang_main}/${choice_lang}/g") # modyfikuj spis listy języków: usuń cudzysłowy
					languages=$(echo $languages | sed "s/${choice_lang}_temp/${lang_main}/g") # modyfikuj spis listy języków: usuń cudzysłowy
					ssh root@$ip "sed -i 's/$languages_orig/$languages/g' $cfg_path"

					success "Zmieniono język główny na ${c_color}${choice_lang}${d_color}"
					sleep 2
					run_script $display
				else
					bad_choice
					run_script $display
				fi

				# EO Menu > display > 1
				;;
			2)
				# Menu > display > 2
				# dodawanie języka
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Dodaj język${d_color} ]"
				echo

				languages=$(echo $languages_orig | sed 's/"//g') # modyfikuj spis listy języków: usuń cudzysłowy
				languages=$(echo $languages | tr ' ' '\n' | sort | tr '\n' ' ') # sortuj języki alfabetycznie
				languages=$(echo $languages | sed 's/, $//g' | sed 's/" "/", "/g') # usuń ostatnią spację i przecinek z $languages | dodaj cudzysłów przed spacją między językami

				echo -e "${p_color}Lista języków${d_color}: $languages"
				echo
				echo -ne "Podaj nowy język (puste anuluje): ${p_color}"; read choice_lang; echo -ne "${d_color}"
				if [ -z "$choice_lang" ]; then
					run_script $display
				fi
				choice_lang=$(echo $choice_lang | tr '[:upper:]' '[:lower:]' | sed 's/ //g' | sed 's/\"//g') # w zmiennej $choice_lang zamień litery na małe | usuń spacje | usuń cudzysłowy

				# sprawdź czy wybrany język jest już na liście
				if echo $languages | grep -w $choice_lang > /dev/null; then
					clear && $title
					echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Dodaj język${d_color} ]"
					echo
					error "Podany język jest już na liście" 
					sleep 2
					run_script $display
				fi

				# dodaj język na koniec listy
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Dodaj język${d_color} ]"
				echo
				warn "Dodawanie języka ${c_color}${choice_lang}${d_color}..."
				choice_lang=$(echo $choice_lang | sed 's/ *$//g') # usuń spacje z końca zmiennej
				ssh root@$ip "sed -i 's/]/, \"${choice_lang}\"]/g' ${cfg_path}"
				success "Dodano język do listy: ${c_color}${choice_lang}${d_color}"
				sleep 2
				run_script $display

				# EO Menu > display > 2
				;;
			3)
				# Menu > display > 3
				# usuwanie języka

				# sprawdź czy lista języków jest pusta
				if [ -z $languages ]; then
					clear && $title
					echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Usuń język${d_color} ]"
					echo
					error "Lista języków jest pusta"
					sleep 2
					run_script $display
				fi

				# wyświetl listę języków
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Usuń język${d_color} ]"
				echo
				echo -e "${p_color}Lista języków${d_color}: $languages"
				echo
				echo -ne "Język do usunięcia: ${p_color}"; read -r choice_lang; echo -ne "${d_color}"
				choice_lang=$(echo $choice_lang | tr '[:upper:]' '[:lower:]' | sed 's/ //g' | sed 's/\"//g') # w zmiennej $choice_lang zamień litery na małe | usuń spacje | usuń cudzysłowy

				# sprawdź czy wybrany język jest na liście
				if ! echo $languages | grep -w $choice_lang > /dev/null; then
					error "Podany język nie znajduje się na liście" 
					sleep 2
					run_script $display
				fi

				# usuń język z listy
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Usuń język${d_color} ]"
				echo
				warn "Usuwanie języka: ${c_color}${choice_lang}${d_color}..."

				ssh root@$ip "sed -i 's/\"${choice_lang}\"//g' ${cfg_path}"
				ssh root@$ip "sed -i 's/, ,/,/g' ${cfg_path} &>/dev/null"
				ssh root@$ip "sed -i 's/, ]/]/g' ${cfg_path} &>/dev/null"
				ssh root@$ip "sed -i 's/\[, /\[/g' ${cfg_path} &>/dev/null"

				success "Usunięto język ${c_color}${choice_lang}${d_color} z listy"
				sleep 2
				run_script $display
				# EO Menu > display > 3
				;;
			4)
				# Menu > display > 4
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Sortuj dodatkowe języki${d_color} ]"
				echo
				warn "Sortowanie języków..."

				languages=$(echo $languages_orig | sed "s/\"${lang_main}\", //g") # usuń $lang_main z $languages
				languages=$(echo $languages | tr ' ' '\n' | sort | tr '\n' ' ') # sortuj języki dodatkowe
				languages="\"${lang_main}\", $languages" # dodaj $lang_main na początek $languages
				languages=$(echo $languages | sed 's/, $//g' | sed 's/" "/", "/g' | sed 's/,$//g') # usuń ostatnią spację i przecinek z $languages | dodaj cudzysłów przed spacją między językami

				# zapisz listę języków do wyświetlacza
				ssh root@$ip "sed -i 's/$languages_orig/$languages/g' $cfg_path"
				success "Języki zostały posortowane"
				sleep 2
				run_script $display

				# EO Menu > display > 4
				;;
			5)
				# Menu > display > 5
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Ustaw karuzelę pokazową${d_color} ]"
				# Sprawdź, czy istnieje katalog /media/data/unidisplay-webapp na urządzeniu
				echo
				if ssh root@$ip '[ -d /media/data/unidisplay-webapp ]'; then
					success "Katalog /media/data/unidisplay-webapp istnieje"
					echo
					elif ssh root@$ip '[ ! -d /media/data/unidisplay-webapp ]'; then
					error "Katalog /media/data/unidisplay-webapp nie istnieje, anulowanie..."
					exit
				fi
				sleep 2

				# Sprawdź, czy istnieje katalog pokaz_karuzela na komputerze i zapisz jego lokalizację do zmiennej $dir_karuzela
				dir_karuzela=$(find / -type d -iname 'pokaz_karuzela' 2>/dev/null)
				if [ -z "$dir_karuzela" ]; then
					error "Katalog pokaz_karuzela nie istnieje, anulowanie..."
					exit
				else
					success "Znaleziono katalog pokaz_karuzela..."
					echo
				fi
				sleep 2

				# Skopiuj zawartość katalogu pokaz_karuzela na urządzenie
				warn "Kopiowanie zawartości katalogu pokaz_karuzela na urządzenie..."
				echo
				scp -r $dir_karuzela/* root@$ip:/media/data/unidisplay-webapp
				echo
				sleep 2

				# Usuń /lib/mdev/find-inputs.sh z linijki input/event.* 0:0 0660 @/lib/mdev/find-inputs.sh w pliku /etc/mdev.conf
				warn "Usuwanie /lib/mdev/find-inputs.sh z pliku /etc/mdev.conf..."
				echo
				ssh root@$ip 'sed -i "s/input\/event.* 0:0 0660 @\/lib\/mdev\/find-inputs.sh/input\/event.* 0:0 0660/g" /etc/mdev.conf'
				sleep 2

				# Zrestartuj urządzenie
				warn "Ponowne uruchamianie urządzenia..."
				ssh root@$ip '/sbin/reboot'
				sleep 5
				while true; do if ping -c1 $ip > /dev/null; then break; fi;
				done;
				sleep 5
				success "Uruchomiono ponownie";
				echo

				# Zrestartuj usługę qt-webengine-browser
				warn "Restartowanie usługi qt-webengine-browser..."
				sleep 5
				ssh root@$ip '/usr/sbin/service qt-webengine-browser restart'
				echo '[ ${p_color}+${d_color} ] Konfiguracja karuzeli zakończona'
				sleep 2
				run_script $display
				# EO Menu > display > 5
				;;
			6)
				# Menu > display > 6
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Aktualizuj oprogramowanie DISP10TC${d_color} ]"
				echo
				echo -en "Podaj nową wersję oprogramowania DISP10TC (np. 0.27.0): ${p_color}"; read lekoD10tcVersion; echo -en "${d_color}"; rewrite_line "-n"

				if [ -z "$lekoD10tcVersion" ]; then
					error "Nie podano wersji oprogramowania"
					sleep 1
					run_script $display
				fi

				wget https://leko.ekoenergetyka.com.pl/distrib/$lekoD10tcVersion/images/disp10tc/imx-boot-disp10tc-sd.bin-flash_evk
				wget https://leko.ekoenergetyka.com.pl/distrib/$lekoD10tcVersion/images/disp10tc/eko-image-display-disp10tc.wic.bz2

				sleep 2

				help "Wyłącz Disp10TC"
				pause_continue

				rewrite_line "$(help 'Podłącz komputer do USB OTG kontrolera')"
				pause

				rewrite_line "$(help 'Wciśnij i przytrzymaj przez 5s przycisk BOOT FROM SERIAL, i uruchom wyswietlacz')"
				pause

				clear && $title

				sudo uuu -v -b emmc_all imx-boot-disp10tc-sd.bin-flash_evk eko-image-display-disp10tc.wic.bz2

				sucess "Zakończono"
				rm imx-boot-disp10tc-sd.bin-flash_evk eko-image-display-disp10tc.wic.bz2 2>/dev/null


				unset lekoD10tcVersion
				sleep 2
				run_script $display
				;;
			7)
				# Menu > display > 7
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Zmień logo${d_color} ]"
				echo

				# check if file /etc/config/gui/resource/bootupLogo.svg exists on $ip
				bootupLogo_test=$(ssh root@$ip 'ls /etc/config/gui/resource/bootupLogo.svg 2>/dev/null')
				if [ -z "$bootupLogo_test" ]; then
					echo -en "Podaj ścieżkę do logo (np. /home/user/Downloads/logo.svg): ${p_color}"; read logo_path; echo -en "${d_color}"
					rewrite_line "-n"

					warn "Zamienianie logo..."
					echo

					logo_path=$(echo $logo_path | sed "s/\"//g" | sed "s/'//g" | sed 's/`//g')
					scp "$logo_path" root@$ip:/etc/config/gui/resource/bootupLogo.svg

					echo
					success "Zakończono"
					help "Aby zastosować zmiany, uruchom ponownie urzędzenie"

					echo
					pause
				else
					error "Brak pliku do podmiany na urządzeniu"
					sleep 1
				fi

				run_script $display
				# EO Menu > display > 7
				;;
			r)
				# Menu > display > r
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}Uruchom ponownie urządzenie${d_color} ]"
				echo
				dev_restart 15
				run_script $display
				# EO Menu > display > r
				;;
			ssh)
				# Menu > display > ssh
				clear && $title
				echo -e "[ ${c_color}Wyświetlacz (${qp})${d_color} > ${c_color}SSH${d_color} ]"
				echo
				start_ssh
				run_script $display
				# EO Menu > display > ssh
				;;

			0)
				# Menu > display > 0
				run_script
				# EO Menu > display > 0
				;;
			00)
				# Menu > display > 00
				rm $path_pw_stored
				ctrl_c
				# EO Menu > display > 00
				;;
			*)
				# Menu > display > *
				bad_choice
				run_script $display
				# EO Menu > display > *
				;;
		esac