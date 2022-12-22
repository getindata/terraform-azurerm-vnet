namespace           = "gid"
stage               = "example"
location            = "West Europe"
resource_group_name = "example"

descriptor_formats = {
  resource-group = {
    labels = ["name"]
    format = "%v-rg"
  }
  azure-public-ip = {
    labels = ["namespace", "environment", "stage", "name", "attributes"]
    format = "%v-%v-%v-%v-%v-pip"
  }
  azure-nat-gateway = {
    labels = ["namespace", "environment", "stage", "name", "attributes"]
    format = "%v-%v-%v-%v-%v-ngw"
  }
  azure-vnet = {
    labels = ["namespace", "environment", "stage", "name", "attributes"]
    format = "%v-%v-%v-%v-%v-vnet"
  }
}

tags = {
  Terraform = "True"
}
