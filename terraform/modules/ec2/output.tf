output "public_ip" {
  value = aws_instance.ec2_public.public_ip
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tpl",
    {
      server_ip = aws_instance.ec2_public.public_ip
    }
  )
  filename = "../ansible/hosts.cfg"
}