<%@ page import="java.sql.*" %>
<html><head><title>Checking...</title></head>
<body>
<%  
             if (request.getMethod().equalsIgnoreCase("post")) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String retypePassword = request.getParameter("retype");
                String message;
            if (password.equals(retypePassword)) {
                try {
                String url = "jdbc:oracle:thin:@localhost:1521:XE";
                String dbUsername = "system";
                String dbPassword = "20C047new1";
                Connection conn = DriverManager.getConnection(url, dbUsername, dbPassword);
                
                String sql = "INSERT INTO users VALUES (?, ?, ?)";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, username);
                pstmt.setString(2, password);
                pstmt.setString(3, username.substring(3) + password.substring(0, 3));
                pstmt.executeUpdate();
                
                message = "Account successfully made!";
                out.println("<script>alert(\"" + message  + "\");</script>");
                out.println("<script>setTimeout(function() { window.location.href = 'http://localhost:8080/ARTISAN/Login.html'; }, 500);</script>");
                pstmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("Error: " + e.getMessage());
            }
            }else{
                message = "Passwords do not match!";
                out.println("<script>alert(\"" + message  + "\");</script>");
                out.println("<script>setTimeout(function() { window.location.href = 'http://localhost:8080/ARTISAN/CreateAccount.html'; }, 500);</script>");
            
        }
      
    }
    %>
</body>
</html>