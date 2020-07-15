4. Example

## Example from the course BAWJ
```
using Pkg
Pkg.activate(".")
Pkg.precompile()

using Rocket
using DataFrames

# start docker containers
cmd = `docker start test_sshd`
run(cmd)

cmd = `docker start test_sshd2`
run(cmd)

cmd = `docker ps`
run(cmd)

sleep(5)

@info("Enable distributed computing")
using Distributed

@info("Add processes")
addprocs([("rob@172.17.0.2", 1)]; exeflags=`--project=$(Base.active_project())`, tunnel=true, dir="/home/rob")
addprocs([("rob@172.17.0.3", 1)]; exeflags=`--project=$(Base.active_project())`, tunnel=true, dir="/home/rob")
#addprocs([("pi@192.168.2.3", 1)]; exename=`/home/pi/julia/julia-1.3.1/bin/julia`, dir="/home/pi")

@info("Assign pids to containers")
gl_pid = procs()[2] # general ledger
ar_pid = procs()[3] # accounts receivable (orders/bankstatements)

@info("Activate the packages")
@everywhere begin
    using AppliSales
    using AppliGeneralLedger
    using AppliAR
    using Query
end;

@info("Load the actor definitions")
include("./src/actors.jl")

@info("Activate the actors")
sales_actor = SalesActor()
ar_actor = ARActor(ar_pid, gl_pid)
gl_actor = GLActor(gl_pid)
stm_actor = StmActor(ar_pid)

@info("Start the application")
subscribe!(from(["START"]), sales_actor)

@info("Process payments")
subscribe!(from(["READ_STMS"]), stm_actor)

@info("Print aging report")
r1 = @fetchfrom ar_pid report()
result = DataFrame(r1)
println("\nUnpaid invoices\n===============")
@show(result)

@info("Get balance of the ledger accounts 1300, 8000, 1150, and 4000")
r2 = @fetchfrom gl_pid AppliGeneralLedger.read_from_file("./test_ledger.txt")

df2 = r2 |> @filter(_.accountid == 1300) |> DataFrame
balance_1300 = sum(df2.debit - df2.credit)

df2 = df |> @filter(_.accountid == 8000) |> DataFrame
balance_8000 = sum(df2.credit - df2.debit)

df2 = df |> @filter(_.accountid == 1150) |> DataFrame
balance_1150 = sum(df2.debit - df2.credit)

df2 = df |> @filter(_.accountid == 4000) |> DataFrame
balance_4000 = sum(df2.credit - df2.debit)

println("")
println("Balance Accounts Receivable is $balance_1300. $(balance_1300 == 1210 ? "Is correct." : "Should be 1210.")")
println("Sales is $balance_8000. $(balance_8000 == 4000 ? "Is correct." : "Should be 4000.")")
println("Balance bank is $balance_1150. $(balance_1150 == 3630 ? "Is correct." : "Should be 3630.0.")")
println("Balance VAT is $balance_4000. $(balance_4000 == 840 ? "Is correct." : "Should be 840.0.")")

@info("Open shell in container")
cmd = `ssh rob@172.17.0.2`
@info("after run(cmd) is activated: goto console, press Enter, and rm test_* files. Leave the container with Ctrl-D")
run(cmd)

@info("Open shell in container")
cmd = `ssh rob@172.17.0.3`
@info("after run(cmd) is activated: goto console, press Enter, and rm test_* invoicenbr.txt files. Leave the container with Ctrl-D")
run(cmd)
@info("Ctrl-L to clean the console. Close julia with Ctrl-D.")

# end

```

## actors.jl
```
# actors.jl

using Rocket

struct StmActor <: Actor{String}
    ar_pid::Int64
    StmActor(ar_pid::Int) = new(ar_pid)
end
Rocket.on_next!(actor::StmActor, data::String) = begin
    if data == "READ_STMS"
        stms = AppliAR.read_bank_statements("./bank.csv")
        unpaid_inv = @fetchfrom actor.ar_pid retrieve_unpaid_invoices()
        entries = @fetchfrom actor.ar_pid AppliAR.process(unpaid_inv, stms)
        subscribe!(from(entries), gl_actor)
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

struct ARActor <: Actor{AppliSales.Order}
    values::Vector{AppliGeneralLedger.JournalEntry}
    ar_pid::Int64
    gl_pid::Int64
    ARActor(ar_pid, gl_pid) = new(Vector{AppliGeneralLedger.JournalEntry}(), ar_pid, gl_pid)
end
Rocket.on_next!(actor::ARActor, data::AppliSales.Order) = begin
        d = @fetchfrom actor.ar_pid AppliAR.process([data])
        push!(actor.values, d[1])
end
Rocket.on_complete!(actor::ARActor) = begin
    #println(actor.values)
    @info(typeof(actor.values))
    subscribe!(from(actor.values), gl_actor)
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
```

## Output
```
Press Enter to start a new session.
Starting Julia...
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.3.1 (2019-12-30)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |
 environment at `~/julia-projects/tc/AppliMaster/Project.toml`
Precompiling project...
test_sshd
test_sshd2
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                   NAMES
5d281627d29d        eg_sshd             "/usr/sbin/sshd -D"   7 months ago        Up 2 hours          0.0.0.0:32769->22/tcp   test_sshd2
13304c03391d        eg_sshd             "/usr/sbin/sshd -D"   7 months ago        Up 2 hours          0.0.0.0:32768->22/tcp   test_sshd
[ Info: Enable distributed computing
[ Info: Add processes
[ Info: Assign pids to containers
[ Info: Activate the packages
[ Info: Load the actor definitions
[ Info: Activate the actors
[ Info: Start the application
[ Info: Array{AppliGeneralLedger.JournalEntry,1}
[ Info: GLActor completed!
[ Info: ARActor Completed!
[ Info: SalesActor completed!
[ Info: Process payments
[ Info: GLActor completed!
[ Info: StmActor completed!
[ Info: Print aging report

Unpaid invoices
===============
1×5 DataFrame
│ Row │ id_inv │ csm                     │ inv_date   │ amount  │ days   │
│     │ String │ String                  │ Dates.Date │ Float64 │ Dates… │
├─────┼────────┼─────────────────────────┼────────────┼─────────┼────────┤
│ 1   │ A1001  │ Scrooge Investment Bank │ 2020-07-15 │ 1210.0  │ 0 days │
[ Info: Get balance of the ledger accounts 1300, 8000, 1150, and 4000

Balance Accounts Receivable is 1210.0. Is correct.
Sales is 4000.0. Is correct.
Balance bank is 3630.0. Is correct.
Balance VAT is 840.0. Is correct.
```
