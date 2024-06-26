#! /bin/bash

kubectl create ns opentelemetry
kubectl apply -f src/resources/00-secret.yml
kubectl apply -f src/resources/01-rbac.yml
kubectl apply -f src/resources/02-otel-collector-ls.yml
kubectl apply -f src/resources/03-instrumentation.yml
kubectl apply -f src/resources/04-service-monitor.yml
kubectl apply -f src/resources/04a-pod-monitor.yml
kubectl apply -f src/resources/05-python-client.yml
kubectl apply -f src/resources/06-python-server.yml
kubectl apply -f src/resources/08-python-app.yml