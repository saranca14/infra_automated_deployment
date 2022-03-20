// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    owners = ["099720109477"]
}

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

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.key_name}-key"
  public_key = tls_private_key.ec2_private_key.public_key_openssh
}

// Configure the Nginx EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key_pair.key_name
  iam_instance_profile        = "ec2_admin_role"
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

   provisioner "local-exec" {
       command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ~/.ssh/${var.key_name}.pem -i ${aws_instance.ec2_public.public_ip} ../ansible/site.yml"
   }

  tags = {
    "Name" = "${var.namespace}-nginx_server"
  }
}

    