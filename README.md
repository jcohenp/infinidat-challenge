# Infinidat challenge 

This repository contains various resources and configurations for managing a Kubernetes environment using Ansible, Kubernetes configurations, and more.

## Prerequisites

- **Git**: For cloning the repository and managing the source code.
- **Environment**: EC2 machine running on Ubuntu operating system


## Folder Structure:

- **ansible_kubernetes/**: Contains Ansible playbooks and roles for managing the Kubernetes environment.
  - **roles/**: Directory housing individual Ansible roles for specific configurations or tasks within the Kubernetes setup.
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
    ansible-playbook -i inventory kubernetes_deploy.yml
    ```
    
8. **Connect to the new kubernetes user:**
    
    ```
    sudo su kubernetes
    ```

9. **Check if everything is setup on your kubernetes cluster:**
    
    **kubectl get nodes -o wide**
    ```
    NAME               STATUS   ROLES           AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    ip-172-31-23-166   Ready    control-plane   3h3m   v1.28.2   172.31.23.166   <none>        Ubuntu 22.04.3 LTS   6.2.0-1017-aws   containerd://1.7.2
    ```
    **kubectl get all -A**

    ```
    NAMESPACE      NAME                                           READY   STATUS    RESTARTS   AGE
    default        pod/flask-app-5bccc6cfc4-24gtj                 1/1     Running   0          35m
    default        pod/flask-app-5bccc6cfc4-b7bh4                 1/1     Running   0          35m
    kube-flannel   pod/kube-flannel-ds-9ndgs                      1/1     Running   0          3h3m
    kube-system    pod/coredns-5dd5756b68-kntdw                   1/1     Running   0          3h3m
    kube-system    pod/coredns-5dd5756b68-np8xx                   1/1     Running   0          3h3m
    kube-system    pod/etcd-ip-172-31-23-166                      1/1     Running   2          3h4m
    kube-system    pod/kube-apiserver-ip-172-31-23-166            1/1     Running   2          3h4m
    kube-system    pod/kube-controller-manager-ip-172-31-23-166   1/1     Running   2          3h4m
    kube-system    pod/kube-proxy-p58qb                           1/1     Running   0          3h3m
    kube-system    pod/kube-scheduler-ip-172-31-23-166            1/1     Running   2          3h4m
    
    NAMESPACE     NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
    default       service/flask-svc    LoadBalancer   10.102.181.1   <pending>     80:31401/TCP             35m
    default       service/kubernetes   ClusterIP      10.96.0.1      <none>        443/TCP                  3h4m
    kube-system   service/kube-dns     ClusterIP      10.96.0.10     <none>        53/UDP,53/TCP,9153/TCP   3h4m
    
    NAMESPACE      NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    kube-flannel   daemonset.apps/kube-flannel-ds   1         1         1       1            1           <none>                   3h4m
    kube-system    daemonset.apps/kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   3h4m
    
    NAMESPACE     NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
    default       deployment.apps/flask-app   2/2     2            2           35m
    kube-system   deployment.apps/coredns     2/2     2            2           3h4m
    
    NAMESPACE     NAME                                   DESIRED   CURRENT   READY   AGE
    default       replicaset.apps/flask-app-5bccc6cfc4   2         2         2       35m
    kube-system   replicaset.apps/coredns-5dd5756b68     2         2         2       3h3m
    ```

10. **Validate that the flask app is reachable insinde the cluster (service ip on port 80):**

    **curl -vv 10.102.181.1**

    ```
    *   Trying 10.102.181.1:80...
    * Connected to 10.102.181.1 (10.102.181.1) port 80 (#0)
    > GET / HTTP/1.1
    > Host: 10.102.181.1
    > User-Agent: curl/7.81.0
    > Accept: */*
    > 
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 200 OK
    < Server: Werkzeug/3.0.1 Python/3.9.18
    < Date: Fri, 12 Jan 2024 12:34:30 GMT
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

11. ****Validate that the flask app is reachable outside the cluster (public ip on port 31401):****
    
    **curl -vv 3.80.64.20:31401**
    ```
    *   Trying 3.80.64.20:31401...
    * Connected to 3.80.64.20 (3.80.64.20) port 31401 (#0)
    > GET / HTTP/1.1
    > Host: 3.80.64.20:31401
    > User-Agent: curl/7.79.1
    > Accept: */*
    > 
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 200 OK
    < Server: Werkzeug/3.0.1 Python/3.9.18
    < Date: Fri, 12 Jan 2024 12:37:27 GMT
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
    </html>
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

### Monitoring and Analysis
- **Prometheus Integration**: Integrate Prometheus to monitor and check the status of the Kubernetes cluster, ensuring proactive identification of issues and performance analysis.

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
