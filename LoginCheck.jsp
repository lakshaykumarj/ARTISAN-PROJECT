<%@ page import="java.sql.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    String url = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUsername = "system";
    String dbPassword = "20C047new1";
    String message;

    String query = "SELECT * FROM users WHERE username = ? AND password = ?";
    String query2 = "INSERT INTO tableNames VALUES(?,?)";
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        PreparedStatement stmt = conn.prepareStatement(query);
        stmt.setString(1, username);
        stmt.setString(2, password);

        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            String result = username.substring(3) + password.substring(0, 3);
            String redirectUrl = "Options.jsp?username="+username;
            PreparedStatement stmt2 = conn.prepareStatement(query2);
            stmt2.setString(1,result);
            stmt2.setDate(2, new java.sql.Date(System.currentTimeMillis()));
            stmt2.executeQuery();
            stmt2.close();
               out.println("<script>setTimeout(function() { window.location.href = 'http://localhost:8080/ARTISAN/Options.jsp?username=" + username + "'; }, 800);</script>");

        } else {
                message = "Incorrect username or password!";
                out.println("<script>alert(\"" + message  + "\");</script>");
                out.println("<script>setTimeout(function() { window.location.href = 'http://localhost:8080/ARTISAN/Login.html'; }, 500);</script>");
        }
        rs.close();
        stmt.close();
        conn.close();

    } catch (Exception e) {
        out.println("An error occurred: " + e.getMessage());
    }
%>

