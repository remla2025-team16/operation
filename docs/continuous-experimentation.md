# Continuous Experimentation: Evaluating app-service v2

## Hypothesis

The hypothesis of this experiment is that app-service version v2 reduces the average and 95th percentile request latency compared to version v1, without increasing memory usage or degrading model performance.

## What Changed

Version v2 introduces changes to the preprocessing logic and improves the efficiency of the request handling pipeline. These modifications aim to enhance performance, particularly under moderate to high load.

## Experiment Design

We deploy two versions of the app-service:

- v1 (baseline): version v1.0.0
- v2 (experimental): version latest

Routing between versions is handled by Istio. A DestinationRule defines subsets for v1 and v2. A VirtualService splits incoming traffic with the following weights:

- 90% of traffic is routed to app-service v1
- 10% of traffic is routed to app-service v2

Sticky sessions are enabled using a cookie named "user-id" to ensure that once a user is assigned to a version, they continue interacting with the same version throughout the experiment.

## Metrics

The app-service emits the following Prometheus metrics:

- `webapp_predictions_total` (Counter): total number of prediction requests, labeled by version and prediction class
- `webapp_response_latency_seconds` (Histogram): measures response time duration for the analyze endpoint
- `webapp_ram_usage_bytes` (Gauge): tracks RAM usage of the app-service process

Prometheus automatically scrapes these metrics, and they are visualized in Grafana.

## Dashboard Visualization

A custom Grafana dashboard has been created to visualize and compare the following across versions:

- Total number of predictions per version
- Response time histograms
- 95th percentile latency trends
- Memory usage over time

The dashboard is exported as a JSON file and can be imported into any Grafana instance.

- Dashboard file: `grafana-experiment.json`
- Screenshot: `grafana-experiment.png`

## Decision Criteria

Version v2 will be considered successful if the following conditions are met:

- 95th percentile latency is consistently lower than v1 over a 5-minute window
- RAM usage does not increase by more than 10% compared to v1
- Model output correctness is verified to remain unchanged

If these conditions are satisfied, the new version may be promoted and the traffic ratio adjusted accordingly.
