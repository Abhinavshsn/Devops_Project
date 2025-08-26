#### Steps

1. Clone the git repo and make sure you have the persistent volume host path and edit the same in deploy.sh 'VOLUME_DIR' variable.
2. Mount that path into your wsl2 ubuntu
3. Run the deploy.sh which will give you 1+3 nodes and 5 namespaces with all the tools.
4. Ingress controller won't work in wsl2 docker desktop so no use of ingress.sh.
5. Use destroy.sh to delete the resources.Don't worry all the data will be present in the host path which you mounted for next use.
6. Powershell script is also of no use.
7. Edit .wslconfig file in C:\Users\abhin to limit resources for wsl
   [wsl2]
   memory=6GB         # Limit WSL2 to 6GB RAM
   processors=2       # Limit to 2 CPU cores
   swap=1GB           # Optional swap space
8. Use port forwarding as below
   # Jenkins
      kubectl port-forward svc/jenkins 8080:8080 -n cicd &

   # ArgoCD
      kubectl port-forward svc/argo-argocd-server 8081:80 -n cicd &

   # Grafana
      kubectl port-forward svc/grafana 3000:80 -n monitoring &

   # Prometheus
      kubectl port-forward svc/prometheus-server 9090:80 -n monitoring &
  