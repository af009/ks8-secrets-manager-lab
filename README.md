# AWS Lab: Mounting secrets from AWS Secrets Manager

### This project is based on the EKS workshop to get familiar with secrets implementation in AWS


## How to use?

* Install make in order to run Makefile
* Clone this repo

## First part: 
### Secrets Store CSI Secret driver and AWS Secrets and Configuration Provider (ASCP).

1. Run ` make fp_runAll`
2. Finally, we wait until for the daemonsets confirmation.

## Second Part:
### Prepare secret and IAM access controls


1. Manually declaration
 ```shell
 AWS_REGION="us-east-1"
 EKS_CLUSTERNAME="eksworkshop-eksctl"
 ```
2.    
```bash
aws --region "$AWS_REGION" secretsmanager create-secret --name DBSecret_eksworkshop --secret-string '{"username":"foo", "password":"super-sekret"}';

sleep 5

SECRET_ARN=$(aws --region "$AWS_REGION" secretsmanager describe-secret --secret-id  DBSecret_eksworkshop --query 'ARN' | sed -e 's/"//g');

sleep 5

echo "$SECRET_ARN"

IAM_POLICY_NAME_SECRET="DBSecret_eksworkshop_secrets_policy_$RANDOM";

sleep 5

IAM_POLICY_ARN_SECRET=$(aws --region "$AWS_REGION" iam \
	create-policy --query Policy.Arn \
    --output text --policy-name $IAM_POLICY_NAME_SECRET \
    --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["'"$SECRET_ARN"'" ]
    } ]
}');

sleep 5
echo "$IAM_POLICY_ARN_SECRET" | tee -a 00_iam_policy_arn_dbsecret;

eksctl utils associate-iam-oidc-provider \
    --region="$AWS_REGION" --cluster="$EKS_CLUSTERNAME" \
    --approve;

sleep 10

eksctl create iamserviceaccount \
    --region="$AWS_REGION" --name "nginx-deployment-sa"  \
    --cluster "$EKS_CLUSTERNAME" \
    --attach-policy-arn "$IAM_POLICY_ARN_SECRET" --approve \
    --override-existing-serviceaccounts;
```

## Third Part:
###  Deploy pods with mounted secrets

1. Run `make part3_runAll`

## Fourth Part:

1. Run `make part4_runAll`

2. Verify the result:

3. Then run the next command inside the pod bash:
```shell
export PS1='# '
cd /mnt/secrets
ls -l   #--- List mounted secrets

cat dbusername; echo  
cat dbpassword; echo
cat DBSecret_eksworkshop; echo

env | grep DB    #-- Display two ENV variables set from the secret values
sleep 2
exit
```
## Finally, Clean the lab:

1. Run the followings commands

```shell
kubectl delete -f nginx-deployment-k8s-secrets.yaml
rm nginx-deployment-k8s-secrets.yaml

kubectl delete -f nginx-deployment-spc-k8s-secrets.yaml
rm nginx-deployment-spc-k8s-secrets.yaml

kubectl delete -f nginx-deployment.yaml
rm nginx-deployment.yaml

kubectl delete -f nginx-deployment-spc.yaml
rm nginx-deployment-spc.yaml

eksctl delete iamserviceaccount \
    --region="$AWS_REGION" --name "nginx-deployment-sa"  \
    --cluster "$EKS_CLUSTERNAME" 

sleep 5

aws --region "$AWS_REGION" iam \
	delete-policy --policy-arn $(cat 00_iam_policy_arn_dbsecret)
unset IAM_POLICY_ARN_SECRET
unset IAM_POLICY_NAME_SECRET
rm 00_iam_policy_arn_dbsecret

aws --region "$AWS_REGION" secretsmanager \
  delete-secret --secret-id DBSecret_eksworkshop --force-delete-without-recovery

kubectl delete -f \
 https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

helm uninstall -n kube-system csi-secrets-store
helm repo remove secrets-store-csi-driver
```

## Done!
