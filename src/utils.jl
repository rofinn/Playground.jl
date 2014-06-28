# A set of utility function that might be able
# to get merged into base julia.

# creates a symlink for nix systems.
function mklink(src::String, dest::String)
    if ispath(src)
        run(`ln -s $(src) $(dest)`)
    else
        error("$(src) is not a valid path")
    end
end
