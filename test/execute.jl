playground = Playground.create_playground(
    root=joinpath(TMP_DIR, "execute"),
)

default_julia = readchomp(`which julia`)
playground_julia = readchomp(playground, `which julia`)

@test playground_julia != default_julia
@test playground_julia == playground.julia_path

# When julia executable is unavailable an error will be raised.
Playground.run(`julia -v`)

Playground.remove(playground)
