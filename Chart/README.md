# Helm Chart for Multi-Service Deployment

This Helm Chart is designed to deploy a multi-service application, including `model-service`, `app-frontend`, and `app-service`, to a Kubernetes cluster. It allows customization of parameters such as replica counts, container images, and service ports.

## Prerequisites

Before using this Helm Chart, ensure the following prerequisites are met:

1. **Kubernetes Cluster**: A **running** Kubernetes cluster (e.g., Minikube, Kind, or a cloud provider).
2. **Helm Installed**: Helm CLI installed on your local machine. You can install Helm by following the [official guide](https://helm.sh/docs/intro/install/).
3. **kubectl Installed**: Ensure `kubectl` is installed and configured to communicate with your Kubernetes cluster.
4. Start minikube for local testing:
   ```bash
   minikube start
   ```
5. **Prometheus Operator Installed**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/kube-prometheus-stack
   ```
6. Install Istio and add it to the path following instructions in [official](https://istio.io/latest/docs/setup/install/istioctl/) and run the following command to install Istio in your cluster:
   ```bash
   istioctl install
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
## Sticky Session and Weighted Routing (Option - 1)
1. Test Istio gateway by running
   ```bash
   kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
   ```
   Now you can access http://localhost:8080/ to access the frontend
2. To test sticky session by running the following command:
   ```bash
   # generate cookie
   curl -s -H "Host: myapp.local" -c cookies.txt http://localhost:8080/ > /dev/null

   # use the same cookie to query the same endpoint
   for i in {1..10}; do
   curl -s -H "Host: myapp.local" -b cookies.txt http://localhost:8080/api/whoami | jq -r '.podName, ."app-service-version"'
   done

   # You will get the result like the following:
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   ```
3. To test 90/10 routing of the app service run the following script:
   ```bash
   for i in {1..100}; do
   curl -s http://localhost:8080/api/whoami | jq -r '."app-service-version"'
      done | sort | uniq -c
   
   # You will get the result like the following
   89 v1.0.0
   11 v2.0.0
   ```
## Sticky Session and Weighted Routing (Option - 2)
1. Open the minikube tunnel in one terminal and keep it:
   ```bash
   minikube tunnel
   ```
2. Open another terminal and run the command to get an EXTERNAL_IP for your istio-ingressgateway by:
   ```bash
   kubectl -n istio-system get svc istio-ingressgateway
   ```
3. To test sticky session by running the following command:
   ```bash
   # generate cookie
   curl -s -H "Host: myapp.local" -c cookies.txt <EXTERNAL_IP>/ > /dev/null

   # use the same cookie to query the same endpoint
   for i in {1..10}; do
   curl -s -H "Host: myapp.local" -b cookies.txt <EXTERNAL_IP>/api/whoami | jq -r '.podName, ."app-service-version"'
   done

   # You will get the result like the following:
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   istio-test-my-app-app-service-v1-554c76ddc7-9mlk7
   v1.0.0
   ```
3. To test 90/10 routing of the app service run the following script:
   ```bash
   for i in {1..100}; do
   curl -s <EXTERNAL_IP>/api/whoami | jq -r '."app-service-version"'
      done | sort | uniq -c
   
   # You will get the result like the following
   89 v1.0.0
   11 v2.0.0
   ```