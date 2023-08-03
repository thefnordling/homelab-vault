storage "raft" {
    path="/vault/data"
    node_id = "zero"
}

listener "tcp" {
    address="0.0.0.0:8200"
    tls_disable = "true"
}

telemetry {
  statsite_address = "0.0.00:8125"
  disable_hostname = true
  prometheus_retention_time = "12h"  
}