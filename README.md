# OpenTelemetry Target Allocator Example

This is the companion repo for the KubeCon EU 2024 Talk, ["Prometheus and OpenTelemetry: Better Together"](https://kccnceu2024.sched.com/event/1YePz/prometheus-and-opentelemetry-better-together-adriana-villela-servicenow-cloud-observability-reese-lee-new-relic).

This tutorial is based on the following two blog posts:

* [Ingest Prometheus Metrics with OpenTelemetry](https://trstringer.com/opentelemetry-prometheus-metrics/)
* [Troubleshooting the OpenTelemetry Target Allocator](https://trstringer.com/opentelemetry-target-allocator-troubleshooting/)

Check out the demo video [here](https://youtu.be/dRbUKhBtMg4), which shows you how to run this project in GitHub Codespaces.

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


## 3a - Kubernetes Deployment (Collector stdout only)

> 🚨 This step deploys resources to send telemetry to the OTel Collector's sdout only. If you want to send telemetry to [ServiceNow Cloud Observability (formerly known as Lightstep)](https://www.servicenow.com/products/observability.html), you'll need to skip this step and follow **Step 3b** instead.

Now you are ready to deploy the Kubernetes resources

```bash
./src/scripts/04-deploy-resources.sh
```

### 3b- Kubernetes deployment (ServiceNow Cloud Observability backend)

> 🚨 If you want to send telemetry to [ServiceNow Cloud Observability (formerly known as Lightstep)](https://www.servicenow.com/products/observability.html), you'll need to follow the steps below, and skip **Step 3a**.

To send telemetry to ServiceNow Cloud Observability, you will first need a Cloud Observability account.

Next, you will need to obtain an [access token](https://docs.lightstep.com/docs/create-and-manage-access-tokens#create-an-access-token).

First, create a secrets file for the Lightstep token.

```bash
tee -a src/resources/00-secret.yaml <<EOF
 apiVersion: v1
 kind: Secret
 metadata:
   name: otel-collector-secret
   namespace: opentelemetry
 data:
   LS_TOKEN: <base64-encoded-LS-token>
 type: "Opaque"
EOF
```

Replace <base64-encoded-LS-token> with your own [access token] (https://docs.lightstep.com/docs/create-and-manage-access-tokens#create-an-access-token)

Be sure to Base64 encode it like this:

```bash
echo <LS-access-token> | base64
```

Or you can Base64-encode it through [this website](https://www.base64encode.org/).

Finally, deploy the Kubernetes resources:

```bash
./src/scripts/04-deploy-resources-ls-backend.sh
```

## 4- Check logs

This command will tail the Collector logs

```bash
kubectl logs -l app.kubernetes.io/component=opentelemetry-collector -n opentelemetry --follow
```

This command will return unique items from the Collector logs containing "Name:"

```bash
kubectl logs otelcol-collector-0 -n opentelemetry | grep "Name:" | sort | uniq
```

Check Target Allocator logs:

```bash
kubectl logs -l app.kubernetes.io/component=opentelemetry-targetallocator -n opentelemetry --follow
```

## Troubleshooting

Based on [this article](kubectl port-forward svc/otelcol-targetallocator 8080:80)

Expose target allocator port

```bash
kubectl port-forward svc/otelcol-targetallocator -n opentelemetry 8080:80

# If above errs out
kubectl port-forward pods/$(kubectl -n opentelemetry get pods -o jsonpath='{.items[1].metadata.name}') 8080:80 -n opentelemetry
```

So we can get list of jobs

```bash
curl localhost:8080/jobs | jq
```

Sample output:

```json
{
  "serviceMonitor/opentelemetry/sm-example/2": {
    "_link": "/jobs/serviceMonitor%2Fopentelemetry%2Fsm-example%2F2/targets"
  },
  "serviceMonitor/opentelemetry/sm-example/0": {
    "_link": "/jobs/serviceMonitor%2Fopentelemetry%2Fsm-example%2F0/targets"
  },
  "serviceMonitor/opentelemetry/sm-example/1": {
    "_link": "/jobs/serviceMonitor%2Fopentelemetry%2Fsm-example%2F1/targets"
  },
  "otel-collector": {
    "_link": "/jobs/otel-collector/targets"
  }
}
```

Peek into one of the jobs:

```bash
curl localhost:8080/jobs/serviceMonitor%2Fopentelemetry%2Fmy-app%2F1/targets | jq
```

Sample output:

```json
{
  "otelcol-collector-0": {
    "_link": "/jobs/serviceMonitor%2Fopentelemetry%2Fmy-app%2F1/targets?collector_id=otelcol-collector-0",
    "targets": [
      {
        "targets": [
          "10.244.0.29:8082"
        ],
        "labels": {
          "__meta_kubernetes_endpointslice_annotation_endpoints_kubernetes_io_last_change_trigger_time": "2024-02-28T18:09:34Z",
          "__meta_kubernetes_endpointslice_labelpresent_app_kubernetes_io_name": "true",
          "__meta_kubernetes_endpointslice_endpoint_conditions_serving": "true",
          "__meta_kubernetes_endpointslice_labelpresent_endpointslice_kubernetes_io_managed_by": "true",
          "__meta_kubernetes_service_labelpresent_app": "true",
          "__meta_kubernetes_pod_label_pod_template_hash": "f89fdbc4f",
          "__meta_kubernetes_endpointslice_endpoint_conditions_terminating": "false",
          "__meta_kubernetes_pod_label_app": "my-app",
          "__meta_kubernetes_pod_ip": "10.244.0.29",
          "__meta_kubernetes_pod_container_image": "otel-target-allocator-talk:0.1.0-py-otel-server",
          "__meta_kubernetes_endpointslice_address_type": "IPv4",
          "__meta_kubernetes_service_annotation_kubectl_kubernetes_io_last_applied_configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Service\",\"metadata\":{\"annotations\":{},\"labels\":{\"app\":\"my-app\",\"app.kubernetes.io/name\":\"py-otel-server\"},\"name\":\"py-otel-server-svc\",\"namespace\":\"opentelemetry\"},\"spec\":{\"ports\":[{\"name\":\"py-server-port\",\"port\":8082,\"protocol\":\"TCP\",\"targetPort\":\"py-server-port\"}],\"selector\":{\"app.kubernetes.io/name\":\"py-otel-server\"}}}\n",
          "__meta_kubernetes_endpointslice_annotationpresent_endpoints_kubernetes_io_last_change_trigger_time": "true",
          "__meta_kubernetes_pod_container_port_number": "8082",
          "__meta_kubernetes_pod_uid": "06cc65c5-61a2-4d0c-87ef-74302f977d48",
          "__meta_kubernetes_endpointslice_labelpresent_kubernetes_io_service_name": "true",
          "__meta_kubernetes_endpointslice_label_endpointslice_kubernetes_io_managed_by": "endpointslice-controller.k8s.io",
          "__meta_kubernetes_service_name": "py-otel-server-svc",
          "__meta_kubernetes_endpointslice_endpoint_conditions_ready": "true",
          "__meta_kubernetes_endpointslice_address_target_kind": "Pod",
          "__meta_kubernetes_pod_annotation_instrumentation_opentelemetry_io_inject_python": "true",
          "__meta_kubernetes_pod_container_port_name": "py-server-port",
          "__meta_kubernetes_endpointslice_address_target_name": "py-otel-server-f89fdbc4f-lbb7z",
          "__meta_kubernetes_endpointslice_labelpresent_app": "true",
          "__meta_kubernetes_pod_host_ip": "172.24.0.2",
          "__meta_kubernetes_pod_container_name": "py-otel-server",
          "__meta_kubernetes_namespace": "opentelemetry",
          "__meta_kubernetes_endpointslice_label_kubernetes_io_service_name": "py-otel-server-svc",
          "__meta_kubernetes_pod_controller_name": "py-otel-server-f89fdbc4f",
          "__meta_kubernetes_pod_labelpresent_app_kubernetes_io_name": "true",
          "__meta_kubernetes_service_label_app_kubernetes_io_name": "py-otel-server",
          "__meta_kubernetes_pod_node_name": "otel-target-allocator-talk-control-plane",
          "__meta_kubernetes_pod_labelpresent_pod_template_hash": "true",
          "__address__": "10.244.0.29:8082",
          "__meta_kubernetes_service_labelpresent_app_kubernetes_io_name": "true",
          "__meta_kubernetes_pod_label_app_kubernetes_io_name": "py-otel-server",
          "__meta_kubernetes_pod_container_port_protocol": "TCP",
          "__meta_kubernetes_pod_labelpresent_app": "true",
          "__meta_kubernetes_pod_annotationpresent_instrumentation_opentelemetry_io_inject_python": "true",
          "__meta_kubernetes_endpointslice_port": "8082",
          "__meta_kubernetes_pod_phase": "Running",
          "__meta_kubernetes_endpointslice_name": "py-otel-server-svc-t2wgv",
          "__meta_kubernetes_endpointslice_label_app_kubernetes_io_name": "py-otel-server",
          "__meta_kubernetes_endpointslice_port_protocol": "TCP",
          "__meta_kubernetes_service_annotationpresent_kubectl_kubernetes_io_last_applied_configuration": "true",
          "__meta_kubernetes_pod_ready": "true",
          "__meta_kubernetes_pod_controller_kind": "ReplicaSet",
          "__meta_kubernetes_pod_name": "py-otel-server-f89fdbc4f-lbb7z",
          "__meta_kubernetes_service_label_app": "my-app",
          "__meta_kubernetes_endpointslice_port_name": "py-server-port",
          "__meta_kubernetes_endpointslice_label_app": "my-app"
        }
      }
    ]
  }
}
```
