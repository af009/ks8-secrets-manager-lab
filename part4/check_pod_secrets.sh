POD_NAME=$(kubectl get pods -l app=nginx-k8s-secrets -o jsonpath='{.items[].metadata.name}')
export POD_NAME
kubectl exec -it "${POD_NAME}" -- /bin/bash
