#!/bin/bash


export PROJECT_ID=$1

export PROJECT_NUMBER="$(gcloud projects describe $PROJECT_ID --format='get(projectNumber)')"
export NETWORK=gke-network
export SUBNETWORK=gke-subnet
export REGION=europe-west1
export ZONE=europe-west1-c
export ROUTER=gke-router
export NAT=gke-nat
export SA_GKE=gke-sa
export CLUSTER=gke-cluster
export CLUSTER_CONTROL_PLANE_CIDR=172.16.0.0/28

gcloud config set project $PROJECT_ID

gcloud container clusters delete $CLUSTER \
    --zone $ZONE \
    --quiet

gcloud iam service-accounts delete $SA_GKE@$PROJECT_ID.iam.gserviceaccount.com \
    --quiet

gcloud compute routers nats delete $NAT \
    --router $ROUTER \
    --region=$REGION \
    --quiet

gcloud compute routers delete $ROUTER \
    --region=$REGION \
    --quiet

gcloud compute networks subnets delete $SUBNETWORK \
    --region=$REGION \
    --quiet

gcloud compute networks delete $NETWORK \
    --quiet