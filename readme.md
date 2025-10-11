# Sandbox Julia Depot

This repository provides a pre-configured Julia depot along with helper scripts for setting up agent-compatible Julia projects.

## Prerequisites
- Install Julia (tested with Julia 1.9 and newer) and ensure the binary is available on your `PATH`. Set `JULIA_BIN=/path/to/julia` if you use a non-default location.
- `rsync` is optional but speeds up file copies during provisioning.

## Bootstrap the depot
From the repository root run:

```bash
./agent_julia_sandbox/scripts/bootstrap_depot.sh
```

This installs the packages listed under `[packages]` in `agent_julia_sandbox/packages.toml` into `.agent_julia_depot`. Adjust the versions in that file as needed before running the bootstrap step.

## Provision a Julia project
Provision an existing project (e.g. `/path/to/project`) with the prepared depot and agent scripts:

```bash
./agent_julia_sandbox/scripts/provision_project.sh /path/to/project
```

The script copies the depot into `/path/to/project/.julia`, creates `AGENTS.md` from the template if missing, and installs helper scripts under `/path/to/project/scripts/agent`.

## Run Julia or tests inside the project
After provisioning, run the included helper scripts from your project directory:

```bash
./scripts/agent/run_julia.sh                # Start Julia with the project environment
./scripts/agent/run_tests.sh                # Run `Pkg.test()` for the project
```

These scripts set `JULIA_DEPOT_PATH` to the provisioned `.julia` folder so packages resolve consistently.

## Update the depot
To refresh the precompiled depot after editing `packages.toml`, rerun:

```bash
./agent_julia_sandbox/scripts/update_depot.sh
```

This reuses the bootstrap logic to add or update packages in `.agent_julia_depot`.
