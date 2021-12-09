cat << EOF > nginx-deployment-spc.yaml
---
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: nginx-deployment-spc
spec:
  provider: aws
  parameters:
    objects: |
        - objectName: "DBSecret_eksworkshop"
          objectType: "secretsmanager"
EOF
