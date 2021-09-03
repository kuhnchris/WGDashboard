#!/bin/bash

app_name="dashboard.py"
app_official_name="Wireguard Dashboard"
dashes='------------------------------------------------------------'
equals='============================================================'
help () {
  printf "<Wireguard Dashboard> by Donald Zou - https://github.com/donaldzou \n"
  printf "Usage: ./wgd.sh <option>"
  printf "\n \n"
  printf "Available options: \n"
  printf "    start: To start "app_official_name".\n"
  printf "    stop: To stop "app_official_name".\n"
  printf "    debug: To start "app_official_name" in debug mode (i.e run in foreground).\n"
  printf "    update: To update "app_official_name" to the newest version from GitHub.\n"
  printf "    install: To install "app_official_name".\n"
  printf "Thank you for using! Your support is my motivation ;) \n"
  printf "\n"
}

install_wgd(){
    # Check Python3 version
    version_pass=$(python3 -c 'import sys; print("1") if (sys.version_info.major == 3 and sys.version_info.minor >= 7) else print("0");')
    if [ $version_pass == "0" ]
      then printf "| Wireguard Dashboard required Python3.7+                  |\n"
      printf "%s\n" "$dashes"
      exit 1
    fi
    rm db/hi.txt >  /dev/null 2>&1
    if [ ! -d "log" ]
      then mkdir "log"
    fi
    printf "| Installing latest Python dependencies                    |\n"
    python3 -m pip install -r requirements.txt >  /dev/null 2>&1
    printf "| Wireguard Dashboard installed successfully!              |\n"
    printf "| Starting Dashboard                                       |\n"
    start_wgd
}


check_wgd_status(){
  if ps aux | grep '[p]ython3 '$app_name > /dev/null;
    then
      return 0
      else
        return 1
  fi
}

start_wgd () {
    printf "%s\n" "$dashes"
    printf "| Starting Wireguard Dashboard in the background.          |\n"
    d=$(date '+%Y%m%d%H%M%S')
    python3 "$app_name" > log/"$d".txt 2>&1 &
    printf "| Log files is under log/                                  |\n"
    printf "%s\n" "$dashes"
}

stop_wgd() {
  kill "$(ps aux | grep "[p]ython3 $app_name" | awk '{print $2}')"
}

start_wgd_debug() {
  printf "%s\n" "$dashes"
  printf "| Starting Wireguard Dashboard in the foreground.          |\n"
  python3 "$app_name"
  printf "%s\n" "$dashes"
}

update_wgd() {
  new_ver=$(python3 -c "import json; import urllib.request; data = urllib.request.urlopen('https://api.github.com/repos/donaldzou/wireguard-dashboard/releases/latest').read(); output = json.loads(data);print(output['tag_name'])")
  printf "%s\n" "$dashes"
  printf "| Are you sure you want to update to the %s? (Y/N): " "$new_ver"
  read up
  if [ "$up" = "Y" ]; then
    printf "| Shutting down Wireguard Dashboard...                     |\n"
    kill "$(ps aux | grep "[p]ython3 $app_name" | awk '{print $2}')"
    printf "| Downloading %s from GitHub...                            |\n" "$new_ver"
    git stash > /dev/null 2>&1
    git pull https://github.com/donaldzou/wireguard-dashboard.git $new_ver --force >  /dev/null 2>&1
    printf "| Installing latest Python dependencies                    |\n"
    python3 -m pip install -r requirements.txt >  /dev/null 2>&1
    printf "| Update Successfully!                                     |\n"
    start_wgd
  else
    printf "%s\n" "$dashes"
    printf "| Update Canceled.                                         |\n"
    printf "%s\n" "$dashes"
  fi
}


if [ "$#" != 1 ];
  then
    help
  else
    if [ "$1" = "start" ]; then
        if check_wgd_status; then
          printf "%s\n" "$dashes"
          printf "| Wireguard Dashboard is already running.                  |\n"
          printf "%s\n" "$dashes"
          else
            start_wgd
        fi
      elif [ "$1" = "stop" ]; then
        if check_wgd_status; then
            printf "%s\n" "$dashes"
            stop_wgd
            printf "| Wireguard Dashboard is stopped.                          |\n"
            printf "%s\n" "$dashes"
            else
              printf "%s\n" "$dashes"
              printf "| Wireguard Dashboard is not running.                      |\n"
              printf "%s\n" "$dashes"
        fi
      elif [ "$1" = "update" ]; then
        update_wgd
      elif [ "$1" = "install" ]; then
        install_wgd
      elif [ "$1" = "restart" ]; then
         if check_wgd_status; then
           stop_wgd
           sleep 2
           printf "| Wireguard Dashboard is stopped.                          |\n"
           start_wgd
        else
          start_wgd
        fi
      elif [ "$1" = "debug" ]; then
        if check_wgd_status; then
          printf "| Wireguard Dashboard is already running.                  |\n"
          else
            start_wgd_debug
        fi
      else
        help
    fi
fi

