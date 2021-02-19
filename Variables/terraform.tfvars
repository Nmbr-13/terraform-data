#Auto fill all declared parameters
# 0. Can be .tfvars or tfvars.json - json-format also allowed
# 1. !!! .tfvars file values are more prioritized than default !!!
# 2. !!! All values should match variables types set in variables.tf !!!
# 3. !!! To load automatically file should have names:
#     - terraform.tfvars or terraform.tfvars.json
#     - names ending in .auto.tfvars or .auto.tfvars.json

region                      = "eu-west-2"
instance_type               = "t2.small"
enable_detailed_monitoring  = false

allowed_http_ports          = [80, 443, 8080, 8888]

latest_ami_search_values = {
    AMAZON_LINUX_2          = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
    UBUNTU_20               = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    WINDOWS_SERVER_2019     = "Windows_Server-2019-English-Full-Base-*"
}
