# redis subnet
resource "aws_elasticache_subnet_group" "redis_subnetgroup" {
  name       = "${var.tag}-redis-subnetgroup"
  subnet_ids = [aws_subnet.redis_sub_a.id, aws_subnet.redis_sub_c.id]
  
  tags = {
    Name = "${var.tag}-redis-subnetgroup"
  }
}


# redis-replication-group
resource "aws_elasticache_replication_group" "redis-rep-group" {
  automatic_failover_enabled  = true
  multi_az_enabled            = true

  preferred_cache_cluster_azs = ["ap-northeast-2a", "ap-northeast-2c"]
  replication_group_id        = "${var.tag}-redis"
  description                 = "${var.tag}-redis"
  engine                      = "redis"
  node_type                   = "cache.r6g.large"

  engine_version              = "7.0"
#  parameter_group_name        = "default.redis7.0"

  subnet_group_name           = "${aws_elasticache_subnet_group.redis_subnetgroup.name}"

  port                        = 6379
  num_cache_clusters          = 2

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }
}


# redis cluster
resource "aws_elasticache_cluster" "replica" {
  count = 1

  cluster_id           = "redis-rep-group-${count.index}"
  replication_group_id = aws_elasticache_replication_group.redis-rep-group.id
}