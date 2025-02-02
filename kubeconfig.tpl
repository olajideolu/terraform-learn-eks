apiVersion: v1
kind: Config
preferences: {}
clusters:
- cluster:
    server: ${cluster_endpoint}
    certificate-authority-data: ${cluster_ca_certificate}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${cluster_name}
  name: ${cluster_name}
current-context: ${cluster_name}
users:
- name: ${cluster_name}
  user:
    token: ${cluster_token}
