#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

ping_host_string="@ping_host"

ping_host_default="8.8.8.8"
ping_count=3
ping_wait_time=10

ping_log_file="/tmp/tmux_ping.log"
ping_result_file="/tmp/tmux_ping_result"
ping_pid_file="/tmp/tmux_ping.pid"

ping_not_running() {
    local pid=$(cat $ping_pid_file)
    ! ps -p $pid > /dev/null
}

read_cached_result() {
    if [ -e $ping_result_file ]; then
        cat $ping_result_file
    else
        echo -1
    fi
}

read_ping_result() {
    result=$( cut -sd / -f 5 $ping_log_file | cut -d . -f 1 )

    if is_number $result; then
        echo $result
    else
        echo -1
    fi
}

update_cached_result() {
    echo "$1" > $ping_result_file
}

execute_ping() {
    if is_osx; then
        local timeout_flag="-t"
    else
        local timeout_flag="-w"
    fi
    if is_cygwin; then
        local number_pings_flag="-n"
    else
        local number_pings_flag="-c"
    fi

    local ping_host="$(get_tmux_option "$ping_host_string" \
      "$ping_host_default")"

    ping $number_pings_flag $ping_count \
      $timeout_flag $ping_wait_time \
      $ping_host > $ping_log_file &

    echo "$!" > $ping_pid_file
}

colorize_ping_value() {
    local ping=$1
    local result

    if [ $ping -eq -1 ] || [ $ping -ge 100 ]; then
        result="#[default fg=red reverse]"
    elif [ $ping -lt 25 ]; then
        result="#[fg=default]"
    elif [ $ping -lt 50 ]; then
        result="#[fg=yellow]"
    elif [ $ping -lt 100 ]; then
        result="#[fg=brightyellow]"
    elif [ $ping -lt 1000 ]; then
        result="#[fg=red]"
    fi

    echo $result
}

format_ping_value() {
    local value=$1
    local result

    if [ $value -eq -1 ]; then
        result="× "
    elif [ $value -ge 1000 ]; then
        result=$(min $value 9999)
        result=$(($result / 1000))
        result=">$result"K
    elif [ $value -ge 100 ]; then
        result=$(min $value 99)
    else
        result=$( printf %2d $value )
    fi

    echo "$(colorize_ping_value $value $result) $result"
}

main () {
    local ping_result

    if ping_not_running; then
        ping_result=$(read_ping_result)
        update_cached_result $ping_result

        execute_ping
    else
        ping_result=$(read_cached_result)
    fi

    ping_result="$(format_ping_value $ping_result)"
    echo "$ping_result"
}
main
