module AppliAR

#using AppliSales: Order
#using AppliGeneralLedger: JournalEntry
import AppliSales: Order
import AppliGeneralLedger: JournalEntry
using Dates: Date, DateTime
using DataFrames
using CSV
using Serialization

export create, process, retrieve_unpaid_invoices, retrieve_paid_invoices, read_bank_statements, report


export UnpaidInvoice, PaidInvoice, meta, header, body, id
export PaidInvoice, stm
export BankStatement, date, descr, iban, amount
export MetaInvoice, order_id, training_id, date, currency, currency_ratio
export Header, invoice_nbr, name, address, zip, city, country, order_ref, name_contact, email_contact
export OpentrainingItem, name_training, date, price_per_student, students, vat_perc

# first, link to the model
include("Domain.jl"); using .Domain
include("API.jl"); using .API
include("Infrastructure.jl"); using .Infrastructure

# next, submodule Reporting
include("Reporting.jl"); using .Reporting

# Aging report
function report(;path_unpaid="./test_invoicing.txt", path_paid="./test_invoicing_paid.txt")
	#@info(path)
	x = Reporting.aging(path_unpaid, path_paid)
	return x
end
export report

end # module
