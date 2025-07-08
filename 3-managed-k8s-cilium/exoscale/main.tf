resource "exoscale_sks_cluster" "cluster" {
  zone          = var.zone
  name          = var.cluster.name
  version       = var.cluster.version
  service_level = var.cluster.service_level
  cni           = var.cluster.cni
}

resource "exoscale_sks_kubeconfig" "kubeconfig" {
  cluster_id = exoscale_sks_cluster.cluster.id
  zone       = exoscale_sks_cluster.cluster.zone
  user       = "kubernetes-admin"
  groups     = ["system:masters"]
}

resource "exoscale_sks_nodepool" "nodepool" {
  cluster_id         = exoscale_sks_cluster.cluster.id
  zone               = exoscale_sks_cluster.cluster.zone
  name               = "${var.cluster.name}-nodepool"
  instance_type      = var.cluster.instance_type
  size               = var.cluster.instance_count
  security_group_ids = [exoscale_security_group.nodepool_sg.id]
}

resource "exoscale_security_group" "nodepool_sg" {
  name = "${var.cluster.name}-nodepool"
}

resource "exoscale_security_group_rule" "nodeport_services" {
  security_group_id = exoscale_security_group.nodepool_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 30000
  end_port          = 32767
}

resource "exoscale_security_group_rule" "sks_logs" {
  security_group_id = exoscale_security_group.nodepool_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 10250
  end_port          = 10250
}

resource "exoscale_security_group_rule" "cilium-health" {
  security_group_id      = exoscale_security_group.nodepool_sg.id
  type                   = "INGRESS"
  protocol               = "TCP"
  user_security_group_id = exoscale_security_group.nodepool_sg.id
  start_port             = 4240
  end_port               = 4240
}
