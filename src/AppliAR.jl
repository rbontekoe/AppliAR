module AppliAR

using AppliSales

using AppliGeneralLedger

using Dates

# first, link to the model
include("./infrastructure/infrastructure.jl")

# next, submodule Reporting
#include("Reporting.jl")

export create, process, retrieve_unpaid_invoices, retrieve_paid_invoices, read_bank_statements, report

# fields order
export id, meta, header, body, stm

# fields Meta
export order_id, training_id, date, currency, currency_ratio

# fields Header
export invoice_nbr, name, address, zip, city, country, name_contact, email_contact

# field OpenTraining
export name_training, date, price_per_student, students, vat_perc

# gfields BankStatement
export date, descr, iban, amount

end # module
