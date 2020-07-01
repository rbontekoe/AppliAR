import AppliAR: Domain, API, Infrastructure, report
using .Infrastructure
using .API
using .Domain

using Test
using AppliSales
using AppliGeneralLedger
using Dates
#using SQLite

# TEST MODEL
@testset "Orders" begin
    orders = AppliSales.process()
    @test length(orders) == 3
    @test orders[1].org.name == "Scrooge Investment Bank"
    @test orders[1].training.name == "Learn Smiling"
end

@testset "Retrieve UnpaidInvoices" begin
    orders = AppliSales.process()
    Infrastructure.process(orders)
    unpaid_invoices = read_from_file("./test_invoicing.txt")
    unpaid_invoice = unpaid_invoices[1]

    @test id(unpaid_invoice) == "A1001"
    @test currency_ratio(meta(unpaid_invoice)) == 1.0
    @test name(header(unpaid_invoice)) == "Scrooge Investment Bank"
    @test length(students(body(unpaid_invoice))) == 1
    @test price_per_student(body(unpaid_invoice)) == 1000.0
    @test first(students(body(unpaid_invoice))) == "Scrooge McDuck"
    @test vat_perc(body(unpaid_invoice)) == 0.21

    cmd = `rm test_invoicing.txt`
    run(cmd)
end

@testset "Retrieve BankStatement from CSV" begin
    #stms = read_bank_statements("./bank.csv")
    stms = [BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)]
    @test length(stms) == 1
    @test amount(stms[1]) == 2420.0
end

@testset "JounalEntry's" begin
    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]

    orders = AppliSales.process()
    Infrastructure.process(orders)

    invoices = read_from_file("./test_invoicing.txt")

    potential_paid_invoices = []
    for unpaid_invoice in invoices
      for s in stms # get potential paid invoices
        if occursin(id(unpaid_invoice), descr(s)) # description contains invoice number
          push!(potential_paid_invoices, create(unpaid_invoice, s))
        end
      end
    end

    @test length(potential_paid_invoices) == 1
    @test id(potential_paid_invoices[1]) == "A1002"
    @test amount(stm((potential_paid_invoices[1]))) == 2420.0

    cmd = `rm test_invoicing.txt`
    run(cmd)
end

@testset "process(db, orders)" begin
    orders = AppliSales.process()
    entries = Infrastructure.process(orders)
    @test length(entries) == 3
    @test entries[1].from == 1300
    @test entries[1].to == 8000
    @test entries[1].debit == 1000.0
    @test entries[1].vat == 210.0
    @test entries[1].descr == "Learn Smiling"

    cmd = `rm test_invoicing.txt`
    run(cmd)
end

@testset "retrieve unpaid invoices" begin
    path = "./test_invoicing.txt"
    orders = AppliSales.process()
    entries = Infrastructure.process(orders; path=path)
    unpaid_invoices = read_from_file("./test_invoicing.txt")

    @test length(unpaid_invoices) == 3
    @test id(unpaid_invoices[1]) == "A1001"

    cmd = `rm test_invoicing.txt`
    run(cmd)
end

@testset "process(unpaid_invoices)" begin
    orders = AppliSales.process()
    Infrastructure.process(orders)
    #unpaid_invoices = UnpaidInvoice[invoice for invoice in read_from_file("./test_invoicing.txt")]
    unpaid_invoices = retrieve_unpaid_invoices()

    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]
    entries = Infrastructure.process(unpaid_invoices, stms)
    @test length(entries) == 1
    @test entries[1].from == 1150
    @test entries[1].to == 1300
    @test entries[1].debit == 2420.0

    cmd = `rm test_invoicing.txt test_invoicing_paid.txt`
    run(cmd)
end

@testset "report" begin
    orders = AppliSales.process()
    Infrastructure.process(orders)
    unpaid_invoices = retrieve_unpaid_invoices()

    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]

    Infrastructure.process(unpaid_invoices, stms)

    #r = Reporting.aging(path)
    r = report()
    @test r[1].csm == "Scrooge Investment Bank"
    @test r[1].days == Day(0)

    cmd = `rm test_invoicing.txt test_invoicing_paid.txt`
    run(cmd)
end
