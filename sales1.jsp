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

        try {
            Connection conn = DriverManager.getConnection(url, username, password);

            // Retrieve the tablename from the tablenames table
            String tablenameQuery = "select username from users,tablenames where users.key = tablenames.tabname order by time desc fetch first 1 rows only";
            PreparedStatement tablenameStmt = conn.prepareStatement(tablenameQuery);
            ResultSet tablenameRs = tablenameStmt.executeQuery();
            if (tablenameRs.next()) {
                String requestee = tablenameRs.getString("username");
                String sqlQuery = "select * from log where requestee=? order by time desc";
                PreparedStatement stmt = conn.prepareStatement(sqlQuery);
                stmt.setString(1,requestee);
                
                ResultSet rs = stmt.executeQuery();
                
                //Print the resultset row by row in a table form
                out.println("<table>");
                out.println("<tr><th>Product</th><th>Quantity</th><th>Rate</th><th>Time</th><th>Requestor</th></tr>");
                while (rs.next()) {
                    String productName = rs.getString("product");
                    double costprice = rs.getDouble("rate")*1.3;
                    int quantity = rs.getInt("quantity");
                    String requestor = rs.getString("requestor");
                    String time = rs.getString("time");
                    out.println("<tr><td>" + productName + "</td><td>" + quantity + "</td><td>" + costprice + "</td><td>" + time + "</td><td>" + requestor +"</td></tr>");
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
