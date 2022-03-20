// Generate the SSH keypair that we’ll use to configure the EC2 instance. 
// After that, write the private key to a local file and upload the public key to AWS
/*
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  filename          = "${var.namespace}-key.pem"
  sensitive_content = tls_private_key.key.private_key_pem
  file_permission   = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.namespace}-key"
  public_key = tls_private_key.key.public_key_openssh
}
*/

resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ec2_private_key.private_key_pem}' > ~/.ssh/${var.key_name}.pem"
  }
}

resource "null_resource" "key-perm" {
  depends_on = [tls_private_key.ec2_private_key,
  ]
  provisioner "local-exec" {
    command = "chmod 400 ~/.ssh/${var.key_name}.pem"
  }
}

