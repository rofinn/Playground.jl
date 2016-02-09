function list(show_links=false)
    # TODO: In what cases are Julia version not links?
    println("Julia Versions:")
    for file in readdir(CORE.bin_dir)
        if file != "playground"
            julia = joinpath(CORE.bin_dir, file)
            if show_links && islink(julia)
                println("    $julia -> $(readlink(julia))")
            else
                println("    $julia")
            end
        end
    end

    println("\nNamed Playgrounds:")
    for name in readdir(CORE.share_dir)
        if show_links
            root = realpath(joinpath(CORE.share_dir, name))
            println("    $name -> $root")
        else
            println("    $name")
        end
    end
end
