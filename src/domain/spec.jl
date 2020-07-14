# domain spec.jl

abstract type Realm end

abstract type Invoice <: Realm end

abstract type Structure <: Realm end

abstract type BodyItem <: Structure end

abstract type Payment <: Realm end

"""
    meta(i::Invoice)

Returns the meta data of an invoice.
"""
function meta end

"""
    header(i::Invoice)

Returns the header of an invoice.
"""
function header end

"""
    body(i::Invoice)

Returns the body of an invoice.
"""
function body end

"""
    id(i::Invoice)

Returns the id of an invoice.
"""
function id end
