POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[].metadata.name}')
export POD_NAME
kubectl exec -it "${POD_NAME}" -- cat /mnt/secrets/DBSecret_eksworkshop; echo
