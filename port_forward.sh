#!/bin/bash

nohup minikube tunnel &
kubectl port-forward svc/ansible-awx-service --address 0.0.0.0 32483:80 &> /dev/null &
