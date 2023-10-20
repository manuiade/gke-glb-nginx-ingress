# GLB Nginx Ingress

Setup Nginx Ingress Controller for url rewrite and other L7 features not currently supported by GCE Ingress Controller.
To further benefit from L7 exposition of GCE LB, the nginx ingress controller is deployed as a clusterIP NEG service.
The Ingress resource for the nginx ingress class redirects requests to backends, meanwhile the GCE Ingress is simpy
used to expose via L7 GLB the Nginx Ingress Controller.

Here path rewrite is configured via Nginx to test the effectiveness of the solution.


## Requirements

- GCP Project
- GCP User with enough GCP roles
- Helm for installing nginx ingress controller

## Setup

### Replace env vars for domain substitution

```
export MAIN_DOMAIN=<MAIN_DOMAIN>

sed -i "s/<MAIN_DOMAIN>/$MAIN_DOMAIN/g" ./gcp-lb-ingress.yaml
sed -i "s/<MAIN_DOMAIN>/$MAIN_DOMAIN/g" ./nginx-ingress.yaml
```

### Setup cluster

```
./setup.sh <PROJECT_ID>
```

### Deploy backend services

```
kubectl apply -f deployment-1.yaml
kubectl apply -f deployment-2.yaml
```

### Deploy health check configuration for nginx reverse proxy
```
kubectl apply -f nginx-ingress-bec.yaml
```

### Install nginx ingress controller with custom options
```
helm upgrade --install -f nginx-helm-values.yaml ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx
```

### Configure ingress resource for app backends
```
kubectl apply -f nginx-ingress.yaml
```

### Create GLB ingress with GCP certificate
```
kubectl apply -f gcp-lb-ingress.yaml
```

### Test call
```
curl https://$MAIN_DOMAIN/d1
curl https://$MAIN_DOMAIN/d2
```

## Clear


### Restore env vars name on YAML files

```
sed -i "s/$MAIN_DOMAIN/<MAIN_DOMAIN>/g" ./gcp-lb-ingress.yaml
sed -i "s/$MAIN_DOMAIN/<MAIN_DOMAIN>/g" ./nginx-ingress.yaml
```

### Clear resources
```
./delete.sh
```