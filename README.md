# Infrastructure

## Terraform

A series of Terraform modules to deploy our infrastructure on Google Cloud
located in the `./terraform` folder. On each push our private project on
[Terraform Cloud](https://api.terraform.io) applies the changes to our GCP
Projects.

### Setup

In each of our GCP project, `ask-and-attest` and `ask-and-attest`:

* Create a service account for Terraform with:
  * Project editor permissions
  * Compute Network Admin Permissions
* Enable the Google Cloud SQL Admin API
* Enable the Cloud Resource Manager API
* Enable the Service Networking API

### Production

In the `./terraform/production` folder, we create Terraform modules in the
`Neon-Law` GCP project.

* A VPC or private network named private-network
* A PostgreSQL database.
* A Container Registry located in the United States
* A Google Kubernetes Engine Cluster in the Las Vegas Region

#### Interface, hosted at https://www.askandattest.com

* A Kubernetes Deployment for the `interface` project
* A Kubernetes Service for the `interface` project
* A Kubernetes Ingress for the `interface` project (GCP Load Balancer)
  * This includes a SSL cert for https://www.askandattest.com

### Staging

In the `./terraform/staging` folder, we create Terraform modules in the
`Neon-Law-Development` GCP project.

* A VPC or private network named private-network
* A PostgreSQL database.
* A Container Registry located in the United States
* A Google Kubernetes Engine Cluster in the Las Vegas Region

#### Interface, hosted at https://www.neonlaw.com

* A Kubernetes Deployment for the `interface` project
* A Kubernetes Service for the `interface` project
* A Kubernetes Ingress for the `interface` project (GCP Load Balancer)
  * This includes a SSL cert for https://www.askandattest.com

## Legal

Copyright 2020 Ask And Attest. Licensed under the [Apache License Version
2.0](https://www.apache.org/licenses/LICENSE-2.0.txt).
