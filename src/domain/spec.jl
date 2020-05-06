# domain spec.jl

abstract type Domain end

abstract type Invoice <: Domain end

abstract type Structure <: Domain end

abstract type BodyItem <: Structure end

abstract type Payment <: Domain end

#=
"""
    meta(i::Invoice)

Returns the meta data from an invoice.
"""
meta(i::Invoice) = error("Meta is not defined as concrete type")
=#

"""
    meta(i::Invoice)

Returns the meta data from an invoice.
"""
function meta end

#=
"""
    header(i::Invoice)

Returns the meta data from an invoice.
"""
header(i::Invoice) = error("Header is not defined as concrete type")
=#

"""
    header(i::Invoice)

Returns the meta data from an invoice.
"""
function header end

#=
"""
    body(i::Invoice)

Returns the meta data from an invoice.
"""
body(i::Invoice) = error("Header is not defined as concrete type")
=#

"""
    body(i::Invoice)

Returns the meta data from an invoice.
"""
function body end

#=
"""
    id(i::Invoice)

Returns the id of an invoice.
"""
id(i::Invoice) = error("Header is not defined as concrete type")
=#

"""
    id(i::Invoice)

Returns the id of an invoice.
"""
function id end
