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
        with_pkg_silence() do
            for (name, ver_any) in pkgs
                spec = package_spec(name, ver_any)
                if spec === nothing
                    Pkg.add(name)
                else
                    Pkg.add(spec)
                end
            end
            Pkg.precompile()
        end
        @info "Depot bootstrap complete" depot=ENV["JULIA_DEPOT_PATH"]
    finally
        Pkg.activate()
    end
end

function with_pkg_silence(f::Function)
    if isdefined(Pkg, :silence)
        Pkg.silence(f)
    elseif isdefined(Pkg, :API) && isdefined(Pkg.API, :silence)
        Pkg.API.silence(f)
    else
        f()
    end
end

function package_spec(name::AbstractString, ver_any)::Union{Nothing,Pkg.PackageSpec}
    ver = String(ver_any)
    ver = strip(ver)
    isempty(ver) && return nothing
    ver_str = String(ver)
    version_spec = try_parse_version_spec(ver_str)
    if version_spec !== nothing
        return Pkg.PackageSpec(name=name, version=version_spec)
    end
    return Pkg.PackageSpec(name=name, version=ver_str)
end

function try_parse_version_spec(ver::AbstractString)
    semver_spec = try
        Pkg.Versions.semver_spec(ver; throw=false)
    catch
        nothing
    end
    if semver_spec !== nothing
        return semver_spec
    end
    try
        return Pkg.Types.VersionSpec(ver)
    catch
        return nothing
    end
end

packages_toml = get(ENV, "PACKAGES_FILE", joinpath(pwd(), "packages.toml"))
bootstrap_depot(packages_toml)
