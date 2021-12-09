cat << EOF > nginx-deployment-spc-k8s-secrets.yaml
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: nginx-deployment-spc-k8s-secrets
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "DBSecret_eksworkshop"
        objectType: "secretsmanager"
        jmesPath:
          - path: username
            objectAlias: dbusername
          - path: password
            objectAlias: dbpassword
  # Create k8s secret. It requires volume mount first in the pod and then sync.
  secretObjects:
    - secretName: my-secret-01
      type: Opaque
      data:
        #- objectName: <objectName> or <objectAlias>
        - objectName: dbusername
          key: db_username_01
        - objectName: dbpassword
          key: db_password_01
EOF

sleep 10
kubectl apply -f nginx-deployment-spc-k8s-secrets.yaml
sleep 10
kubectl get SecretProviderClass nginx-deployment-spc-k8s-secrets
