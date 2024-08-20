# Atlas Kubernetes Operator and Minikube

Get a kubernetes cluster, the MongoDB Atlas Kubernetes Operator and and Atlas Project/Database setup in minimal time/effort

## Requirements
- minikube if you want this script to setup a cluster for you
- An Atlas account (where you will deploy your cluster)
- An Atlas API Key (how the operator talks to Atlas)

## Usage
Simply run this command (from this folder) and follow the prompts:
```
bash quick-start.sh # on linux/mac
powershell quick-start.ps1 # on windows
```

You can then take a look at the generated `deploy-a-cluster.yaml` file, or run:
```
kubectl apply -f deploy-a-cluster.yaml
```

This will create your secret (forgit push origin  your api key), your project, and an m10 deployment. It will also set up a tag with the projectname you provided and a keep.until variable (which we use to automatically remove test clusters) set to tomorrow.

## to restore and create vector search along with ready embedded data with fireworks ai
1. after finishing the above step and made sure that the cluser is reflected successfully in the UI fully deployed.
2. extract the attached mongodump.zip in any location to use later, can be in same folder or in downloads folder for example.
3. run (on mac only for now):
```
bash restore.sh 
```
and add the extracted folder location + MongoDB Atlas connection URI, for example mongodb+srv://<username>:<password>@<cluster-url>/?retryWrites=true&w=majority
4. that's it.
ps: book used was https://github.com/karlseguin/the-little-mongodb-book 

## extras
if you want to explore with running it against chatbot using fireworks ai with npm and ui, you can use the reference here and get the trial API, in this case you can use https://docs.google.com/document/d/199oT1BBqkB7VM4aHjgNWEdAFF_WgA1vmm9uoTtqNE9s to run the server without the need for any ingest.

## Clean up
To remove the minikube cluster and any tools that where downloaded to this directory simply run
```
bash clean-up.sh # on linux/mac
powershell clean-up.sh # on windows
```
