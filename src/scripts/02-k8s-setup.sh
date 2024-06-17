#! /bin/bash

# Install just ServiceMonitor and PodMonitor
# NOTE: This GH issue put me on the right track: https://github.com/open-telemetry/opentelemetry-operator/issues/1811#issuecomment-1584128371
kubectl --context kind-otel-target-allocator-talk apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl --context kind-otel-target-allocator-talk apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.74.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml

# Install cert-manager, since it's a dependency of the OTel Operator
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml

# Need to wait for cert-manager to finish before installing the operator
# Sometimes it takes a while for cert-manager pods to come up
echo "Taking a 90-second nap while the cert-manager pods come up..."
sleep 90

# Install operator
kubectl --context kind-otel-target-allocator-talk apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.102.0/opentelemetry-operator.yaml