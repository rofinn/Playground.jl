# A set of utility function that might be able
# to get merged into base julia.

# currently only creates a symlink
function mklink(src::String, dest::String)
    if ispath(src)
        @unix_only begin
            run(`ln -s $(src) $(dest)`)
        end
        @windows_only begin
            if isfile(src)
                run(`mklink $(dest) $(src)`)
            else
                run(`mklink /D $(dest) $(src)`)
            end
        end
    else
        error("$(src) is not a valid path")
    end
end

