#!/bin/bash
# Menu > tester

		connect 205
		cfg_path="/media/data/ev-simulator/config/config.cfg"

		if [ -n "$2" ]; then # Jeśli drugi argument został podany
			choice2=$2
		fi

		clear && $title
		echo -e "[ ${c_color}Tester (${qp})${d_color} ]"
		echo

		# check if cfg file exists
		if ! ssh root@$ip "test -f ${cfg_path}"; then
			error "Żądany plik konfiguracyjny nie istnieje:"
			echo -e "${e_color}${cfg_path}${d_color}"
			sleep 3
			run_script
		fi


		clear && $title
		echo -e "[ ${c_color}Tester (${qp})${d_color} ]"
		echo
		echo -e "Pobieranie danych..."

		# Pobierz aktualne wartości z pliku konfiguracyjnego
		prog_bar "-c" 0 6
		cur_mCL=$(ssh root@$ip "grep -E 'maxCurrentLimit = [0-9]{1,}' ${cfg_path} | grep -oE '[0-9]{1,}'")
		prog_bar "-c" 1 6
		cur_mVL=$(ssh root@$ip "grep -E 'maxVoltageLimit = [0-9]{1,}' ${cfg_path} | grep -oE '[0-9]{1,}'")
		prog_bar "-c" 2 6
		cur_pTC=$(ssh root@$ip "grep -E 'prechargeTargetCurrent = [0-9]{1,}' ${cfg_path} | grep -oE '[0-9]{1,}'")
		prog_bar "-c" 3 6
		cur_SoC=$(ssh root@$ip "grep -E 'SOC = [0-9]{1,}' ${cfg_path} | grep -oE '[0-9]{1,}'")
		prog_bar "-c" 4 6
		cur_tCL=$(ssh root@$ip "grep -E 'targetCurrent = [0-9]{1,}' ${cfg_path} | grep -oE '[0-9]{1,}'")
		prog_bar "-c" 5 6
		cur_tVL=$(ssh root@$ip "grep -E 'targetVoltage = [0-9]{1,}' ${cfg_path} | grep -oE '[0-9]{1,}'")
		prog_bar "-c" 6 6

		clear && $title
		echo -e "[ ${c_color}Tester (${qp})${d_color} ]"
		echo
		echo -e "= Wybierz czynność ="
		option 1 "Zmień limit natężenia [ ${w_color}${cur_mCL}${d_color}A ]"
		option 2 "Zmień limit napięcia [ ${w_color}${cur_mVL}${d_color}V ]"
		option 3 "Zmień limit napięcia 'precharge' [ ${w_color}${cur_pTC}${d_color}A ]"
		option 4 "Zmień żądane natężenie [ ${w_color}${cur_tCL}${d_color}A ]"
		option 5 "Zmień żądane napięcie [ ${w_color}${cur_tVL}${d_color}V ]"
		option 6 "Zmień poziom wskaźnika naładowania baterii [ ${w_color}${cur_SoC}${d_color}% ]"
		option R "Uruchom ponownie urządzenie"
		option SSH "Połącz się z urządzeniem przez SSH"
		echo
		option 0 "Powrót"
		option 00 "Wyloguj i wyjdź"
		if [ -z "$choice2" ]; then
			echo -e "\n-----\n"
			echo -ne "Wybór: ${p_color}"; read choice2; echo -ne "${d_color}"
			choice2=$(echo $choice2 | tr '[:upper:]' '[:lower:]')
		fi

		clear && $title

		case $choice2 in
			1)
				# Menu > tester > 1
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Zmień limit natężenia${d_color} ]"
				echo
				echo -ne "Podaj nowy limit natężenia (puste anuluje): ${p_color}"; read mCL; echo -ne "${d_color}"
				if [ -z "$mCL" ]; then
					warn "Anulowanie..."
					sleep 1
					run_script $tester
				else
					clear && $title
					warn "Zmienianie limitu natężenia ${c_color}${cur_mCL}${d_color}A > ${c_color}${mCL}${d_color}A..."

					mCL_change="find ${cfg_path} -type f -exec sed -i -e 's/maxCurrentLimit = [0-9]*/maxCurrentLimit = ${mCL}/g' {} \;"
					ssh root@$ip $mCL_change';/usr/sbin/start-stop-daemon --stop --pidfile /var/run/ev-simulator.pid &>/dev/null;/usr/sbin/service EVSimulator --full-restart;'

					sleep 1
					run_script $tester
				fi
				;;
				# EO Menu > tester > 1
			2)
				# Menu > tester > 2
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Zmień limit napięcia${d_color} ]"
				echo
				echo -ne "Podaj nowy limit napięcia (puste anuluje): ${p_color}"; read mVL; echo -ne "${d_color}"
				if [ -z "$mVL" ]; then
					warn "Anulowanie..."
					sleep 1
					run_script $tester
				else
					clear && $title
					warn "Zmienianie limitu napięcia ${c_color}${cur_mVL}${d_color}V > ${c_color}${mVL}${d_color}V..."

					mVL_change="find ${cfg_path} -type f -exec sed -i -e 's/maxVoltageLimit = [0-9]*/maxVoltageLimit = ${mVL}/g' {} \;"
					ssh root@$ip $mVL_change';/usr/sbin/start-stop-daemon --stop --pidfile /var/run/ev-simulator.pid &>/dev/null;/usr/sbin/service EVSimulator --full-restart;'

					sleep 1
					run_script $tester
				fi
				;;
				# EO Menu > tester > 2
			3)
				# Menu > tester > 3
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Zmień limit napięcia 'precharge'${d_color} ]"
				echo
				echo -ne "Podaj nowy limit napięcia "precharge" (puste anuluje): ${p_color}"; read pTC; echo -ne "${d_color}"
				if [ -z "$pTC" ]; then
					clear && $title
					warn "Anulowanie..."

					sleep 1
					run_script $tester
				else
					clear && $title
					warn "Zmienianie limitu napięcia "precharge" ${c_color}${cur_pTC}${d_color}A > ${c_color}${pTC}${d_color}A..."

					pTC_change="find ${cfg_path} -type f -exec sed -i -e 's/prechargeTargetCurrent = [0-9]*/prechargeTargetCurrent = ${pTC}/g' {} \;"
					ssh root@$ip $pTC_change';/usr/sbin/start-stop-daemon --stop --pidfile /var/run/ev-simulator.pid &>/dev/null;/usr/sbin/service EVSimulator --full-restart;'

					sleep 1
					run_script $tester
				fi
				;;
				# EO Menu > tester > 3
			4)
				# Menu > tester > 4
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Zmień żądane natężenie${d_color} ]"
				echo
				echo -ne "Podaj nowe żądane natężenie (puste anuluje): ${p_color}"; read tCL; echo -ne "${d_color}"
				if [ -z "$tCL" ]; then
					clear && $title
					warn "Anulowanie..."

					sleep 1
					run_script $tester
				else
					clear && $title
					warn "Zmienianie żądanego natężenia ${c_color}${cur_tCL}${d_color}A > ${c_color}${tCL}${d_color}A..."

					tCL_change="find ${cfg_path} -type f -exec sed -i -e 's/targetCurrent = [0-9]*/targetCurrent = ${tCL}/g' {} \;"
					ssh root@$ip $tCL_change';/usr/sbin/start-stop-daemon --stop --pidfile /var/run/ev-simulator.pid &>/dev/null;/usr/sbin/service EVSimulator --full-restart;'

					sleep 1
					run_script $tester
				fi
				;;
				# EO Menu > tester > 4
			5)
				# Menu > tester > 5
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Zmień żądane napięcie${d_color} ]"
				echo
				echo -ne "Podaj nowe żądane napięcie (puste anuluje): ${p_color}"; read tVL; echo -ne "${d_color}"
				if [ -z "$tVL" ]; then
					clear && $title
					warn "Anulowanie..."

					sleep 1
					run_script $tester
				else
					clear && $title
					warn "Zmienianie żądanego napięcia ${c_color}${cur_tVL}${d_color}V > ${c_color}${tVL}${d_color}V..."

					tVL_change="find ${cfg_path} -type f -exec sed -i -e 's/targetVoltage = [0-9]*/targetVoltage = ${tVL}/g' {} \;"
					ssh root@$ip $tVL_change';/usr/sbin/start-stop-daemon --stop --pidfile /var/run/ev-simulator.pid &>/dev/null;/usr/sbin/service EVSimulator --full-restart;'

					sleep 1
					run_script $tester
				fi
				;;
				# EO Menu > tester > 5
			6)  
				# Menu > tester > 6
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Zmień poziom wskaźnika naładowania baterii${d_color} ]"
				echo
				echo -ne "Podaj nowy poziom wskaźnika naładowania baterii (puste anuluje): ${p_color}"; read SoC; echo -ne "${d_color}"
				if [ -z "$SoC" ]; then
					clear && $title
					warn "Anulowanie..."

					sleep 1
					run_script $tester
				else
					clear && $title
					warn "Zmienianie poziomu wskaźnika naładowania baterii ${c_color}${cur_SoC}${d_color}% > ${c_color}${SoC}${d_color}%..."

					SoC_change="find ${cfg_path} -type f -exec sed -i -e 's/SOC = [0-9]*/SOC = ${SoC}/g' {} \;"
					ssh root@$ip $SoC_change';/usr/sbin/start-stop-daemon --stop --pidfile /var/run/ev-simulator.pid &>/dev/null;/usr/sbin/service EVSimulator --full-restart;'

					sleep 1
					run_script $tester
				fi
				;;
				# EO Menu > tester > 6
			r)
				# Menu > tester > r
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}Uruchom ponownie urządzenie${d_color} ]"
				echo
				dev_restart 25
				run_script $tester
				;;
				# EO Menu > tester > r
			ssh)
				# Menu > display > ssh
				clear && $title
				echo -e "[ ${c_color}Tester (${qp})${d_color} > ${c_color}SSH${d_color} ]"
				echo
				start_ssh
				run_script $tester
				# EO Menu > tester > ssh
				;;
			0)
				# Menu > tester > 0
				run_script
				;;
				# EO Menu > tester > 0
			00)
				# Menu > tester > 00
				rm $path_pw_stored
				ctrl_c
				;;
				# EO Menu > tester > 00
			*)
				# Menu > tester > *
				bad_choice
				run_script $tester
				;;
				# EO Menu > tester > *
		esac