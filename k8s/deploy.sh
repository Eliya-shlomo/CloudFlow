#!/bin/bash


set -e

APP_NAME= "cloudflow"
NAMESPACE= "default"
DEPLOYMENT_FILE= "deployment.yaml"
SERVICE_FILE= "service.yaml"

echo "Applying Deployment..."
kubectl apply -f $DEPLOYMENT_FILE

echo "Applying Service..."
kubectl apply -f $SERVICE_FILE

echo "Wating for external IP..."

while true; do
  EXTERNAL_IP=$(kubectl get svc ${APP_NAME}-service --namespace $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [[ -z "$EXTERNAL_IP" ]]; then
    echo "🔄 עדיין ממתין ל-EXTERNAL IP..."
    sleep 10
  else
    break
  fi
done

echo "✅"
echo "http://${EXTERNAL_IP}"