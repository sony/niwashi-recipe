# Niwashi Recipe

Reference Recipes for [Niwashi](https://github.com/sony/niwashi), maintained by the Niwashi project.

## Usage

Clone this repository alongside `nwsctl`:

```bash
git clone https://github.com/sony/niwashi-recipe recipe
nwsctl plan --recipe-dir ./recipe -t state.yaml
```

See the [Niwashi User Guide](https://github.com/sony/niwashi/blob/main/docs/user-guide/content/en/_index.md) for details on defining a desired state and using Recipes.

## Recipes

| Recipe | Capability | Description |
|--------|-----------|-------------|
| **Vagrant** | `infra.vm` (`driver=vagrant`) | Creates multiple VM instances on the host using a single Vagrantfile |
| **Ansible** | `host.tool.ansible`, `adapter.tool.ansible` | Installs/detects Ansible and provides an adapter for running Ansible playbooks |
| **Kubernetes (kubespray)** | `cluster.kubernetes` (`by=kubespray`) | Builds a Kubernetes cluster using kubespray |
| **Python venv** | `host.tool.python-venv` | Installs and manages Python virtual environments |
| **git** | `host.tool.git` | Detects git on the host |
| **jq** | `host.tool.jq` | Detects jq on the host |

## Contributing

Niwashi does not currently accept external contributions; see [CONTRIBUTING.md](CONTRIBUTING.md) for details and the current policy. Bug reports and feature requests via [Issues](https://github.com/sony/niwashi-recipe/issues) are welcome.

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Licensed under the [Apache License 2.0](LICENSE).

Copyright 2026 Sony Group Corporation.
