Terraform for IBM Cloud, creating your ready to use Docker Swarm in IBM Cloud.

## Customzied Image

It uses [packer.io](https://www.packer.io/) and [builder](https://github.com/leonidlm/packer-builder-softlayer) to build our own base image in IBM Cloud.

Briefly it takes ubnunt 16.10, docker ce_18.03.1, docker-machine, docker-compose and customized script for set NAT route table up in post provisioning step. Also, it creates user `ubuntu`.

`docker.options` enables `experimental=true` and `insecure-registry` to `10.0.0.0/8`， `192.0.0.0/8` and `172.0.0.0/8`

## TODOS

- terraform_provider_ibm@0.9.1 lacks of completed support on AutoScale and Load Balancer operation.

  - Lack of ability to tie a LBaaS to a AutoScale group
  - Lack of ability to attache Security group to LBaaS
  - [ ] Replace NFS to local disk

- Packer image

   - [x] Add separated user name `ubuntu`

   - [ ] Move authorized_keys from root to `ubuntu`

   - [ ] Setup `sudoers` file

## Commands

**Initialize Terraform@0.11.7**
 (one time job)
```bash
terraform init
terraform get
```
**Generate SSH key for difference roles**
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
terraform apply -parallelism=2
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

# Experiement
terraform import ibm_storage_file.metrics 43327889
terraform import ibm_storage_file.logs 43327905
terraform import ibm_storage_file.certs 43327299
# terraform import ibm_storage_file.data 40646029
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

You should be able to find the file at `Manager-1`

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

You should be able to find the file at `Manager-2`

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

