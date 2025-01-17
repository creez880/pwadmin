<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.security.*"%>
<%@include file="WEB-INF/.pwadminconf.jsp"%>

<%!
    String encode(String salt, String algorithm) throws NoSuchAlgorithmException {
        MessageDigest alg = MessageDigest.getInstance(algorithm);
        alg.reset();
        alg.update(salt.getBytes());
        byte[] digest = alg.digest();
        StringBuffer hashedpasswd = new StringBuffer();
        String hx;
        for(int i=0; i<digest.length; i++)
        {
            hx =  Integer.toHexString(0xFF & digest[i]);
            if(hx.length() == 1)
            {
                hx = "0" + hx;
            }
            hashedpasswd.append(hx);
        }
        return hashedpasswd.toString();
    }
%>

<style>
    /* Styling for the login page */
    body {
        background-color: #333;
        color: #eee;
    }
    .login-container {
        width: 350px;
        margin: 100px auto;
        padding: 20px;
        border: 1px solid #555;
        border-radius: 5px;
        background-color: #444;
    }
    .login-container h2 {
        text-align: center;
        margin-bottom: 20px;
    }
    .login-form label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
    }
    .login-form input[type="text"],
    .login-form input[type="password"] {
        width: 100%;
        padding: 8px;
        margin-bottom: 10px;
        border: 1px solid #777;
        border-radius: 3px;
        background-color: #555;
        color: #eee;
    }
    .login-form input[type="image"] {
        display: block;
        margin: 10px auto;
        border: 0px;
    }
    .error-message {
        color: #ff0000;
        text-align: center;
        margin-bottom: 10px;
    }
    #reload-image{
        width: 6%;
    }
</style>

<div class="login-container">
    <h2>Admin Login</h2>
    <%
        String errorMessage = "";

        if(request.getParameter("logout") != null && request.getParameter("logout").compareTo("true") == 0)
        {
            request.getSession().removeAttribute("ssid");
            request.getSession().removeAttribute("items");
            request.getSession().removeAttribute("captcha"); // Remove CAPTCHA from session on logout
        }

        if(request.getMethod().equalsIgnoreCase("POST"))
        {
            // Check if username, password, and captcha are provided
            String enteredUsername = request.getParameter("username");
            String enteredPassword = request.getParameter("password");
            String enteredCaptcha = request.getParameter("captcha"); // Get the CAPTCHA input

            // Validate CAPTCHA
            String sessionCaptcha = (String) session.getAttribute("captcha");
            if (sessionCaptcha != null && sessionCaptcha.equals(enteredCaptcha)) {

                // Proceed with username and password validation
                if(enteredUsername != null && enteredPassword != null)
                {
                    String clientIP = request.getRemoteAddr();
                    boolean ipAllowed = true;

                    try {
                        String encodedUsername = encode(enteredUsername, "MD5");
                        String encodedPassword = encode(enteredPassword, "MD5");

                        // Check if credentials match
                        if (encodedUsername.compareTo(iweb_username) == 0 && encodedPassword.compareTo(iweb_password) == 0)
                        {
                            if(enable_ip_whitelist)
                            {
                                 ipAllowed = false;
                                    // Read whitelist from file
                                    try {
                                        File whiteListFile = new File(request.getRealPath("WEB-INF/whitelist.txt"));
                                           if(whiteListFile.exists())
                                        {
                                            BufferedReader reader = new BufferedReader(new FileReader(whiteListFile));
                                            String line;
                                            while((line = reader.readLine()) != null)
                                            {
                                                if(clientIP.trim().equalsIgnoreCase(line.trim()))
                                                {
                                                    ipAllowed = true;
                                                    break;
                                                }
                                            }
                                            reader.close();
                                        }
                                    }
                                    catch (IOException e) {
                                        errorMessage = "Error reading whitelist file.";
                                        e.printStackTrace();
                                    }
                            }
                             if(ipAllowed)
                             {
                                request.getSession().setAttribute("ssid", request.getRemoteAddr());
                                request.getSession().setAttribute("ipAllowed", true);
                                response.sendRedirect("index.jsp");
                                return;
                             }
                            else
                             {
                                errorMessage = "<p class=\"error-message\">Access denied, your IP ("+ clientIP +") is not whitelisted.</p>";
                             }

                        } else {
                            errorMessage = "<p class=\"error-message\">Invalid username, password, or CAPTCHA.</p>";
                        }
                    } catch (NoSuchAlgorithmException e) {
                        errorMessage = "<p class=\"error-message\">Error encoding password: "+ e.getMessage() +"</p>";
                    }
                }
            } else {
                errorMessage = "<p class=\"error-message\">Invalid CAPTCHA.</p>";
            }
        }

        // If the user is not logged in, show the login form
        if(request.getSession().getAttribute("ssid") == null)
        {
            out.println("<form action=\"login.jsp\" method=\"post\" class=\"login-form\">");
            out.println(errorMessage);
            out.println("<label for=\"username\">Username:</label>");
            out.println("<input type=\"text\" id=\"username\" name=\"username\" required>");
            out.println("<label for=\"password\">Password:</label>");
            out.println("<input type=\"password\" id=\"password\" name=\"password\" required>");
            out.println("<label for=\"captcha\">Enter the CAPTCHA:</label>");
            out.println("<input type=\"text\" id=\"captcha\" name=\"captcha\" required>");
            out.println("<img src=\"include/captcha.jsp\" id=\"captcha-image\" alt=\"CAPTCHA Image\" /><a href=\"#\" onclick=\"reloadCaptcha();\">  <img src=\"include/reload.png\" id=\"reload-image\" title=\"Reload CAPTCHA\"/></a>");  // Show CAPTCHA image
            out.println("<input type=\"image\" src=\"include/btn_login.jpg\" style=\"border: 0px;\">");
            out.println("</form>");
        }
        else
        {
            out.println("<a href=\"index.jsp?logout=true\" class=\"logout-button\"><img src=\"include/btn_logout.jpg\" border=\"0\"></a>");
        }
    %>
</div>
<script>
    function reloadCaptcha() {
        var captcha = document.getElementById("captcha-image");
        captcha.src = captcha.src.split('?')[0] + '?' + new Date().getTime();
    }
</script>
