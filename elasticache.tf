#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_serverless_cache
resource "aws_elasticache_serverless_cache" "example" {
  engine = "redis"
  name   = var.name
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = "09:00"
  description              = "Redis cache server for ${var.name}"
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = [aws_security_group.custom_sg.id]
  subnet_ids               = aws_subnet.private[*].id
  kms_key_id               = aws_kms_key.custom_kms_key.arn
}