# ChromaDB Service Deployment on GCP Cloud Run with Persistent Storage

Welcome to the ChromaDB deployment on Google Cloud Run guide! This document is designed to help you deploy the ChromaDB service on Google Cloud Platform (GCP) using Cloud Run and connect it with persistent storage in a Google Cloud Storage (GCS) bucket. This setup ensures that your ChromaDB service is secure and backed by GCP's robust infrastructure.


## Prerequisites

Before proceeding, please ensure you have the following:

- A Google Cloud account.
- The `gcloud` CLI installed and authenticated with your Google Cloud account.
- A Google Cloud project set up.

If you are new to GCP or `gcloud` CLI, Google provides extensive documentation to get you started.

Note: be sure to have a recent version of `gcloud` CLI installed, as the deployment is using CSI volumes for Cloud Run (early 2023). You can update your `gcloud` CLI with the following command: `gcloud components update`.

Shell scripts are used, consider using Git Bash on Windows if no Unix-like shell is installed on the environment.

Clone this project onto your environmment to customize setup parameters, as explained below.


## Prepare information for deployment

The following parameters will be used to customize the deployment of the ChromaDB service on Cloud Run. Please review and prepare them for the deployment steps below.
| Parameter             | Description |
|-----------------------|-------------|
| `<YOUR_BUCKET_NAME>`  | The name of the Google Cloud Storage bucket where the ChromaDB data will be stored. This bucket will be created in the next step. |
| `<REGION>`            | The region where the Google Cloud Storage bucket and the Cloud Run service will be deployed. Choose a region based on your requirements and the location of your users, e.g., `europe-west1` for the EU West region, `us-central1` for the US Central region. |
| `<YOUR_PROJECT_ID>`   | The ID of your Google Cloud project. You can find your project ID in the Google Cloud Console, under the project name or in the project settings page. |
| `<SERVICE_NAME>`      | The name of the Cloud Run service (e.g., `chroma`). |
| `<SERVICE_ACCOUNT>`   | The GCP service account to run the service. Usually, the default Compute Engine service account is used, which can be found on the Google Cloud project IAM page. However, it is a better security practice to have a dedicated service account created for the service. |
| `<API_TOKEN>`         | The API token to be used for authentication. This token will be used to authenticate requests to the ChromaDB service. You can generate a token using the `generate_token.sh` script provided in this repository. |


## Step 1: Create a Google Cloud Storage Bucket

First, create a dedicated GCS bucket for persistent storage of the ChromaDB data. Replace `<YOUR_BUCKET_NAME>` with your desired bucket name, `<REGION>` with the region name (e.g., `europe-west1`), and `<YOUR_PROJECT_ID>` with your Google Cloud project ID.

```bash
gsutil mb -p <YOUR_PROJECT_ID> -l <REGION> gs://<YOUR_BUCKET_NAME>/
```

Replace `<REGION>` with the desired region for your bucket. For example, `europe-west1` for the EU West region, `us-central1` for the US Central region. This bucket will be used to store the ChromaDB data, ensuring data persistence even if the Cloud Run service is scaled down or restarted.


## Step 2: Generate a custom Cloud Run yaml file

The script `generate_yaml.sh` is provided to generate a custom version of the Cloud Run yaml file with your specific bucket name and project ID. Edit the bash script to replace the following variables:
- `SERVICE_NAME`: name of the Cloud Run service (default: chroma)
- `SERVICE_ACCOUNT`: GCP service account to run the service (usually the default Compute Engine SA, get its name from the Google Cloud project IAM page)
- `SERVICE_REGION`: name of the region the service will be deployed to (example: europe-west1)
- `API_TOKEN`: an alphanumeric sequence to be generated as wanted. Make sure to replace the example to avoid unwanted access.
- `BUCKET_NAME`: name of the bucket created in Step 1


## Step 3: Deploy the Cloud Run Service

Run gcloud command to deploy the service:
```bash
gcloud run services replace deploy.yaml --project <YOUR_PROJECT_ID>
```
Note: you can copy paste the second command from the output of the step 2 command.


## Step 4: Allow unauthenticated traffic on the service

Run gcloud command to allow unauthenticated traffic on the service.
```bash
gcloud run services add-iam-policy-binding <SERVICE_NAME> --member="allUsers" --role="roles/run.invoker" --region=<REGION> --project=<YOUR_PROJECT_ID>
```
Note: you can copy paste the second command from the output of the step 2 command.

Remark: it is not possible to instruct this from the YAML file.


## Step 5: Check Chroma is running fine

Get the ChromaDB service URL and check it's running fine by sending a GET request to `/api/v1/heartbeat` endpoint. Replace `<YOUR_SERVICE_URL>` with the URL of your deployed Cloud Run service. You can get the URL from the output of the previous command or by checking the Cloud Run service details in the Google Cloud Console.

```bash
curl <YOUR_SERVICE_URL>/api/v1/heartbeat
```

You should receive a response similar to this, indicating that the ChromaDB service is running correctly:
```json
{"nanosecond heartbeat":1724920144119441795}
```


## Step 6: Test the ChromaDB Service

Now refer to Chroma documentation to test the ChromaDB service. You can use the Python client, REST API, or any other supported client to interact with the ChromaDB service. Make sure to use the correct API token and service URL when configuring the client.

### Using Chroma Python Client

Install the Chroma Python client library using pip: `pip install chromadb`. Then, use the following code to interact with the ChromaDB service. Replace `<YOUR_SERVICE_URL>` and `<YOUR_API_TOKEN>` with the URL and API token of your deployed Cloud Run service. You can get the API token from the `deploy.yaml` file or the Cloud Run service details in the Google Cloud Console.

```python	
import chromadb
from chromadb.config import Settings

# Create a Chroma client with the service URL and API token
client = chromadb.HttpClient(host="<YOUR_SERVICE_URL>", port=443, ssl=True,
                             settings=Settings(chroma_client_auth_provider="chromadb.auth.token_authn.TokenAuthClientProvider",
                                               chroma_client_auth_credentials="abcdefghijklmnopqrstuvwxyz",
                                               anonymized_telemetry=False))
```

Now you can use the `client` object to interact with the ChromaDB service, such as creating collections, adding documents, querying documents, etc. Refer to the Chroma documentation for more details on how to use the Python client library.
