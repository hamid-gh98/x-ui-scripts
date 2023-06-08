#!/bin/bash


AUTHOR="[hamid-gh98](https://github.com/hamid-gh98)"
VERSION="1.0.0"


#
# Version: 1.0.0
# Date Created: 2023-06-08
# Date Modified: 2023-06-08
# 
# Script: build_3x-ui.sh
# 
# Description:
#   The script clones the 3x-ui repository and manually builds the 3x-ui panel.
#   (https://github.com/MHSanaei/3x-ui)
# 
# Author: [hamid-gh98](https://github.com/hamid-gh98)
# 
# Usage: bash ./build_3x-ui.sh
# 
# Thanks To: [MHSanaei](https://github.com/MHSanaei)
# 
# Supported OS:
#   1. Ubuntu
#   2. Debian
#   3. CentOS
#   4. Arch
#   5. Alma
#   6. Rocky
# 
# One-Line Command for installation: (use of this commands)
#   `bash <(curl -sSL ...)`
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
CAN_USE_TPUT="false"
ARCH=$(uname -m)
SPIN_TEXT_LEN=0
SPIN_PID=


# Install variables
GO_VERSION=""
GO_ROOT="/usr/local/go"
GO_BIN="${GO_ROOT}/bin"
GO_FILE=""
GO_ARCH=""
XRAY_NAME=""
XRAY_ARCH=""
TEMP_FOLDER="/temp/3x-ui"
ROOT_FOLDER="/usr/local/x-ui"
BIN_FOLDER="${ROOT_FOLDER}/bin"
DB_FOLDER="/etc/x-ui"

# Status Variables
# STEP_STATUS ==>  (0: failed) | (1: success) 
STEP_STATUS=1

# OS Variables
OS_SYS=
OS_INDEX=
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS")
RELEASE_REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux")
PKG_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update")
PKG_INSTALL=("apt -y --fix-broken install" "apt -y --fix-broken install" "yum -y install" "yum -y install")
PKG_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove")


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
T[010]="Thanks for using this script . \n  Please give a star on github if you find this script useful!"
T[011]="Version:"
T[012]="Author:"
T[013]=""
T[014]="Options:"
T[015]=""
T[016]=""
T[017]=""
T[018]=""
T[019]=""
# alert_install
T[020]="** Caution **"
T[021]="You are about to uninstall the '3x-ui' panel (if installed) \n  and manually build and install it from the repo.\n  If you want to abort this process, exit this script by pressing 'Ctrl + C' NOW!"
T[022]=""
T[023]=""
T[024]=""
# prompts for Run stage => install go and 3x-ui
T[025]="Are you sure you want to manually build and instal the '3x-ui' panel?"
T[026]="Do you want to reinstall the latest version of 'go'? (It's required to build the '3x-ui' panel)"
T[027]="Do you want to uninstall 'go'?"
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
T[041]=""
T[042]=""
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
T[057]=""
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
# make_folders
T[069]="Making necessary folders..."
T[070]="Failed to make required folders!"
T[071]="Made required folder successfully. Moving forward..."
# uninstall_go
T[072]="Unstalling 'go'..."
T[073]="Failed to uninstall 'go'!"
T[074]="Successfully uninstalled 'go'."
# install_go
T[075]="Installing 'go'..."
T[076]="Failed to install 'go'!"
T[077]="Successfully installed 'go'."
# uninstall_3xui
T[078]="Unstalling '3x-ui'..."
T[079]="Failed to uninstall '3x-ui'!"
T[080]="Successfully uninstalled '3x-ui'."
# install_3xui
T[081]="Installing '3x-ui'..."
T[082]="Failed to install '3x-ui'!"
T[083]="Successfully installed '3x-ui'."


# ===============================
# ******** Base Function ********
# ===============================
# Get Options
while getopts ":" opt; do
  case ${opt} in
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


function generate_random_string() {
  local length="${1}"
  local chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  local text=""

  for (( i=0; i<${length}; i++ )); do
    local idx=$(( RANDOM % ${#chars} ))
    local rnd_char=${chars:${idx}:1}
    text="${text}${rnd_char}"
  done

  echo "${text}"
}


function check_command() {
  local cmd="${1}"
  command -v "${cmd}" >/dev/null 2>&1 && echo "true" || echo "false"
}


# Check for global needed commands and randoms
CAN_USE_TPUT=$(check_command tput)


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
  # Clear temp folder
  rm -rf ${TEMP_FOLDER}
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
    ${PKG_UPDATE[OS_INDEX]}
    ${PKG_UNINSTALL[OS_INDEX]} golang-go
    ${PKG_INSTALL[OS_INDEX]} bash nano curl gcc unzip wget certbot

    if [[ "${ARCH}" == "aarch64" ]]; then
      ${PKG_INSTALL[OS_INDEX]} gcc-aarch64-linux-gnu
      export CC=aarch64-linux-gnu-gcc
    fi

    if [[ "${ARCH}" == "aarch64" ]]; then
      GO_ARCH="arm64"
      XRAY_NAME="arm64"
      XRAY_ARCH="arm64-v8a"
    else 
      GO_ARCH="amd64"
      XRAY_NAME="amd64"
      XRAY_ARCH="64"
    fi
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_make_folders() {
  {
    rm -rf ${TEMP_FOLDER}
    mkdir -p ${TEMP_FOLDER}/{ver,clone}
    mkdir -p ${BIN_FOLDER}
    mkdir -p ${DB_FOLDER}
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_uninstall_go() {
  {
    # uninstall from package and remove folders
    ${PKG_UNINSTALL[OS_INDEX]} golang-go
    rm -rf ${GOPATH}
    rm -rf ${GOROOT}
    rm -rf ${GO_ROOT}

    # remove from shell files
    local bash_files=(
      "~/.bash_profile"
      "~/.profile"
      "~/.bashrc"
      "~/.zshrc"
    )
    for bf in "${bash_files[@]}"; do
      if [[ -f "${bf}" ]]; then
        sed -i '|# GoLang|d' ${bf}
        sed -i '|export GOROOT|d' ${bf}
        sed -i '|:$GOROOT|d' ${bf}
        sed -i '|export GOPATH|d' ${bf}
        sed -i '|:$GOPATH|d' ${bf}
        source ${bf}
      fi
    done

    # remove form path
    export PATH=$(echo "${PATH}" | sed -e "s|:${GO_BIN}||")
    export PATH=$(echo "${PATH}" | sed -e "s|${GO_BIN}:||")
    export PATH=$(echo "${PATH}" | sed -e "s|${GO_BIN}||")
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_install_go() {
  {
    cd ${TEMP_FOLDER}/ver

    # check for latest version of go
    local GO_TEMP_VER="go-temp-ver.html"
    if [[ -z "${GO_VERSION}" ]]; then
      wget https://github.com/golang/go/tags -O ${GO_TEMP_VER}
      GO_VERSION=$(cat ${GO_TEMP_VER} | grep -o 'go[0-9]*\.[0-9]*\.[0-9]*' | sort -r | head -1 | tr -d '[:space:]\r\n')
    fi

    # install go
    GO_FILE="${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    wget "https://go.dev/dl/${GO_FILE}"
    tar -C /usr/local -xzvf "${GO_FILE}"
    rm -rf ${TEMP_FOLDER}/ver

    # add go to path if not exists
    if ! echo "${PATH}" | grep -q "go/bin"; then
      export PATH="${PATH}:${GO_BIN}"
    fi
    go version
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_uninstall_3xui() {
  {
    if [[ -f /etc/systemd/system/x-ui.service ]];then
      systemctl stop x-ui
      systemctl disable x-ui
      rm -f /etc/systemd/system/x-ui.service
    fi
    systemctl daemon-reload
    systemctl reset-failed
    rm -rf ${ROOT_FOLDER}
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
}


function step_build_3xui() {
  {
    cd ${TEMP_FOLDER}/clone
    git clone https://github.com/MHSanaei/3x-ui .

    export CGO_ENABLED="1"
    export GOOS="linux"
    export GOARCH="${GO_ARCH}"

    go build main.go
    mv main ${ROOT_FOLDER}/x-ui

    cd ${BIN_FOLDER}
    rm -f iran.dat geoip.dat geosite.dat
    wget -O Xray-linux-${XRAY_ARCH}.zip "https://github.com/mhsanaei/Xray-core/releases/latest/download/Xray-linux-${XRAY_ARCH}.zip"
    unzip -o "Xray-linux-${XRAY_ARCH}.zip"
    rm -f "Xray-linux-${XRAY_ARCH}.zip" iran.dat geoip.dat geosite.dat LICENSE README.md
    wget -O geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
    wget -O geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
    wget -O iran.dat https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat

    mv xray "xray-linux-${XRAY_NAME}"
    mv ${TEMP_FOLDER}/clone/x-ui.sh /usr/bin/x-ui

    chmod +x \
      "/usr/bin/x-ui"\
      "${ROOT_FOLDER}/x-ui"\
      "${BIN_FOLDER}/xray-linux-${XRAY_NAME}"

    touch "${ROOT_FOLDER}/access.log"
    touch "${ROOT_FOLDER}/error.log"

    cat <<- EOF > /etc/systemd/system/x-ui.service
[Unit]
Description=x-ui Service
After=network.target
Wants=network.target

[Service]
Environment="XRAY_VMESS_AEAD_FORCED=false"
Type=simple
WorkingDirectory=${ROOT_FOLDER}/
ExecStart=${ROOT_FOLDER}/x-ui
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    if [[ ! -f "${DB_FOLDER}/x-ui.db" ]]; then
      "${ROOT_FOLDER}/x-ui" setting -username "admin" -password "admin"
      "${ROOT_FOLDER}/x-ui" setting -port 2053
      "${ROOT_FOLDER}/x-ui" migrate
    fi

    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
  }
  [[ $? -ne 0 ]] && STEP_STATUS=0
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
${blue}
$(draw_line)
$(draw_line)
${plain}"
}


function show_warnings() {
  local alert_vars=()

  # loop through options variables and check if they exist, add to final message
  local alert_msgs=()
  for alert in "${alert_vars[@]}"; do
    IFS=':' read -r var option message <<< "${alert}"
    if [[ "${!var}" == "true" ]]; then
      alert_msgs+=("    ${red}${option}${plain}   =>   ${blue}${!message}${plain}")
    fi
  done

  # if there is any message to show, echo it
  if [[ ${#alert_msgs[@]} -gt 0 ]]; then
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


function install_base_packages() {
  start_spin "${yellow}${T[066]}${plain}"
  run_step "step_install_pkgs"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[067]}${plain}" && exit 1
  fi
  end_spin "${green}${T[068]}${plain}"
}


function make_folders() {
  start_spin "${yellow}${T[069]}${plain}"
  run_step "step_make_folders"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[070]}${plain}" && exit 1
  fi
  end_spin "${green}${T[071]}${plain}"
}


function alert_install() {
  echo -e "

  ${red}${T[020]}${plain}
  ${bYellow}${T[021]}${plain}
  ${red}${T[020]}${plain}

"
}


function uninstall_go() {
  start_spin "${yellow}${T[072]}${plain}"
  run_step "step_uninstall_go"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[073]}${plain}" && exit 1
  fi
  end_spin "${green}${T[074]}${plain}"
}


function install_go() {
  start_spin "${yellow}${T[075]}${plain}"
  run_step "step_install_go"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[076]}${plain}" && exit 1
  fi
  end_spin "${green}${T[077]}${plain}"
}


function uninstall_3xui() {
  start_spin "${yellow}${T[078]}${plain}"
  run_step "step_uninstall_3xui"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[079]}${plain}" && exit 1
  fi
  end_spin "${green}${T[080]}${plain}"
}


function install_3xui() {
  start_spin "${yellow}${T[081]}${plain}"
  run_step "step_build_3xui"
  if [[ "${STEP_STATUS}" -eq 0 ]]; then
    end_spin "${red}${T[007]} ${T[082]}${plain}" && exit 1
  fi
  end_spin "${green}${T[083]}${plain}"
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
make_folders

alert_install
if confirm "${T[025]}" "y/N"; then
  if [[ $(check_command "go") == "false" ]] || confirm "${T[026]}" "Y/n"; then
    uninstall_go
    install_go
  fi

  uninstall_3xui
  install_3xui

  confirm "${T[027]}" "Y/n" && uninstall_go
fi

# END
clean_up
# END

