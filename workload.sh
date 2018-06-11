#!/bin/bash

a=0

while [ $a -lt 100000 ]
do
   curl -X GET http://34.228.16.67 > /dev/null
   a=`expr $a + 1`
done