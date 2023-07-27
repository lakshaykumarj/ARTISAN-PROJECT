<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Table Display</title>
    <link rel="stylesheet" type="text/css" href="table.css">
</head>
<body>
    <%
        // Database connection details
        String driver = "oracle.jdbc.driver.OracleDriver";
        String url = "jdbc:oracle:thin:@localhost:1521:XE";
        String username = "system";
        String password = "20C047new1";

        // Get the display type from the form submission
        String displayType = request.getParameter("displayType");

        try {
            Connection conn = DriverManager.getConnection(url, username, password);

            // Retrieve the tablename from the tablenames table
            String tablenameQuery = "SELECT tabname FROM tablenames ORDER BY time DESC FETCH FIRST 1 ROWS ONLY";
            PreparedStatement tablenameStmt = conn.prepareStatement(tablenameQuery);
            ResultSet tablenameRs = tablenameStmt.executeQuery();
            if (tablenameRs.next()) {
                String tablename = tablenameRs.getString("tabname");
                String sellerName = "";
                // Prepare the SQL query based on the display type
                String sqlQuery = "";
                if (displayType.equals("All Tables")) {
                    sqlQuery = "select product_name , cost_price , quantity , username from users join product on users.key = product.tablename order by product_id";
                } else if (displayType.equals("Specific User")) {
                    sqlQuery = "select product_name , cost_price , quantity , username from users join product on users.key = product.tablename where users.username=? order by product_id;";
                    sellerName = request.getParameter("sellerName");
                }

                // Execute the SQL query
                PreparedStatement stmt = conn.prepareStatement(sqlQuery);
                if(displayType.equals("Specific User")){
                    stmt.setString(1,sellerName);
                }
                
                ResultSet rs = stmt.executeQuery();

                //Print the resultset row by row in a table form
                out.println("<table>");
                out.println("<tr><th>Product Name</th><th>Expected Price</th><th>Quantity</th><th>Vendor</th></tr>");
                while (rs.next()) {
                    String productName = rs.getString("product_name");
                    double costprice = rs.getDouble("cost_price")*1.3;
                    int quantity = rs.getInt("quantity");
                    String vendor = rs.getString("username");
                    out.println("<tr><td>" + productName + "</td><td>" + costprice + "</td><td>" + quantity + "</td><td>" + vendor +"</td></tr>");
                }
                out.println("</table>");
            
                // Close the ResultSets, Statements, and Connection
                rs.close();
                stmt.close();
                tablenameRs.close();
                tablenameStmt.close();
                conn.close();
            }
        } catch (Exception e) {
            out.println("<h3>Error occurred: " + e.getMessage() + "</h3>");
        }
    %>
</body>
</html>
