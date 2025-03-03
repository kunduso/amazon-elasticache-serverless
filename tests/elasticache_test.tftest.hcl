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

  assert {
    condition     = aws_elasticache_serverless_cache.serverless_cache.kms_key_id != null
    error_message = "KMS key must be configured for encryption"
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
