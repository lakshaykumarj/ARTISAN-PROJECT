<%@ page import="java.sql.*" %>
<%
  // Database connection details
  String driver = "oracle.jdbc.driver.OracleDriver";
  String url = "jdbc:oracle:thin:@localhost:1521:XE";
  String username = "system";
  String password = "20C047new1";

  // Form submission data
  String sellerName = request.getParameter("sellerName");
  String productName = request.getParameter("productName");
  int quantity = Integer.parseInt(request.getParameter("quantity"));
  out.println("sellerName:" + sellerName);
  try (Connection conn = DriverManager.getConnection(url, username, password)) {
    // Get the current tablename
    String tablenameQuery = "SELECT tabname from tablenames order by time";
    String currentTablename = "";
    try (PreparedStatement pstmt = conn.prepareStatement(tablenameQuery)) {
      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          currentTablename = rs.getString("tabname");
        }
      }
    }
    
    //Get current username from the tablename
    String requestor = "";
    String tablenameQuery2 = "SELECT username from users where key = ? ";
    try (PreparedStatement pstmt2 = conn.prepareStatement(tablenameQuery2)) {
      pstmt2.setString(1,currentTablename);
      try (ResultSet rs2 = pstmt2.executeQuery()) {
        if (rs2.next()) {
          requestor = rs2.getString("username");
        }
      }
    }
    out.println("Requestor: " + requestor);
    //Get seller Tablename
    String sellerTableName = "";
    String sellerTableQuery = "SELECT key FROM users where username = ? ";
    try(PreparedStatement stmt1 = conn.prepareStatement(sellerTableQuery)){
        stmt1.setString(1,sellerName);
        try (ResultSet rs1 = stmt1.executeQuery()) {
        if (rs1.next()) {
           sellerTableName = rs1.getString("key");
        }
      }
    }

    // Get the rate for the product from seller side
    String rateQuery = "SELECT cost_price FROM product WHERE product_name = ? AND tablename = ?";
    double rate = 0;
    try (PreparedStatement pstmt = conn.prepareStatement(rateQuery)) {
      pstmt.setString(1, productName);
      pstmt.setString(2, sellerTableName);
      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          rate = rs.getDouble("cost_price");
        }
      }
    }
    out.println("Rate for the product: " + rate);

    // Apply the rate calculation
    rate = rate * 1.3;
    out.println("Adjusted rate: " + rate);
    out.println("requestor:" + requestor);
    // Insert into the log table
    String insertLogQuery = "INSERT INTO log (requestor, requestee, time, product, quantity, rate, success) VALUES (?, ?, SYSDATE, ?, ?, ?, 'P')";
    try (PreparedStatement pstmt = conn.prepareStatement(insertLogQuery)) {
      pstmt.setString(1, requestor);
      pstmt.setString(2, sellerName);
      pstmt.setString(3, productName);
      pstmt.setInt(4, quantity);
      pstmt.setDouble(5, rate);
      pstmt.executeUpdate();
    }
    out.println("Log entry inserted successfully!");

    // Print success message
    out.println("<h1>Request submitted successfully!</h1>");
  } catch (Exception e) {
    // Print error message
    out.println("<h1>Error occurred!</h1>");
    out.println("<p>" + e.getMessage() + "</p>");
  }
%>
