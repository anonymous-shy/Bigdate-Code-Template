#!/bin/bash

case $1 in
"start"){
    echo "******** $i ********"
    ssh $i "/home/shy/kafka_2.11-2.1.0/bin/kafka-server-start.sh -daemon /home/shy/kafka_2.11-2.1.0/config/server.properties"
};;
"status"){
    echo "******** $i ********"
    ssh $i "/home/shy/kafka_2.11-2.1.0/bin/kafka-server-stop.sh"
};;
"stop"){
    echo "******** $i ********"
    ssh $i "/home/shy/kafka_2.11-2.1.0/bin/kafka-server-stop.sh"
};;
"restart"){
    echo "******** $i ********"
    ssh $i "/home/shy/kafka_2.11-2.1.0/bin/kafka-server-start.sh -daemon /home/shy/kafka_2.11-2.1.0/config/server.properties"
};;
esac