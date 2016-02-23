import Base: string, parse

const BUILT_FORMAT = Dates.DateFormat("yyyymmddTHHMM")

type VersionInfo
    version::VersionNumber
    revision::AbstractString
    built::DateTime
end

function VersionInfo(julia_exec::Cmd)
    version_info = readall(`$julia_exec -e versioninfo()`)
    lines = split(version_info, '\n')

    version = VersionNumber(split(lines[1], ' ')[3])

    m = match(r"Commit (\w+)\*? \((.+) UTC\)", lines[2])
    revision = m[1]
    built = DateTime(m[2], "yyyy-mm-dd HH:MM")

    VersionInfo(version, revision, built)
end

function string(vi::VersionInfo)
    join([
        "$(vi.version.major).$(vi.version.minor).$(vi.version.patch)",  # Ignore prelrealease/build info
        vi.revision,
        Dates.format(vi.built, BUILT_FORMAT),
    ], "-")
end

function parse(::Type{VersionInfo}, str::AbstractString)
    m = match(r"^(\d+\.\d+\.\d+)-(\w+)-(.*)$", str)
    VersionInfo(
        VersionNumber(m[1]),
        m[2],
        DateTime(m[3], BUILT_FORMAT),
    )
end
