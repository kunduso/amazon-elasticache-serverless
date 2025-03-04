#https://registry.terraform.io/modules/kunduso/vpc/aws/1.0.3
module "vpc" {
  source                  = "kunduso/vpc/aws"
  version                 = "1.0.3"
  region                  = var.region
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_flow_log         = true
  enable_internet_gateway = false
  enable_nat_gateway      = false
  vpc_name                = var.name
  vpc_cidr                = var.vpc_cidr
  subnet_cidr_public      = var.subnet_cidr_public
  subnet_cidr_private     = var.subnet_cidr_private
  #CKV_TF_1: Ensure Terraform module sources use a commit hash
  #checkov:skip=CKV_TF_1: This is a self hosted module where the version number is tagged rather than the commit hash.
}