#    $$\   $$\  $$$$$$\  $$\      $$\ $$$$$$$$\  $$$$$$\  $$$$$$$\   $$$$$$\   $$$$$$\  $$$$$$$$\  $$$$$$\
#    $$$\  $$ |$$  __$$\ $$$\    $$$ |$$  _____|$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$  _____|$$  __$$\
#    $$$$\ $$ |$$ /  $$ |$$$$\  $$$$ |$$ |      $$ /  \__|$$ |  $$ |$$ /  $$ |$$ /  \__|$$ |      $$ /  \__|
#    $$ $$\$$ |$$$$$$$$ |$$\$$\$$ $$ |$$$$$\    \$$$$$$\  $$$$$$$  |$$$$$$$$ |$$ |      $$$$$\    \$$$$$$\
#    $$ \$$$$ |$$  __$$ |$$ \$$$  $$ |$$  __|    \____$$\ $$  ____/ $$  __$$ |$$ |      $$  __|    \____$$\
#    $$ |\$$$ |$$ |  $$ |$$ |\$  /$$ |$$ |      $$\   $$ |$$ |      $$ |  $$ |$$ |  $$\ $$ |      $$\   $$ |
#    $$ | \$$ |$$ |  $$ |$$ | \_/ $$ |$$$$$$$$\ \$$$$$$  |$$ |      $$ |  $$ |\$$$$$$  |$$$$$$$$\ \$$$$$$  |
#    \__|  \__|\__|  \__|\__|     \__|\________| \______/ \__|      \__|  \__| \______/ \________| \______/
#
#
#

resource "kubernetes_namespace_v1" "ops" {
  count = var.deploy_k8s_resources ? 1 : 0

  metadata {
    name = "ops"
  }

  depends_on = [module.aks_public_cluster]
}

#     $$$$$$\  $$$$$$$\   $$$$$$\
#    $$  __$$\ $$  __$$\ $$  __$$\
#    $$ /  \__|$$ |  $$ |$$ /  \__|
#    \$$$$$$\  $$$$$$$  |$$ |
#     \____$$\ $$  ____/ $$ |
#    $$\   $$ |$$ |      $$ |  $$\
#    \$$$$$$  |$$ |      \$$$$$$  |
#     \______/ \__|       \______/
#
#
#

resource "kubernetes_manifest" "spc-httpbin" {
  count = var.deploy_k8s_resources ? 1 : 0

  manifest = {
    "apiVersion" = "secrets-store.csi.x-k8s.io/v1"
    "kind"       = "SecretProviderClass"
    "metadata" = {
      "name"      = "httpbin"
      "namespace" = kubernetes_namespace_v1.ops[0].metadata[0].name
    }
    "spec" = {
      "provider" = "azure"
      "secretObjects" = [
        {
          "secretName" = "httpbin-credential"
          "type"       = "kubernetes.io/tls"
          "data" = [
            {
              "objectName" = "httpbin-key"
              "key"        = "tls.key"
            },
            {
              "objectName" = "httpbin-crt"
              "key"        = "tls.crt"
            }
          ]
        }
      ]
      "parameters" = {
        "clientID"     = module.aks_workload_identity.client_id
        "keyvaultName" = module.keyvault.name
        "cloudName"    = ""
        "tenantId"     = data.azurerm_client_config.current.tenant_id
        "objects"      = <<OBJECTS
array:
  - |
    objectName: wildcard-ssl-key
    objectType: secret
    objectAlias: "httpbin-key"
  - |
    objectName: wildcard-ssl-crt
    objectType: secret
    objectAlias: "httpbin-crt"
OBJECTS
      }
    }
  }
}

#    $$\   $$\ $$$$$$$$\ $$$$$$$$\ $$$$$$$\  $$$$$$$\  $$$$$$\ $$\   $$\
#    $$ |  $$ |\__$$  __|\__$$  __|$$  __$$\ $$  __$$\ \_$$  _|$$$\  $$ |
#    $$ |  $$ |   $$ |      $$ |   $$ |  $$ |$$ |  $$ |  $$ |  $$$$\ $$ |
#    $$$$$$$$ |   $$ |      $$ |   $$$$$$$  |$$$$$$$\ |  $$ |  $$ $$\$$ |
#    $$  __$$ |   $$ |      $$ |   $$  ____/ $$  __$$\   $$ |  $$ \$$$$ |
#    $$ |  $$ |   $$ |      $$ |   $$ |      $$ |  $$ |  $$ |  $$ |\$$$ |
#    $$ |  $$ |   $$ |      $$ |   $$ |      $$$$$$$  |$$$$$$\ $$ | \$$ |
#    \__|  \__|   \__|      \__|   \__|      \_______/ \______|\__|  \__|
#
#
#

# Istio httpbin is the official HTTP request/response testing application bundled as a sample workload
# The workload below is adjusted for the service account and for the secretprovider
#  Original: https://raw.githubusercontent.com/istio/istio/release-1.27/samples/httpbin/httpbin.yaml

# Service Account
resource "kubernetes_service_account_v1" "httpbin" {
  count = var.deploy_k8s_resources ? 1 : 0

  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace_v1.ops[0].metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = module.aks_workload_identity.client_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# Service
resource "kubernetes_service_v1" "httpbin" {
  count = var.deploy_k8s_resources ? 1 : 0

  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace_v1.ops[0].metadata[0].name
    labels = {
      app     = "httpbin"
      service = "httpbin"
    }
  }
  spec {
    selector = {
      app = "httpbin"
    }
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8000
      target_port = 8080
    }
  }
}

# Deployment
resource "kubernetes_deployment_v1" "httpbin" {
  count = var.deploy_k8s_resources ? 1 : 0

  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace_v1.ops[0].metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = "httpbin"
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app                           = "httpbin"
          version                       = "v1"
          "azure.workload.identity/use" = "true"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.httpbin[0].metadata[0].name
        container {
          image             = "docker.io/mccutchen/go-httpbin:v2.15.0"
          image_pull_policy = "IfNotPresent"
          name              = "httpbin"
          port {
            container_port = 8080
          }
          volume_mount {
            name       = "secrets-store01-inline"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }
        }
        volume {
          name = "secrets-store01-inline"
          csi {
            driver    = "secrets-store.csi.k8s.io"
            read_only = true
            volume_attributes = {
              secretProviderClass = "httpbin"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.spc-httpbin]
}

#     $$$$$$\   $$$$$$\ $$$$$$$$\ $$$$$$$$\ $$\      $$\  $$$$$$\ $$\     $$\
#    $$  __$$\ $$  __$$\\__$$  __|$$  _____|$$ | $\  $$ |$$  __$$\\$$\   $$  |
#    $$ /  \__|$$ /  $$ |  $$ |   $$ |      $$ |$$$\ $$ |$$ /  $$ |\$$\ $$  /
#    $$ |$$$$\ $$$$$$$$ |  $$ |   $$$$$\    $$ $$ $$\$$ |$$$$$$$$ | \$$$$  /
#    $$ |\_$$ |$$  __$$ |  $$ |   $$  __|   $$$$  _$$$$ |$$  __$$ |  \$$  /
#    $$ |  $$ |$$ |  $$ |  $$ |   $$ |      $$$  / \$$$ |$$ |  $$ |   $$ |
#    \$$$$$$  |$$ |  $$ |  $$ |   $$$$$$$$\ $$  /   \$$ |$$ |  $$ |   $$ |
#     \______/ \__|  \__|  \__|   \________|\__/     \__|\__|  \__|   \__|
#
#
#

resource "kubernetes_manifest" "gateway" {
  count = var.deploy_k8s_resources ? 1 : 0

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "Gateway"
    "metadata" = {
      "name"      = "gateway"
      "namespace" = kubernetes_namespace_v1.ops[0].metadata[0].name
    }
    "spec" = {
      "gatewayClassName" = "approuting-istio"
      listeners = [
        {
          "name"     = "https"
          "hostname" = var.fqdn
          "port"     = 443
          "protocol" = "HTTPS"
          "tls" = {
            "mode" = "Terminate"
            "certificateRefs" = [
              {
                "name" = "httpbin-credential"
              }
            ]
          }
          "allowedRoutes" = {
            "namespaces" = {
              "from" = "Selector"
              "selector" = {
                "matchLabels" = {
                  "kubernetes.io/metadata.name" = kubernetes_namespace_v1.ops[0].metadata[0].name
                }
              }
            }
          }
        }
      ]
    }
  }
}

#    $$$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$$$\  $$$$$$\
#    $$  __$$\ $$  __$$\ $$ |  $$ |\__$$  __|$$  _____|$$  __$$\
#    $$ |  $$ |$$ /  $$ |$$ |  $$ |   $$ |   $$ |      $$ /  \__|
#    $$$$$$$  |$$ |  $$ |$$ |  $$ |   $$ |   $$$$$\    \$$$$$$\
#    $$  __$$< $$ |  $$ |$$ |  $$ |   $$ |   $$  __|    \____$$\
#    $$ |  $$ |$$ |  $$ |$$ |  $$ |   $$ |   $$ |      $$\   $$ |
#    $$ |  $$ | $$$$$$  |\$$$$$$  |   $$ |   $$$$$$$$\ \$$$$$$  |
#    \__|  \__| \______/  \______/    \__|   \________| \______/
#
#
#

resource "kubernetes_manifest" "route-httpbin" {
  count = var.deploy_k8s_resources ? 1 : 0

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = "httpbin"
      "namespace" = kubernetes_namespace_v1.ops[0].metadata[0].name
    }
    "spec" = {
      "parentRefs" = [
        {
          "name" = kubernetes_manifest.gateway[0].manifest["metadata"]["name"]
        }
      ]
      "hostnames" = [var.fqdn]
      "rules" = [
        {
          "matches" = [
            {
              "path" = {
                "type"  = "PathPrefix"
                "value" = "/status"
              }
            },
            {
              "path" = {
                "type"  = "PathPrefix"
                "value" = "/delay"
              }
            }
          ]
          "backendRefs" = [
            {
              "name" = kubernetes_service_v1.httpbin[0].metadata[0].name
              "port" = 8000
            }
          ]
        }
      ]
    }
  }
}

#     $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$$\  $$\   $$\ $$$$$$$$\
#    $$  __$$\ $$ |  $$ |\__$$  __|$$  __$$\ $$ |  $$ |\__$$  __|
#    $$ /  $$ |$$ |  $$ |   $$ |   $$ |  $$ |$$ |  $$ |   $$ |
#    $$ |  $$ |$$ |  $$ |   $$ |   $$$$$$$  |$$ |  $$ |   $$ |
#    $$ |  $$ |$$ |  $$ |   $$ |   $$  ____/ $$ |  $$ |   $$ |
#    $$ |  $$ |$$ |  $$ |   $$ |   $$ |      $$ |  $$ |   $$ |
#     $$$$$$  |\$$$$$$  |   $$ |   $$ |      \$$$$$$  |   $$ |
#     \______/  \______/    \__|   \__|       \______/    \__|
#
#
#


data "kubernetes_resource" "gateway" {
  count = var.deploy_k8s_resources ? 1 : 0

  api_version = "gateway.networking.k8s.io/v1"
  kind        = "Gateway"

  metadata {
    name      = "gateway"
    namespace = kubernetes_namespace_v1.ops[0].metadata[0].name
  }

  depends_on = [kubernetes_manifest.gateway]
}

output "aks_public_ip_address_ingress_gateway" {
  description = "Public IP address assigned to the Gateway API resource"
  value = try(
    data.kubernetes_resource.gateway[0].object.status.addresses[0].value,
    "The gateway IP is not yet available, use \"kubectl get gateways -n ops\" to check the status of the gateway resource.",
    null
  )
}
