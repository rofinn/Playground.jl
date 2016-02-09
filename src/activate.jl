function activate(pg::PlaygroundConfig)
    withenv(pg) do
        run_shell(pg)
    end
end

@windows_only function run_shell(pg::PlaygroundConfig)
    run(`cmd /K prompt $(prompt(pg))`)
end

@unix_only function run_shell(pg::PlaygroundConfig)
    playground_rc = joinpath(dirname(ENV["JULIA_PKGDIR"]), basename(ENV["SHELL"]) * "rc")
    args = isfile(playground_rc) ? `-i -c "source '$playground_rc'"` : ``

    withenv("PS1" => prompt(pg)) do
        run(`env $(ENV["SHELL"]) $args`)
    end
end
