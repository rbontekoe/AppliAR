# infrastructure.jl

module Infrastructure

include("./db.jl")
include("./doc.jl") # database functions
include("./counter.jl") # sequence number invoice

using ..AppliAR

using CSV

import ..AppliAR: Domain, API
using .Domain
using .API

import AppliSales: Order
import AppliGeneralLedger: JournalEntry
using Dates, Sockets

export process, read_bank_statements, retrieve_unpaid_invoices, retrieve_paid_invoices, connect, disconnect

#CONST start_invoice_nbr = 1000
const START_INVOICE_NBR = 1000
#const file_invoice_nbr = "./invoicenbr.txt"
const FILE_INVOICE_NBR = "./invoicenbr.txt"
#const file_unpaid_invoices = "./test_invoicing.txt"
const FILE_UNPAID_INVOICES = "./test_invoicing.txt"
#const file_paid_invoices = "./test_invoicing_paid.txt"
const FILE_PAID_INVOICES = "./test_invoicing_paid.txt"

const SALES = 8000
const BANK = 1150
const AR = 1300
const VAT = 4000

read_bank_statements(path::String) = begin
    # read the CSV file containing bank statements
    df = CSV.read(path) # returns a DataFrame

    # return an array with BankStatement's
    # row[1] is the first value of row, row[2] the second value, etc.
    return [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]
end # read_bank_statements

process(orders::Array{Order, 1}; path=FILE_UNPAID_INVOICES) = begin
    # get last invoice number
    #try
    #    read_from_file(FILE_INVOICE_NBR)
    #catch e
    #    add_to_file(FILE_INVOICE_NBR, [START_INVOICE_NBR])
    #end

    #invnbr = last(read_from_file(FILE_INVOICE_NBR))

    # run in kubernetes
    #key = haskey(ENV, "HOSTNAME") ? split(ENV["HOSTNAME"], "-")[1] * split(ENV["HOSTNAME"], "-")[3] : "A"

    # create invoices
    #invoices = [create(order, key * "-" * string(invnbr += 1)) for order in orders]
    #invoices = [create(order, key * "-" * string(retrieve_invoice_nbr("ABC", ip"192.168.2.40", 30014))) for order in orders]
    
    #invoices = [create(order, key * "-" * string(retrieve_invoice_nbr(ENV["CNTNAME"], IPv4(ENV["CNTIP"]), parse(Int64, ENV["CNTPORT"])))) for order in orders]
    invoices = [create(order, string(retrieve_invoice_nbr(ENV["CNTNAME"], IPv4(ENV["CNTIP"]), parse(Int64, ENV["CNTPORT"])))) for order in orders]
    
    # save invoice number
    #add_to_file(FILE_INVOICE_NBR, [invnbr])

    # archive invoices
    add_to_file(path, invoices)

    # create journal entries from invoices
    return entries = [conv2entry(inv, AR, SALES) for inv in invoices]

end # process orders


process(invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1}; path=FILE_PAID_INVOICES) = begin

    # create array with potential paid invoices based on received bank statements
    paid_invoices = PaidInvoice[]
    for unpaid_invoice in invoices
      for s in stms # get potential paid invoices
        if occursin(id(unpaid_invoice), descr(s)) # description contains invoice number
          push!(paid_invoices, create(unpaid_invoice, s))
        end
      end
    end

    # archive paid invoices
    add_to_file(path, paid_invoices)

    # return array with JournalEntry's
    return entries = [conv2entry(inv, BANK, AR) for inv in paid_invoices]
end # process invoices


retrieve_unpaid_invoices(;path=FILE_UNPAID_INVOICES)::Array{UnpaidInvoice, 1} = begin

    # retrieve unpaid invoices
    unpaid_invoices = UnpaidInvoice[invoice for invoice in read_from_file(path)]

    # return the array with UnpaidInvoice's that
    return unpaid_invoices
end # retrieve_unpaid_invoices

retrieve_paid_invoices(;path=FILE_PAID_INVOICES)::Array{PaidInvoice, 1} = begin

    # retrieve unpaid invoices as dataframe
    paid_invoices = PaidInvoice[invoice for invoice in read_from_file(path)]

    # return the array with UnpaidInvoice's that
    return paid_invoices
end # retrieve_unpaid_invoices

end # module
