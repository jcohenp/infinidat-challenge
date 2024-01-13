# Infinidat challenge 

This repository contains various resources and configurations for managing a Kubernetes environment using Ansible, Kubernetes configurations, and more.

## Prerequisites

- **Git**: For cloning the repository and managing the source code.
- **Environment**: EC2 machine running on Ubuntu V22.04 operating system


## Folder Structure:

- **ansible_kubernetes/**: Contains Ansible playbooks and roles for managing the Kubernetes environment.
  - **roles/**: Directory housing individual Ansible roles for specific configurations or tasks within the Kubernetes setup.
    - **flask-app**: Role to set up the deployment and service of our flask app
    - **monitoring**: Set up prometheus with grafana
  - **ansible_install.sh**: script to install ansible on ubuntu system
  - **prepare_cluster.sh**: script used by ansible to prepare the system before initialized the kubernetes cluster 
- **templates**: htmls files that are used for the endpoints/routes
    - **hello.html**: route to display hello to the user
    - **about.html**: information about me
    - **error.html**: error page when a route is not found
- **k8s**: Contains the kubernetes yaml files to deploy the flask app
    - **deployment.yaml**: deployment of the flask app
    - **flask-svc.yaml**: service to expose the deployment
- **Dockerfile**: used to build the flask app before to push to the docker registry.
- **README.md**: This document providing instructions, explanations, and a guide on how to use the repository.
- **appy.py**: flask app with 2 routes and logging system used by the dockerfile
- **requirements.txt**: dependencies used to run properly the flask app

## Actions Performed:

- **Dockerfile**:
    - The Dockerfile, would be used for defining the steps to create a Docker image encapsulating a specific application within the Kubernetes environment. It might detail the necessary dependencies, commands, and configurations required to build the image.

- **Ansible Playbooks (`ansible_kubernetes/`)**:
  - Utilizes Ansible playbooks to automate Kubernetes environment setup, including installation, configuration, and management of services.
  - Installing Kubernetes main components: 
    - Kubectl: CLI used to communicate with the Kubernetes cluster
    - Kubelet: componenent that is facilitate the communication between control plane and normal nodes, execution of containarized app ...
    - Kubeadm: tool that is used to manage the cluster, init, update, maintenance...
  -  Creation of a new user that will be used to communicate with the kubernetes cluster

- **k8s**:
Deployment of the flask-app will be set with replicas, in this way it will ensure that if one crash another one continue to work.

### Configuration:

1. **Clone this repository:**

    ```
    git clone https://github.com/jcohenp/infinidat-challenge.git
    ```
2. **Build the Docker Image:**

    ```
    sudo docker build -t infinidat-app .
    ```
3. **Create a tag:**

    ```
    sudo docker tag <imageID> docker.io/jcohenp/infinidat-app
    ```
4. **Push the image in the Docker registry**

    ```
    sudo docker push docker.io/jcohenp/infinidat-app
    ```
    
5. **Installation of ansible**:
    ```
    cd ansible_kubernetes
    ./ansible_install.sh
    ``` 
6. **Update the `inventory` file with the IP address of your AWS EC2 instance:**

    ```ini
    [kubernetes-nodes]
    <your_instance_ip> ansible_user=ubuntu ansible_ssh_private_key_file=<path_to_ssh_key>
    ```

7. **Execute the initial setup playbook:**

    ```
    ansible-playbook -i inventory.ini kubernetes_deploy.yaml
    ```
    
8. **Connect to the new kubernetes user:**
    
    ```
    sudo su kubernetes
    ```

9. **Check if everything is setup on your kubernetes cluster:**
    
    **kubectl get nodes -o wide**
    ```
    NAME              STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    ip-172-31-27-42   Ready    control-plane   24m   v1.28.5   172.31.27.42   <none>        Ubuntu 22.04.3 LTS   6.2.0-1017-aws   containerd://1.7.2
    ```
    **kubectl get all -A**

    ```
    NAMESPACE      NAME                                                         READY   STATUS    RESTARTS   AGE
    default        pod/flask-app-5bccc6cfc4-fp8l2                               1/1     Running   0          24m
    default        pod/flask-app-5bccc6cfc4-mqw9b                               1/1     Running   0          24m
    kube-flannel   pod/kube-flannel-ds-8vd86                                    1/1     Running   0          24m
    kube-system    pod/coredns-5dd5756b68-hmfrj                                 1/1     Running   0          24m
    kube-system    pod/coredns-5dd5756b68-t7lx2                                 1/1     Running   0          24m
    kube-system    pod/etcd-ip-172-31-27-42                                     1/1     Running   3          25m
    kube-system    pod/kube-apiserver-ip-172-31-27-42                           1/1     Running   3          25m
    kube-system    pod/kube-controller-manager-ip-172-31-27-42                  1/1     Running   3          25m
    kube-system    pod/kube-proxy-622dj                                         1/1     Running   0          24m
    kube-system    pod/kube-scheduler-ip-172-31-27-42                           1/1     Running   3          25m
    prometheus     pod/alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          24m
    prometheus     pod/prometheus-grafana-77c588fccf-qspsd                      3/3     Running   0          24m
    prometheus     pod/prometheus-kube-prometheus-operator-5f8cbfb69c-6gqhl     1/1     Running   0          24m
    prometheus     pod/prometheus-kube-state-metrics-6db866c85b-h4rt6           1/1     Running   0          24m
    prometheus     pod/prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          24m
    prometheus     pod/prometheus-prometheus-node-exporter-qczcp                1/1     Running   0          24m
    
    NAMESPACE     NAME                                                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
    default       service/flask-svc                                            LoadBalancer   10.105.107.84    <pending>     80:32144/TCP                    25m
    default       service/kubernetes                                           ClusterIP      10.96.0.1        <none>        443/TCP                         25m
    kube-system   service/kube-dns                                             ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP          25m
    kube-system   service/prometheus-kube-prometheus-coredns                   ClusterIP      None             <none>        9153/TCP                        24m
    kube-system   service/prometheus-kube-prometheus-kube-controller-manager   ClusterIP      None             <none>        10257/TCP                       24m
    kube-system   service/prometheus-kube-prometheus-kube-etcd                 ClusterIP      None             <none>        2381/TCP                        24m
    kube-system   service/prometheus-kube-prometheus-kube-proxy                ClusterIP      None             <none>        10249/TCP                       24m
    kube-system   service/prometheus-kube-prometheus-kube-scheduler            ClusterIP      None             <none>        10259/TCP                       24m
    kube-system   service/prometheus-kube-prometheus-kubelet                   ClusterIP      None             <none>        10250/TCP,10255/TCP,4194/TCP    24m
    prometheus    service/alertmanager-operated                                ClusterIP      None             <none>        9093/TCP,9094/TCP,9094/UDP      24m
    prometheus    service/prometheus-grafana                                   LoadBalancer   10.111.170.214   <pending>     80:30713/TCP                    24m
    prometheus    service/prometheus-kube-prometheus-alertmanager              ClusterIP      10.104.36.224    <none>        9093/TCP,8080/TCP               24m
    prometheus    service/prometheus-kube-prometheus-operator                  ClusterIP      10.96.157.189    <none>        443/TCP                         24m
    prometheus    service/prometheus-kube-prometheus-prometheus                LoadBalancer   10.97.252.202    <pending>     9090:32734/TCP,8080:31297/TCP   24m
    prometheus    service/prometheus-kube-state-metrics                        ClusterIP      10.102.225.112   <none>        8080/TCP                        24m
    prometheus    service/prometheus-operated                                  ClusterIP      None             <none>        9090/TCP                        24m
    prometheus    service/prometheus-prometheus-node-exporter                  ClusterIP      10.102.78.108    <none>        9100/TCP                        24m
    
    NAMESPACE      NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    kube-flannel   daemonset.apps/kube-flannel-ds                       1         1         1       1            1           <none>                   25m
    kube-system    daemonset.apps/kube-proxy                            1         1         1       1            1           kubernetes.io/os=linux   25m
    prometheus     daemonset.apps/prometheus-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   24m
    
    NAMESPACE     NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
    default       deployment.apps/flask-app                             2/2     2            2           25m
    kube-system   deployment.apps/coredns                               2/2     2            2           25m
    prometheus    deployment.apps/prometheus-grafana                    1/1     1            1           24m
    prometheus    deployment.apps/prometheus-kube-prometheus-operator   1/1     1            1           24m
    prometheus    deployment.apps/prometheus-kube-state-metrics         1/1     1            1           24m
    
    NAMESPACE     NAME                                                             DESIRED   CURRENT   READY   AGE
    default       replicaset.apps/flask-app-5bccc6cfc4                             2         2         2       24m
    kube-system   replicaset.apps/coredns-5dd5756b68                               2         2         2       24m
    prometheus    replicaset.apps/prometheus-grafana-77c588fccf                    1         1         1       24m
    prometheus    replicaset.apps/prometheus-kube-prometheus-operator-5f8cbfb69c   1         1         1       24m
    prometheus    replicaset.apps/prometheus-kube-state-metrics-6db866c85b         1         1         1       24m
    
    NAMESPACE    NAME                                                                    READY   AGE
    prometheus   statefulset.apps/alertmanager-prometheus-kube-prometheus-alertmanager   1/1     24m
    prometheus   statefulset.apps/prometheus-prometheus-kube-prometheus-prometheus       1/1     24m
    ```

10. **Validate that the flask app is reachable insinde the cluster (service ip on port 80):**

    **curl -vv 10.105.107.84**

    ```
    *   Trying 10.105.107.84:80...
    * Connected to 10.105.107.84 (10.105.107.84) port 80 (#0)
    > GET / HTTP/1.1
    > Host: 10.105.107.84
    > User-Agent: curl/7.81.0
    > Accept: */*
    > 
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 200 OK
    < Server: Werkzeug/3.0.1 Python/3.9.18
    < Date: Sat, 13 Jan 2024 11:25:45 GMT
    < Content-Type: text/html; charset=utf-8
    < Content-Length: 278
    < Connection: close
    < 
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hello Page</title>
    </head>
    <body>
        <h1>Hello!</h1>
        <p>Welcome to my website. Feel free to explore!</p>
    </body>
    * Closing connection 0
    ```

11. **Validate that the flask app is reachable outside the cluster (public ip on port 31401):**
    
    **curl -vv 18.234.85.169:32144**
    ```
    *   Trying 18.234.85.169:32144...
    * Connected to 18.234.85.169 (18.234.85.169) port 32144 (#0)
    > GET / HTTP/1.1
    > Host: 18.234.85.169:32144
    > User-Agent: curl/7.81.0
    > Accept: */*
    > 
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 200 OK
    < Server: Werkzeug/3.0.1 Python/3.9.18
    < Date: Sat, 13 Jan 2024 11:26:58 GMT
    < Content-Type: text/html; charset=utf-8
    < Content-Length: 278
    < Connection: close
    < 
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hello Page</title>
    </head>
    <body>
        <h1>Hello!</h1>
        <p>Welcome to my website. Feel free to explore!</p>
    </body>
    * Closing connection 0    
    ```
12. **Accessing grafana outside the cluster - change svc type from ClusterIP to LoadBalancer**:
   
    ```
    kubectl edit svc prometheus-kube-prometheus-prometheus -n prometheus
    kubectl edit svc prometheus-grafana -n prometheus
    ```
13. **login to grafana using \<publicip>:\<loadBalancerPort>**
14. **Get default password for grafana**:

    kubectl get secret --namespace prometheus prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```
    prom-operator
    ```
15. **create a new dashboard in grafana and get promotheus data**:
    ```
    Click '+' button on left panel and select 'Import'.
    
    Enter 12740 dashboard id under Grafana.com Dashboard.
    
    Click 'Load'.
    
    Select 'Prometheus' as the endpoint under prometheus data sources drop down.
    
    Click 'Import'.
    ```

## Project Enhancement Plan

### Domain and Certificate
- **Domain Creation**: Register a domain name to uniquely identify the project.
- **Certificate Authority (CA)**: Obtain an SSL/TLS certificate from a trusted Certificate Authority

### Continuous Deployment
- **Jenkins Pipeline**: Establish a continuous deployment pipeline in Jenkins to automate the build process on docker registry + deployment of new nodes.

### Kubernetes Cluster Setup
- **Master and Worker Nodes**: Create a Kubernetes cluster architecture with dedicated master nodes for administrative tasks and worker nodes for application-related activities.
- **Security Analysis**: Implement security measures for the Kubernetes cluster, including pods, to ensure robust protection against vulnerabilities and unauthorized access.


### Security Measures
- **Web Application Firewall (WAF)**: Implement a WAF to control and manage incoming traffic, allowing filtering based on predefined rules to block potentially malicious IP addresses.

### Secrets Management
- If any sensitive data is used (e.g., SSL certificates, API keys), demonstrate how to manage these securely within the deployment process.

### Automated Testing:
- Introduce automated testing into the CI/CD pipeline to verify the functionality and performance of the deployed application automatically.

### Scalability and High Availability:
- Address how the Kubernetes deployment can be scaled horizontally or made highly available, especially if this application is part of a production environment.
- Horizontal Pod Autoscaling (HPA) to autoscale the load of the kubernetes pods according to the CPU usage
- Pod Anti Affinity to avoid setting up replicas on the same node (in case where severals worker nodes are availables)
