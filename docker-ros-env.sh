#!/bin/bash
# set -e
function docker-ros() {
    local stable=true
    local name=""
    local start_container_name=""
    while getopts "r:n:hs" opt
    do
        case "$opt" in
            s)
                stable=false
                ;;
            n)
                name=${OPTARG:1:${#OPTARG}-1}
                ;;
            r)
                start_container_name=${OPTARG:1:${#OPTARG}-1}
                ;;
            h)
                echo 'docker-ros [option] cmd'
                echo ' '
                echo '      option:'
                echo '          -s : create container based on osrf/ros'
                echo '          -n=name : set container name'
                echo '          -r=container_name : run a existed container'
                echo ' '
                echo '      eg(run image once):'
                echo '          docker-ros roscore'
                echo '          docker-ros -n=temp roscore'
                echo '          docker-ros roslaunch pkg xxx.launch (automatically mount pwd directory) '
                echo ' '
                echo '      eg(create container):'
                echo '          docker-ros -s -n=name'
                echo '          docker-ros -s -n=name bash'
                echo '          docker-ros -s -n=name roscore'
                echo '          docker-ros -s -n=mavros bash'
                echo ' '
                echo '      eg(run container):'
                echo '          docker-ros -r=name roscore'
                echo '          docker-ros -r=name rosrun turtlesim turtlesim_node'
                echo '          docker-ros -r=mavros roslaunch mavros px4.launch fcu_url:="udp://:14540@127.0.0.1:14557"'
                echo ' '
                echo '      attach:'
                echo '          涉及到显示的节点，需要在宿主机上先执行：xhost +'
                echo '          目前只能支持独显，nvidia显卡不好使，没研究过'
                return
                ;;
            \?)
                echo "only -s -n -r is supported"
                return
                ;;
        esac
    done

    shift $((OPTIND-1))

    if [[ "$start_container_name" ]];then
        echo "\e[32mstart container : $start_container_name \e[0m"
        echo " "
        docker start "$start_container_name" > /dev/null
        cmd_file=$(docker exec -it mavros ls | grep docker-ros-cmd.sh)
        if [[ "$cmd_file" ]];then
            docker exec -it "$start_container_name" /ros_entrypoint.sh ./docker-ros-cmd.sh "$@"
        else
            docker exec -it "$start_container_name" /ros_entrypoint.sh "$@"
        fi
        echo " "
        echo "\e[32myou can stop container : docker stop $start_container_name \e[0m"
    else
        if [[ -f docker-ros-cmd.sh ]];then
            docker run -it --rm="$stable" --name="$name" --privileged -v="`pwd`:/mnt" -w="/mnt" --env=LOCAL_USER_ID="$(id -u)" -v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY=:0 --network host osrf/ros:noetic-desktop-full ./docker-ros-cmd.sh "$@"
        else
            docker run -it --rm="$stable" --name="$name" --privileged -v="`pwd`:/mnt" -w="/mnt" --env=LOCAL_USER_ID="$(id -u)" -v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY=:0 --network host osrf/ros:noetic-desktop-full "$@"
        fi
    fi
}