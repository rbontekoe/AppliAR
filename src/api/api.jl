# api.jl

include("../domain/domain.jl")
include("./spec.jl")

import AppliSales.Order # Order is not exported but is refered to in the next function

create(order::Order, invoice_id::String)::UnpaidInvoice = begin
    meta = MetaInvoice(order.id, order.training.id)
    header_invoice = Header(
		    invoice_id, order.org.name, order.org.address, order.org.zip, order.org.city, order.org.country, order.order_ref, order.contact_name, order.contact_email)
    body_invoice = OpentrainingItem(order.training.name, order.training.date, order.training.price, order.students)
	return UnpaidInvoice(invoice_id, meta, header_invoice, body_invoice)
end

create(invoice::UnpaidInvoice, bs::BankStatement)::PaidInvoice = begin
	id_inv = id(invoice)
	meta_inv = meta(invoice)
	header_inv = header(invoice)
	body_inv = body(invoice)
	s = bs
	return PaidInvoice(id_inv, meta_inv, header_inv, body_inv, s)
end

conv2entry(inv::UnpaidInvoice, from::Int, to::Int) = begin
    id = string(Date(now())) * "-" * string(global n += 1)
    customer_id = name(header(inv))
	inv_nbr = invoice_nbr(header(inv))
	b = body(inv)
    debit = price_per_student(b) * length(students(b))
    credit = 0.0
    vat = debit * vat_perc(b)
    descr = name_training(b)
    return create_journal_entry(id, customer_id, inv_nbr, from, to, debit, credit, vat, descr)
end

conv2entry(inv::PaidInvoice, from::Int, to::Int) = begin
    id = string(Date(now())) * "-" * string(global n += 1)
    customer_id = name(header(inv))
    inv_nbr = invoice_nbr(header(inv))
	b = body(inv)
    debit = amount(stm(inv))
    credit = 0.0
    vat = 0.0
    descr = name_training(b)
    return create_journal_entry(id, customer_id, inv_nbr, from, to, debit, credit, vat, descr)
end

function report(;path="./test_invoicing.sqlite")
	#@info(path)
	x = Reporting.aging(path)
	return x
end
