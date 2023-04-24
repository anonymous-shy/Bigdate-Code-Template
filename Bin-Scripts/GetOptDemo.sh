#!/bin/bash

# 使用 "$@" 来让每个命令行参数扩展为一个单独的单词。 "$@" 周围的引号是必不可少的！
# 使用 getopt 整理参数
ARGS=$(getopt -o 'u:p:n:vl::' -l 'username:,password:,port:,verbose,log-level::' -- "$@")

if [ $? != 0 ] ; then echo "Parse error! Terminating..." >&2 ; exit 1 ; fi

# 将参数设置为 getopt 整理后的参数
# $ARGS 需要用引号包围
eval set -- "$ARGS"

# 循环解析参数
while true ; do
     # 从第一个参数开始解析
     case "$1" in
          # 用户名，需要带参数值，所以通过 $2 取得参数值，获取后通过 shift 清理已获取的参数
          -u|--username) CONN_USERNAME="$2" ; shift 2 ;;
          # 密码，获取规则同上
          -p|--password) CONN_PASSWORD="$2" ; shift 2 ;;
          # 端口，获取规则同上
          -n|--port) CONN_PORT="$2" ; shift 2 ;;
          # 是否显示详情，开关型参数，带上该选项则执行此分支
          -v|--verbose) CONN_SHOW_DETAIL=true ; shift ;;
          # 日志级别，默认值参数
          # 短格式：-l3
          # 长格式：--log-level=3
          -l|--log-level)
               # 如指定了参数项，未指定参数值，则默认得到空字符串，可以根据此规则使用默认值
               # 如果指定了参数值，则使用参数值
               case "$2" in
                    "") CONN_LOG_LEVEL=1 ; shift 2 ;;
                    *)  CONN_LOG_LEVEL="$2" ; shift 2 ;;
               esac ;;
          --) shift ; break ;;
          *) echo "Internal error!" ; exit 1 ;;
     esac
done

# 通过第一个无名称参数获取 主机
CONN_HOST="$1"

# 显示获取参数结果
echo '用户名：    '  "$CONN_USERNAME"
echo '密码：      '  "$CONN_PASSWORD"
echo '主机：      '  "$CONN_HOST"
echo '端口：      '  "$CONN_PORT"
echo '显示详情：   '  "$CONN_SHOW_DETAIL"
echo '日志级别：   '  "$CONN_LOG_LEVEL"