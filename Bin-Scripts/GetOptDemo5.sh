#处理参数，规范化参数
ARGS=$(getopt --options=n:m:c: --longoptions=name:,mem:,cpu: -- "$@")
if [ $? != 0 ];then
        echo "Terminating..."
        exit 1
fi
#重新排列参数顺序
eval set -- "${ARGS}"
#通过shift和while循环处理参数
while :
do
    case $1 in
        -n|--name)
            name=$2
            shift
            ;;
        -m|--mem)
            mem=$2
            shift
            ;;
        -c|--cpu)
            cpu=$2
            shift
            ;;
        -H|--host)
            host=$2
            shift
            ;;
        -N|--netmask)
            netmask=$2
            shift
            ;;
        -G|--gateway)
            gateway=$2
            shift
            ;;
        -D|--dns)
            dns=$2
            shift
            ;;
        --help)
            usage
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
shift
done
echo "name: $name"
echo "mem: $mem"
echo "cpu: $cpu"
echo "host: $host"
echo "netmask: $netmask"
echo "gateway: $gateway"
echo "dns: $dns"