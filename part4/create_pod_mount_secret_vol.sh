cat << EOF > nginx-deployment-k8s-secrets.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-k8s-secrets
  labels:
    app: nginx-k8s-secrets
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-k8s-secrets
  template:
    metadata:
      labels:
        app: nginx-k8s-secrets
    spec:
      serviceAccountName: nginx-deployment-sa
      containers:
      - name: nginx-deployment-k8s-secrets
        image: nginx
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 80
        volumeMounts:
          - name: secrets-store-inline
            mountPath: "/mnt/secrets"
            readOnly: true
        env:
          - name: DB_USERNAME_01
            valueFrom:
              secretKeyRef:
                name: my-secret-01
                key: db_username_01
          - name: DB_PASSWORD_01
            valueFrom:
              secretKeyRef:
                name: my-secret-01
                key: db_password_01
      volumes:
        - name: secrets-store-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: nginx-deployment-spc-k8s-secrets
EOF

sleep 10
kubectl apply -f nginx-deployment-k8s-secrets.yaml
sleep 10
kubectl get pods -l "app=nginx-k8s-secrets"
