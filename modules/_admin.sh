#!/bin/bash
# Menu > 2137

		path_pw_admin='/tmp/.LekoTools-admin.lock'

		dev_password="35b2b79a57a88f179c365033f2b9efdf309489f9c78bf825815ebb8ea27f9cd3c2de61c542fbe4b5cdbbaa992936a31f1d4a4cb1e6b52bc77b2ca134b784bd66"

		clear && $title
		echo -e "[ ${c_color}Opcje deweloperskie${d_color} ]"
		echo
		echo -ne "Wprowadź hasło: "; stty -echo; read password; stty echo; echo

		password=$(echo $password | encryption | awk '{print $1}')
		if [ "$password" != "$dev_password" ]; then
			clear && $title
			echo -e "[ ${c_color}Opcje deweloperskie${d_color} ]"
			echo
			error "Nieprawidłowe hasło"
			sleep 1
			run_script
		fi

		test() {
			echo -e "This is a function to test various funtionalities."
			echo -e "Edit it inside the script source code to your needs."
			echo

			lovato_plc=$(cat lovato/plc)
			echo -e "$lovato_plc"
		}

		clear && $title
		echo -e "[ ${c_color}Opcje deweloperskie${d_color} ]"
		echo
		echo "= Wybierz opcję ="
		option 1 "Konsola poleceń"
		option 2 "Pobierz oprogramowanie Leko"
		option 3 "Zaktualizuj hash wersji"
		echo
		option 0 "Powrót"
		option 00 "Wyloguj i wyjdź"
		echo -e "\n------\n"
		echo -en "Wybór: ${p_color}"; read choice2; echo -en "${d_color}"

		case $choice2 in
		1)
			# Menu > 2137 > 1
			clear; echo -e "Użyj 'q' lub 'quit', aby wyjść"
			while true; do
				echo

				# Command: quit
				echo -en "${w_color}admin${d_color}@${p_color}LekoTools${d_color}# "; read cmnd
				if [ "$cmnd" = "q" ] || [ "$cmnd" = "quit" ]; then
					break
				fi

				if [ $(command -v $cmnd) ]; then
					eval "$cmnd"
				elif [ -z "$cmnd" ]; then
					sleep 0
				else
					echo -e "Nieznane polecenie: $cmnd"
				fi
			done
			;;
			# EO Menu > 2137 > 1
		2)
			# Menu > 2137 > 2
			clear

			copyFiles() {
				version=$(echo "$version" | tr '[:lower:]' '[:upper:]')
				controller=$(echo "$controller" | tr '[:lower:]' '[:upper:]')
				amount=$(wc -l < list.lst | cut -c 1-2)  # Count how many lines are in list.lst
				variable=1
				lp="$variable"p

				while [ "$variable" -le "$amount" ]; do
					application=$(sed -n "$lp" list.lst)
					mkdir app
					cp "$controller/$version"/*"$application"* app
					variable=$((variable + 1))
					lp="$variable"p
				done
			}

			get_versions() {
				curl -s https://leko.ekoenergetyka.com.pl/distrib/ | grep -o '<a href="[^\"]\+"' | sed 's/<a href="//;s/"$//'
			}

			get_leko() {
				local controller=$1
				local version=$2

				uppercasecontroller=$(echo "$controller" | tr '[:lower:]' '[:upper:]')
				if [ ! -d "~/$uppercasecontroller" ]; then
					mkdir "~/$uppercasecontroller"
				else
					echo "Folder exists, skipping"
				fi

				wget --recursive --no-parent --cut-dirs=5 --accept="$controller.swu" "https://leko.ekoenergetyka.com.pl/distrib/$version/swu/" 2>&1
				wget --recursive --no-parent --cut-dirs=5 --accept="$controller.wic.gz" "https://leko.ekoenergetyka.com.pl/distrib/$version/images/$controller/" 2>&1
				wget --recursive --no-parent --cut-dirs=5 --accept="ota-$controller.swu" "https://leko.ekoenergetyka.com.pl/distrib/$version/images/$controller/" 2>&1

				mv leko.ekoenergetyka.com.pl $version
				mv $version "~/$uppercasecontroller"/

				echo -e "Pobrano oprogramowanie Leko ${c_color}v$version${d_color} dla ${c_color}$controller${d_color} do folderu ${c_color}~/$uppercasecontroller${d_color}"
				pause
			}

			clear && $title
			echo -e "[ ${c_color}Opcje deweloperskie${d_color} > ${c_color}Pobierz oprogramowanie Leko${d_color} ]"
			echo
			echo "= Wybierz opcję ="
			option 1 "Pobierz wszystkie wersje Leko"
			option 2 "Pobierz wersję Leko dla danego kontrolera"
			option 3 "Kopiuj pliki oprogramowania"
			echo
			option 0 "Powrót"
			option 00 "Wyloguj i wyjdź"
			echo -e "\n------\n"
			echo -en "Wybór: ${p_color}"; read choice3; echo -en "${d_color}"

			case $choice3 in
				1)
					get_versions
					;;
				2)
					clear && $title
					echo -e "[ ${c_color}Opcje deweloperskie${d_color} > ${c_color}Pobierz oprogramowanie Leko${d_color} ]"
					echo
					echo -en "Podaj żądaną wersję Leko (np. 0.24.0): "; read version

					clear && $title
					echo -e "[ ${c_color}Opcje deweloperskie${d_color} > ${c_color}Pobierz oprogramowanie Leko${d_color} ]"
					echo
					echo -en "Podaj żądany kontroler (np. clc4): "; read controller

					get_leko "$controller" "$version"
					;;
				3)
					copyFiles "$controller" "$version"
					;;
				0)
					run_script 2137
					;;
				00)
					rm $path_pw_admin
					clear && exit
					;;
				*)
					bad_choice
					run_script 2137
					;;
			esac
			;;
			# EO Menu > 2137 > 2
		3)
			# Menu > 2137 > 3
			clear && $title
			echo -e "[ ${c_color}Opcje deweloperskie${d_color} > ${c_color}Zaktualizuj hash wersji${d_color} ]"
			echo
			echo -en "Podaj numer nowej wersji: ${p_color}"; read new_ver; echo -en "${d_color}"; rewrite_line "-n"

			warn "Aktualizacja hash'a wersji"

			if [ "$new_ver" != "" ]; then
				sed -i "s/$Ver/$new_ver/g" $script_path # replace $Ver in script with new_ver
			fi
			new_ver_hash=$(echo $(date +%s) | md5sum | awk '{print $1}')
			sed -i "s/$Ver_hash/$new_ver_hash/g" $script_path # replace $Ver_hash in script with new_ver_hash

			success "Zaktualizowano hash wersji"
			sleep 1
			ctrl_c
			# EO Menu > 2137 > 3
			;;
		0)
			# Menu > 2137 > 0
			run_script
			;;
			# EO Menu > 2137 > 0
		00)
			# Menu > 2137 > 00
			rm $path_pw_admin
			clear && exit
			;;
			# EO Menu > 2137 > 00
		*)
			# Menu > 2137 > *
			bad_choice
			run_script
			;;
			# EO Menu > 2137 > *
		esac