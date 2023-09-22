## docker-ros

> 可自行更换ros版本，本仓库使用的ros镜像为：osrf/ros:noetic-desktop-full，具体请参考`docker-ros-env`

本仓库含有两个文件`docker-ros-cmd`和`docker-ros-env`
其中`docker-ros-env`必须有，`docker-ros-cmd`可有可无

* `docker-ros-env`
    1. 建议把这个文件放在一个固定的位置，比如`~/.config/docker-ros/docker-ros-env.sh`
    2. 添加运行权限：`sudo chmod +X ~/.config/docker-ros/docker-ros-env.sh`
    3. 然后在`~/.bashrc`中添加`source ~/.config/docker-ros/docker-ros-env.sh`
    4. `source ~/.bashrc`
    5. 然后输入`docker-ros -h`就会有提示信息
    6. `docker-ros`命令会自动挂载运行该命令所在的文件夹，并挂载到`/mnt`文件夹下
    7. 可以自行修改`docker-ros-env`下的命令

* `docker-ros -h`：
  
    ```{.shell}
    docker-ros [option] cmd
 
      option:
          -s : create container based on osrf/ros
          -n=name : set container name
          -r=container_name : run a existed container
 
      eg(run image once):
          docker-ros roscore
          docker-ros -n=temp roscore
          docker-ros roslaunch pkg xxx.launch (automatically mount pwd directory) 
 
      eg(create container):
          docker-ros -s -n=name
          docker-ros -s -n=name bash
          docker-ros -s -n=name roscore
          docker-ros -s -n=mavros bash
 
      eg(run container):
          docker-ros -r=name roscore
          docker-ros -r=name rosrun turtlesim turtlesim_node
          docker-ros -r=mavros roslaunch mavros px4.launch fcu_url:="udp://:14540@127.0.0.1:14557"
 
      attach:
          涉及到显示的节点，需要在宿主机上先执行：xhost +
          目前只能支持独显，nvidia显卡不好使，没研究过
    ```

* `docker-ros-cmd`
    1. （如果用的上这个的话）需要将`docker-ros-cmd`和`src`放在同一个文件夹下，`docker-ros`会自动读取这个文件，没有该文件则忽略
    2. 这个脚本可以用来为容器安装程序需要的依赖库，会在创建容器的时候运行一次
    3. 也可以在每次开启容器运行一次，具体请看该文件内部具体代码
    4. 如果是需要编译代码的话，输出的`build`和`devel`是属于`root`的，没必要改，因为宿主机用不上这俩文件夹
    5. 比如mavros容器脚本如下：
        ```{.shell}
        #!/bin/bash
        shopt -s expand_aliases

        if [[ -f /start_container ]];then
            # 第二次进入容器时的命令，可以添加环境变量，或者干点别的，if里面不能空着，要不然报错
            echo "not first" > /dev/null
        else
            # 创建容器时的命令
            # 比如安装依赖库，编译，或者干点别的
            mkdir /temp && cd /temp
            apt-get update
            apt-get -y install ros-noetic-mavros ros-noetic-mavros-extras wget
            wget https://gitee.com/robin_shaun/XTDrone/raw/master/sitl_config/mavros/install_geographiclib_datasets.sh
            chmod a+x ./install_geographiclib_datasets.sh
            # 这一步需要一定的时间
            ./install_geographiclib_datasets.sh
            cd /mnt

            # 创建一个文件判断是第几次进入容器
            touch /start_container
        fi

        if [[ -d /mnt/devel ]];then
            source /mnt/devel/setup.bash
        fi
        
        exec "$@"
        ``` 
        * 运行：`docker-ros -s -n=mavros bash`创建容器
        * 运行：`docker-ros -r=mavros roslaunch mavros px4.launch fcu_url:="udp://:14540@127.0.0.1:14557"`启动mavros节点
