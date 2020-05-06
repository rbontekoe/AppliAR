# Reporting.jl

module Reporting


const PATH_DB = "./test_invoicing.sqlite"

using Dates

export aging

import ..AppliInvoicing: retrieve_unpaid_invoices, retrieve_paid_invoices

import ..AppliInvoicing: id, name, date, meta, header, body, students, price_per_student, vat_perc

struct Aging
    id_inv::String
    csm::String
    inv_date::Date
    amount::Float64
    days::Day
end

aging(path_db::String) = begin
    @info(path_db)
    unpaid_invoices = retrieve_unpaid_invoices(;path=path_db)
    paid_invoices = retrieve_paid_invoices(;path=path_db)

    paid = [id(x) for x in paid_invoices]
    unpaid = filter(x -> id(x) ∉ paid, unpaid_invoices)

    list = []
    for invoice in unpaid
        id_inv = id(invoice)
        csm = name(header(invoice))
        inv_date = Date(date(meta(invoice)))
        b = body(invoice)
        amount = (price_per_student(b) * length(students(b))) * (1 + vat_perc(b))
        days = Dates.today() - inv_date
        aging_item = Aging(id_inv, csm, inv_date, amount, days)
        push!(list, aging_item)
    end
    return list
end # aging

end # module
