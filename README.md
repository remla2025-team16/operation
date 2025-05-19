# Operations

This repository contains the deployment and orchestration configuration for the A1 assignment. It enables you to spin up all components of the application (model-service, app-service, and frontend) with a single command. The personal contribution can be seen from `ACTIVITY.md`.

---

## Services Overview

The Docker Compose file defines the following services:

| Service           | Build Context      | Bound Ports | Environment Variables                         |
| ----------------- | ------------------ | ----------- | --------------------------------------------- |
| **model-service** | `../model-service` | `5010:5010` | *(none)*                                      |
| **app-service**   | `../app-service`   | `8080:8080` | `MODEL_SERVICE_URL=http://model-service:5010` |
| **app-frontend**      | `../app-frontend`  | `3000:3000` | *(none)*                                      |

* **model-service**: Hosts the sentiment analysis REST API on port **5010**.
* **app-service**: Provides the application backend on port **8080**, configured to call `model-service`.
* **frontend**: Serves the user interface on port **3000**, connecting to `app-service`.

---

## Prerequisites

* Docker Engine (v20.10+)
* Docker Compose CLI (v2+)
* Clone all related repositories in a single parent directory:

  ```
   ├── app
   │   ├── app-frontend
   │   └── app-service
   ├── model-service
   └── operation-repo
  ```

---

## Quick Start

1. **Navigate** to this `operation-repo` directory:

   ```bash
   cd operation-repo
   ```

2. **Bring up all services** with a single command:

   ```bash
   docker-compose up --build
   ```

3. **Access the services**:

   * Frontend UI:  [http://localhost:3000](http://localhost:3000)
   * App Backend:  [http://localhost:8080](http://localhost:8080)
   * Model API:    [http://localhost:5010/api/model](http://localhost:5010/api/model)
   * Version API:  [http://localhost:5010/api/version](http://localhost:5010/api/version)

4. **Shut down** all services:

   ```bash
   docker-compose down
   ```

---

## Assignment Requirements Coverage

This Compose setup satisfies the A1 assignment by:

1. **Single-entry orchestration**: One `docker-compose up` command brings up all three components in the correct order.
2. **Inter-service networking**: Services communicate via Docker Compose DNS (e.g., `http://model-service:5010`).
3. **Port exposure**: Each service is exposed on a unique host port (`3000`, `8080`, `5010`).
4. **Environment configuration**: `app-service` is configured via environment variables to locate `model-service`.

---

## File Reference

* **`docker-compose.yml`**: Defines all services and their orchestration.

---
## Infra Automation (Ansible)

All infrastructure provisioning and Kubernetes setup are defined under [`ansible/`](./ansible):
  
- **Playbooks**: `general.yaml`, `ctrl.yaml`, `node.yaml`  
- **Setup:** 
   1. put the public key under `/keys` folder and add your path to `ssh_key_files` in `general.yaml`
   2. running `vagrant ssh-config <VM_NAME>` to get the `IdentityFile` and add them to `inventory.cfg` as `ansible_private_key_file` path
- **Quickstart**:
  ```bash
  export WORKERS=2
  vagrant up --no-provision # create+boot
  vagrant provision 
  ```
- **Quick Recovery**
   - If you get unreachable error, first use `vagrant ssh-config <VM_NAME>` to check whether the running `ansible_port` matches those registered in `inventory.cfg`

   ## Assignment 2 - kubernetes Provisioning (NEW SECTION STARTS HERE)

   In Assignment 2, we set up the infrastructure required to host a multi-node Kubernetes cluster. This includes using **Vagrant**, **VirtualBox**, and **Ansible** to automate configuration of three Ubuntu-based virtual machines.

   ### Infrastructure Setup with Vagrant

   We use Vagrant to:

   - `ctrl` (Controller Node): 192.168.56.100
   - `node-1` (Worker Node): 192.168.56.101
   - `node-2` (Worker Node): 192.168.56.102

   Each VM has:
   - 2 network interfaces (NAT + private host-only)
   - A static IP on the private network

   #### How to Start

   ```bash
   cd operation
   vagrant up
   ```

   In case of SSH CRASH

   ```bash
   vagrant destroy -r
   vagrant node-1 up
   vagrant node-2 up
   ```

   ### Ansible Provisioning

   The Ansible playbook `ansible/general.yaml` applies the following configurations to all VMs:

   | Step | Task |
   |   5  | Disable swap (`swapoff -a`) and remove from `/etc/fstab` |
   |   6  | Load `br_netfilter` kernel module and persist it |
   |   7  | Enable IPv4 forwarding and bridge sysctl options |
   |   8  | Copy a custom `/etc/hosts` file to each VM |

   An inventory file (`ansible/inventory.cfg`) ensures each VM is properly targeted via SSH.

   #### Verification Commands

   You can SSH into each VM using:

   ```bash
   vagrant ssh ctrl  
   ```

   From there, you can check:

   ```bash
   free -h                       
   lsmod | grep br_netfilter     
   sysctl net.ipv4.ip_forward    
   cat /etc/hosts                
   ```

   ---

   ## Kubernetes Cluster Setup 
   ### Step 9–12: Install Kubernetes Components
   - Installed `containerd`, `kubeadm`, `kubectl`, `kubelet`
   - Configured `crictl.yaml` to use containerd
   - Enabled and started the `containerd` service

   ### Step 13-14: Initialize Control Plane
   - Initialized the Kubernetes cluster using `kubeadm init`
   - Used pod network CIDR: `10.244.0.0/16`
   - Prepared `/etc/kubernetes/admin.conf` for kubectl access

   ### Step 15: Configure Pod Network with Flannel
   - Installed Flannel CNI plugin using:

   ```bash
   kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.26.7/kube-flannel.yml
   ```

   ### Step 16-17 : Helm Installation
   - Helm installed on controller

   ### Step 18–19: Worker Node Join

   - Worker nodes joined using token from controller
   - Implemented in `ansible/node.yaml` using `kubeadm token create --print-join-command`

   ### Step 20: Install MetalLB

   - MetalLB core manifests applied
   - IP pool configured: `192.168.56.90-192.168.56.99`

   ### Step 21: Ingress-NGINX 

   ### Step 22: Kubernetes Dashboard

   ## Authors & Contributions
   - System preparation
   - Security 
   - Vagrant + Ansible structure: 
   - Kubernetes provisioning: 

   ## Assignment 3 - Operate and Monitor Kubernetes
   This section covers the conversion of the existing Docker Compose setup into a Kubernetes deployment with `Deployment`, `Service`, `Ingress`, `ConfigMap`, and `Secret` objects. The three application components (`model-service`, `app-service`, `app-frontend`) are all deployed and managed through Kubernetes resources

   ###  Docker Image Preparation
   Before deploying to Kubernetes, make sure the images are built and pushed to DockerHub:

   ```bash
   cd model-service
   docker build -t <your-dockerhub-username>/model-service:latest .
   docker push <your-dockerhub-username>/model-service:latest

   cd ../app/app-frontend
   docker build -t <your-dockerhub-username>/app-frontend:latest .
   docker push <your-dockerhub-username>/app-frontend:latest

   cd ../app/app-service
   docker build -t <your-dockerhub-username>/app-service:latest .
   docker push <your-dockerhub-username>/app-service:latest
   ```

   ###  Apply Kubernetes Resources
   After building and pushing your images, apply all Kubernetes resources using:

   ```bash
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/secret.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   ```

   
   ### Verify Deployment
   ```bash
   kubectl get pods
   kubectl get svc
   ```

   If a pod fails, inspect with:

   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name> -c model-service
   ```

   If needed:

   ```bash
   kubectl delete pod -l app=my-app
   ```

   ### Run the App Locally via Port Forwarding
   ```
   kubectl port-forward svc/my-app 8080:80
   ```