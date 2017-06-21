function list(config::Config; show_links=false)
	init(config)

    println("Julia Versions:")
    for j in readdir(config.bin)
        if j != p"playground"
            file_path = join(config.bin, j)
            if islink(file_path) && show_links
                println("\t$(j) -> $(readlink(file_path))")
            else
                println("\t$(j)")
            end
        end
    end

    println("\nPlaygrounds:")
    for p in readdir(config.share)
        file_path = join(config.share, p)
        if islink(file_path) && show_links
            println("\t$(string(p)) -> $(string(readlink(file_path)))")
        else
            println("\t$(string(p))")
        end
    end
end
