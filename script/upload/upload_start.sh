#!/usr/bin/env bash

ec2_host=ec2-52-37-99-80.us-west-2.compute.amazonaws.com
pem_file=~/upload_log4ec2/wty.pem

sleep_second=10

access_name=access.log
account_service_name=accounts_service.log
error_name=error.log
unicorn_stderr_name=unicorn.stderr.log
sales_funnel_name=sales_funnel.log

access_path=/var/log/nginx/"$access_name"
account_service_path=/var/log/"$account_service_name"
error_path=/var/log/nginx/"$error_name"
account_service_unicorn_stderr_path=/usr/share/nginx/accounts_service/log/"$unicorn_stderr_name"
sales_funnel_unicorn_stderr_path=/usr/share/nginx/sales_refresh_app/log/"$unicorn_stderr_name"
sales_funnel_path=/var/log/"$sales_funnel_name"


function upload(){
    DAY=$(date -d "$D" '+%d')

    #empty file
    if [ ! -s "$1" ]
    then
        return
    fi

    last_time_last_line=""

    while [ 1 ]
    do
        this_time_last_line="$(tail -n 1 ""$1"")"
        #first time run | too much log in 1 minute
    #    echo "access_this_time_last_line: ""$access_this_time_last_line"
    #    echo "access_last_time_last_line: ""$access_last_time_last_line"
        if [ -z "$last_time_last_line" ] || ! cat "$1" | grep -Fxq "$last_time_last_line"
        then
            cat "$1" | ssh -o StrictHostKeychecking=no -i "$pem_file" ubuntu@"$ec2_host" 'cat >> ~/'$3_$2
            echo "$1" uploaded - all
        elif [ "$last_time_last_line" == "$this_time_last_line" ]
        then
            echo "$1" uploaded - nothing
        else
            grep -Fx -A1000000 "$last_time_last_line" $1 | awk '{if(NR>1)print}' | ssh -o StrictHostKeychecking=no -i "$pem_file" ubuntu@"$ec2_host" 'cat >> ~/'$3_$2
            echo "$1" uploaded - part
        fi
        last_time_last_line="$this_time_last_line"
        sleep "$sleep_second"
    done
}

#common log file
upload "$access_path" "$access_name" "$1" &
upload "$error_path" "$error_name" "$1" &

if [ "$1" == "as" ]
then
    echo as..............
    #account service special
    upload "$account_service_path" "$account_service_name" "$1" &
    upload "$account_service_unicorn_stderr_path" "$unicorn_stderr_name" "$1" &
else
    echo sf..............
    #sales funnel special
    upload "$sales_funnel_path" "$sales_funnel_name" "$1" &
    upload "$sales_funnel_unicorn_stderr_path" "$unicorn_stderr_name" "$1" &
fi

echo account service 4 log file upload to ec2 running...

# 问题1:access.log是只记录一天的内容,轮询有一定时间间隔,一天的最后几秒的记录可能不会被记录
# 问题2:搜索效率,从底部开始搜索,现在是顶部开始