# Deploy AKS Cluster with Terraform

This guide will help you set up a Kubernetes cluster in Azure Kubernetes Service (AKS) using Terraform and deploy a "Hello World" application.

## Prerequisites

1. **Azure Account**: Ensure you have an Azure subscription.
2. **Azure CLI**: Install the Azure CLI. On Linux, use:
    ```sh
    sudo apt-get install azure-cli
    ```
   On macOS, use:
    ```sh
    brew install azure-cli
    ```
3. **Terraform**: Install Terraform from [here](https://learn.hashicorp.com/tutorials/terraform/install-cli).
4. **kubectl**: Install kubectl using Azure CLI:
    ```sh
    az aks install-cli
    ```

## Step 1: Set Up Terraform Configuration

1. **Create a directory** for your Terraform configuration files.
    ```sh
    mkdir terraform-aks && cd terraform-aks
    ```

2. **Create a `providers.tf` file** with the following content:

    ```hcl
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.0"
        }
      }
    }

    provider "azurerm" {
      features {}
    }
    ```

3. **Create a `variables.tf` file** to define variables:

    ```hcl
    variable "resource_group_name" {
      description = "The name of the resource group"
      type        = string
      default     = "aks-resource-group"
    }

    variable "location" {
      description = "The Azure location where the resources will be created"
      type        = string
      default     = "UK South"
    }

    variable "cluster_name" {
      description = "The name of the AKS cluster"
      type        = string
      default     = "aks-cluster"
    }

    variable "kubernetes_version" {
      description = "Kubernetes version"
      type        = string
      default     = "1.24.6"
    }

    variable "node_count" {
      description = "Number of AKS worker nodes"
      type        = number
      default     = 2
    }
    ```

4. **Create a `terraform.tfvars` file** to specify variable values:

    ```hcl
    resource_group_name = "aks_terraform_rg"
    location            = "UK South"
    cluster_name        = "aks-terraform-cluster"
    kubernetes_version  = "1.24.6"
    node_count          = 2
    ```

5. **Create a `main.tf` file** with the following content:

    ```hcl
    resource "azurerm_resource_group" "aks_rg" {
      name     = var.resource_group_name
      location = var.location
    }

    resource "azurerm_kubernetes_cluster" "aks" {
      name                = var.cluster_name
      kubernetes_version  = var.kubernetes_version
      location            = var.location
      resource_group_name = azurerm_resource_group.aks_rg.name
      dns_prefix          = var.cluster_name

      default_node_pool {
        name       = "system"
        node_count = var.node_count
        vm_size    = "Standard_DS2_v2"
        availability_zones  = [1, 2, 3]
        enable_auto_scaling = false
      }

      identity {
        type = "SystemAssigned"
      }

      network_profile {
        load_balancer_sku = "Standard"
        network_plugin    = "kubenet"
      }
    }

    output "kube_config" {
      value     = azurerm_kubernetes_cluster.aks.kube_config_raw
      sensitive = true
    }
    ```

6. **Create an `output.tf` file** to output necessary values:

    ```hcl
    output "kube_config" {
      value     = azurerm_kubernetes_cluster.aks.kube_config_raw
      sensitive = true
    }
    ```

## Step 2: Initialize and Apply Terraform Configuration

1. **Initialize the Terraform configuration**:
    ```sh
    terraform init
    ```

2. **Create an execution plan**:
    ```sh
    terraform plan -out main.tfplan
    ```

3. **Apply the Terraform configuration** to create the resources:
    ```sh
    terraform apply main.tfplan
    ```

    Confirm the apply with `yes` when prompted.

## Step 3: Configure kubectl

1. **Save the kubeconfig output** from Terraform to a file:
    ```sh
    terraform output -raw kube_config > ./azurek8s
    ```

2. **Set the KUBECONFIG environment variable**:
    ```sh
    export KUBECONFIG=./azurek8s
    ```

3. **Verify the cluster is accessible**:
    ```sh
    kubectl get nodes
    ```

## Step 4: Deploy a "Hello World" Application

1. **Create a YAML file** for the Hello World deployment:

    ```yaml
    # hello-world-deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: hello-world
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: hello-world
      template:
        metadata:
          labels:
            app: hello-world
        spec:
          containers:
          - name: hello-world
            image: k8s.gcr.io/echoserver:1.4
            ports:
            - containerPort: 8080
    ```

2. **Create a YAML file** for the Hello World service:

    ```yaml
    # hello-world-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: hello-world
    spec:
      type: LoadBalancer
      ports:
      - port: 80
        targetPort: 8080
      selector:
        app: hello-world
    ```

3. **Deploy the application** to your AKS cluster:

    ```sh
    kubectl apply -f hello-world-deployment.yaml
    kubectl apply -f hello-world-service.yaml
    ```

4. **Get the external IP** of the service:

    ```sh
    kubectl get service hello-world
    ```

    After a few minutes, you should see an external IP address assigned. Access this IP address in your web browser to see the Hello World application running.

These updated instructions should help you successfully provision an AKS cluster using Terraform and deploy a "Hello World" application in the UK region.
