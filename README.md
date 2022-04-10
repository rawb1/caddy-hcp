# caddy-hcp

## Introduction
A custom built docker image for [Caddy](https://caddyserver.com/) to use along the [HashiCorp](https://www.hashicorp.com/) Stack/Platform ([Nomad](https://www.nomadproject.io/) & [Consul](https://www.consul.io/))

> Docker image can be found on [dockerhub](https://hub.docker.com/r/rawb1/caddy-hcp) : https://hub.docker.com/r/rawb1/caddy-hcp

I will push new tags based on the official [caddy image](https://hub.docker.com/_/caddy) tags

## Features
- Caddy config reload on **SIGHUP** signal for Nomad template (forked from [optiz0r/caddy-consul](https://github.com/optiz0r/caddy-consul)
- Caddy [**caddy-tlsconsul**](https://github.com/pteich/caddy-tlsconsul) module from [pteich](https://github.com/pteich)
- **CADDYFILE_PATH** env var to define caddyfile location
- **ADAPTER** env var to use non default adpater


## Example Nomad HCL config file

```json
job "caddy" {
  datacenters = ["dc1"]

  group "caddy" {
    count = 1

    network {
      port "http" {
        static       = 80
      }
      port "https" {
        static       = 443
      }
    }

    service {
      name = "caddy-service"
      port = "https"
    }

    task "caddy" {
      driver = "docker"

      config {
        image        = "rawb1/caddy-hcp:2"
        network_mode = "host"

        ports = ["http", "https"]

        volumes = [
          "local:/etc/caddy",
        ]
      }

      template {
        data          = <<EOF
{
    storage consul {
           address      {{ env "CONSUL_HTTP_ADDR" }}
           token        "consul-access-token"
           timeout      10
           prefix       "caddytls"
           value_prefix "myprefix"
           aes_key      "consultls-1234567890-caddytls-32"
           tls_enabled  "false"
           tls_insecure "true"
    }
}

example.com {
    reverse_proxy {{ range service "example" }} {{ .Address }}:{{ .Port }} {{ end }}
}
EOF
        destination   = "local/Caddyfile"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = 250
        memory = 128
      }
    }
  }
}
```
