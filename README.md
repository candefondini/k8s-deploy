Trabajo Práctico - Cloud Computing - ITU UNCuyo

# 🐳 Despliegue de sitio web estático en Kubernetes (TP Producción)

Este repositorio contiene los manifiestos YAML necesarios para desplegar un sitio web estático utilizando Minikube y Kubernetes. La solución implementa un volumen persistente, un `Deployment` de Nginx, y un `Service` de tipo `NodePort` para exponer el sitio de manera local.

## Estructura del repositorio

k8s-deploy/
├── deployment.yaml
├── persistentvolume.yaml
├── persistentvolumeclaim.yaml
└── service.yaml


## Requisitos

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Docker instalado y funcionando como backend
- Git

## Pasos para ejecutar el despliegue

### 1. Clonar el repositorio

git clone https://github.com/candefondini/k8s-deploy.git
cd k8s-deploy

### 2. Iniciar Minikube con perfil de producción

minikube start --driver=docker -p produccion --addons=metrics-server,dashboard

### 3. Aplicar los manifiestos

kubectl apply -f persistentvolume.yaml
kubectl apply -f persistentvolumeclaim.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

### 4. Verificar que todo esté funcionando

kubectl get pv
kubectl get pvc
kubectl get pods
kubectl get svc

### 5. Acceder al sitio web

minikube service ejemplo-service -p produccion


## Archivos importantes

| `deployment.yaml` | Define el despliegue de Nginx con 2 réplicas. |
| `service.yaml` | Exposición del servicio con `NodePort` (puerto 30080). |
| `persistentvolume.yaml` | Define el volumen físico disponible. |
| `persistentvolumeclaim.yaml` | Reclama el volumen para los pods. |


## Notas

- El contenido del sitio web se basa en un fork personalizado del repo [static-website](https://github.com/ewojjowe/static-website), disponible en:  
   https://github.com/candefondini/mi-static-website

- La solución garantiza persistencia de datos a través del PVC, incluso si los pods se reinician.

