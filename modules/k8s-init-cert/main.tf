
resource "local_file" "ca-config" {
  content  = <<EOF
      {
        "signing": {
          "default": {
            "expiry": "${var.expiry}"
          },
          "profiles": {
            "kubernetes": {
              "usages": ["signing", "key encipherment", "server auth", "client auth"],
              "expiry": "${var.expiry}"
            }
          }
        }
      }
    EOF
  filename = "${path.root}/k8s/cert/ca-config.json"
}

resource "local_file" "ca-csr" {
  content  = <<EOF
    {
      "CN": "Kubernetes",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
      {
        "C": "IN",
        "L": "Belgaum",
        "O": "Tansanrao",
        "OU": "CA",
        "ST": "Karnataka"
      }
     ]
    }
  EOF
  filename = "${path.root}/k8s/cert/ca-csr.json"
}


resource "local_file" "kubernetes-csr" {
  content = <<EOF
    {
      "CN": "Kubernetes",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
      {
        "C": "IN",
        "L": "Belgaum",
        "O": "Tansanrao",
        "OU": "CA",
        "ST": "Karnataka"
      }
     ]
    }
  EOF

  filename = "${path.root}/k8s/cert/kubernetes-csr.json"
}



resource "null_resource" "init_cert" {

  depends_on = [
    local_file.ca-config,
    local_file.ca-csr,
    local_file.kubernetes-csr,
  ]
  provisioner "local-exec" {
    command     = <<EOT
        cfssl gencert -initca ca-csr.json | cfssljson -bare ca &&
        cfssl gencert \
        -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=ca-config.json \
        -hostname=${var.addresses} \
        -profile=kubernetes kubernetes-csr.json | \
        cfssljson -bare kubernetes
    EOT
    working_dir = "${path.root}/k8s/cert"
  }

}
