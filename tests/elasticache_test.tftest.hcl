variables {
  name = "test-redis-cache"
}

run "elasticache_serverless_validation" {
  command = plan

  # Assert that the plan will create the ElastiCache resource
  assert {
    condition     = length(aws_elasticache_serverless_cache.serverless_cache) > 0
    error_message = "ElastiCache Serverless Cache resource was not created"
  }

  # Validate the engine configuration
  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.engine == "redis"
    error_message = "ElastiCache engine must be redis"
  }

  # Validate major engine version
  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.major_engine_version == "7"
    error_message = "ElastiCache major engine version must be 7"
  }

  # Validate cache usage limits
  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.cache_usage_limits[0].data_storage[0].maximum == 10
    error_message = "Data storage maximum must be 10 GB"
  }

  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.cache_usage_limits[0].data_storage[0].unit == "GB"
    error_message = "Data storage unit must be GB"
  }

  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.cache_usage_limits[0].ecpu_per_second[0].maximum == 5000
    error_message = "ECPU per second maximum must be 5000"
  }
}

# Test for security configuration
run "security_configuration" {
  command = plan

  assert {
    condition     = length(aws_elasticache_serverless_cache.serverless_cache.security_group_ids) > 0
    error_message = "Security group IDs must be configured"
  }

  assert {
    condition     = length(aws_elasticache_serverless_cache.serverless_cache.subnet_ids) > 0
    error_message = "Subnet IDs must be configured"
  }
}

# Test for backup configuration
run "backup_configuration" {
  command = plan

  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.daily_snapshot_time == "09:00"
    error_message = "Daily snapshot time must be set to 09:00"
  }

  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.snapshot_retention_limit == 1
    error_message = "Snapshot retention limit must be 1 day"
  }
}

# Test resource naming and description
run "resource_metadata" {
  command = plan

  assert {
    condition     = can(regex("Redis cache server for.*", aws_elasticache_serverless_cache.serverless_cache.description))
    error_message = "Description must follow the expected format"
  }
}
# Test for post-deployment configuration
run "post_deployment_validation" {
  command = apply

  # Validate KMS encryption configuration
  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.kms_key_id != ""
    error_message = "KMS key must be configured for encryption"
  }

  # Validate that the cache endpoint is created
  assert {
    condition     = can(aws_elasticache_serverless_cache.serverless_cache.endpoint[0].address)
    error_message = "Cache endpoint address was not created"
  }

  # Validate that the cache port is set correctly (default Redis port)
  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.endpoint[0].port == 6379
    error_message = "Cache endpoint port is not set to default Redis port (6379)"
  }

  # Validate the cache status
  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.status == "available"
    error_message = "Cache is not in available state"
  }

  # Validate reader endpoint configuration (if applicable)
  assert {
    condition     = can(aws_elasticache_serverless_cache.serverless_cache.reader_endpoint[0].address)
    error_message = "Reader endpoint was not created"
  }

  # Validate that the cache has an ARN
  assert {
    condition     = can(regex("^arn:aws:elasticache:", aws_elasticache_serverless_cache.serverless_cache.arn))
    error_message = "Cache ARN is not in the correct format"
  }

  # Validate that the cache is in a VPC
  assert {
    condition     = length(aws_elasticache_serverless_cache.serverless_cache.subnet_ids) >= 2
    error_message = "Cache must be deployed across at least two subnets for high availability"
  }
}