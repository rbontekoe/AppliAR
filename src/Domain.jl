# domain.jl

module Domain

include("./domain/spec.jl")

using ..AppliAR
using Dates
using Dates: Date, DateTime

export UnpaidInvoice, PaidInvoice, meta, header, body, id
export PaidInvoice, stm
export BankStatement, date, descr, iban, amount
export MetaInvoice, order_id, training_id, date, currency, currency_ratio
export Header, invoice_nbr, name, address, zip, city, country, order_ref, name_contact, email_contact
export OpentrainingItem, name_training, date, price_per_student, students, vat_perc

struct MetaInvoice <: Structure
    _order_id::String
    _training_id::String
    _date::DateTime
    _currency::String
    _currency_ratio::Float64
    # Constructors
    MetaInvoice(order_id, training_id) = new(order_id, training_id, now(), "€", 1.0) #2
    MetaInvoice(order_id, training_id, date, currency, currency_ratio) = new(order_id, training_id, now(), currency, currency_ratio)
end # MetaInvoice

struct Header <: Structure
    _invoice_nbr::String
    _name::String
    _address::String
    _zip::String
    _city::String
    _country::String
    _order_ref::String
    _name_contact::String
    _email_contact::String
end # Header

struct OpentrainingItem <: BodyItem
    _name_training::String
    _date::DateTime
    _price_per_student::Float64
    _students::Array{String, 1}
    _vat_perc::Float64
    # constructors
    OpentrainingItem(name_training, date, price_per_student, students) = new(name_training, date, price_per_student, students, 0.21)
    OpentrainingItem(name_training, date, price_per_student, students, vat_perc) = new(name_training, date, price_per_student, students, vat_perc)
end # OpentrainingItem

struct UnpaidInvoice <: Invoice
    _id::String
    _meta::MetaInvoice
    _header::Header
    _body::OpentrainingItem
end # UnpaidInvoice

struct BankStatement <: Payment
	_date::Date
	_descr::String
	_iban::String
	_amount::Float64
end # BankStatement

struct PaidInvoice <: Invoice
    _id::String
    _meta::MetaInvoice
    _header::Header
    _body::OpentrainingItem
    _stm::BankStatement
end # PaidInvoice

"""
    stm(i::PaidInvoice)

Returns the Bankstatement of a paid invoice.
"""
stm(i::PaidInvoice) = i._stm

# Fields Invoice
meta(i::Invoice)::MetaInvoice = i._meta
header(i::Invoice)::Header = i._header
body(i::Invoice)::BodyItem = i._body
id(i::Invoice)::String = i._id

# fields MetaInvoice
order_id(m::MetaInvoice)::String = m._order_id
training_id(m::MetaInvoice)::String = m._training_id
date(m::MetaInvoice)::DateTime = m._date
currency(m::MetaInvoice)::String = m._currency
currency_ratio(m::MetaInvoice)::Float64 = m._currency_ratio

# fields Header
invoice_nbr(h::Header)::String = h._invoice_nbr
name(h::Header)::String = h._name
address(h::Header)::String = h._address
zip(h::Header)::String = h._zip
city(h::Header)::String = h._city
country(h::Header)::String = h._country
order_ref(h::Header)::String = h._order_ref
name_contact(h::Header)::String = h._name_contact
email_contact(h::Header)::String = h._email_contact

# field OpenTraining
name_training(o::OpentrainingItem)::String = o._name_training
date(o::OpentrainingItem)::DateTime = o._date
price_per_student(o::OpentrainingItem)::Float64 = o._price_per_student
students(o::OpentrainingItem)::Array{String, 1} = o._students
vat_perc(o::OpentrainingItem)::Float64 = o._vat_perc

# gfields BankStatement
date(b::BankStatement)::Date = b._date
descr(b::BankStatement)::String = b._descr
iban(b::BankStatement)::String = b._iban
amount(b::BankStatement)::Float64 = b._amount

end # module
