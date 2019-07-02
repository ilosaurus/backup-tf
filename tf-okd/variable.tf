variable "public_key_path" {
  description = "The path of the ssh pub key"
  default     = "/home/ubuntu/.ssh/id_rsa.pub"
}

variable "node_prop" {
  description = "instance property"
  type = "map"
  default = {
     hostname = "master199.openshift.local,node199.openshift.local"
     ip_address = "10.199.199.30,10.199.199.31"
     flavor = "ns.4-8-20,ns.4-8-20"
     image = "CentOS-7-x86_64-GenericCloud-1802"
     network_id = "0610bf20-6662-45db-ae6e-9e8bc5fe3f1e"
     subnet_id = "4048512c-031f-4ffb-8318-7b26c72b995e"
  }
}


