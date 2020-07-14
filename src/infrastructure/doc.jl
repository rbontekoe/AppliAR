# doc.jl - infrastructure

"""
    process(::Array{AppliSales.Order, 1}; path="./test_invoices.sqlite")

    process(::Array{UnpaidInvoice, 1}, ::Array{AppliGeneralLedger.BankStatement, 1}; path="./test_invoices.sqlite")

- Creates UnpaidInvoice's from AppliSale.Order's, archive them, and creates AppliGeneralLedger.Entry's for the general ledger.
- Creates PaidInvoices's from UnpaidInvoices by using AppliGeneralLedger.BankStatement's, and creates AppliGeneralLedger.Entry's for the general ledger.

# Example

```
julia> using AppliSales

julia> using AppliGeneralLedger

julia> using AppliAR

julia> const PATH_CSV = "./bank.csv"

julia> orders = AppliSales.process()

julia> journal_entries_1 = AppliAR.process(orders)

julia> stms = AppliAR.read_bank_statements(PATH_CSV)

julia> unpaid_invoices = AppliAR.retrieve_unpaid_invoices()

julia> journal_entries_2 = AppliAR.process(unpaid_invoices, stms)

julia> cmd = `rm test_invoicing.txt test_invoicing_paid.txt invoicenbr.txt`

julia> run(cmd)
```
"""
function process end


"""
    read_bank_statements(path::String)

Retrieves bank statements from a CSV-file.

# Example

```
julia> const PATH_CSV = "./bank.csv"

julia> stms = AppliAR.read_bank_statements(PATH_CSV)
```
"""
function read_bank_statements end


"""
    retrieve_unpaid_invoices(;path="./test_invoicing.txt")::Array{UnpaidInvoice, 1}

Retrieves UnpaidInvoice's from a text file.

# Example

```
julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process()

julia> AppliAR.process(orders)

julia> unpaid_invoices = retrieve_unpaid_invoices()

julia> cmd = `rm test_invoicing.txt invoicenbr.txt`

julia> run(cmd)
```
"""
function retrieve_unpaid_invoices end

"""
    retrieve_paid_invoices(;path="./test_invoicing_paid.txt")::Array{PaidInvoice, 1}

Retrieves PaidInvoice's from a text file.

# Example

```
julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process()

julia> AppliAR.process(orders)

julia> unpaid_invoices = retrieve_unpaid_invoices()

julia> const PATH_CSV = "./bank.csv"

julia> stms = AppliAR.read_bank_statements(PATH_CSV)

julia> AppliAR.process(unpaid_invoices, stms)

julia> paid_invoices = AppliAR.retrieve_paid_invoices()

julia> cmd = `rm test_invoicing.txt test_invoicing_paid.txt invoicenbr.txt`

julia> run(cmd)
```
"""
function retrieve_paid_invoices end
