# doc,jl - api

"""
    create(::AppliSales.Order, invoice_id::String)::UnpaidInvoice

    create(::UnpaidInvoice, ::AppliGeneralLedger.BankStatement)::PaidInvoice

- Create an UnpaidInvoice from an AppliSales.Order.
- Create a PaidInvoice from an UnpaidInvoice and a BankStatement.

@see also [`conv2entry`](@ref)

# Example - create an UnpaidInvoice
```jldoctest
julia> using AppliInvoicing

julia> using AppliSales

julia> orders = AppliSales.process()

julia> invnbr = 1000

julia> invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]
```

# Example - create a PaidInvoice
```jldoctest
julia> using Dates

julia> using AppliSales

julia> using AppliGeneralLedger

julia> using AppliInvoicing
[ Info: Precompiling AppliInvoicing [3941c6da-33b5-11ea-2884-afa98fed5e3b]

julia> const PATH_CSV = "./bank.csv"
"./bank.csv"

julia> orders = AppliSales.process();

julia> journal_entries_1 = AppliInvoicing.process(orders);

julia> unpaid_invoices = retrieve_unpaid_invoices();

julia> stms = AppliInvoicing.read_bank_statements(PATH_CSV);

julia> journal_entries_2 = AppliInvoicing.process(unpaid_invoices, stms);

julia> paid_invoices = retrieve_paid_invoices();

julia> paid_invoices[1]
AppliInvoicing.PaidInvoice("A1002", AppliInvoicing.MetaInvoice("17583855613870738754", "LS", 2020-03-31T10:53:17.153, "€", 1.0), AppliInvoicing.Header("A1002", "Duck City Chronicals", "1185 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "DD-001", "Mickey Mouse", "mickey@duckcity.com"), AppliInvoicing.OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Mini Mouse", "Goofy"], 0.21), AppliInvoicing.BankStatement(2020-01-15, "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0))

julia> cmd = `rm test_invoicing.sqlite`;

julia> run(cmd);
```
"""
function create end
