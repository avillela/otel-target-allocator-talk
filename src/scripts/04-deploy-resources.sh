#! /bin/bash

kubectl apply -f src/resources/01-app-deployment.yml
kubectl apply -f src/resources/02-rbac.yml
kubectl apply -f src/resources/03-otel-collector.yml
kubectl apply -f src/resources/04-service-monitor.yml