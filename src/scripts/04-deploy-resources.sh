#! /bin/bash

kubectl create ns opentelemetry

if [ $# -eq 0 ]; then
    SUFFIX=""
    echo "** No arguments supplied **"
else
    # Additional configuration for deploying to SaaS backends
    SUFFIX="-$1"
    echo "** Suffix is '${SUFFIX}' **"
    kubectl apply -f src/resources/00-secret${SUFFIX}.yml
fi

kubectl apply -f src/resources/01-rbac.yml
kubectl apply -f src/resources/02-otel-collector${SUFFIX}.yml
kubectl apply -f src/resources/03-instrumentation.yml
kubectl apply -f src/resources/04-service-monitor.yml
kubectl apply -f src/resources/04a-pod-monitor.yml
kubectl apply -f src/resources/05-python-client.yml
kubectl apply -f src/resources/06-python-server.yml
kubectl apply -f src/resources/08-python-app.yml
kubectl apply -f src/resources/09-jaeger.yml
