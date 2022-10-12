# example-terraform-k8s-kvm
this simple infrastructure as code governed 
by terraform setup cluster kubernetes HA on kvm 
for cni network plugins example Calico or Flannel

# run 

first need you install dependency packages required

```bash
nix develop 
```
then build cloud image for easy start vm 
```bash
cloud-init-build-img
packer init ./packer/master-node.pkr.hcl
packer build ./packer/master-node.pkr.hcl
packer init ./packer/ loadbalancer-node.pkr.hcl
packer build ./packer/loadbalancer-node.pkr.hcl
```

after need configurations variables.tf and
you can deploy k8s HA on kvm 
```
terraform init && terraform apply
```
and load certs admin 
```
load-k8s-config
```
check all nodes 
```
kubectl get nodes
```

# info
<img src=./docs/example.png>

# tools 

```bash
cloud-init-build-img
```
this command for create iso image for build packer 

```bash
load-k8s-config
```
copy admin certs in master node for kubectl 