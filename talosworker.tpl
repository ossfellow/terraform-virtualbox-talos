version: v1alpha1 # Indicates the schema used to decode the contents.
debug: false # Enable verbose logging to the console.
persist: true # Indicates whether to pull the machine config upon every boot.

# Provides machine specific configuration options.
machine:
  type: ${tf_type} # Defines the role of the machine within the cluster.
  token: ${tf_talos_token} # The `token` is used by a machine to join the PKI of the cluster.

  # Used to provide additional options to the kubelet.
%{if tf_kube_version != "" ~}
  kubelet:
    image: k8s.gcr.io/kube-proxy-${tf_host_arch}:${tf_kube_version} # The `image` field is an optional reference to an alternative kubelet image.
%{else ~}
  kubelet: {}
%{endif ~}

  # Provides machine specific network configuration options.
  network:
    hostname: ${tf_hostname}

  # # Allows for extra entries to be added to the `/etc/hosts` file
    extraHostEntries:
      # Host IPs and aliases
      - ip: 127.0.0.1
        aliases:
        - ${tf_hostname}
        - ${tf_node_fqdn}
%{for item in tf_cp_extrahosts ~}
      - ip: ${item[0]}
        aliases:
        - ${tf_cluster_endpoint}
        - ${item[1]}
%{endfor ~}
%{for item in tf_wk_extrahosts ~}
      - ip: ${item[0]}
        aliases:
        - ${item[1]}
%{endfor ~}

  # Used to provide instructions for installations.
  install:
    disk: /dev/sda # The disk used for installations.
    image: ghcr.io/talos-systems/installer:${tf_talos_version} # Allows for supplying the image used to perform the installation.
    bootloader: true # Indicates if a bootloader should be installed.
    wipe: false # Indicates if the installation disk should be wiped at installation time.

# Provides cluster specific configuration options.
cluster:
  # Provides control plane specific configuration options.
  controlPlane:
    endpoint: https://${tf_cluster_endpoint}:6443 # Endpoint is the canonical controlplane endpoint, which can be an IP address or a DNS hostname.
  # Provides cluster specific network configuration options.
  network:
    dnsDomain: ${tf_kube_dns_domain} # The domain used by Kubernetes DNS.
    # The pod subnet CIDR.
    podSubnets:
      - 10.244.0.0/16
    # The service subnet CIDR.
    serviceSubnets:
      - 10.96.0.0/12

  token: ${tf_kube_token} # The [bootstrap token](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/) used to join the cluster.
  # The base64 encoded root certificate authority used by Kubernetes.
  ca:
    crt: ${tf_kube_ca_crt}
    key: ""
