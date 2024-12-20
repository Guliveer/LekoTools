##########################################################
#                                                        #
#      NIE EDYTUJ KODU, JEŚLI NIE WIESZ CO ROBISZ!       #
#                                                        #
# ====================================================== #
#          Pomysł i wykonanie: Oliwer Pawelski           #
# ====================================================== #
#                                                        #
##########################################################

#!/bin/bash

# Informacje o programie
Name="LekoTools"
Ver="4.15.9"
Ver_hash="b053a9409de268a2392b2aa633c5be7a"

executor="/bin/bash"
# if [ "$0" = "$BASH_SOURCE" ]; then exec sh "$0" "$@"; fi # run with desired shell
if [ -z "$BASH_VERSION" ]; then exec /bin/bash "$0" "$@"; fi # run with 'bash'

ctrl_c() {
	tput cnorm; stty echo; clear; exit
}

trap ctrl_c INT

#################################
# Ustawienia kolorystyki
#

# Lista kolorów czcionki
black='30m' # Czarny
white='97m' # Biały

gray='90m' # Szary
light_gray='37m' # Jasny szary

red='31m' # Czerwony
light_red='91m' # Jasny czerwony

blue='34m' # Niebieski
light_blue='94m' # Jasny niebieski

yellow='33m' # Żółty
light_yellow='93m' # Jasny żółty

green='32m' # Zielony
light_green='92m' # Jasny zielony

cyan='36m' # Cyjan
light_cyan='96m' # Jasny cyjan

purple='35m' # Fioletowy
light_purple='95m' # Jasny fioletowy

d_color="${white}" # Domyślny kolor podstawowy (biały)
p_color="${light_green}" # Domyślny kolor główny (jasny zielony)
c_color="${light_blue}" # Domyślny kolor menu (jasny niebieski)
w_color="${light_yellow}" # Domyślny kolor ostrzeżeń (jasny żółty)
e_color="${light_red}" # Domyślny kolor błędów (jasny czerwony)

config_path="$HOME/.LekoTools.config"

if [ -f $config_path ]; then
	# Nadpisanie domyślnych kolorów z pliku konfiguracyjnego, jeśli istnieje
	d_color=$(cat $config_path | grep "d_color" | awk '{print $2}')
	p_color=$(cat $config_path | grep "p_color" | awk '{print $2}')
	c_color=$(cat $config_path | grep "c_color" | awk '{print $2}')
	w_color=$(cat $config_path | grep "w_color" | awk '{print $2}')
	e_color=$(cat $config_path | grep "e_color" | awk '{print $2}')
else
	# Utworzenie pliku konfiguracyjnego, jeśli ten nie istnieje
	echo -e "d_color: $d_color" > $config_path
	echo -e "p_color: $p_color" >> $config_path
	echo -e "c_color: $c_color" >> $config_path
	echo -e "w_color: $w_color" >> $config_path
	echo -e "e_color: $e_color" >> $config_path
fi

# Sformatowanie i ustawienie kolorów
d_color="\e[${d_color}"
p_color="\e[${p_color}"
c_color="\e[${c_color}"
w_color="\e[${w_color}"
e_color="\e[${e_color}"

#
#
#################################

# Messages
option() {
	echo -e "[ ${p_color}$1${d_color} ] $2"
}

success() {
	echo -e "[ ${p_color}+${d_color} ] $1"
}

warn() {
	echo -e "[ ${w_color}!${d_color} ] $1"
}

error() {
	echo -e "[ ${e_color}x${d_color} ] $1"
}

help() {
	echo -e "[ ${c_color}?${d_color} ] $1"
}

bad_choice() {
	error "Niepoprawny wybór"; sleep 1
}

pause() {
	echo -ne "Naciśnij [Enter], aby kontynuować..."; stty -echo; read pause_continue; stty echo; unset pause_continue
}

cd $(dirname $0)
script_loc=$(pwd)
script_path=$script_loc/$(basename $0)

git init >/dev/null 2>&1 # initialize git repository here

clear

run_script() {
	$executor $script_path $@ && exit
}

check_package() {
	if [ -z "$1" ]; then # if $1 not defined
		return -1
	else # if $1 defined
		if [ -x "$(command -v $1)" ]; then
			return 1 # package is installed
		else
			return 0 # package is not installed
		fi
	fi
}

install_package() {
	# instalacja pakietów dla różnych dystrybucji Linux (różne menadżery pakietów)

	if [ -z "$1" ]; then
		return -1
	else
		packagesToInstall="$1"
	fi

	
	echo Instalowanie wymaganych pakietów: "$packagesToInstall" ...

	if [ -x "$(command -v apk)" ]; then sudo apk add --no-cache $packagesToInstall
	elif [ -x "$(command -v apt-get)" ]; then sudo apt-get update -y; sudo apt-get install -y $packagesToInstall
	elif [ -x "$(command -v dnf)" ]; then sudo dnf install $packagesToInstall
	elif [ -x "$(command -v zypper)" ]; then sudo zypper install $packagesToInstall
	elif [ -x "$(command -v pacman)" ]; then sudo pacman -S $packagesToInstall
	elif [ -x "$(command -v yum)" ]; then sudo yum install $packagesToInstall
	elif [ -x "$(command -v snap)" ]; then sudo snap install $packagesToInstall
	else error "Nie udało się zainstalować żądanych pakietów. Zainstaluj je ręcznie: $packagesToInstall"; pause
	fi
}

requiredPackages=$(cat packages.txt) # read packages from file

for package in $requiredPackages; do
	# add each not installed package to the new variable
	check_package $package
	if [ "$?" = "0" ]; then # if checked package returns 0
		packageQueue+="$package "
	fi
done
if [ -x $(command -v arp)]; then
	packageQueue+="net-tools"
fi

if [ "$packageQueue" != "" ]; then # if $packageQueue is not empty
	# clear $packageQueue from whitespaces
	packageQueue=$(echo "$packageQueue" | xargs)
	install_package "$packageQueue" # install all missing packages
fi

title="echo -e === ${p_color}\e[1;4m$Name\e[00;00m${d_color} ===\n" # Tekst na górze okna terminala
echo -e "\e]2;${Name} (v$Ver) © Oliwer Pawelski\007" # Tytuł okna terminala

rewrite_line() {
	if [ "$1" = "-n" ]; then
		echo -ne "\r\033[K"
	else
		echo -e "\r\033[K$1"
	fi
}

cur() {
	if [ "$1" = "show" ]; then
		tput cnorm # show cursor
	elif [ "$1" = "hide" ]; then
		tput civis # hide cursor
	fi
}

cur show

cur_pos() {
	exec < /dev/tty
	oldstty=$(stty -g)
	stty raw -echo min 0
	# on my system, the following line can be replaced by the line below it
	echo -e "\033[6n" > /dev/tty
	# tput u7 > /dev/tty    # when TERM=xterm (and relatives)

	stty $oldstty
	echo $pos
	# change from one-based to zero based so they work with: tput cup $row $col
	row=$(echo $pos | cut -d';' -f1 | cut -d'+' -f1)
	echo $row
	col=$(echo $pos | cut -d';' -f2 | cut -d'+' -f2)
	echo $col
	cur_row=$row
	cur_col=$col
	return $cur_row $cur_col
}

prog_bar() {
	if [ "$1" = "end" ]; then
		rewrite_line "$(success 'Zakończono')"
		sleep 1
		break

	elif [ "$1" = "start" ]; then
		prog_start=$(vramsteg --now)

	elif [ "$1" = "stop" ]; then
		rewrite_line "-n"
		unset prog_start

	else
		if [ "$1" != "-c" ]; then
			rewrite_line "$1"
		fi

		if [ -z "$3" ]; then # if $3 not defined
			total=100
		else
			total=$3
		fi

		if [ "$prog_start" != "" ]; then
			vramsteg --style mono --min 0 --max $total --current $2 --percentage --start $prog_start --elapsed
		else
			vramsteg --style mono --min 0 --max $total --current $2 --percentage
		fi
	fi
}

hyperlink() {
	# Samodzielne użycie (jako polecenie):
	#
	# hyperlink https://example.com "Example" -> Rezultat: "Example"
	# - lub -
	# hyperlink https://example.com -> Rezultat: "https://example.com"
	
	# Użycie wewnątrz 'echo':
	#
	# echo -e "Przykładowy tekst $(hyperlink 'https://example.com' 'Example')" -> Rezultat: "Przykładowy tekst Example"
	# - lub -
	# echo -e "Przykładowy tekst $(hyperlink 'https://example.com')" -> Rezultat: "Przykładowy tekst https://example.com"

	if [ -z "$1" ]; then
		link=""
	else
		link="$1"
	fi

	if [ -z "$2" ]; then
		text="$link"
	else
		text="$2"
	fi

	# if $text and $link has content, then print hyperlink
	if [ "$link" != "" ]; then
		echo -e "\e]8;;${link}\a${text}\e]8;;\a"
	fi

	unset link text
}


# Procedura logowania
path_pw_stored="$HOME/.LekoTools.lock"
script_pw="b8de590b095e9e0f436211970b8e50937a7d3030dd602b2e08133e564172411224181c05c070c52888258f53ed9a714b5bdc9c89305213ceefbf9501f7cf9183"
stored_pw=$(cat $path_pw_stored 2>/dev/null)

clear && $title
if [ $1 ]; then
	if [ $1 = "incorrect_pw" ]; then
		error "Nieprawidłowe hasło"
	fi
fi

encryption() {
	sha512sum
}

if [ "$stored_pw" != "$script_pw" ]; then
	echo -ne "Podaj hasło: "; stty -echo; read input_pw; stty echo
	input_pw=$(echo $input_pw | encryption | awk '{print $1}')
	echo $input_pw > $path_pw_stored
else
	input_pw=$stored_pw
fi

clear
if [ "$input_pw" != "$script_pw" ]; then
	run_script "incorrect_pw"
fi

if [ "$1" = "-u" ]; then
	run_script 9 1
fi

# Sprawdzenie wersji / Aktualizacja
lekotools_update() {
	git config --global credential.helper store >/dev/null 2>&1 # permanently save git login data
	clear

	remote_repo="https://github.com/Guliveer/LekoTools.git" # URL of your remote repository
	remote_branch="main" # Name of the remote branch

	# if current dir is git
	if [ $(git rev-parse --is-inside-work-tree 2>/dev/null) ] && [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" != "$remote_branch" ]; then
		return 0 # not main branch
	fi

	clear

	download_file="/tmp/LekoTools/LekoTools.sh"
	download_dest="/tmp/LekoTools"

	rm -rf $download_dest 2>/dev/null
	mkdir -p $download_dest
	git clone $remote_repo $download_dest >/dev/null 2>&1

	if [ -f $download_file ]; then
		get_ver=$(grep "Ver=\"*\"" $download_file | awk '{print $1}' | sed "s/Ver=//g" | sed "s/\"//g" | sed "s/'//g")
		get_hash=$(grep "Ver_hash=\"*\"" $download_file | awk '{print $1}' | sed "s/Ver_hash=//g" | sed "s/\"//g" | sed "s/'//g")
	fi

	if [ "$get_ver" = "" ] || [ "$get_hash" = "" ]; then
		if [ "$1" = "update" ]; then
			error "Nie udało się pobrać informacji o najnowszej wersji"
			pause; clear
		fi
		return -1
	fi

	if [ "$get_ver" != "$Ver" ] || [ "$get_hash" != "$Ver_hash" ]; then
		if [ ! -f /tmp/.LekoTools.remind-later ]; then
			# code executed, if current version different from fetched
			clear && $title
			echo -e "Dostępna jest nowa wersja programu. Zaktualizować?"
			echo
			echo -e "[ ${p_color}T${d_color} ] Tak"
			echo -e "[ ${p_color}N${d_color} ] Nie, przypomnij później"
			read update
			case $update in
				[Tt]* | [Yy]* )
					cp -rf $download_dest/* $script_loc/
					mv -f $script_loc/LekoTools.sh $(basename $0) 2>/dev/null
					chmod -R +rw $script_loc/*
					chmod -R +x $script_loc/*.sh
					chmod +x $script_loc/modules/*.sh

					check_new_ver=$(grep "Ver=\"*\"" $script_loc/$(basename $0) | awk '{print $1}' | sed "s/Ver=//g" | sed "s/\"//g" | sed "s/'//g")
					check_new_hash=$(grep "Ver_hash=\"*\"" $script_loc/$(basename $0) | awk '{print $1}' | sed "s/Ver_hash=//g" | sed "s/\"//g" | sed "s/'//g")

					clear && $title
					if [ "$check_new_ver" = "$get_ver" ] || [ "$check_new_hash" = "$get_hash" ]; then
						success "Zaktualizowano do najnowszej wersji"
					else
						error "Wystąpił błąd podczas aktualizacji"
					fi
					echo
					pause

					if [ $1 ] && [ "$1" = "update" ]; then
						run_script 9
					else
						run_script
					fi
					;;
				[Nn]* )
					touch /tmp/.LekoTools.remind-later

					if [ $1 ] && [ "$1" = "update" ]; then
						run_script 9
					else
						run_script
					fi
					;;
			esac
		fi
	else
		if [ $1 ] && [ "$1" = "update" ]; then
			echo -e "Posiadasz już najnowszą wersję LekoTools"
			sleep 1
		fi
	fi

	rm -rf $download_dest 2>/dev/null
}

lekotools_update "$2"

# Commands
dev_ver="
	echo -e '[ ${p_color}Wersja systemu${d_color} ]';
	lsb_release -a;
	"

svc_status="
	echo -e '[ ${p_color}Status usług${d_color} ]';
	/usr/sbin/service --status-all;
	"

dev_time="
	echo -e '[ ${p_color}Czas systemowy${d_color} ]';
	date +'%H:%M:%S %Z%n%d/%m/%Y';
	"

svc_ntpds_restart="
	echo -e '[ ${w_color}!${d_color} ] Restartowanie usługi ntpd...';
	ln -sf /etc/init.d/ntpds /etc;
	ln -sf /etc/init.d/ntpds /etc/rc1.d/S52ntpds 2>/dev/null;
	/usr/sbin/service --enable ntpds 76;
	/usr/sbin/service ntpds --full-restart;

	echo -e '[ ${p_color}+${d_color} ] Zakończono';
	"

svc_ucm_restart="
	echo -e '[ ${w_color}!${d_color} ] Restartowanie usługi UCM...';
	/usr/sbin/service UCM --full-restart;
	echo -e '[ ${p_color}+${d_color} ] Zakończono';
	"

close_info="echo 'Wciśnij CTRL+C, aby zakończyć...'"

dev_restart() {
	sleep 2
	ssh root@$ip '/sbin/reboot'

	if [ -z $2 ]; then
		warn "Ponowne uruchamianie urządzenia..."
	else
		stage=$2
		
		if [ -z $3 ]; then
			total=100
		else
			total=$(($3+1))
		fi

		prog_bar "$(warn 'Ponowne uruchamianie urządzenia...')" $stage $total
	fi

	sleep 10
	while true; do
		if ping -c1 $ip > /dev/null; then
			break
		fi
	done

	if [ ! $1 ]; then
		sleep 40
	else
		sleep $1
	fi

	if [ -z $2 ]; then
		success 'Uruchomiono ponownie'
	else
		stage=$(($stage+1))
		prog_bar "$(success 'Uruchomiono ponownie')" $stage $total
	fi

	unset stage total
	sleep 2
}

connect() {
	clear && $title
	warn "Nawiązywanie połączenia..."

	if [ $(nmap --max-rtt-timeout 0.01 -sP 192.168.14.$1 2>/dev/null | grep 'Host is up' | wc -l) -gt 0 ]; then
		ip="192.168.14.$1"
		rm $HOME/.ssh/known_hosts; rm $HOME/.ssh/known_hosts.old; clear
		qp=$(ssh -o "StrictHostKeyChecking no" root@$ip '/bin/hostname' 2>/dev/null); clear
		return 1
		break

	elif [ $(nmap --max-rtt-timeout 0.01 -sP 192.168.20.$1 2>/dev/null | grep 'Host is up' | wc -l) -gt 0 ]; then
		ip="192.168.20.$1"
		rm $HOME/.ssh/known_hosts; rm $HOME/.ssh/known_hosts.old; clear
		qp=$(ssh -o "StrictHostKeyChecking no" root@$ip '/bin/hostname' 2>/dev/null); clear
		return 1
		break

	elif [ $(nmap --max-rtt-timeout 0.01 -sP 192.168.1.$1 2>/dev/null | grep 'Host is up' | wc -l) -gt 0 ]; then
		ip="192.168.1.$1"
		rm $HOME/.ssh/known_hosts; rm $HOME/.ssh/known_hosts.old; clear
		qp=$(ssh -o "StrictHostKeyChecking no" root@$ip '/bin/hostname' 2>/dev/null); clear
		return 1
		break

	else
		clear && $title
		error "Nie udało się nawiązać połączenia"
		sleep 2
		run_script
	fi
}

change_name() {
	ip=$1
	case $ip in
	192.168.*.190)
		there=$main
		;;
	192.168.*.191)
		there=$ext
		;;
	*)
		there=$2
		;;
	esac

	clear && $title
	echo -e "Sprawdzanie połączenia z [ ${w_color}${ip}${d_color} ]..."
	if ! ping -c1 $ip > /dev/null; then # Sprawdź czy urządzenie jest osiągalne
		error "Brak połączenia z urządzeniem"
		sleep 2
		run_script
	else 
		rm $HOME/.ssh/known_hosts; rm $HOME/.ssh/known_hosts.old; clear
		ssh -o "StrictHostKeyChecking no" root@$ip 'sleep 0' 2>/dev/null; clear
	fi

	qp1=$(ssh root@$ip '/bin/hostname')
	clear && $title
	echo -e "Połączono z [ ${w_color}$ip${d_color} ]"
	echo
	echo -e "Aktualne QP:${p_color}" $qp1; echo -ne "${d_color}"
	echo -ne "Podaj nowe QP (puste anuluje): ${p_color}QP-"; read qp2; echo -ne "${d_color}"
	qp2="QP-${qp2}"
	if [ "$qp2" = "QP-" ] || [ "$qp2" = "$qp1" ]; then
		run_script $there
	fi

	clear && $title
	echo -e "Połączono z [ ${w_color}$ip${d_color} ]"
	echo

	prog_bar "$(warn "Zmienianie nazwy urządzenia ${c_color}${qp1}${d_color} > ${c_color}${qp2}${d_color}...")" 0 10

	count_qp1=$(ssh root@$ip "find /etc -type f -exec grep -l '${qp1}' {} + | wc -l") # Policz wystąpienia nazwy początkowej
	prog_bar "-c" 1 10
	sleep 1
	ssh root@$ip "find /etc -type f -exec sed -i -e 's/${qp1}/${qp2}/g' {} \;" # Zmień nazwę urządzenia
	prog_bar "-c" 2 10
	sleep 1
	count_qp2=$(ssh root@$ip "find /etc -type f -exec grep -l '${qp2}' {} + | wc -l") # Policz wystąpienia nazwy docelowej

	prog_bar "$(success "Zmieniono ${c_color}${count_qp2}${d_color}/${c_color}${count_qp1}${d_color} wystąpień nazwy")" 3 10

	dev_restart 35 2 5 # Procedura ponownego uruchamiania

	prog_bar "$(warn 'Sprawdzanie poprawności nazwy...')" 95 100

	qp_update=$(ssh root@$ip '/bin/hostname') # Pobierz aktualną nazwę urządzenia
	if [ $qp_update = $qp2 ]; then # Sprawdź czy nazwa urządzenia została zmieniona
		rewrite_line "$(success 'Nazwa urządzenia została zmieniona')"
		sleep 2
	else
		rewrite_line "$(error 'Nazwa urządzenia nie została zmieniona')"
		pause
	fi

	run_script $there
}

send_attenuation() {
	name="$qp"
	dest_path="/etc/config/ccs"
	src_path="$HOME/PSD_Calibration"

	if [ ! -d "$src_path/$name" ]; then
		echo -ne "Podaj nazwę wprowadzoną w PSDCalib: ${p_color}"; read name; echo -e "${d_color}"
	fi

	# sprawdź czy plik istnieje
	if [ ! -f "$src_path/$name/attenuation.atn" ]; then
		error "Nie znaleziono żądanego pliku:"
		echo -e "${e_color}$src_path/$name/attenuation.atn${d_color}"
		echo
		pause
		return -1
	fi

	warn "Przesyłanie pliku ${p_color}${src_path}/${name}/attenuation.atn${d_color} do ${p_color}${ip}:${dest_path}/${d_color} ..."
	echo
	echo Status:
	scp $src_path/$name/attenuation.atn root@$ip:$dest_path
	echo
	success "Zakończono przesyłanie pliku"
	help "Po pomyślnym transferze uruchom ponownie urządzenie"
	echo
	pause
}

start_ssh() {
	echo "Łączenie z urządzeniem..."
	ssh root@$ip "echo $(help 'Wpisz \"exit\", aby rozłączyć')"
	ssh root@$ip
}

# Menu
main=1
ext=2
display=3
tester=4
router=5
# Start from argument
if [ -n $1 ]; then
	choice=$1
fi

echo -ne "${d_color}" # Ustaw na domyślny kolor

if [ ! $1 ]; then
	echo -n "Ładowanie urządzeń..."
	nmap --max-rtt-timeout 0.01 -sP 192.168.1,14,20.190,191,205,254 >/dev/null 2>&1 # Sprawdzenie jakie urządzenia są osiągalne

	ip_check_main=$(arp -an | grep -E "\(192\.168\.(14|20|1)\.190\).*\[(ether)\]")
	ip_check_ext=$(arp -an | grep -E "\(192\.168\.(14|20|1)\.191\).*\[(ether)\]")
	ip_check_disp_test=$(arp -an | grep -E "\(192\.168\.(14|20|1)\.205\).*\[(ether)\]")
	ip_check_router=$(arp -an | grep -E "\(192\.168\.(14|20|1)\.254\).*\[(ether)\]")
fi

clear && $title

echo -e "[ ${c_color}Menu główne${d_color} ]"
echo
echo -e "= Wybierz urządzenie ="

if [ $(echo $ip_check_main | grep "ether" | wc -l) -gt 0 ]; then
	option $main "Ładowarka / main"
else
	error "Ładowarka / main (Brak połączenia)"
fi

if [ $(echo $ip_check_ext | grep "ether" | wc -l) -gt 0 ]; then
	option $ext "Satelita / ext"
else
	error "Satelita / ext (Brak połączenia)"
fi

if [ $(echo $ip_check_disp_test | grep "ether" | wc -l) -gt 0 ]; then
	option $display "Wyświetlacz"
	option $tester "Tester"
else
	error "Wyświetlacz (Brak połączenia)"
	error "Tester (Brak połączenia)"
fi

if [ $(echo $ip_check_router | grep "ether" | wc -l) -gt 0 ]; then
	option $router "Router"
else
	error "Router (Brak połączenia)"
fi

echo
option F "Odśwież status"
echo
option 2137 "Opcje deweloperskie"
echo
option 9 "Ustawienia"
option 00 "Wyloguj i wyjdź"
if [ -z "$choice" ]; then
	echo -e "\n------\n"
	echo -ne "Wybór: ${p_color}"; read choice; echo -e "${d_color}"
	choice=$(echo $choice | tr '[:upper:]' '[:lower:]')
fi

# Menu
case $choice in
	$main)
		source modules/_main.sh
		;;
	$ext)
		source modules/_ext.sh
		;;
	$display)
		source modules/_display.sh
		;;
	$tester)
		source modules/_tester.sh
		;;
	$router)
		source modules/_router.sh
		;;
	f)
		run_script
		;;
	2137)
		source modules/_admin.sh
		;;
	9)
		source modules/_settings.sh
		;;
	00)
		rm $path_pw_stored
		clear; exit
		;;
	*)
		bad_choice
		run_script
		;;
esac

run_script # Jakby coś poszło nie tak, to wracamy do początku
