function create_playground(; root::AbstractString="", name::AbstractString="",
    julia::AbstractString="", reqs_file::AbstractString="", reqs_type::Symbol=:REQUIRE)

    pg = PlaygroundConfig(root, name)

    # Only create a new playground if the destination is non-existent or empty
    if !ispath(pg.root) || isdir(pg.root) && length(readdir(pg.root)) == 0
        if isnull(pg.name)
            info("Creating playground $(pg.root)")
        else
            info("Creating playground named $(get(pg.name)) in $(pg.root)")
        end

        mkpath(pg.root)

        # Make the playground globally accessible by it's name
        if !isnull(pg.name)
            global_root = joinpath(CORE.share_dir, get(pg.name))
            !isdir(global_root) && symlink(abspath(pg.root), global_root)
        end
    else
        error("Playground directory already in use")
    end

    # Set the playground Julia executable
    if isempty(julia)
        julia_path = readchomp(`which julia`)
    elseif ispath(julia)
        julia_path = julia
    else
        julia_path = joinpath(CORE.bin_dir, julia)
        ispath(julia_path) || throw(ArgumentError("Cannot locate Julia executable: $julia"))
    end

    mkpath(dirname(pg.julia_path))
    mklink(abspath(julia_path), pg.julia_path)

    # Install packages listed in the requirements file
    if !isempty(reqs_file)
        if reqs_type == :DECLARE || basename(reqs_file) == "DECLARE"
            info("Installing packages from DECLARE file $reqs_file...")
            install_declared_packages(pg, reqs_file)
        elseif reqs_type == :REQUIRE || basename(reqs_file) == "REQUIRE"
            info("Installing packages from REQUIRE file $reqs_file...")
            install_required_packages(pg, reqs_file)
        else
            error("Unknown requirements file type $reqs_type for file $reqs_file")
        end
    else
        mkpath(pg.pkg_dir)
    end

    return pg
end

function install_required_packages(pg::PlaygroundConfig, file_path::AbstractString)
    withenv("JULIA_PKGDIR" => pg.pkg_dir) do
        run(`$(pg.julia_path) -e Pkg.init()`)
        for version in readdir(pg.pkg_dir)
            copy(file_path, joinpath(pg.pkg_dir, version, "REQUIRE"))
            try
                run(`$(pg.julia_path) -e Pkg.resolve()`)
            catch
                warn("Failed to resolve requirements. Perhaps there is something wrong with your REQUIRE file.")
                rethrow()
            end
        end
    end
end

function install_declared_packages(pg::PlaygroundConfig, file_path::AbstractString)
    declarative_packages_dir = Pkg.dir("DeclarativePackages")
    !isdir(declarative_packages_dir) && error("DeclarativePackages not installed")
    install_packages_script = joinpath(declarative_packages_dir, "src", "installpackages.jl")

    function added{T}(o::Array{T}, n::Array{T})
        changes = T[]
        for el in n
            if !(el in o)
                push!(changes, el)
            end
        end
        return changes
    end

    # Use a temporary file for interacting with DeclarativePackages.jl since the package
    # will modify our DECLARE file.
    tmp_declare = tempname()
    copy(file_path, tmp_declare)

    # Note: ".declare"
    withenv("JULIA_PKGDIR" => joinpath(pg.pkg_dir, ".declare"), "DECLARE" => tmp_declare) do
        parent_dir = normpath(joinpath(ENV["JULIA_PKGDIR"], ".."))
        mkpath(parent_dir)
        old_listing = readdir(parent_dir)

        local created
        try
            # Make sure to run DeclarativePackages.jl from the current version of Julia as
            # that the current version of Julia will be compatible with this package.
            try
                include(install_packages_script)
            finally
                # DeclarativePackages always creates a temporary directory in the parent of
                # JULIA_PKGDIR. To determine what was installed we'll compare directory
                # listings before and after running "installpackages.jl"
                created = map(
                    f -> joinpath(pg.pkg_dir, f),
                    added(old_listing, readdir(parent_dir)),
                )

                # TODO: DeclarativePackages.jl removes the write permission for some reason...
                @unix_only for f in created
                    run(`chmod -R u+w $f`)
                end
            end
        catch
            warn("Failed to install from DECLARE file. Perhaps there is something wrong with your DECLARE file or you need to update DeclarativePackages.jl")
            for f in created
                rm(f, recursive=true)
            end
            rethrow()
        end

        # Move the declared packages version folders to the pkg_dir
        for declared_folder in created
            if isdir(declared_folder) && !islink(declared_folder)
                for version in readdir(declared_folder)
                    mv(joinpath(declared_folder, version), joinpath(pg.pkg_dir, version))

                    # Keep a permanent record of the original DECLARE file.
                    copy(file_path, joinpath(pg.pkg_dir, version, "DECLARE"))
                end
            end
        end

        # Clean up the temporary directories created by DeclarativePackages.jl
        for f in created
            rm(f, recursive=true)
        end
    end
end
