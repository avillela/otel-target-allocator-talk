#! /bin/bash

# Install Prometheus Operator (overkill)
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo update
# helm install prometheus prometheus-community/kube-prometheus-stack

# Install Just ServiceMonitor and PodMonitor
# NOTE: This GH issue put me on the right track: https://github.com/open-telemetry/opentelemetry-operator/issues/1811#issuecomment-1584128371
kubectl --context kind-otel-target-allocator-talk apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl --context kind-otel-target-allocator-talk apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml

sleep 35

# Install cert-manager
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml

# Sometimes it takes a while for cert-manager pods to come up
sleep 90

# Install operator
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.94.0/opentelemetry-operator.yaml