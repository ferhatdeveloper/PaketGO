# AGENTS.md

## Cursor Cloud specific instructions

This repository ("PaketGO") is currently an empty/bare repository containing only a README.md. There are no application services, dependencies, build systems, or test frameworks configured yet.

### Current state

- No source code, package managers, or lockfiles exist.
- No services to start, no tests to run, no linting configured.
- The update script is intentionally a no-op (`true`) since there are no dependencies to install.

### When code is added

Once application code and a package manager are introduced, future agents should:

1. Update the `SetupVmEnvironment` update script to install dependencies (e.g. `npm install`, `pip install -r requirements.txt`).
2. Update this section with service startup instructions, test commands, and lint commands.
