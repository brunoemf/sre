#!/bin/bash

a=0
site=http://34.228.16.67

while [ $a -lt 100000 ]
do
   curl -X GET $site > /dev/null
   a=`expr $a + 1`
done