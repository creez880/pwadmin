<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.security.*"%>
<%@include file="WEB-INF/.pwadminconf.jsp"%>

<%!
    String pw_encode(String salt, MessageDigest alg) {
        alg.reset(); 
        alg.update(salt.getBytes());
        byte[] digest = alg.digest();

        // Convert the hash to Base64
        String base64Encoded = Base64.getEncoder().encodeToString(digest);
        return base64Encoded;
    }
%>

<%
    // Beispiel zur Verwendung der Methode
    String salt = "exampleSalt";
    MessageDigest md5 = MessageDigest.getInstance("MD5");
    String hashedPassword = pw_encode(salt, md5);
    out.println("Base64 Encoded Password: " + hashedPassword);
%>
