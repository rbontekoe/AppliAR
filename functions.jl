function template(t::String)
    """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <title>BAWJ</title>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

            <style>
                table, th, td {
                    border: 1px solid black;
                    padding: 0.5em;
                    border-collapse: collapse;
                }
            </style>
        </head>
        <body>
            <nav class="navbar navbar-expand-md bg-dark navbar-dark">
            <!-- Brand -->
            <a class="navbar-brand" href="#">AppliGate</a>
    
            <!-- Toggler/collapsibe Button -->
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar">
            <span class="navbar-toggler-icon"></span>
            </button>
    
            <!-- Navbar links -->
                <div class="collapse navbar-collapse" id="collapsibleNavbar">
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="/">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/agingreport">Aging Report</a>
                        </li>
                    </ul>
                </div>
            </nav>
          
            $(t)
          
        </body>
    </html>
    """
end

function index(c::WebController)
    render(HTML, template("<h2>Hello World!</h2>"))
end

function aging_report(c::WebController)
    r = @fetchfrom ar_pid report()
    result = 
  """
    <h1>Aging Report</h1>
    <table>
    <th>Invoice</th><th>Customer</th><th>Date</th><th>Amount</th><th>Age</th>
  """
    for n = 1:length(r)
      result = result * """
        <tr>
          <td>$(r[n].id_inv)</td>
          <td>$(r[n].csm)</td><td>$(r[n].inv_date)</td>
          <td style='text-align:right'>$(r[n].amount)</td>
          <td>$(r[n].days)</td>
        </tr>"""
    end
    result * "</table>"
    render(HTML, template("$(result)"))
end
