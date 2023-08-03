storage "raft" {
    path="/vault/data"
    node_id = "zero"
}

listener "tcp" {
    address="0.0.0.0:8200"
    tls_disable = "true"
}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "12h"  
}