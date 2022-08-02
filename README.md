

  # uri   = "qemu+ssh://xi@109.194.163.242/system?keyfile=/home/xi/.ssh/id_rsa&sshauth=privkey&no_verify=1&no_tty=1"
https://tansanrao.com/kubernetes-ha-cluster-with-kubeadm/

https://foxutech.com/setup-a-multi-master-kubernetes-cluster-with-kubeadm/

1) scripts template pki for generate node cert and initializations
2) module upload cert
3) template etcd configs
4) module loadbalancer

kubeadm join --token <token> --discovery-token-ca-cert-hash <sha256>

TOKEN=$(sshpass -p $PASSWORD ssh  -o StrictHostKeyChecking=no root@$MASTER_IP sudo kubeadm token list | tail -1 | cut -f 1 -d " ")
HASH=$(sshpass -p $PASSWORD ssh  -o StrictHostKeyChecking=no  root@$MASTER_IP  openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' ) 