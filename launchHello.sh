#!/bin/bash
curl -XPUT -H "Accept: application/json" -H "Content-Type: application/json" http://mesos1.mesos.vagrant:8080/v2/apps/helloworld -d '{
    "cmd": "echo \"hello world\"; sleep 30;",
    "cpus": 0.1,
    "instances": 10,
    "mem": 16
}'