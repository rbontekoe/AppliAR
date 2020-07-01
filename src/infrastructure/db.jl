# db.jl

using Serialization

# Database item
struct DatabaseItem{T}
   time::Float64
   agent::String
   action::String
   key::String
   item::T
end # DatabaseItem

function read_from_file(file::String)
    io = open(file, "r")

    r = []
    while !eof(io)
        push!(r, deserialize(io))
    end

    close(io)

    return r
end

function add_to_file(file::String, data::Array{T, 1} where T <: Any)
    io = open(file, "a+")

    [serialize(io, r) for r in data]

    close(io)
end
