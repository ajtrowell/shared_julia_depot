import Pkg
using TOML

function bootstrap_depot(packages_toml::String)
    @info "Reading package list" packages_toml
    d = TOML.parsefile(packages_toml)
    pkgs = get(d, "packages", Dict{String,Any}())
    if isempty(pkgs)
        @warn "No packages declared under [packages] in $(packages_toml)."
    end

    tmp = mktempdir()
    try
        Pkg.activate(tmp; shared=false)
        Pkg.API.silence() do
            for (name, ver_any) in pkgs
                ver = String(ver_any)
                if isempty(ver)
                    Pkg.add(name)
                else
                    Pkg.add(Pkg.PackageSpec(name=name, version=ver))
                end
            end
            Pkg.precompile()
        end
        @info "Depot bootstrap complete" depot=ENV["JULIA_DEPOT_PATH"]
    finally
        Pkg.activate()
    end
end

packages_toml = get(ENV, "PACKAGES_FILE", joinpath(pwd(), "packages.toml"))
bootstrap_depot(packages_toml)
