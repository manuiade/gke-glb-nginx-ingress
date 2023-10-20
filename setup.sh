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

# Create VPC
gcloud compute networks create $NETWORK \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional

# Create subnetwork
gcloud compute networks subnets create $SUBNETWORK \
    --range=10.100.0.0/20  \
    --network=$NETWORK \
    --region=$REGION

# Enable nodes access to Internet
gcloud compute routers create $ROUTER \
    --network=$NETWORK \
    --region=$REGION

gcloud compute routers nats create $NAT \
    --router $ROUTER \
    --region=$REGION \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges

### Create GKE cluster with Gateway APIs enabled
gcloud iam service-accounts create $SA_GKE

# Create private cluster
gcloud container clusters create $CLUSTER \
  --zone $ZONE \
  --enable-private-nodes \
  --master-ipv4-cidr $CLUSTER_CONTROL_PLANE_CIDR \
  --no-enable-master-authorized-networks \
  --enable-ip-alias \
  --service-account $SA_GKE@$PROJECT_ID.iam.gserviceaccount.com \
  --num-nodes 2 \
  --spot

gcloud container clusters get-credentials $CLUSTER --zone $ZONE