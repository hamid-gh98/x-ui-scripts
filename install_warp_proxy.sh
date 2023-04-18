#!/bin/bash


AUTHOR="[hamid-gh98](https://github.com/hamid-gh98)"
VERSION="1.2.0"


#
# Version: 1.2.0
# Date Created: 2023-04-18
# Date Modified: 2023-05-30
# 
# Script: install_warp_proxy.sh
# 
# Description:
#   This script installs Warp Socks5 Proxy (WireProxy) for your system.
#   WireProxy is a secure and fast proxy service that routes your network traffic through Cloudflare's global network.
# 
# Author: [hamid-gh98](https://github.com/hamid-gh98)
# 
# Usage: bash ./install-warp-proxy.sh [-y] [-f]
# 
# Options:
#   -y      Accept default inputs.
#   -f      Force reinstallation of Warp Socks5 Proxy (WireProxy) even if it's already installed.
# 
# Note:
#   By default, the script checks whether Warp Socks5 Proxy (WireProxy) is already installed before proceeding.
#   Use the -y option to accept defaults.
#   Use the -f option to force reinstallation.
# 
# Thanks To: [fscarmen](https://github.com/fscarmen)
# 
# Supported OS:
#   1. Ubuntu
#   2. Debian
#   3. CentOS
#   4. Alpine
#   5. Arch
#   6. Oracle
#   7. Alma
#   8. Rocky
# 
# One-Line Command for installation: (use of this commands)
#   not-forced: `curl -fsSL https://gist.githubusercontent.com/hamid-gh98/dc5dd9b0cc5b0412af927b1ccdb294c7/raw/install_warp_proxy.sh | bash`
#   not-forced: `bash <(curl -sSL https://gist.githubusercontent.com/hamid-gh98/dc5dd9b0cc5b0412af927b1ccdb294c7/raw/install_warp_proxy.sh)`
#   forced: `bash <(curl -sSL https://gist.githubusercontent.com/hamid-gh98/dc5dd9b0cc5b0412af927b1ccdb294c7/raw/install_warp_proxy.sh) -yf`
# 


# Define colors
red="\e[31m\e[01m"
blue="\e[36m\e[01m"
green="\e[32m\e[01m"
yellow="\e[33m\e[01m"
bYellow="\e[1;33m"
plain="\e[0m"


# Draw ASCII-ART
function draw_ascii_art() {
  echo -e "
   ____  ____       _       ____    ____  _____  ______              ______  ____  ____    
  |_   ||   _|     / \     |_   \  /   _||_   _||_   _ \`.          .' ___  ||_   ||   _|  
    | |__| |      / _ \      |   \/   |    | |    | | \`. \ ______ / .'   \_|  | |__| |    
    |  __  |     / ___ \     | |\  /| |    | |    | |  | ||______|| |   ____  |  __  |     
   _| |  | |_  _/ /   \ \_  _| |_\/_| |_  _| |_  _| |_.' /        \ \`.___]  |_| |  | |_   
  |____||____||____| |____||_____||_____||_____||______.'          \`._____.'|____||____|  
  "
}


# ===============================
# ********** Variables **********
# ===============================
# General Variables
CAN_USE_TPUT=$(command -v tput >/dev/null 2>&1 && echo "true" || echo "false")
USE_DEFAULT="false"
FORCE="false"
SPIN_TEXT_LEN=0
SPIN_PID=
WP_INSTALL_PORT="40000"
WP_LISTENING_PORT=


# Status Variables
# STEP_STATUS ==>  (0: failed) | (1: success) 
# WP_STATUS ==>  (0: not installed) | (1: off) | (2: on)
STEP_STATUS=1
WP_STATUS=0


# OS Variables
OS_SYS=
OS_INDEX=
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine" "Arch")
RELEASE_REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux" "alpine" "arch linux")
PKG_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f" "pacman -Sy")
PKG_INSTALL=("apt -y --fix-broken install" "apt -y --fix-broken install" "yum -y install" "yum -y install" "apk add -f --no-cache" "pacman -S --noconfirm")


# ===============================
# *********** Message ***********
# ===============================
declare -A T
# base
T[000]="Option requires an argument:"
T[001]="Invalid option:"
T[002]="Invalid choice."
T[003]=""
T[004]=""
T[005]="[INFO]"
T[006]="[ALERT]"
T[007]="[ERROR]"
T[008]="[DEBUG]"
T[009]="[WARNING]"
# intro
T[010]="Thanks for using this script to install warp. \n  Please give a star on github if you find this script useful!"
T[011]="Version:"
T[012]="Author:"
T[013]=""
T[014]="Options:"
T[015]="Accept default values."
T[016]="Force reinstall Warp Socks5 Proxy (WireProxy)."
T[017]=""
T[018]=""
T[019]=""
T[020]="Useful Commands:"
T[021]="Uninstall Warp"
T[022]="Change Warp Account Type (free, plus, ...)"
T[023]="Turn on/off WireProxy"
T[024]=""
T[025]=""
T[026]=""
T[027]=""
T[028]=""
T[029]=""
T[030]=""
T[031]=""
T[032]=""
T[033]=""
T[034]=""
T[035]=""
T[036]=""
T[037]=""
T[038]=""
T[039]=""
# show_warnings
T[040]="You're using this options:"
T[041]="Accepting default values"
T[042]="Forcing reinstall Warp Socks5 Proxy (WireProxy)"
T[043]=""
T[044]=""
T[045]=""
T[046]=""
T[047]=""
T[048]=""
T[049]=""
# prompts
T[050]="Default"
T[051]="Exceeded maximum attempts. Exiting..."
T[052]="Remaining attempts:"
T[053]="Last attempt! Remaining attempt:"
T[054]="Please enter a port for"
T[055]="Oops! Invalid input. Please enter a port between 1 and 65535."
T[056]="Oops! The port is already in use. Please choose another port between 1 and 65535!"
T[057]="WireProxy"
T[058]=""
T[059]=""
# check_root
T[060]="Verifying root access..."
T[061]="Please run this script as root!"
T[062]="Great News! You have Superuser privileges. Let's continue..."
# check_os
T[063]="Verifying if your OS is supported..."
T[064]="Unfortunately, your OS is not supported at this time! \n  The script supports Debian, Ubuntu, CentOS, Arch or Alpine systems only.\n"
T[065]="Your os is compatible with this installation. Moving forward..."
# install_base_packages
T[066]="Installing essential packages for your OS..."
T[067]="There was an error during the installation of essential packages! \n  Please check your connection or try again later."
T[068]="All required packages have been successfully installed."
# warp_command
T[069]="Checking if [warp] command shortcut exists, and creating it if necessary..."
T[070]="Failed to create [warp] command shortcut! Please try again later."
T[071]="[warp] command shortcut created successfully."
T[072]="[warp] command shortcut is already set up."
# warp_status
T[073]="Checking WARP Status..."
T[074]="The WARP socks5 proxy (WireProxy) is already installed and currently running. \n  WARP is listening on socks5://127.0.0.1:"
T[075]="The WARP socks5 proxy (WireProxy) has already been installed, but it's currently not running."
T[076]="The WARP socks5 proxy (WireProxy) isn't installed yet. No worries, we'll take care of it."
# install_warp
T[077]="Installing WARP socks5 proxy (WireProxy)..."
T[078]="Sorry, the installation of WARP socks5 proxy (WireProxy) failed! Please try again later."
T[079]="You're all set! WARP socks5 proxy (WireProxy) has been installed and is ready to use. \n  WARP is listening on socks5://127.0.0.1:"
# start_warp
T[080]="Activating the WARP socks5 proxy (WireProxy)..."
T[081]="The WARP socks5 proxy (WireProxy) failed to start! Please try again later."
T[082]="The WARP socks5 proxy (WireProxy) is active and listening on socks5://127.0.0.1:"
# confirm reinstall_warp
T[083]="Do you want to proceed with reinstalling the WARP socks5 proxy?"
# reinstall_warp
T[084]="Performing a fresh installation of WARP socks5 proxy (WireProxy)..."
T[085]="Sorry, the reinstallation of WARP socks5 proxy (WireProxy) failed! Please try again later."
T[086]="Completed! WARP socks5 proxy (WireProxy) has been reinstalled and is ready to use. \n  WARP is listening on socks5://127.0.0.1:"
T[087]=""
T[088]=""
T[089]=""
T[090]=""
T[091]=""
T[092]=""
T[093]=""
T[094]=""
T[095]=""
T[096]=""
T[097]=""
T[098]=""
T[099]=""
T[100]=""


# ===============================
# ******** Base Function ********
# ===============================
# Get Options
while getopts ":yf" opt; do
  case ${opt} in
    f)
      FORCE="true"
      ;;
    y)
      USE_DEFAULT="true"
      ;;
    :)
      echo -e "  ${red}${T[000]} -${OPTARG}${plain}" 1>&2
      exit 1
      ;;
    \?)
      echo -e "  ${red}${T[001]} -${OPTARG}${plain}" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


function escaped_length() {
  # escape color from string
  local str="${1}"
  local stripped_len=$(echo -e "${str}" | sed 's|\x1B\[[0-9;]\{1,\}[A-Za-z]||g' | tr '\n' ' ' | wc -m)
  echo ${stripped_len}
}


function draw_line() {
  local line=""
  local width=$(( ${COLUMNS:-${CAN_USE_TPUT:+$(tput cols)}:-92} ))
  line=$(printf "%*s" "${width}" | tr ' ' '_')
  echo "${line}"
}


function confirm() {
  local question="${1}"
  local options="${2:-Y/n}"
  local RESPONSE=""
  read -rep "  > ${question} [${options}] " RESPONSE
  RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]') || return
  if [[ -z "${RESPONSE}" ]]; then
    case "${options}" in
      "Y/n") RESPONSE="y";;
      "y/N") RESPONSE="n";;
    esac
  fi
  # return (yes=0) (no=1)
  case "${RESPONSE}" in
    "y"|"yes") return 0;;
    "n"|"no") return 1;;
    *)
      echo -e "${red}${T[002]}${plain}"
      confirm "${question}" "${options}"
      ;;
  esac
}


function run_step() {
  {
    $@
  } &> /dev/null
}


# Spinner Function
function start_spin() {
  local spin_chars='/-\|'
  local sc=0
  local delay=0.1
  local text="${1}"
  SPIN_TEXT_LEN=$(escaped_length "${text}")
  # Hide cursor
  [[ "${CAN_USE_TPUT}" == "true" ]] && tput civis
  while true; do
    printf "\r  [%s] ${text}"  "${spin_chars:sc++:1}"
    sleep ${delay}
    ((sc==${#spin_chars})) && sc=0
  done &
  SPIN_PID=$!
  # Show cursor
  [[ "${CAN_USE_TPUT}" == "true" ]] && tput cnorm
}


function kill_spin() {
  kill "${SPIN_PID}"
  wait "${SPIN_PID}" 2>/dev/null
}


function end_spin() {
  local text="${1}"
  local text_len=$(escaped_length "${text}")
  run_step "kill_spin"
  if [[ ! -z "${text}" ]]; then
    printf "\r  ${text}"
    # Due to the preceding space in the text, we append '6' to the total length.
    printf "%*s\n" $((${SPIN_TEXT_LEN} - ${text_len} + 6)) ""
  fi
  # Reset Status
  STEP_STATUS=1
}


# Clean up if script terminated.
function clean_up() {
  # Show cursor && Kill spinner
  [[ "${CAN_USE_TPUT}" == "true" ]] && tput cnorm
  end_spin ""
}
trap clean_up EXIT TERM SIGHUP SIGTERM SIGKILL


# Check OS Function
function get_os_release() {
  local RELEASE_OS=
  local RELEASE_CMD=(
    "$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
    "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
    "$(lsb_release -sd 2>/dev/null)"
    "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
    "$(grep . /etc/redhat-release 2>/dev/null)"
    "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
  )

  for i in "${RELEASE_CMD[@]}"; do
    RELEASE_OS="${i}" && [[ -n "${RELEASE_OS}" ]] && break
  done

  echo "${RELEASE_OS}"
}


# Prompt Function
function prompt_port() {
  local for_text="${1}"
  local var_text="${2}"
  local attempts="${3:-0}"
  local check_occupied="${4:-false}"
  local default_port=""
  local error_msg=""

  # set defaults
  eval "default_port=\"\$${var_text}\""
  local ports_str="${default_port}"

  # remaining attempts
  local current_attempt=1
  local remaining_attempts=$((attempts - current_attempt + 1))
  local remaining_msg=""

  # array commands to check port occupation
  local check_cmds=(
    "ss:-nltp | grep -q"
    "lsof:-i"
  )

  # loop to get a correct port
  while true; do
    # reset error msg
    error_msg=""

    # calculate remaining attempts to show user
    remaining_attempts=$((attempts - current_attempt + 1))
    if [[ $remaining_attempts -gt 1 ]]; then
      remaining_msg="(${T[052]} ${remaining_attempts})"
    else
      remaining_msg="(${T[053]} ${remaining_attempts})"
    fi

    # ask user for input
    read -rep "  ${T[054]} ${for_text} (1-65535): `echo $'\n  > '` ${for_text} [${T[050]} '${default_port}'] ${remaining_msg}: " ports_str

    # Set default if input is empty
    if [[ -z "$ports_str" ]]; then
      ports_str=${default_port}
    fi

    # Check if port is a valid number between 1 and 65535
    is_invalid="false"
    if [[ ! "${ports_str}" =~ ^[0-9]+$ || ${ports_str} -lt 1 || ${ports_str} -gt 65535 ]]; then
      is_invalid="true"
      error_msg="${T[055]}"
    fi

    # Check if port is occupied
    if [[ "${check_occupied}" == "true" ]]; then
      for cmd_arg in "${check_cmds[@]}"; do
        IFS=':' read -r cmd args <<< "${cmd_arg}"
        if command -v "${cmd}" &> /dev/null; then
          if eval "${cmd} ${args} \":${ports_str}\"" &> /dev/null; then
            is_invalid="true"
            error_msg="${T[056]}"
            break
          fi
        fi
      done
    fi

    # if port is valid, set value and then break the loop
    if [[ "${is_invalid}" == "false" ]]; then
      eval "${var_text}=\$ports_str"
      break
    fi

    # check attempts
    if [[ ${attempts} -gt 0 && ${current_attempt} -ge ${attempts} ]]; then
      echo -e "  ${red}${T[051]}${plain}" 1>&2
      exit 1
    fi
    current_attempt=$((current_attempt + 1))

    # if invalid, show error
    echo -e "  ${red}${error_msg}${plain}"
  done
}


# ===============================
# ********** BaseSteps **********
# ===============================
function step_check_os() {
  for ((OS_INDEX=0; OS_INDEX<${#RELEASE_REGEX[@]}; OS_INDEX++)); do
    [[ $(get_os_release | tr '[:upper:]' '[:lower:]') =~ ${RELEASE_REGEX[OS_INDEX]} ]] \
    && export OS_SYS="${RELEASE[OS_INDEX]}" \
    && [ -n "${OS_SYS}" ] && break
  done
}


function step_install_pkgs() {
  {
    case "${OS_SYS}" in
      "Arch")
        ${PKG_UPDATE[OS_INDEX]}
        ;;
      *)
        ${PKG_UPDATE[OS_INDEX]}
        ${PKG_INSTALL[OS_INDEX]} wget net-tools
        ;;
    esac
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_create_command() {
  {
    mkdir -p /etc/wireguard
    wget -N -P /etc/wireguard https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh
    chmod +x /etc/wireguard/menu.sh
    ln -sf /etc/wireguard/menu.sh /usr/bin/warp
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_check_status() {
  WP_STATUS=0
  if [[ $(type -p wireproxy) ]]; then
    WP_STATUS=1
    if [[ $(ss -nltp) =~ wireproxy ]]; then
      WP_STATUS=2
      WP_LISTENING_PORT=$(ss -nltp | grep 'wireproxy' | awk '{print $(NF-2)}' | cut -d: -f2)
    fi
  fi
}


function step_install_warp() {
  warp w <<< $'1\n1\n'"${WP_INSTALL_PORT}"$'\n1\n'
  [[ $? -ne 0 ]] && STEP_STATUS=0 || STEP_STATUS=1
}


function step_start_warp() {
  systemctl start wireproxy
  sleep 2
}


function step_reinstall_warp() {
  {
    warp u <<< $'y\n'
    run_step "step_create_command"
    warp w <<< $'1\n1\n'"${WP_INSTALL_PORT}"$'\n1\n'
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0 || STEP_STATUS=1
}


# ===============================
# ************ Steps ************
# ===============================
function intro() {
  echo -e "${blue}
$(draw_line)
$(draw_line)
$(draw_ascii_art)
${plain}
  ${green}${T[011]}${plain} ${bYellow}${VERSION}${plain}
  ${green}${T[012]}${plain} ${bYellow}${AUTHOR}${plain}

  ${blue}${T[010]}${plain}

  ${red}${T[014]}${plain}
    ${green}-y${plain}     => ${bYellow}${T[015]}${plain}
    ${green}-f${plain}     => ${bYellow}${T[016]}${plain}

  ${red}${T[020]}${plain}
    ${green}warp u${plain} => ${bYellow}${T[021]}${plain}
    ${green}warp a${plain} => ${bYellow}${T[022]}${plain}
    ${green}warp y${plain} => ${bYellow}${T[023]}${plain}
${blue}
$(draw_line)
$(draw_line)
${plain}"
}


function show_warnings() {
  local should_show="false"
  local alert_msgs=()
  local alert_vars=(
    "USE_DEFAULT:-y:T[041]"
    "FORCE:-f:T[042]"
  )

  # loop through options variables and check if they exist, add to final message
  for alert in "${alert_vars[@]}"; do
    IFS=':' read -r var option message <<< "${alert}"
    if [[ "${!var}" == "true" ]]; then
      should_show="true"
      alert_msgs+=("    ${red}${option}${plain}   =>   ${blue}${!message}${plain}")
    fi
  done

  # if there is any message to show, echo it
  if [[ "${should_show}" == "true" ]]; then
    echo -e "  ${yellow}${T[006]} ${T[040]}${plain}"
    for msg in "${alert_msgs[@]}"; do
      echo -e "${msg}"
    done
    echo ""
  fi
}


function check_root() {
  start_spin "${yellow}${T[060]}${plain}"
  [[ $EUID -ne 0 ]] && end_spin "${red}${T[007]} ${T[061]}${plain}" && exit 1
  end_spin "${green}${T[062]}${plain}"
}


function check_os() {
  start_spin "${yellow}${T[063]}${plain}"
  run_step "step_check_os"
  if [[ -z "${OS_SYS}" ]]; then
    end_spin "${red}${T[007]} ${T[064]}${plain}" && exit 1
  fi
  if echo "${OS_SYS}" | grep -qiE "debian|ubuntu"; then
    export DEBIAN_FRONTEND="noninteractive"
  fi
  end_spin "${green}${T[065]}${plain}"
}


function prompt_all() {
  local attempts=5
  local check_occupied=$( [[ "${WP_STATUS}" == "0" ]] && echo "true" || echo "false" )
  [[ "${USE_DEFAULT}" == "false" ]] && prompt_port "${T[057]}" "WP_INSTALL_PORT" "${attempts}" "${check_occupied}"
}


function install_base_packages() {
  start_spin "${yellow}${T[066]}${plain}"
  run_step "step_install_pkgs"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[067]}${plain}" && exit 1
  fi
  end_spin "${green}${T[068]}${plain}"
}


function warp_command() {
  start_spin "${yellow}${T[069]}${plain}"
  if ! command -v warp &> /dev/null; then
    run_step "step_create_command"
    if [[ "${STEP_STATUS}" -eq 0 ]]; then
      end_spin "${red}${T[007]} ${T[070]}${plain}" && exit 1
    fi
    end_spin "${green}${T[071]}${plain}"
  else
    end_spin "${green}${T[072]}${plain}"
  fi
}


function warp_status() {
  start_spin "${yellow}${T[073]}${plain}"
  run_step "step_check_status"
  case "${WP_STATUS}" in
    2)
      end_spin "${green}${T[074]}${WP_LISTENING_PORT}${plain}"
      ;;
    1)
      end_spin "${yellow}${T[075]}${plain}"
      ;;
    0)
      end_spin "${yellow}${T[076]}${plain}"
      ;;
  esac
}


function install_warp() {
  start_spin "${yellow}${T[077]}${plain}"
  run_step "step_install_warp"
  run_step "step_check_status"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[078]}${plain}" && exit 1
  fi
  end_spin "${green}${T[079]}${WP_LISTENING_PORT}${plain}\n"
}


function start_warp() {
  start_spin "${yellow}${T[080]}${plain}"
  run_step "step_start_warp"
  run_step "step_check_status"
  if [[ "${WP_STATUS}" -ne 2 ]]; then
    end_spin "${red}${T[007]} ${T[081]}${plain}" && exit 1
  fi
  end_spin "${green}${T[082]}${WP_LISTENING_PORT}${plain}\n"
}


function reinstall_warp() {
  start_spin "${yellow}${T[084]}${plain}"
  run_step "step_reinstall_warp"
  run_step "step_check_status"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[085]}${plain}" && exit 1
  fi
  end_spin "${green}${T[086]}${WP_LISTENING_PORT}${plain}\n"
}


# ===============================
# ************* Run *************
# ===============================
clear
intro
show_warnings
check_root
check_os
install_base_packages
warp_command
warp_status
case "${WP_STATUS}" in
  0)
    prompt_all
    install_warp
    ;;
  1|2)
    [[ "${FORCE}" == "false" ]] && ! confirm "${T[083]}" "y/N" && exit 0
    prompt_all
    reinstall_warp
    run_step "step_check_status"
    [[ "${WP_STATUS}" -eq 1 ]] && start_warp
    ;;
esac


# END
clean_up
# END

