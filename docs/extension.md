# Extension Proposal: Improving Version Tagging and Release Stability

## 1. Identified Shortcoming

Currently, the `app-service` deployment uses the `latest` tag for the experimental version (v2). This approach introduces several risks to the stability and reproducibility of deployments:

- It is difficult to trace which version is actually deployed when using `latest`
- The `latest` tag is mutable; new builds overwrite the same tag, causing unintended updates
- Experiments lose meaning if the version under test changes mid-deployment

This issue affects our ability to execute reliable continuous experimentation, violates reproducibility principles, and makes debugging significantly harder when rollback is required.

## 2. Proposed Extension: Use Git-Based Versioning and Automated Image Tagging

We propose to replace `latest` with explicit semantic versioning (e.g., `v2.0.0`, `v2.1.0`) for all container images, tied directly to Git tags.

### Key Changes:

- Each release commit should include a Git tag (e.g., `git tag v2.0.0`)
- CI/CD workflows should use this tag to build and push images:

docker build -t ghcr.io/team/app-service:v2.0.0 .
docker push ghcr.io/team/app-service:v2.0.0