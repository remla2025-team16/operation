# Helm Chart for Multi-Service Deployment

This Helm Chart is designed to deploy a multi-service application, including `model-service`, `app-frontend`, and `app-service`, to a Kubernetes cluster. It allows customization of parameters such as replica counts, container images, and service ports.

## Prerequisites

Before using this Helm Chart, ensure the following prerequisites are met:

1. **Kubernetes Cluster**: A **running** Kubernetes cluster (e.g., Minikube, Kind, or a cloud provider).
2. **Helm Installed**: Helm CLI installed on your local machine. You can install Helm by following the [official guide](https://helm.sh/docs/intro/install/).
3. **kubectl Installed**: Ensure `kubectl` is installed and configured to communicate with your Kubernetes cluster.
4. **Prometheus Operator Installed**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/kube-prometheus-stack
   ```

## Installation

To deploy the services using this Helm Chart, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd operation/Chart
   ```

2. **Install the Chart**:
   Use the following command to install the Chart. Replace `<release-name>` with a unique name for your deployment:
   ```bash
   helm install <release-name> .
   ```

3. **Verify the Deployment**:
   After installation, verify that the resources have been created:
   ```bash
   kubectl get all -l app=<release-name>
   ```
## Testing

1. **Map the custom domain locally**
   Edit your hosts file (`/etc/hosts` on Linux/macOS or `C:\Windows\System32\drivers\etc\hosts` on Windows) and add:
   ```bash
   127.0.0.1   myapp.local
   ```

2. **Port-forward the Ingress controller**
   ```bash
   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
   ```

3. **Open the app in your browser**
   Navigate to the app-frontend by:
   ```bash
   http://myapp.local:8080
   ```
## Customization

You can customize the deployment by modifying the `values.yaml` file or by passing parameters directly via the `--set` flag. Below are some examples:

1. **Change the Model Service Port**:
   ```bash
   helm install <release-name> . --set modelService.service.port=5020
   ```

2. **Set Custom Replica Counts**:
   ```bash
   helm install <release-name> . --set modelService.replicaCount=2,appFrontend.replicaCount=3
   ```

3. **Override Container Images**:
   ```bash
   helm install <release-name> . --set modelService.image.repository=my-custom-image,modelService.image.tag=v1.0.0
   ```

## Uninstallation

To uninstall the Chart and delete all associated resources, run:
```bash
helm uninstall <release-name>
```

## Notes

- Ensure that the `values.yaml` file is properly configured for your environment.
- You can use the `helm template` command to render the templates locally and inspect the generated Kubernetes manifests:
  ```bash
  helm template <release-name> .
  ```
- Once Chart is modified, run:
  ```bash
  helm upgrade <release-name> .
  ```
- You can see the rendered Kubernets resource without submitting to the cluster by
  ```bash
  helm install <release-name> . -n <namespace> --dry-run --debug
  ```

# Istio Configuration

1. Deploy using
   ```bash
   helm install <installation_name> . -n <namespace>
   ```
2. check Istio resource by runing
   ```bash
   # Gateway
   kubectl get gateway -n <namespace>

   # DestinationRule
   kubectl get destinationrule -n <namespace>

   # VirtualService
   kubectl get virtualservice -n <namespace>

   # Deployment/Pod
   kubectl get pods -n <namespace>
   ```
3. Test Istio gateway by running
   ```bash
   kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
   ```
4. Test the canary release by executing the `app-service-version` on http://localhost:8080/apidocs/