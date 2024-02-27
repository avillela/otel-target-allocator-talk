#! /bin/bash

# Install Prometheus Operator
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack

# Install ServiceMonitor and PodMonitor
# kubectl --context kind-otel-target-allocator-talk apply -f src/resources/service-monitor.yml
# kubectl --context kind-otel-target-allocator-talk apply -f src/resources/pod-monitor.yml

sleep 30

# Install cert-manager
# kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml


sleep 30

# Install operator
# kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.94.0/opentelemetry-operator.yaml
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.81.0/opentelemetry-operator.yaml