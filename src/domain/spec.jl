# domain spec.jl

abstract type Realm end

abstract type Invoice <: Realm end

abstract type Structure <: Realm end

abstract type BodyItem <: Structure end

abstract type Payment <: Realm end

"""
    meta(i::Invoice)

Returns the meta data of an invoice.

# example
```
julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process();

julia> AppliAR.process(orders);

julia> unpaid_invoices = AppliAR.retrieve_unpaid_invoices();

julia> m = AppliAR.meta(unpaid_invoices[1])
MetaInvoice("9715406426271665630", "LS", 2020-07-14T16:56:33.194, "€", 1.0)

julia> orderid = order_id(m)
"9715406426271665630"

julia> trainingid = training_id(m)
"LS"

julia> date(m)
2020-07-14T16:56:33

julia> currency(m)
"€"

julia> currency_ratio(m)
1.0
```
"""
function meta end

"""
    header(i::Invoice)

Returns the header of an invoice.

example
```
julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process();

julia> AppliAR.process(orders);

julia> unpaid_invoices = AppliAR.retrieve_unpaid_invoices();

julia> h = header(unpaid_invoices[1])
Header("A1001", "Scrooge Investment Bank", "1180 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "PO-456", "Scrooge McDuck", "scrooge@duckcity.com")

julia> invoice_nbr(h)
"A1001"

julia> name(h)
"Scrooge Investment Bank"

julia> address(h)
"1180 Seven Seas Dr"

julia> city(h)
"Lake Buena Vista"

julia> country(h)
"USA"

julia> order_ref(h)
"PO-456"

julia> name_contact(h)
"Scrooge McDuck

julia> email_contact(h)
"scrooge@duckcity.com"
```
"""
function header end

"""
    body(i::Invoice)

Returns the body of an invoice.

example
```
julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process();

julia> AppliAR.process(orders);

julia> unpaid_invoices = AppliAR.retrieve_unpaid_invoices();

julia> b = body(unpaid_invoices[1])
OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Scrooge McDuck"], 0.21)

julia> name_training(b)
"Learn Smiling"

julia> date(b)
2019-08-30T00:00:00

julia> price_per_student(b)
1000.0

julia> students(b)
1-element Array{String,1}:
"Scrooge McDuck"

julia> vat_perc(b)
0.21
```
"""
function body end

"""
    id(i::Invoice)

Returns the id of an invoice.

example
```
julia> using AppliSales

julia> using AppliAR

julia> orders = AppliSales.process();

julia> AppliAR.process(orders);

julia> unpaid_invoices = AppliAR.retrieve_unpaid_invoices();

julia> id(unpaid_invoices[1])
"A1001"
```
"""
function id end
