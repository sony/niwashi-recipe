# Contributing to Niwashi Recipe

Thank you for your interest in contributing to Niwashi Recipe.

## Accepting Contributions

At this time, this repository does not accept external contributions (pull requests) from outside Sony. We plan to open the project to external contributions in the first half of 2027.

Bug reports, questions, and feature requests via [Issues](https://github.com/sony/niwashi-recipe/issues) are welcome from anyone in the meantime.

## Reporting Issues

Before opening a new issue, please search existing issues to avoid duplicates.

When sharing logs or code snippets in an issue, please double-check that no secrets were accidentally included.

## Security

Recipes execute local and remote commands, and may install or run third-party tools — some of which (e.g. Ansible) can themselves run those commands with elevated privileges. Changes to recipes are reviewed with extra attention to their security implications: arbitrary code execution paths, unpinned or unverified downloads, and credential handling.

## Testing a Recipe Change

This repository does not have automated tests or CI yet. Validate changes manually with `nwsctl`:

```bash
nwsctl init
nwsctl plan -t <state-file> --recipe-dir <path-to-changed-recipe>
nwsctl apply --plan plan.json --recipe-dir <path-to-changed-recipe>
```

See [`test/python/venv/`](test/python/venv/) for an example that provisions a Vagrant VM and runs a full plan/apply/destroy cycle. When adding a new recipe, consider adding a similar test setup.

## Making Changes

1. Fork the repository and create a branch from `main`.
2. Make your changes.
3. Validate them as described above.
4. Open a pull request against `main`.
5. Address review feedback; a maintainer will merge once approved.

Keep each pull request focused and reviewable in scope. If a change is likely to grow large, split it into multiple, smaller pull requests.

## Code of Conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
