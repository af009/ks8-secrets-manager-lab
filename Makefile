# First part: Prepare your cluster by installing:
# Secrets Store CSI Secret driver and
# AWS Secrets and Configuration Provider (ASCP).

1 || create_cluster:
	eksctl create cluster -f eks.yaml; \

2 || helm_add_secrets_store: 1
	helm repo add secrets-store-csi-driver \
      https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/charts

3 || helm_install_secrets_store: 2
	helm install -n kube-system csi-secrets-store \
      --set syncSecret.enabled=true \
      --set enableSecretRotation=true \
      secrets-store-csi-driver/secrets-store-csi-driver \

4 || apply_ASCP: 3
	kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

# First Part commands & Check installation
fp_runAll: 1 2 3 4
	sleep 5; \
	kubectl get daemonsets -n kube-system -l app=csi-secrets-store-provider-aws; \
    kubectl get daemonsets -n kube-system -l app.kubernetes.io/instance=csi-secrets-store


# Second Part: Prepare secret and IAM access controls
# Manually implemented

# Part 3: Deploy pods with mounted secrets

10 || create_spc_deployment:
	bash ./part3/create_spc_deployment.sh

11 || create_custom_resource: 10
	kubectl apply -f nginx-deployment-spc.yaml;\
    kubectl get SecretProviderClass

12 || create_nginx_deployment:
	bash ./part3/create_nginx_deployment.sh

13 || apply_nginx_deploy: 12
	kubectl apply -f nginx-deployment.yaml;\
    sleep 10; \
    kubectl get pods -l "app=nginx"

14 || verify_mounted_secret: 13
	bash ./part3/verify_mounted_secret.sh

part3_runAll: 10 11 12 13 14
	echo 'Third part done'

# Part 4: Sync with native Kuberbetes secrets

15 || create_provider_class:
	bash ./part4/secret_provider_class_template.sh

16 || create_pod_mount_secret: 15
	bash ./part4/create_pod_mount_secret_vol.sh

17 || check_mounted_secrets: 16
	bash ./part4/check_pod_secrets.sh

part4_runAll: 15 16 17
	echo 'Done!'


