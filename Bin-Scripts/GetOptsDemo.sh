#!/bin/bash
today=$(date '+%F')
jobId=""
instanceId=""

tableName=""
batchDate="$today"

#echo $1
#echo $2
#echo $3
#echo $4
#echo "$@"
echo "params -> $*"

func() {
    echo "Usage:"
    echo "test.sh [-j jobId] [-i instanceId] [-t tableName] [-d batchDate]"
}


while getopts ':j:i:t:d:' OPT; do
    case $OPT in
        j) jobId="$OPTARG";;
        i) instanceId="$OPTARG";;
        t) tableName="$OPTARG";;
        d) batchDate="$OPTARG";;
        ?) func;;
    esac
done

echo "jobId:" $jobId
echo "instanceId:" $instanceId
echo "tableName:" $tableName
echo "batchDate:" $batchDate

echo $#
echo $0