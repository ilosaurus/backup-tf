output "node_name_length" {
  value = "${length(split(",",var.node_prop["hostname"]))}"
}

resource "openstack_blockstorage_volume_v2" "volumes" {
  count = "${length(split(",",var.node_prop["hostname"]))}"
  name = "${format("vol-okd-%02d", count.index+1)}"
  size = 10
}

resource "openstack_compute_keypair_v2" "instance" {
  name       = "keypair1"
  public_key = "${chomp(file(var.public_key_path))}"
}

resource "openstack_networking_port_v2" "port" {
  count = "${length(split(",",var.node_prop["hostname"]))}"
  name           = "${format("instance_port_%02d", count.index+1)}"
  network_id     = "${var.node_prop["network_id"]}"
  admin_state_up = "true"
  fixed_ip {
    "subnet_id"  = "${var.node_prop["subnet_id"]}"
    "ip_address" = "${element(split(",",var.node_prop["ip_address"]), count.index)}"
  }
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  count = "${length(split(",",var.node_prop["hostname"]))}"
  pool = "net-ext"
}


resource "openstack_compute_instance_v2" "instance" {
  count = "${length(split(",",var.node_prop["hostname"]))}"
  name = "${element(split(",",var.node_prop["hostname"]), count.index)}"
  image_name       = "${var.node_prop["image"]}"
  flavor_name      = "${element(split(",",var.node_prop["flavor"]), count.index)}"
  key_pair         = "${openstack_compute_keypair_v2.instance.name}"
  security_groups  = ["default"]
  network {
    port = "${element(openstack_networking_port_v2.port.*.id, count.index)}"
  }
}


resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  count = "${length(split(",",var.node_prop["hostname"]))}"
  floating_ip = "${element(openstack_networking_floatingip_v2.floating_ip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
}

resource "openstack_compute_volume_attach_v2" "attach" {
  instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.volumes.*.id, count.index)}"
}
