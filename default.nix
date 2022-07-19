with (import <nixpkgs> {});

stdenv.mkDerivation {

  name = "example-terraform-k8s-kvm";
  KUBECONFIG = "./.kube/config";
  
  buildInputs = [
    terraform
    terraform-providers.libvirt
    packer
    kubectl
  ];
}