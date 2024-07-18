export MONGO_INFRA_MINIKUBE_IP=`minikube ip -p opsmanager`
export MONGO_INFRA_MINIKUBE_GLOBAL_API_PUBLIC=`kubectl get secret mongodb-mongo-infra-minikube-admin-key -o jsonpath={.data.publicKey} | base64 --decode`
export MONGO_INFRA_MINIKUBE_GLOBAL_API_PRIVATE=`kubectl get secret mongodb-mongo-infra-minikube-admin-key -o jsonpath={.data.privateKey} | base64 --decode`
export MEKO_namespace=mongodb

# Create an org/project
# echo "$MONGO_INFRA_MINIKUBE_GLOBAL_API_PUBLIC:$MONGO_INFRA_MINIKUBE_GLOBAL_API_PRIVATE"
curl --user "$MONGO_INFRA_MINIKUBE_GLOBAL_API_PUBLIC:$MONGO_INFRA_MINIKUBE_GLOBAL_API_PRIVATE"  \
    --digest \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --include \
    --request POST "http://$MONGO_INFRA_MINIKUBE_IP:30100/api/public/v1.0/orgs" \
    --data '{ "name" : "mongo-infra-minikube-organization" }'

export MONGO_INFRA_MINIKUBE_ORG=`curl --user "$MONGO_INFRA_MINIKUBE_GLOBAL_API_PUBLIC:$MONGO_INFRA_MINIKUBE_GLOBAL_API_PRIVATE" --digest \
 --header 'Accept: application/json' \
 --include \
 --request GET "http://$MONGO_INFRA_MINIKUBE_IP:30100/api/public/v1.0/orgs/?name=mongo-infra-minikube-organization&pretty=true" | tail -n 16 | grep id | awk '{print $3}'  | tr -d '"' | tr -d ","`

# Create secret, lets use the global for now, we can make an org key later which is the correct way to do it
kubectl -n "$MEKO_namespace"  \
create secret generic my-credentials \
--from-literal="publicKey=$MONGO_INFRA_MINIKUBE_GLOBAL_API_PUBLIC" \
--from-literal="privateKey=$MONGO_INFRA_MINIKUBE_GLOBAL_API_PRIVATE"

# Create config-map
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-project
  namespace: mongodb
data:
  projectName: mongo-infra-minikube
  orgId: $MONGO_INFRA_MINIKUBE_ORG
  baseUrl: http://mongo-infra-minikube-svc.mongodb.svc.cluster.local:8080
EOF


# Create deployment