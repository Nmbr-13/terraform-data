locals {
  owner = "Nmb13"
  project = "Study-a"

  common_tags = {
    Owner 	= local.owner
    Project = local.project
    Fullname = "Project '${local.project}' created by ${local.owner}"
    Region_azs = local.az_list
    Location = local.location
  }
  ### data.aws_availability_zones - returns list,
  ### to convert to string use 'join'
  az_list = join(",", data.aws_availability_zones.current_available.names)
  region = data.aws_region.current.description
  location = "In ${local.region} there are AZs: ${local.az_list}"
}