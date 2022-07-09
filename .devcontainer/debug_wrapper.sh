#!/bin/bash
# Java KoolKits - Shorthand - dj -> debug java
POD=$1
CONTAINER=$2
echo ' Debugging container $2 in Pod $1 ...'
kubectl debug -it $POD --image=lightruncom/koolkits:jvm --image-pull-policy=Never --target=$CONTAINER
