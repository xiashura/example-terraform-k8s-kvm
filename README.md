# example-terraform-k8s-kvm
this simple infrastructure as code governed 
by terraform setup cluster kubernetes HA on kvm

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
# info
<img src=./docs/example.png>
