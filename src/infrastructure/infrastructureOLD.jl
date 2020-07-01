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

@enum TableName begin
    UNPAID
    PAID
end # enumerator for TableName types

# get last statement number for today
n = 0

process2(orders::Array{Order, 1}; path="./test_invoicing.sqlite") = begin
    # connect to db
    db = connect(path)

    # get last order number
    invnbr = 1000 #ToDo

    # create invoices
    invoices = [create(order, "A" * string(invnbr += 1)) for order in orders]

    # archive invoices
    archive(db, string(UNPAID), invoices)

    # close db
    disconnect(db)

    # create journal entries from invoices
    return entries = [conv2entry(inv, 1300, 8000) for inv in invoices]
end # process(path, orders::Array{Order, 1})

#process(bankstm::Array(Bankstatement, 1) = begin
process2(invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1}; path="./test_invoicing.sqlite") = begin
    # connect to db
    db = connect(path)

    # create array with potential paid invoices based on received bank statements
    potential_paid_invoices = []
    for unpaid_invoice in invoices
      for s in stms # get potential paid invoices
        if occursin(id(unpaid_invoice), descr(s)) # description contains invoice number
          push!(potential_paid_invoices, create(unpaid_invoice, s))
        end
      end
    end

    # convert to an array with PaidInvoice's
    paid_invoices = convert(Array{PaidInvoice, 1}, potential_paid_invoices)

    # archive PaidInvoice's
    archive(db, string(PAID), paid_invoices)

    # close db
    disconnect(db)

    # return array with JournalEntry's
    return entries = [conv2entry(inv, 1150, 1300) for inv in paid_invoices]
end # process(path, invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1})

read_bank_statements(path::String) = begin
    # read the CSV file containing bank statements
    df = CSV.read(path) # returns a DataFrame

    # return an array with BankStatement's
    # row[1] is the first value of row, row[2] the second value, etc.
    return [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]
end # read_bank_statements

retrieve_unpaid_invoices2(;path="./test_invoicing.sqlite")::Array{UnpaidInvoice, 1} = begin
    # connect to db
    db = connect(path)

    # retrieve unpaid invoices as dataframe
    unpaid_records = retrieve(db, string(UNPAID))

    # convert the dataframe to an array with UnpaidInvoice's.
    # row is an array with one element, which is an array.
    # row[1] is the the content of the element, the UnpaidInvoice.
    unpaid_invoices = [row[1] for row in eachrow(unpaid_records.item)]

    # close db
    disconnect(db)

    # return the array with UnpaidInvoice's that
    return unpaid_invoices
end # retrieve_unpaid_invoices

retrieve_paid_invoices2(;path="./test_invoicing.sqlite")::Array{PaidInvoice, 1} = begin
    # connect to db
    db = connect(path)

    # retrieve unpaid invoices as dataframe
    paid_records = retrieve(db, string(PAID))

    # convert the dataframe to an array with UnpaidInvoice's.
    # row is an array with one element, which is an array.
    # row[1] is the the content of the element, the UnpaidInvoice.
    paid_invoices = [row[1] for row in eachrow(paid_records.item)]

    # close db
    disconnect(db)

    # return the array with UnpaidInvoice's that
    return paid_invoices
end # retrieve_unpaid_invoices

# =============== NEW

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

    # END NEW


end # process


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
    add_to_file("./test_invoicing_paid.txt", paid_invoices)

    # return array with JournalEntry's
    return entries = [conv2entry(inv, 1150, 1300) for inv in paid_invoices]
end # process(path, invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1})


retrieve_unpaid_invoices(;path="./test_invoicing.txt")::Array{UnpaidInvoice, 1} = begin

    # retrieve unpaid invoices
    unpaid_invoices = UnpaidInvoice[invoice for invoice in read_from_file("./test_invoicing.txt")]

    # return the array with UnpaidInvoice's that
    return unpaid_invoices
end # retrieve_unpaid_invoices

retrieve_paid_invoices(;path="./test_invoicing_paid.txt")::Array{PaidInvoice, 1} = begin

    # retrieve unpaid invoices as dataframe
    paid_invoices = PaidInvoice[invoice for invoice in read_from_file("./test_invoicing_paid.txt")]

    # return the array with UnpaidInvoice's that
    return paid_invoices
end # retrieve_unpaid_invoices

# ====================

end # module
