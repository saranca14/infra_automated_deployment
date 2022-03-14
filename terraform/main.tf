module "network" {
  source    = "./modules/network"
  namespace = var.namespace
}

module "ec2" {
  source     = "./modules/ec2"
  namespace  = var.namespace
  vpc        = module.network.vpc
  sg_pub_id  = module.network.sg_id
}