function activate(directory, name, config::Config)
    root_path = abspath(directory)
    log_path = joinpath(root_path, "log")
    bin_path = joinpath(root_path, "bin")
    pkg_path = joinpath(root_path, "packages")

    Logging.configure(level=DEBUG, filename=joinpath(log_path, "playground.log"))

    Logging.info("Setting PATH variable to using to look in playground bin directory first")
    ENV["PATH"] = "$(bin_path):" * ENV["PATH"]
    Logging.info("Setting the JULIA_PKGDIR variable to using the playground packages directory")
    ENV["JULIA_PKGDIR"] = pkg_path

    if config.isolated_julia_history
        ENV["JULIA_HISTORY"] = joinpath(root_path, "julia_history"
    end

    Logging.info("Executing a playground shell")
    @windows? run_windows_shell() : run_nix_shell()
end


function run_windows_shell()
    run(`cmd /K prompt $(ACTIVATED_PROMPT)`)
end


function run_nix_shell()
    ENV["PS1"] = ACTIVATED_PROMPT
    run(`sh -i`)
end
