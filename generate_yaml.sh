#!/bin/bash

# Define variables to be replaced in the template
export SERVICE_NAME="chroma"
export SERVICE_ACCOUNT="sa@developer.gserviceaccount.com"
export SERVICE_REGION="europe-west1"
export API_TOKEN="abcdefghijklmnopqrstuvwxyz"
export BUCKET_NAME="bucketname4storage"

# Optionally, set the following variables
export MIN_INSTANCES=0  # Set to 1 to keep the service always on

# Set GCP projet id
project_id="project-id"

# Replace variables in the template file
envsubst < deploy-template.yaml > tmp/deploy.yaml

# Now you can use the deploy.yaml file for your deployment
# Authentication is managed by ChromaDB, so no need to authenticate with gcloud
echo Use the following command to deploy the service:
echo    gcloud run services replace deploy.yaml --project $project_id
echo then allow authenticated access:
echo    gcloud run services add-iam-policy-binding $SERVICE_NAME --member="allUsers" --role="roles/run.invoker" --region=$SERVICE_REGION --project=$project_id