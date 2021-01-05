# actors.jl

using Rocket

struct StmActor <: Actor{String} end
Rocket.on_next!(actor::StmActor, data::String) = begin
    if data == "READ_STMS"
        stms = AppliAR.read_bank_statements("./bank.csv")
        @show(stms)
        subscribe!(from(stms), ar_actor)
    end
end
Rocket.on_complete!(actor::StmActor) = @info("StmActor completed!")
Rocket.on_error!(actor::StmActor, err) = @info(error(err))

struct SalesActor <: Actor{String} end
Rocket.on_next!(actor::SalesActor, data::String) = begin
    if data == "START"
        #ar_actor = ARActor()
        orders = @fetch AppliSales.process()
        subscribe!(from(orders), ar_actor)
    end
end
Rocket.on_complete!(actor::SalesActor) = @info("SalesActor completed!")
Rocket.on_error!(actor::SalesActor, err) = @info(error(err))

struct ARActor <: Actor{Any}
    ar_pid::Int64
    ARActor(ar_pid) = new(ar_pid)
end
Rocket.on_next!(actor::ARActor, data::AppliSales.Order) = begin
        d = @fetchfrom actor.ar_pid AppliAR.process([data])
        subscribe!(from(d), gl_actor)
end
Rocket.on_next!(actor::ARActor, data::AppliAR.BankStatement) = begin
        unpaid_inv = @fetchfrom actor.ar_pid retrieve_unpaid_invoices()
        entries = @fetchfrom actor.ar_pid AppliAR.process(unpaid_inv, [data])
        subscribe!(from(entries), gl_actor)
end
Rocket.on_complete!(actor::ARActor) = begin
    @info("ARActor Completed!")
end
Rocket.on_error!(actor::ARActor, err) = @info(error(err))

struct GLActor <: Actor{Any}
    gl_pid::Int64
    GLActor(gl_pid) = new(gl_pid)
end
Rocket.on_next!(actor::GLActor, data::Any) = begin
    if data isa AppliGeneralLedger.JournalEntry
        result = @fetchfrom actor.gl_pid AppliGeneralLedger.process([data])
    end
end
Rocket.on_complete!(actor::GLActor) = @info("GLActor completed!")
Rocket.on_error!(actor::GLActor, err) = @info(error(err))
