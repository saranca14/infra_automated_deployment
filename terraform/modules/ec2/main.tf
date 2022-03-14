// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    owners = ["099720109477"]
}

// Configure the Nginx EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "aws_ec2_key"
  iam_instance_profile        = "ec2_admin_role"
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

   provisioner "local-exec" {
        command = "sleep 100; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ./aws_ec2_key.pem -i '${aws_instance.ec2_public.public_ip},' site.yml"
    }

  tags = {
    "Name" = "${var.namespace}-nginx_server"
  }
}