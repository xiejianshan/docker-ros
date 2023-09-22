#!/bin/bash
shopt -s expand_aliases

if [[ -f /start_container ]];then
    # 第二次进入容器时的命令，可以添加环境变量，或者干点别的，但if不能空着，不然会报错
    echo "not first" > /dev/null
else
    # 创建容器时的命令
    # 比如安装依赖库，编译，或者干点别的，没有的话就空着吧

    # 创建一个文件判断是第几次进入容器
    touch /start_container
fi

if [[ -d /mnt/devel ]];then
    source /mnt/devel/setup.bash
fi

exec "$@"