using Sockets, Serialization

function retrieve_invoice_nbr(name::String, ip::IPv4, port::Int64)::Int64
    client = connect(ip, port)

    serialize(client, name)

    return deserialize(client)
end # retrieve_invoice_nbr