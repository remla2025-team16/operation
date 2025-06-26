# System Deployment Documentation

## 1. Introduction

This document outlines the deployment architecture of our sentiment analysis application. The goal is to provide a conceptual overview of the system's structure, components, and data flow to help new team members get up to speed.

Our system is a multi-tier web application deployed on a Kubernetes cluster, leveraging Istio for advanced traffic management and observability.

## 2. High-Level Architecture

The entire system is orchestrated within a Kubernetes cluster. We use a service mesh (Istio) to manage the interactions between our application's microservices and to expose them to the outside world. The observability stack provides deep insights into the application's behavior and performance.

![High-Level Architecture Diagram]() 

[//]: # (#todo: add image)

The main components are:
* **Application Services**: The core microservices that make up our application (`app-frontend`, `app-service`, `model-service`).
* **Kubernetes Cluster**: The underlying container orchestration platform.
* **Istio Service Mesh**: Manages traffic, security, and observability across services.
* **Observability Stack**: A suite of tools for monitoring, tracing, and visualization (Prometheus, Grafana, Jaeger, Kiali).

## 3. Kubernetes and Istio Setup

The infrastructure is provisioned automatically using **Vagrant** and **Ansible**, which sets up a multi-node Kubernetes cluster. For details on the provisioning process, you can refer to the `ansible/` directory in the [operation repository](https://github.com/remla2025-team16/operation).

**Istio** is installed as our service mesh. It provides critical functionalities, including:
* **Ingress Gateway**: A single entry point for all incoming traffic.
* **Smart Routing**: Advanced traffic routing capabilities, which we use for canary releases.
* **Security**: Securing service-to-service communication.
* **Observability**: Exposing metrics, traces, and logs.

Our deployment is defined using a **Helm Chart**, which can be found in the `Chart/` directory. This chart templates and deploys all the necessary Kubernetes and Istio resources.

## 4. Application Components

Our application is composed of three main microservices:

* **`app-frontend`**: A vanilla JavaScript single-page application that serves as the user interface. It communicates with the `app-service` to submit text for analysis and display the results.
* **`model-service`**: A Python service built with Flask that serves a pre-trained sentiment analysis model. It exposes a simple REST API to predict the sentiment of a given text.
* **`app-service`**: The central backend service. It handles business logic, exposes the main API for the frontend, and communicates with the `model-service`. This service is the subject of our canary deployments and currently runs in two versions: `v1` (stable) and `v2` (canary).

## 5. Request Flow and Canary Deployment

We use a canary release strategy to safely roll out new versions of our `app-service`. This is orchestrated entirely by Istio.

![Request Flow Diagram]() 

[//]: # (#todo: add image)

The flow of a typical user request is as follows:

1.  **Ingress**: The request enters the cluster through the **Istio Ingress Gateway**. This is configured via an Istio `Gateway` resource.
2.  **Routing**: An Istio **`VirtualService`** intercepts the request. This `VirtualService` is the core of our traffic management.
3.  **Canary Split**: The `VirtualService` is configured to split traffic for the `app-service` between its two deployed versions:
    * **90% of traffic** is routed to the stable version, `app-service:v1`.
    * **10% of traffic** is routed to the new canary version, `app-service:v2`.
4.  **Service Subsets**: An Istio **`DestinationRule`** defines the `v1` and `v2` subsets based on the `version` label applied to the pods, making them available targets for the `VirtualService`.
5.  **Internal Communication**: The `app-service` (whether `v1` or `v2`) processes the request and calls the `model-service` over the internal cluster network to get the sentiment analysis result.
6.  **Response**: The response travels back to the user through the same path.

This setup allows us to expose a new version to a small subset of users, monitor its performance, and decide whether to proceed with a full rollout or to roll back.

## 6. Observability and Monitoring

A robust observability stack is deployed alongside the application to monitor its health and performance.

* **Prometheus & Grafana**: Prometheus, installed via the `kube-prometheus-stack`, continuously scrapes metrics from all services. A `ServiceMonitor` is specifically configured for `app-service` to gather custom application metrics. Grafana provides dashboards to visualize these metrics, allowing us to track error rates, latency, and resource usage.
* **Jaeger**: Provides distributed tracing capabilities, which lets us follow a single request as it travels through the different microservices (`app-frontend` -> `app-service` -> `model-service`). This is invaluable for debugging performance bottlenecks.
* **Kiali**: Offers a powerful UI to visualize the service mesh. It generates a live graph of our services, showing traffic flow, health status, and the configuration of Istio resources in one place.

---