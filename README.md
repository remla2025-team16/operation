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

## Next Steps

* Extend this repository with CI/CD workflows (`.github/workflows/`), Kubernetes manifests, or Helm charts for production deployments.
* Add monitoring, logging, and secrets management as needed.