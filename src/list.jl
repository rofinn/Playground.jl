function list(config::Config; show_links=false)
	init(config)

    println("Julia Versions:")
    for j in readdir(config.dir.bin)
        if j != "playground"
            file_path = joinpath(config.dir.bin, j)
            if islink(file_path) && show_links
                println("\t$(j) -> $(readlink(file_path))")
            else
                println("\t$(j)")
            end
        end
    end

    println("\nPlaygrounds:")
    for p in readdir(config.dir.store)
        file_path = joinpath(config.dir.store, p)
        if islink(file_path) && show_links
            println("\t$(p) -> $(readlink(file_path))")
        else
            println("\t$(p)")
        end
    end
end
