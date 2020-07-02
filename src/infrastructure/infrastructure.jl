# infrastructure.jl

module Infrastructure

include("./db.jl")
include("./doc.jl") # database functions

using ..AppliAR

using CSV
#import ..AppliAR: API, Domain
#using .API
#using .Domain

import ..AppliAR: Domain, API
using .Domain
using .API

import AppliSales: Order
import AppliGeneralLedger: JournalEntry
using Dates

export process, read_bank_statements, retrieve_unpaid_invoices, retrieve_paid_invoices, connect, disconnect
export UnpaidInvoice, PaidInvoice

# get last statement number for today
n = 0

read_bank_statements(path::String) = begin
    # read the CSV file containing bank statements
    df = CSV.read(path) # returns a DataFrame

    # return an array with BankStatement's
    # row[1] is the first value of row, row[2] the second value, etc.
    return [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]
end # read_bank_statements

process(orders::Array{Order, 1}; path="./test_invoicing.txt") = begin
#process(entries::Array{JournalEntry, 1}; path_journal="./test_journal.txt", path_ledger="./test_ledger.txt") = begin

    # get last order number
    invnbr = 1000 #ToDo

    # create invoices
    invoices = [create(order, "A" * string(invnbr += 1)) for order in orders]

    # archive invoices
    #archive(db, string(UNPAID), invoices)
    add_to_file(path, invoices)

    # create journal entries from invoices
    return entries = [conv2entry(inv, 1300, 8000) for inv in invoices]

end # process orders


#process(bankstm::Array(Bankstatement, 1) = begin
process(invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1}; path="./test_invoicing_paid.txt") = begin

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
    #add_to_file("./test_invoicing_paid.txt", paid_invoices)
    add_to_file(path, paid_invoices)

    # return array with JournalEntry's
    return entries = [conv2entry(inv, 1150, 1300) for inv in paid_invoices]
end # process invoices


retrieve_unpaid_invoices(;path="./test_invoicing.txt")::Array{UnpaidInvoice, 1} = begin

    # retrieve unpaid invoices
    unpaid_invoices = UnpaidInvoice[invoice for invoice in read_from_file(path)]

    # return the array with UnpaidInvoice's that
    return unpaid_invoices
end # retrieve_unpaid_invoices

retrieve_paid_invoices(;path="./test_invoicing_paid.txt")::Array{PaidInvoice, 1} = begin

    # retrieve unpaid invoices as dataframe
    paid_invoices = PaidInvoice[invoice for invoice in read_from_file("./test_invoicing_paid.txt")]

    # return the array with UnpaidInvoice's that
    return paid_invoices
end # retrieve_unpaid_invoices

end # module
