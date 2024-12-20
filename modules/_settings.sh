#!/bin/bash
# Menu > 9

		if [ -n "$2" ] && [ "$2" != "update" ]; then # Jeśli drugi argument został podany
			choice2=$2
		fi

		clear && $title
		echo -e "[ ${c_color}Ustawienia${d_color} ]"
		echo
		option 1 "Sprawdź aktualizacje"
		option 2 "Zmień kolory tekstu"
		option 3 "Utwórz skrót LekoTools na pulpicie"
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
				# Menu > 9 > 1
				clear && $title
				warn "Sprawdzanie dostępności aktualizacji..."
				rm /tmp/.LekoTools.remind-later 2>/dev/null
				sleep 1
				run_script 9 "update"
				# EO Menu > 9 > 1
				;;
			2)
				# Menu > 9 > 2
				color_cat_set() {
					case $1 in
						d_color)
							find $config_path -type f -exec sed -i -e "s/d_color: .*/d_color: $2/g" {} \;
							;;
						p_color)
							find $config_path -type f -exec sed -i -e "s/p_color: .*/p_color: $2/g" {} \;
							;;
						c_color)
							find $config_path -type f -exec sed -i -e "s/c_color: .*/c_color: $2/g" {} \;
							;;
						w_color)
							find $config_path -type f -exec sed -i -e "s/w_color: .*/w_color: $2/g" {} \;
							;;
						e_color)
							find $config_path -type f -exec sed -i -e "s/e_color: .*/e_color: $2/g" {} \;
							;;
					esac
				}

				list_colors() {
					current=$(cat $config_path | grep $1 | awk '{print $2}')
					current="\e[${current}"
					echo -e "++++++++++++++++++"
					echo -e "| ${current}AKTUALNY KOLOR${d_color} |"
					echo -e "++++++++++++++++++"
					echo
					option 1 "\e[${white}Biały${d_color}"
					option 2 "\e[${black}Czarny${d_color}"
					option 3 "\e[${gray}Szary${d_color}"
					option 4 "\e[${light_gray}Jasny szary${d_color}"
					option 5 "\e[${red}Czerwony${d_color}"
					option 6 "\e[${light_red}Jasny czerwony${d_color}"
					option 7 "\e[${blue}Niebieski${d_color}"
					option 8 "\e[${light_blue}Jasny niebieski${d_color}"
					option 9 "\e[${yellow}Żółty${d_color}"
					option 10 "\e[${light_yellow}Jasny żółty${d_color}"
					option 11 "\e[${green}Zielony${d_color}"
					option 12 "\e[${light_green}Jasny zielony${d_color}"
					option 13 "\e[${cyan}Cyjan${d_color}"
					option 14 "\e[${light_cyan}Jasny cyjan${d_color}"
					option 15 "\e[${purple}Fioletowy${d_color}"
					option 16 "\e[${light_purple}Jasny fioletowy${d_color}"
					echo
					option 0 "Powrót"
					echo
					echo -ne "Wybór: ${p_color}"; read new_color; echo -ne "${d_color}"

					case $new_color in
						1)
							color_cat_set $1 $white
							run_script 9 2
							;;
						2)
							color_cat_set $1 $black
							run_script 9 2
							;;
						3)
							color_cat_set $1 $gray
							run_script 9 2
							;;
						4)
							color_cat_set $1 $light_gray
							run_script 9 2
							;;
						5)
							color_cat_set $1 $red
							run_script 9 2
							;;
						6)
							color_cat_set $1 $light_red
							run_script 9 2
							;;
						7)
							color_cat_set $1 $blue
							run_script 9 2
							;;
						8)
							color_cat_set $1 $light_blue
							run_script 9 2
							;;
						9)
							color_cat_set $1 $yellow
							run_script 9 2
							;;
						10)
							color_cat_set $1 $light_yellow
							run_script 9 2
							;;
						11)
							color_cat_set $1 $green
							run_script 9 2
							;;
						12)
							color_cat_set $1 $light_green
							run_script 9 2
							;;
						13)
							color_cat_set $1 $cyan
							run_script 9 2
							;;
						14)
							color_cat_set $1 $light_cyan
							run_script 9 2
							;;
						15)
							color_cat_set $1 $purple
							run_script 9 2
							;;
						16)
							color_cat_set $1 $light_purple
							run_script 9 2
							;;
						0)
							run_script 9 2
							;;
						*)
							bad_choice
							run_script 9 2
					esac
				}

				if [ -n "$3" ]; then
					choice3=$3
				fi

				clear && $title
				echo -e "[ ${c_color}Ustawienia${d_color} > ${c_color}Personalizacja${d_color} ]"
				echo
				option 1 "Zmień kolor główny"
				option 2 "Zmień kolor podstawowy"
				option 3 "Zmień kolor potwierdzenia/menu"
				option 4 "Zmień kolor ostrzeżenia"
				option 5 "Zmień kolor błędu"
				echo
				option 0 "Powrót"
				option 00 "Wyloguj i wyjdź"
				if [ -z "$choice3" ]; then
					echo -e "\n------\n"
					echo -ne "Wybór: ${p_color}"; read choice3; echo -ne "${d_color}"
					choice3=$(echo $choice3 | tr '[:upper:]' '[:lower:]')
				fi

				case $choice3 in
					1)
						# Menu > 9 > 2 > 1
						clear && $title
						echo -e "[ ${c_color}Personalizacja${d_color} > ${c_color}Zmień kolor domyślny${d_color} ]"
						echo
						list_colors d_color
						;;
						# EO Menu > 9 > 2 > 1
					2)
						# Menu > 9 > 2 > 2
						clear && $title
						echo -e "[ ${c_color}Personalizacja${d_color} > ${c_color}Zmień kolor podstawowy${d_color} ]"
						echo
						list_colors p_color
						;;
						# EO Menu > 9 > 2 > 2
					3)
						# Menu > 9 > 2 > 3
						clear && $title
						echo -e "[ ${c_color}Personalizacja${d_color} > ${c_color}Zmień kolor potwierdzenia/menu${d_color} ]"
						echo
						list_colors c_color
						;;
						# EO Menu > 9 > 2 > 3
					4)
						# Menu > 9 > 2 > 4
						clear && $title
						echo -e "[ ${c_color}Personalizacja${d_color} > ${c_color}Zmień kolor ostrzeżenia${d_color} ]"
						echo
						list_colors w_color
						;;
						# EO Menu > 9 > 2 > 4
					5)
						# Menu > 9 > 2 > 5
						clear && $title
						echo -e "[ ${c_color}Personalizacja${d_color} > ${c_color}Zmień kolor błędu${d_color} ]"
						echo
						list_colors e_color
						;;
						# EO Menu > 9 > 2 > 5
					0)
						# Menu > 9 > 2 > 0
						run_script 9
						;;
						# EO Menu > 9 > 2 > 0
					00)
						# Menu > 9 > 2 > 00
						rm $path_pw_stored
						ctrl_c
						;;
						# EO Menu > 9 > 2 > 00
					*)
						# Menu > 9 > 2 > *
						bad_choice
						run_script 9 2
						;;
						# EO Menu > 9 > 2 > *
				esac
				;;
				# EO Menu > 9 > 2
			3)
				# Menu > 9 > 3
				script_path="$(cd "$( dirname $0 )" && pwd)/$(basename $0)"
				clear && $title
				echo -e "[ ${c_color}Ustawienia${d_color} > ${c_color}Utwórz skrót LekoTools na pulpicie${d_color} ]"
				echo

				if [ -d "$HOME/Pulpit" ]; then
					# "Pulpit" istnieje
					destination_path="$HOME/Pulpit"
				elif [ -d "$HOME/Desktop" ]; then
					# "Desktop" istnieje
					destination_path="$HOME/Desktop"
				else
					# żadne z w/w nie istnieje
					destination_path="$HOME"
				fi

				file="$destination_path"/"LekoTools.desktop"
				touch $file

				# Tworzenie aktywatora
				echo -e "[Desktop Entry]" > $file
				echo -e "Name=LekoTools" >> $file
				echo -e "Exec=$executor $script_path" >> $file
				echo -e "Comment=" >> $file
				echo -e "Terminal=true" >> $file
				echo -e "Icon=cs-cat-admin" >> $file
				echo -e "Type=Application" >> $file

				chmod +x $file # Oznacz aktywator jako wykonywalny
				cp -f $file ~/.local/share/applications

				success "Skrót został utworzony w ${c_color}$file${d_color}"
				echo
				pause
				run_script 9
				;;
				# EO Menu > 9 > 3
			0)
				# Menu > 9 > 0
				run_script
				;;
				# EO Menu > 9 > 0
			00)
				# Menu > 9 > 00
				rm $path_pw_stored
				ctrl_c
				;;
				# EO Menu > 9 > 00
			*)
				# Menu > 9 > *
				clear && $title
				bad_choice
				run_script 9
				;;
				# EO Menu > 9 > *
		esac