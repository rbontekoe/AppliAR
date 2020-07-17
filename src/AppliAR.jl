module AppliAR

import AppliSales: Order
import AppliGeneralLedger: JournalEntry
using Dates: Date, DateTime
using DataFrames
using CSV
using Serialization

export process, retrieve_unpaid_invoices, retrieve_paid_invoices, read_bank_statements, report


export UnpaidInvoice, PaidInvoice, meta, header, body, id
export PaidInvoice, stm
export BankStatement, date, descr, iban, amount
export MetaInvoice, order_id, training_id, date, currency, currency_ratio
export Header, invoice_nbr, name, address, postal_code, city, country, order_ref, name_contact, email_contact
export OpentrainingItem, name_training, date, price_per_student, students, vat_perc

# first, link to the model
include("./domain/Domain.jl"); using .Domain
include("./api/API.jl"); using .API
include("./infrastructure/Infrastructure.jl"); using .Infrastructure

# next, submodule Reporting
include("Reporting.jl"); using .Reporting

# Aging report
"""
	report

Generate an aging report

# Example
```
julia> using Dates

julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process();

julia> AppliAR.process(orders);

julia> stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0);

julia> stms = [stm1];

julia> AppliAR.process(unpaid_invoices, stms);

julia> r = report()
2-element Array{Any,1}:
 AppliAR.Reporting.Aging("A1001", "Scrooge Investment Bank", 2020-07-14, 1210.0, 0 days)
 AppliAR.Reporting.Aging("A1003", "Donalds Hardware Store", 2020-07-14, 1210.0, 0 days)
```
"""
function report(;path_unpaid="./test_invoicing.txt", path_paid="./test_invoicing_paid.txt")
	#@info(path)
	x = Reporting.aging(path_unpaid, path_paid)
	return x
end

export report

end # module
