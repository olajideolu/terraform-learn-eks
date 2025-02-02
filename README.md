# EKS Cluster Terraform Configuration

This Terraform configuration sets up an Amazon EKS cluster with managed node groups and attaches necessary IAM policies for CloudWatch and Grafana integration.

## Resources

### EKS Cluster

- **module.eks**: Creates an EKS cluster with managed node groups.

### IAM Policies

- **aws_iam_policy.assume_grafana_role_policy**: Defines a policy to allow EKS nodes to assume the AmazonGrafanaServiceRole.
- **aws_iam_role_policy_attachment.cloudwatch_full_access**: Attaches the CloudWatchFullAccess policy to the EKS node group roles.
- **aws_iam_role_policy_attachment.cloudwatch_agent**: Attaches the CloudWatchAgentServerPolicy to the EKS node group roles.
- **aws_iam_role_policy_attachment.assume_grafana_role_attachment**: Attaches the AssumeGrafanaRolePolicy to the EKS node group roles.

### Local File

- **local_file.kubeconfig**: Generates a kubeconfig file for the EKS cluster.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate credentials.
- An existing VPC with subnets for the EKS cluster.

## How to Run

1. **Initialize Terraform**:

   ```bash
   terraform init
   ```

2. **Plan Terraform**:

   ```bash
   terraform plan
   ```

3. **Apply Terraform**:
   ```bash
   terraform apply -auto-approve
   ```

The terraform script is chained to the Ansible script and will run it simultaneously.

# Deploy Monitoring Stack with Ansible

This Ansible playbook sets up a Prometheus monitoring stack on an EKS cluster created by the Terraform configuration.

## Resources

### Ansible Playbook

- **deploy-monitoring-stack.yaml**: An Ansible playbook that:
  - Adds the Prometheus and kube-state-metrics Helm repositories.
  - Creates a Kubernetes namespace for monitoring.
  - Deploys the Prometheus monitoring stack using Helm.

## Prerequisites

- An EKS cluster created using the provided Terraform configuration.
- Ansible installed on your local machine.
- Helm installed on your local machine.
- Kubernetes CLI (`kubectl`) installed and configured.

## How to Run

1. **Ensure the EKS Cluster is Up and Running**:
   Follow the steps above to create the EKS cluster and run the `aws update` command to update the kubeconfig file.

   ```
   aws eks update-kubeconfig --name <name_of_cluster> --region <cluster_region>
   ```

   move the content of the kubeconfig file to the kubeconfig file in the project directory

   ```
   cp ~/.kube/config kubeconfig
   ```

2. **Set Up Ansible**:
   Ensure Ansible is installed and configured on your local machine.

3. **Run the Ansible Playbook**:
   the playbook is chained with the terraform script and should run automatically but you can run it manually using the below command

   ```bash
   ansible-playbook /home/mubarak/projects/devOps/terraform/ansible/deploy-monitoring-stack.yaml
   ```

# COnfiguring Grafana UI

To access the grafana web ui, run the below commmand to get the loadbalancer service ip address.

```
kubectl get svc -n monitoring
```

the default login details are username: `admin ` password: `prom-operator`

**configure cloudwatch datasource**: In the datasource section, select cloudwatch and use your access key and id as credentials

**Manually install neccessary dashboards**: the kubernetes and cloudwatch dashboards needs to install manually. custom dashboards are located in the `grafana_dashboards` directory.

# Deploying microservice application manual

Normally the microservice architecture should be deploy through the CI/CD pipeline but you can choose to do it manually using helm

```
helm upgrade onlineboutique oci://us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique \
                        --install \
                        --namespace onlineboutique \
                        --create-namespace
```

# Destroying all resources

In order to destroy all resources provisioned by terraform, the created loadbalancers has to be deleted manaually using the below command

```
kubectl delete svc <loadbalncer_service_name> -n <namespace>
```

usually you have two loadbalancer, each in the following namespaces

- monitoring
- onlineboutique

afterwards, the terraform resource can be destroyed

```
terraform destroy -auto-approve
```
