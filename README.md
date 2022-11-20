# a template of Numerai Compute Webhook for Google Cloud Run

This template is to create a webhook endpoint for Numerai Compute using Google Cloud Run.
Inspired by [numerai-cli](https://github.com/numerai/numerai-cli)(numerai official AWS version).

## Getting Started

### setup

1. set `numerai-public-id` and `numerai-secret` into Secret Manager.
2. create `numerai-compute` container image repository in Artifact Registry.
3. create service account to access `cloud run/secret/artifact registry`.
4. set `GCP_REGION/GCP_PROJECT/GCP_SERVICE_ACCOUNT` in [Makefile](./Makefile)

### develop and release


1. write codes into [predictor.py](./predictors/pred1)
2. put required resource (i.e. model pickle files) into [resources](./predictors/pred1/resources)
3. Run below command to deploy into Cloud Run, then you can get an URL.
  - `make release-pred1` (`pred1` is directory name under [predictors](./predictors) directory. You can add your own directory such as `pred2`)
4. Compose numerai compute URL with Numerai Model ID.
  - You can get Model ID from https://numer.ai/models by clicking `Copy Model ID`
  - `https://YOUR_CLOUD_RUN_URL/pred/YOUR_NUMERAI_MODEL_ID`
5. Set the composed URL into Compute as `Submission webhook`
6. Click `Test` button in the modal window to check your webhook

