#!/bin/bash

set -e
set -o pipefail

PROFILE="produccion"
IMAGE="candefondini24/static-website"
REPO_MANIFESTS="https://github.com/candefondini/k8s-deploy.git"
REPO_DIR="k8s-deploy"

function log() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

function error_exit() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

log "Iniciando Minikube con perfil '$PROFILE'..."
minikube start --driver=docker -p "$PROFILE" --addons=metrics-server,dashboard || error_exit "No se pudo iniciar Minikube."

log "Verificando estado del clúster Minikube..."
minikube status -p "$PROFILE" | grep -q "host: Running" || error_exit "Minikube no está corriendo correctamente."

if [ ! -d "$REPO_DIR" ]; then
  log "Clonando repositorio de manifiestos..."
  git clone "$REPO_MANIFESTS" || error_exit "Error al clonar el repositorio de manifiestos."
fi
cd "$REPO_DIR"

log "Aplicando deployment y service YAML..."
kubectl apply -f deployment.yaml || error_exit "Error al aplicar deployment.yaml."
kubectl apply -f service.yaml || error_exit "Error al aplicar service.yaml."

log "Esperando que el pod esté en estado Running..."
POD_NAME=""
for i in {1..20}; do
  POD_NAME=$(kubectl get pods --no-headers | grep "$IMAGE" | awk '{print $1}')
  STATUS=$(kubectl get pod "$POD_NAME" -o jsonpath='{.status.phase}')
  [ "$STATUS" == "Running" ] && break
  sleep 2
done
[ "$STATUS" != "Running" ] && error_exit "El pod no está en estado Running."

log "Obteniendo URL del servicio..."
URL=$(minikube service ejemplo-service -p "$PROFILE" --url)

log "Esperando a que el sitio responda..."
for i in {1..10}; do
  curl -s --head "$URL" | grep -q "200 OK" && break
  sleep 2
done
curl -s --head "$URL" | grep -q "200 OK" || error_exit "El sitio no responde correctamente."

log "Sitio desplegado exitosamente: $URL"
echo -e "\n✅ Accedé al sitio desde: $URL"

exit 0
