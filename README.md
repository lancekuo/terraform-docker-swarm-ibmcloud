# HealtheChain Terraform

Here is the infrastructure code for HealthChain.

## Customzied AMI

It comes in git-submodule and uses [packer.io](https://www.packer.io/) to build our own base image in AWS. The base path for this submodule is under `.packer-docker`

Take a look at `docker.json` to see detailed configuration for the customized AMI. Briefly it takes ubnunt 16.10, docker ce_17.06, docker-machine, docker-compose and AWS CLI installed.

`docker.options` enables `experimental=true` and `insecure-registry` to `10.0.0.0/8`， `192.0.0.0/8` and `172.0.0.0/8`

```Mermaid

```

## TODOS

- terraform_provider_ibm lacks of completed support on AutoScale and Load Balancer operation.

  - Lack of ability to tie a LBaaS to a AutoScale group
  - Lack of ability to attache Security group to LBaaS

- Packer image

 - [ ] Add separated user name `ubuntu`

 - [ ] Move authorized_keys from root to `ubuntu`

 - [ ] Setup `sudoers` file

## Commands

**Initialize Terraform**
 (one time job)
```bash
terraform init
terraform get
```
**Generate SSH key for bastion and node instance**
 (one time job)
```bash
ssh-keygen -q -t rsa -b 4096 -f keys/node -N ''
ssh-keygen -q -t rsa -b 4096 -f keys/nat -N ''
ssh-keygen -q -t rsa -b 4096 -f keys/manager -N ''
ssh-keygen -q -t rsa -b 4096 -f keys/bastion -N ''
```
**Modify variable from default.auto.tfvars.example**

```bash
cp default.auto.tfvars.example default.auto.tfvars
```

**Apply**
```bash
terraform apply
```
## Storage

Import the file storage before you go

```bash
# Staging
terraform import ibm_storage_file.metrics 39511661
terraform import ibm_storage_file.logs 39513841
terraform import ibm_storage_file.data
terraform import ibm_storage_file.certs

# TrialNet
terraform import ibm_storage_file.metrics 40706115
terraform import ibm_storage_file.logs 40706123
terraform import ibm_storage_file.data 40646029
terraform import ibm_storage_file.certs 41978125 #SSL
```

Remove from state 

```bash
terraform state rm ibm_storage_file.metrics
terraform state rm ibm_storage_file.logs
terraform state rm ibm_storage_file.data
terraform state rm ibm_storage_file.certs
```



## Config & Secret

Create the secret as following in docker swarm.

## Prometheus and Grafana
Those docker-compose file brings you the completed stack of prometheus and Grafana.

### Command
**Build your docker image**
```bash
cd prometheus
docker-compose pull
```
**Spin up**
```bash
docker stack deploy monitoring -c docker-compose.yml
```
You can find `admin` password in `docker-compose.yml` under `grafana` service.
The best dashboard that fits to us is [Docker Swarm & Container Overview](https://grafana.com/dashboards/609). Follow the screen to setup your metric source.

## ELK Stack

Those docker-compose file brings you the completed stack of ELK 6.2.

### Command
**Build your docker image**
```bash
cd elk
docker-compose pull
```
**Spin up**
```bash
docker stack deploy logging -c docker-compose.yml
```
**Test Docker Logging Driver**
```bash
docker run --rm -it \
             --log-driver gelf \
             --log-opt gelf-address=udp://{any node}:4790 \
             busybox echo This is my message.
```
Or
```bash
docker service create \
             --name temp_service \
             --network elk_logging \
             --log-driver gelf \
             --log-opt gelf-address=udp://{any node}:4790 \
             busybox echo This is my message.
```
Docker log driver document (https://docs.docker.com/engine/admin/logging/gelf/#gelf-options)

