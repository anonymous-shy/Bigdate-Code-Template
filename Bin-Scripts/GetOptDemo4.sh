#!/bin/bash

# 定义选项列表
opts=":ab:c:d:"

# 解析命令行选项
args=$(getopt $opts "$@")

# 检查解析是否出错
if [ $? -ne 0 ]
then
    exit 1
fi

# 将解析结果存储到变量中
eval set -- "$args"

# 遍历解析结果
while true
do
    case $1 in
        -a)
            echo "Option -a is present"
            shift
            ;;
        -b)
            echo "Option -b is present with value $2"
            shift 2
            ;;
        -c)
            echo "Option -c is present with value $2"
            shift 2
            ;;
        -d)
            echo "Option -d is present with value $2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

# 处理剩余的参数
for arg in "$@"
do
    echo "Argument: $arg"
done
