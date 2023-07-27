<%@ page import="java.sql.*" %>
<%
  // Database connection details
  String driver = "oracle.jdbc.driver.OracleDriver";
  String url = "jdbc:oracle:thin:@localhost:1521:XE";
  String username = "system";
  String password = "20C047new1";

  // Artisan details
  String artisanName = request.getParameter("artisanName");
  int artisanTypeId = 0;
  // Product details
  String productName = request.getParameter("productName");
  double costPrice = Double.parseDouble(request.getParameter("costPrice"));
  int quantity = Integer.parseInt(request.getParameter("quantity"));
  String tablename = "";

  try (Connection conn = DriverManager.getConnection(url, username, password)) {
    //--------------------------------------------------------------------------------------------------------
    // Retrieving TABLENAME
    out.println(artisanName);
    String tablenameQuery = "SELECT tabname FROM tablenames ORDER BY time DESC FETCH FIRST 1 ROWS ONLY";
    try (PreparedStatement pstmt = conn.prepareStatement(tablenameQuery);
         ResultSet rs = pstmt.executeQuery()) {
      if (rs.next()) {
        tablename = rs.getString("tabname");
      }
    }
    //--------------------------------------------------------------------------------------------------------
    // ARTISAN_TYPE INSERTION (OPTIONAL)
    // Retrieve artisanTypeId based on artisanname from the form
    String artisanTypeQuery = "SELECT artisan_type_id FROM artisan_type WHERE artisan_type_name = ?";
    try (PreparedStatement artisanTypeStmt = conn.prepareStatement(artisanTypeQuery)) {
      artisanTypeStmt.setString(1, artisanName);
      try (ResultSet artisanTypeRs = artisanTypeStmt.executeQuery()) {
        if (artisanTypeRs.next()) {
          artisanTypeId = artisanTypeRs.getInt("artisan_type_id");
        }
      }
    }

    // Check if the artisan name already exists in the artisan_type table
    out.println(tablename);
    String checkArtisanQuery = "SELECT COUNT(*) FROM artisan_type WHERE artisan_type_id = ? AND tablename = ?";
    try (PreparedStatement checkArtisanStmt = conn.prepareStatement(checkArtisanQuery)) {
      checkArtisanStmt.setInt(1, artisanTypeId);
      checkArtisanStmt.setString(2, tablename);
      ResultSet countRs = checkArtisanStmt.executeQuery();
      countRs.next();
      int rowCount = countRs.getInt(1);
      out.println(rowCount);
      if (rowCount == 0) {
        out.println("No rows similar found");
        // No similar rows found
        // Proceed with creating a new row
        String artisanSeqQuery = "SELECT artisan_seq.NEXTVAL FROM DUAL";
        PreparedStatement seqStmt = conn.prepareStatement(artisanSeqQuery);
        ResultSet seqRs = seqStmt.executeQuery();
        seqRs.next();
        artisanTypeId = seqRs.getInt(1);

        // Create a new row in the table
        String insertArtisanQuery = "INSERT INTO artisan_type VALUES (?, ?, ?)";
        PreparedStatement insertArtisanStmt = conn.prepareStatement(insertArtisanQuery);
        insertArtisanStmt.setInt(1, artisanTypeId);
        insertArtisanStmt.setString(2, artisanName);
        insertArtisanStmt.setString(3, tablename);
        insertArtisanStmt.executeUpdate();

        out.println("Artisan inserted");
      } else {
        // Similar rows found, ignore insertion
        out.println("Artisan with the same name already exists. Skipping insertion.");
      }
    }
    //------------------------------------------------------------------------------------------------------------
    // PRODUCT INSERTION
    // 1. Search for any rows with the product name, artisan type id, and tablename
    String searchProductQuery = "SELECT COUNT(*) FROM product WHERE product_name = ? AND artisan_type_id = ? AND tablename = ?";

    try (PreparedStatement searchProductStmt = conn.prepareStatement(searchProductQuery)) {

      searchProductStmt.setString(1, productName);
      searchProductStmt.setInt(2, artisanTypeId);
      searchProductStmt.setString(3, tablename);

      try (ResultSet searchProductRs = searchProductStmt.executeQuery()) {

        if (searchProductRs.next()) {
          int rowCount = searchProductRs.getInt(1);
          //if no product of this type already exists,
          if (rowCount == 0) {
            // 2. Insert a new row into the product table with the given details
            String insertProductQuery = "INSERT INTO product (product_id, product_name, cost_price, quantity, date_of_purchase, artisan_type_id, tablename) VALUES (product_seq.NEXTVAL, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement insertProductStmt = conn.prepareStatement(insertProductQuery)) {
              insertProductStmt.setString(1, productName);
              insertProductStmt.setDouble(2, costPrice);
              insertProductStmt.setInt(3, quantity);
              insertProductStmt.setDate(4, new java.sql.Date(System.currentTimeMillis()));
              insertProductStmt.setInt(5, artisanTypeId);
              insertProductStmt.setString(6, tablename);
              insertProductStmt.executeUpdate();

              out.println("\nNew row inserted into the product table");
              // New row inserted into the product table

              // Calculate the amount
              double amount = quantity * costPrice;
              // Calculate new_balance from old_balance
              String balanceQuery = "SELECT new_balance FROM transaction WHERE tablename = ? ORDER BY transaction_date DESC FETCH FIRST 1 ROWS ONLY";
              try (PreparedStatement balanceStmt = conn.prepareStatement(balanceQuery)) {
                balanceStmt.setString(1, tablename);
                try (ResultSet balanceRs = balanceStmt.executeQuery()) {
                  double newBalance = 0;
                  if (balanceRs.next()) {
                    newBalance = balanceRs.getDouble("new_balance");
                  }
                  // if old transaction exists, add it with amount to get the new one, else keep the amount as the first transaction
                  if (newBalance != 0) {
                    newBalance += amount;
                  } else {
                    newBalance = amount;
                  }

                  // Insert into the transaction table
                  String insertTransactionQuery = "INSERT INTO transaction (transaction_id, transaction_date, transaction_type, amount, new_balance, tablename) VALUES (transaction_seq.NEXTVAL, ?, 'Stock change', ?, ?, ?)";
                  try (PreparedStatement insertTransactionStmt = conn.prepareStatement(insertTransactionQuery)) {
                    insertTransactionStmt.setDate(1, new java.sql.Date(System.currentTimeMillis()));
                    insertTransactionStmt.setDouble(2, amount);
                    insertTransactionStmt.setDouble(3, newBalance);
                    insertTransactionStmt.setString(4, tablename);
                    insertTransactionStmt.executeUpdate();
                    out.println("\nNew transaction created");
                    // New row inserted into the transaction table
                  }
                }
              }
            }
          }
          //---------------------------------------------------------------------------------------------------------------
          // IF ADDING QUANTITY TO ALREADY EXISTING PRODUCT
          else {
            out.println("\nProduct of this type already exists.");
            // Find the product_id of the existing product with the same name, tablename, and artisan_type_id
            String findProductQuery = "SELECT product_id, cost_price, quantity FROM product WHERE product_name = ? AND tablename = ? AND artisan_type_id = ?";
            try (PreparedStatement findProductStmt = conn.prepareStatement(findProductQuery)) {
              findProductStmt.setString(1, productName);
              findProductStmt.setString(2, tablename);
              findProductStmt.setInt(3, artisanTypeId);
              try (ResultSet findProductRs = findProductStmt.executeQuery()) {
                if (findProductRs.next()) {
                  int existingProductId = findProductRs.getInt("product_id");
                  double existingCostPrice = findProductRs.getDouble("cost_price");
                  int existingQuantity = findProductRs.getInt("quantity");

                  // Update the quantity and cost price of the existing product
                  int newQuantity = existingQuantity + quantity;
                  double updatedCostPrice = costPrice; // Use the new cost price from the form submission

                  // Update the existing row in the product table
                  String updateProductQuery = "UPDATE product SET quantity = ?, cost_price = ? WHERE product_id = ?";
                  try (PreparedStatement updateProductStmt = conn.prepareStatement(updateProductQuery)) {
                    updateProductStmt.setInt(1, newQuantity);
                    updateProductStmt.setDouble(2, updatedCostPrice);
                    updateProductStmt.setInt(3, existingProductId);
                    updateProductStmt.executeUpdate();
                    // Existing product row updated successfully

                    //---------------------------------------------------
                    // Insert a new row into the transaction table
                    // Calculate the amount
                    double amount = (updatedCostPrice - existingCostPrice) * existingQuantity + (costPrice * quantity);

                    // Retrieve the new_balance from the transaction table
                    String balanceQuery = "SELECT new_balance FROM transaction WHERE tablename = ? ORDER BY transaction_date DESC FETCH FIRST 1 ROWS ONLY";
                    try (PreparedStatement balanceStmt = conn.prepareStatement(balanceQuery)) {
                      balanceStmt.setString(1, tablename);
                      try (ResultSet balanceRs = balanceStmt.executeQuery()) {
                        double newBalance = 0;
                        if (balanceRs.next()) {
                          newBalance = balanceRs.getDouble("new_balance");
                        }

                        // Calculate the new balance
                        if (newBalance != 0) {
                          newBalance += amount;
                        } else {
                          newBalance = amount;
                        }

                        // Insert into the transaction table
                        String insertTransactionQuery = "INSERT INTO transaction (transaction_id, transaction_date,transaction_type, amount,new_balance, tablename) VALUES (transaction_seq.NEXTVAL, ?, 'Stock change', ?, ?, ?)";
                        try (PreparedStatement insertTransactionStmt = conn.prepareStatement(insertTransactionQuery)) {
                          insertTransactionStmt.setDate(1, new java.sql.Date(System.currentTimeMillis()));
                          insertTransactionStmt.setDouble(2, amount);
                          insertTransactionStmt.setDouble(3, newBalance);
                          insertTransactionStmt.setString(4, tablename);
                          insertTransactionStmt.executeUpdate();
                          // New row inserted into the transaction table
                          out.println("\n new row successfully inserted");
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  } catch (Exception e) {
    out.println("<h1>Error occurred!</h1>");
    out.println("<p>" + e.getMessage() + "</p>");
  }
%>
