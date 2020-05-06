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

julia> using AppliInvoicing

julia> const PATH_CSV = "./bank.csv"

julia> orders = AppliSales.process()

julia> journal_entries_1 = AppliInvoicing.process(orders)

julia> stms = AppliInvoicing.read_bank_statements(PATH_CSV)

julia> unpaid_invoices = retrieve_unpaid_invoices()

julia> journal_entries_2 = AppliInvoicing.process(unpaid_invoices, stms)

julia> cmd = `rm test_invoicing.sqlite`

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

julia> stms = AppliInvoicing.read_bank_statements(PATH_CSV)
```
"""
function read_bank_statements end


"""
    retrieve_unpaid_invoices(path="./test_invoicing.sqlite")::Array{UnpaidInvoice, 1}

Retrieves UnpaidInvoice's from a SQLite.jl database.

# Example

```
julia> using AppliSales

julia> using AppliInvoicing

julia> orders = AppliSales.process()

julia> AppliInvoicing.process(orders)

julia> unpaid_invoices = retrieve_unpaid_invoices()

julia> cmd = `rm test_invoicing.sqlite`

julia> run(cmd)
```
"""
function retrieve_unpaid_invoices end

"""
    retrieve_paid_invoices(path="./test_invoicing.sqlite")::Array{PaidInvoice, 1}

Retrieves PaidInvoice's from a SQLite.jl database.

# Example

```
TODO
```
"""
function retrieve_paid_invoices end
