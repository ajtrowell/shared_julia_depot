- Reorganize shell tooling into purpose-specific directories so agent automation lives under `scripts/agent/`, shared Julia depot provisioning under `scripts/depot/`, and project bootstrapping helpers under `scripts/new_setup/`.
- Provide two scripts in `scripts/new_setup/`: `copy_shared_depot.sh` to copy the shared `.julia` depot into the current project directory, and `bind_shared_depot.sh` to create an empty `.julia` then bind-mount it to the shared depot path resolved relative to the script location.
- Note that `scripts/depot/bootstrap_depot.sh` executes Julia with `--project=@stdlib`, reusing the built-in standard library environment so the bootstrap process runs without depending on any user-level packages.
- Plan to ship a pre-populated `.juliaup` alongside the shared `.julia` depot so Juliaup can run offline when bind-mounted.
- Update `scripts/depot/bootstrap_depot.sh` and `scripts/depot/update_depot.sh` to refresh both `.julia` and `.juliaup`, ensuring Julia binaries and metadata stay in sync.
- Provide a `scripts/depot/run_shared_julia.sh` helper so users can launch Julia against the shared depot directly for cache warmups or manual exploration.
- Adjust `scripts/agent/run-julia.sh` and `scripts/agent/run-tests.sh` to bypass Juliaup entirely by invoking the vendored Julia binary under `./.julia/juliaup/.../bin/julia` while still configuring `JULIA_DEPOT_PATH` for package resolution.
- Extend `scripts/new_setup/bind_shared_depot.sh` (and copy helper) to mount or copy `.juliaup` in parallel with `.julia`, and document the expectation in `AGENTS.md`.
- Open question: confirm the bootstrap/update prewarm step fully populates Juliaup state so fresh sandboxes can stay offline until the next manual refresh.

Current Findings
----------------
- Agents now resolve the vendored Julia binary directly, so they run offline provided the shared depot has been refreshed recently.
- The shared depot bootstrap currently mirrors host `.juliaup` metadata/files, but we have not validated that those copies alone satisfy Juliaup’s startup checks. Running `scripts/depot/run_shared_julia.sh` during bootstrap may prewarm caches; need to verify if that suffices for fresh sandboxes.
- Depot maintenance scripts still rely on Juliaup; ensure `run_shared_julia.sh --version` succeeds during bootstrap/update so the mirrored toolchains stay current without requiring agents to perform the refresh.
