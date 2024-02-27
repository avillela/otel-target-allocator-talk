# otel-target-allocator-talk

## Installation

### 1- Install KinD and set up k8s cluster

The scripts below will install KinD, and then will install the following in the newly-created cluster:

* the `PodMonitor` and `ServiceMonitor` Prometheus CRs
* `cert-manager` (an OTel Operator pre-requisite)
* the OTel Operator.

```bash
./src/scripts/01-install-kind.sh
./src/scripts/02-k8s-setup.sh
```

### 2- Build and deploy image

Build Docker image and deploy to KinD

```bash
./src/scripts/03-build-and-deploy-images.sh
```

Verify that images are in KinD:

```bash
docker exec -it otel-target-allocator-talk-control-plane crictl images | grep target-allocator
```

Reference [here](https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster).

### 3- Kubernetes deployment

Deploy Kubernetes resources

```bash
./src/scripts/04-deploy-resources.sh
```

Check Collector logs:

```bash
# Option 1
kubectl logs -l app.kubernetes.io/component=opentelemetry-collector -n opentelemetry --follow

# Option 2
kubectl logs otelcol-collector-0 -n opentelemetry | grep "Name:" | sort | uniq | xsel -b
```