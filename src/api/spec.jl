# doc,jl - api

"""
    create(::AppliSales.Order, invoice_id::String)::UnpaidInvoice

    create(::UnpaidInvoice, ::AppliGeneralLedger.BankStatement)::PaidInvoice

- Create an UnpaidInvoice from an AppliSales.Order.
- Create a PaidInvoice from an UnpaidInvoice and a BankStatement.

@see also [`conv2entry`](@ref)

# Example - create an UnpaidInvoice
```jldoctest
julia> using AppliAR

julia> using AppliSales

julia> invnbr = 1000

julia> invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]
```

# Example - create a PaidInvoice
```jldoctest
julia> using Dates

julia> using AppliSales

julia> using AppliAR

julia> const PATH_CSV = "./bank.csv"
"./bank.csv"

julia> invnbr = 1000

julia> orders = AppliSales.process()

julia> invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]

julia> stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)

julia> stms = [stm1]

julia> paid_invoices = PaidInvoice[]

julia> for unpaid_invoice in invoices
          for s in stms # get potential paid invoices
             if occursin(id(unpaid_invoice), descr(s)) # description contains invoice number
                push!(paid_invoices, create(unpaid_invoice, s))
             end
          end
       end

julia> show(paid_invoices)
```
"""
function create end
