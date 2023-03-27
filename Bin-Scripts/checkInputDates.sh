#!/bin/bash
startDate="$1"
endDate="$2"
DATE_FMT="%Y%m%d"
source ./log.sh
export DEBUG="true"
function showUsage() {
    warn ""
    warn "------------------------ Usage ----------------------------- "
    warn " Syntax:  checkInputDates.sh <start date> <end date>"
    warn ""
    warn " Remark: "
    warn "   1.Two arguments are required and must with format 'YYYYmmDD'."
    warn "   2.Named 'end date' argument must be greater then or equal to 'start date' argument."
    warn ""
    warn "  Example: checkInputDates.sh 20140102 20140901"
    warn "------------------------------------------------------------ "
}
DATE_FMT=${DATE_FMT:-"%Y%m%d"} ##Default with format "%Y%m%d", eg: 20140102
function checkDateValid() {
    local myDate=$1
    local exp="date +$DATE_FMT -d $myDate"
    if [ "$myDate" == "$exp" ]; then
        echo "1"
    else
        echo "0"
    fi

}
# TODO: It's not correctly.
function datesDiff() {
    local d1=date -d $1 +%s
    local d2=date -d $2 +%s

##debug "Dates: "$d1 $d2
local cr=$(($d1-$d2)); ##Diff in 'day' unit.
echo $cr
}

:<<!
Return the day after input date.
Usage: toTomorrow <input date>
!
function compareDates() {
## `date -d " 20141225 1 day" +%Y%m%d`
local cr=$(datesDiff $1 $2); ##Diff in 'day' unit.
##debug "Compare: $(($(date +$DATE_FMT -d $1) - $(date +$DATE_FMT -d $2)));";
if [[ $cr -eq 0 ]]; then
    echo "0"
elif [[ $cr -gt 0 ]]; then
    echo "1"
else
    echo "-1"
fi
}
#
#Return the day after input date.
#Usage: toTomorrow <input date>
#
function toTomorrow() {
local curDate="$1"
##debug $curDate

##TODO: Must be adapted to DATE_FMT...
##curDate="${curDate:0:4}-${curDate:4:2}-${curDate:6:2}"

##debug "date -d '$curDate +1 day ' +$DATE_FMT"
##echo `date -d "$curDate +1 day " +$DATE_FMT`
##echo `date +$DATE_FMT -d "1 day $curDate"`
echo `date -d "1 day $curDate" +$DATE_FMT`

}
function countStrsByBlank() {

##local str="$1"
##local sep="${2:-' '}"
##echo $str |  awk -v v="$sep" '{ split($0, a, v);for(i in a) {c=i;}} END {print c;}'

set j=0
  for item in $dates
  do
    let j=j+1
  done
  echo $j
}
#
#Get the diff date list between input two dates.
#Usage: getDiffDateList <end date> <start date>
#
function getDiffDateList() {

local endd=$1
local stad=$2
dl=()
while [[ "$stad" != "$endd" ]]
do
    dl=(${dl[*]} "$stad")
    stad=$(toTomorrow $stad)
done
dl=(${dl[*]} "$stad")
echo "${dl[*]}"

}
Check inputs
1. Only two arguments.
warn ""
if [ $# != 2 ]; then
    warn "ERROR: Only support two arguments input." | showUsage
    exit 1;
fi
2. Check if they're the leagal value.
tmpSd=$(checkDateValid $startDate)
if [ "$tmpSd" == "0" ]; then ###It's the invalid date. eg: 20141901
    warn "ERROR: Invalid 'start date' with input '$startDate', it must be with format 'yyyyMMdd', eg: 20140101" | showUsage
    exit 1;

fi

tmpEd=$(checkDateValid $endDate)
if [ "$tmpEd" == "0" ]; then ###It's the invalid date. eg: 20141901
    warn "ERROR: Invalid 'end date' with input '$startDate', it must be with format 'yyyyMMdd', eg: 20140101"
    exit 1;
fi
3. Check the arg2 greater than or equal arg1.
echo "Compare result: "$(compareDates $endDate $startDate)
cprs=$(compareDates $endDate $startDate)
if [ "$cprs" == "-1" ]; then
    warn "ERROR: The first argument must not greater than the second one!" | showUsage
    exit 1;
fi
#loop the dates between start and end date.
while [[ "$startDate" != "$endDate" ]]
do
    echo $startDate
    startDate=$(toTomorrow $startDate)
done</pre>