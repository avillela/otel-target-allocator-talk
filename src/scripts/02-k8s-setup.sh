#! /bin/bash

# Install Prometheus Operator
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack

# Install ServiceMonitor and PodMonitor
# Find version of helm charts by running helm list
# kubectl --context kind-otel-target-allocator-talk apply -f https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-56.14.0/charts/kube-prometheus-stack/crds/crd-podmonitors.yaml
# kubectl --context kind-otel-target-allocator-talk apply -f https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-56.14.0/charts/kube-prometheus-stack/crds/crd-servicemonitors.yaml

# kubectl --context kind-otel-target-allocator-talk apply -f src/resources/service-monitor.yml
# kubectl --context kind-otel-target-allocator-talk apply -f src/resources/pod-monitor.yml

sleep 35

# Install cert-manager
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml

sleep 90

# Install operator
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.94.0/opentelemetry-operator.yaml