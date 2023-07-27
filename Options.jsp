<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Options</title>
    <link rel= "stylesheet" type="text/css" href = "options.css">
</head>

<body>
    <div id="container">
        <span><h1>Welcome ! <%=request.getParameter("username")%></h1></span>
        <br>
        <a href = "http://localhost:8080/ARTISAN/AddProduct.html" >
            <div class = "submit">
                Add new Product ?
            </div>
        </a>
        <br>
        <a href = "http://localhost:8080/ARTISAN/Sales.html" >
            <div class = "submit">
                Check log and sell products
            </div>
        </a>
        <br>
        <a href = "http://localhost:8080/ARTISAN/Purchase.html" >
            <div class = "submit">
                Demand orders from other users
            </div>
        </a>
        <br>
        <a href = "#" >
            <div class = "submit">
                Delete customer histories
            </div>
        </a>
        <br>
    </div>
    <br>
    <a>Privacy Policy</a>
    <span class="spacing"></span>
    <a>About</a>
    <span class="spacing"></span>
    <a>Terms and conditions</a>
</body>

</html>