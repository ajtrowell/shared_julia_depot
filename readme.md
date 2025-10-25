# Sandbox Julia Depot

This repository provides a pre-configured Julia depot along with helper scripts for setting up agent-compatible Julia projects.

## Prerequisites
- Install Julia (tested with Julia 1.9 and newer) and ensure the binary is available on your `PATH`. Set `JULIA_BIN=/path/to/julia` if you use a non-default location.
- `rsync` is optional but speeds up file copies during provisioning.

## Bootstrap the depot
From the repository root run:

```bash
./agent_julia_sandbox/scripts/depot/bootstrap_depot.sh
```

This installs the packages listed under `[packages]` in `agent_julia_sandbox/packages.toml` into `.agent_julia_depot`. Adjust the versions in that file as needed before running the bootstrap step.

## Provision a Julia project
Provision an existing project (e.g. `/path/to/project`) with the prepared depot and agent scripts. Run one of the setup helpers from the repository root:

```bash
# Copy the shared depot into the project
./agent_julia_sandbox/scripts/new_setup/copy_shared_depot.sh /path/to/project

# Or bind-mount the shared depot into the project
sudo ./agent_julia_sandbox/scripts/new_setup/bind_shared_depot.sh /path/to/project
```

Both scripts ensure `/path/to/project/.julia` is prepared, create `AGENTS.md` from the template if missing, and install helper scripts under `/path/to/project/scripts/agent`.

### Bind-mount the depot instead of copying

`bind_shared_depot.sh` performs a `--bind` mount from the shared depot inside this repository to `/path/to/project/.julia`, letting many sandboxes reuse the same store.

Key environment variables:
- `BIND_MOUNT_CMD` (optional): Override the mount executable (defaults to `mount`).
- `BIND_MOUNT_PRIVATE` (optional): Set to `1` to run `mount --make-private` on the mount point.

Example (requires privileges to perform mounts):

```bash
sudo BIND_MOUNT_PRIVATE=1 \
     ./agent_julia_sandbox/scripts/new_setup/bind_shared_depot.sh /path/to/project
```

When you no longer need the sandbox, unmount the depot first: `sudo umount /path/to/project/.julia`.


## Run Julia or tests inside the project
After provisioning, run the included helper scripts from your project directory:

```bash
./scripts/agent/run-julia.sh                # Start Julia with the project environment
./scripts/agent/run-tests.sh                # Run `Pkg.test()` for the project
```

These scripts set `JULIA_DEPOT_PATH` to the provisioned `.julia` folder so packages resolve consistently.

## Update the depot
To refresh the precompiled depot after editing `packages.toml`, rerun:

```bash
./agent_julia_sandbox/scripts/depot/update_depot.sh
```

This reuses the bootstrap logic to add or update packages in `.agent_julia_depot`.
