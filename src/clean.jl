function clean()
    function cleandir(dir::AbstractString)
        removed = AbstractString[]
        for file in readdir(dir)
            append!(removed, rmdeadlinks(joinpath(dir, file)))
        end

        for path in sort!(removed)
            println("removed $path")
        end
    end

    # TODO: When would we have bad symlinks in the share dir?
    cleandir(CORE.share_dir)
    cleandir(CORE.bin_dir)
end
