<%@page import="java.lang.*"%>
<%@page import="java.util.*"%>
<%@page import="protocol.*"%>
<%@page import="com.goldhuman.auth.*"%>
<%@page import="com.goldhuman.service.*"%>
<%@page import="com.goldhuman.util.*"%>
<%@page import="org.apache.commons.logging.Log"%>
<%@page import="org.apache.commons.logging.LogFactory"%>
<%@include file="WEB-INF/.pwadminconf.jsp"%>

<script language=javascript>
    function f_doubleexp_submit() {
        // Set the value of doubleexp based on the selected option
        var form = document.forms['form_doubleexp'];
        var selectedValue = form.expselect.options[form.expselect.selectedIndex].value;
        form.doubleexp.value = selectedValue;

        // Validate that doubleexp is not empty (optional)
        if (form.doubleexp.value === "") {
            alert("Please select an EXP/SP rate before submitting.");
            return false; // Cancel form submission
        }

        return true; // Allow form submission
    }  
</script>

<%
    String confFilePath = pw_server_path +"/gamed/ptemplate.conf";
    String message = "";
    String traceLog = ""; // Initialize trace log
    String baseValueString = "Base Value is: 1";

    if(request.getParameter("process") != null) {
        if(request.getParameter("process").compareTo("save_rates") == 0) {
            String newExp = request.getParameter("exp_rate");
            String newDrop = request.getParameter("drop_rate");
            String newMoney = request.getParameter("coins_rate");
            String newSp = request.getParameter("sp_rate");
            String newExpSpModifier = request.getParameter("expselect");

            try {
                traceLog += "Starting save process.<br>";
                // Read config file into memory
                File file = new File(confFilePath);
                traceLog += "File object created: " + file.getAbsolutePath() + "<br>";
                Scanner scanner = new Scanner(file);
                traceLog += "Scanner created.<br>";
                StringBuilder fileContent = new StringBuilder();
                traceLog += "StringBuilder created.<br>";

                while (scanner.hasNextLine()) {
                    String line = scanner.nextLine();
                    if (line.trim().startsWith("exp_bonus = ")) {
                        fileContent.append("exp_bonus = ").append(newExp).append("\n");
                    } else if (line.trim().startsWith("drop_bonus = ")) {
                        fileContent.append("drop_bonus = ").append(newDrop).append("\n");
                    } else if (line.trim().startsWith("money_bonus = ")) {
                        fileContent.append("money_bonus = ").append(newMoney).append("\n");
                    } else if (line.trim().startsWith("sp_bonus = ")) {
                        fileContent.append("sp_bonus = ").append(newSp).append("\n");
                    } else {
                        fileContent.append(line).append("\n");
                    }
                }
                scanner.close();
                traceLog += "File scanned.<br>";

                // Write the modified content back to the file
                BufferedWriter writer = new BufferedWriter(new FileWriter(file));
                traceLog += "BufferedWriter created.<br>";
                writer.write(fileContent.toString());
                writer.close();
                traceLog += "File written.<br>";
                message = "<font color=\"#00cc00\"><b>Rates Saved! Please restart the server for the changes to take effect.<b></font><br>";
                traceLog += "Save process complete.<br>";
            }
            catch (NumberFormatException e){
                StringWriter sw = new StringWriter();
                PrintWriter pw = new PrintWriter(sw);
                e.printStackTrace(pw);
                traceLog += "<font color=\"#ee0000\"><b>Number Format Exception: "+e.getMessage()+"</b></font><br>";
				traceLog += "<font color=\"#ee0000\"><b>Trace Log: "+sw.toString()+"</b></font><br>";
                message = "<font color=\"#ee0000\"><b>Invalid Rate values, please use numbers<b></font><br>";
            }
            catch (Exception e) {
                 StringWriter sw = new StringWriter();
                PrintWriter pw = new PrintWriter(sw);
                e.printStackTrace(pw);
                traceLog += "<font color=\"#ee0000\"><b>Exception: "+e.getMessage()+"</b></font><br>";
				traceLog += "<font color=\"#ee0000\"><b>Trace Log: "+sw.toString()+"</b></font><br>";
                message = "<font color=\"#ee0000\"><b>Error saving rates: "+e.getMessage()+"</b></font><br>";
            }
        }
    }
%>
<html>
<head>
	<title>Server Rate Editor</title>
    <style>
    .base-rate-info {
        font-size: 0.8em; /* Adjust size as needed */
        color: #888; /* Adjust color as needed */
        margin-bottom: 5px; /* Add spacing */
    }
</style>
</head>
<body>

    <table>
        <tr>
            <th colspan="2" align="center" style="padding: 5;">
                <font color="#ffffff"><b><%= pw_server_name %></b></font>
            </th>
        </tr>
        <tr>
            <td colspan="2" align="left" valign="middle" style="border-bottom: 1px solid #cccccc;">
                <iframe src="status.jsp" width="120" height="32" scrolling="no" frameborder="no" style="border: 0;"></iframe>
            </td>
        </tr>
    </table>

    <form action="index.jsp?page=server&process=save_rates" method="post" style="margin: 0px;">
        <table cellpadding="2" cellspacing="0" style="border: 1px solid #cccccc;">

            <%
                int exp_rate = 0;
                int sp_rate = 0;
                int drop_rate = 0;
                int coins_rate = 0;
                try {
                    traceLog += "Starting load process.<br>";
                    File file = new File(confFilePath);
                    traceLog += "File object created: " + file.getAbsolutePath() + "<br>";
                    Scanner scanner = new Scanner(file);
                    traceLog += "Scanner created.<br>";

                    while(scanner.hasNextLine()){
                        String line = scanner.nextLine();
                        if(line.trim().startsWith("exp_bonus = ")){
                            exp_rate = Integer.parseInt(line.trim().substring(line.trim().indexOf("=")+1).trim());
                        }
                        if(line.trim().startsWith("drop_bonus = ")){
                            drop_rate = Integer.parseInt(line.trim().substring(line.trim().indexOf("=")+1).trim());
                        }
                        if(line.trim().startsWith("money_bonus = ")){
                            coins_rate = Integer.parseInt(line.trim().substring(line.trim().indexOf("=")+1).trim());
                        }
                        if(line.trim().startsWith("sp_bonus = ")){
                            sp_rate = Integer.parseInt(line.trim().substring(line.trim().indexOf("=")+1).trim());
                        }
                    }

                    scanner.close();
                    traceLog += "File scanned.<br>";
                }catch(Exception e){
                    StringWriter sw = new StringWriter();
                    PrintWriter pw = new PrintWriter(sw);
                    e.printStackTrace(pw);
                    traceLog += "<font color=\"#ee0000\"><b>Error reading file: "+e.getMessage()+"</b></font><br>";
                    traceLog += "<font color=\"#ee0000\"><b>Trace Log: "+sw.toString()+"</b></font><br>";
                }
                traceLog += "Load process complete.<br>";
            %>
            <tr>
                <td>EXP Rate:</td>
                <td><input type="text" name="exp_rate" value="<%= exp_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
             <tr>
                <td colspan="2" align="center" class="base-rate-info"><%= baseValueString %></td>
            </tr>
            <tr>
                <td>SP Rate:</td>
                <td><input type="text" name="sp_rate" value="<%= sp_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
              <tr>
                <td colspan="2" align="center" class="base-rate-info"><%= baseValueString %></td>
            </tr>
            <tr>
                <td>Drop Rate:</td>
                <td><input type="text" name="drop_rate" value="<%= drop_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
              <tr>
                <td colspan="2" align="center" class="base-rate-info"><%= baseValueString %></td>
            </tr>
             <tr>
                <td>Coins Rate:</td>
                <td><input type="text" name="coins_rate" value="<%= coins_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
             <tr>
                <td colspan="2" align="center" class="base-rate-info"><%= baseValueString %></td>
            </tr>
            <tr>
                <td colspan="2" align="center" style="border-top: 1px solid #cccccc;">
					<input type="image" src="include/btn_save.jpg" style="border: 0px;">
				</td>
            </tr>
            <tr>
                <td colspan="2" align="center"><%= message %></td>
            </tr>
            <% if(!traceLog.isEmpty()){ %>
                <tr>
                    <td colspan="2" align="left" style="border-top: 1px solid #cccccc;">
                    <font color="#ff0000"><b>Trace Log:</b></font><br><%= traceLog %>
                    </td>
                </tr>
            <%}%>
        </table>
    </form>
    <br>
    <form action="index.jsp?page=server&process=exp" method="post" style="margin: 0px;">
        <table cellpadding="2" cellspacing="0" style="border: 1px solid #cccccc;">

            <tr>
                <th align="center" style="padding: 5;">
                    <font color="#ffffff"><b>EXP / SP Modifier</b></font>
                </th>
            </tr>
            <tr>
                <% 
                    String strDoubleExp = new String("");
                    Double v = new com.goldhuman.service.GMServiceImpl().getw2iexperience(new com.goldhuman.service.interfaces.LogInfo());
                    if (v != null) {
                        strDoubleExp = v.toString();
                    }
                %>
            </tr>
        


            <tr>
                <td acolspan="2" align="center" style="border-top: 1px solid #cccccc;">
	                <form action="index.jsp?page=server&process=exp" name="form_doubleexp" method="post" onsubmit="return f_doubleexp_submit();">
	                <input type="hidden" name="doubleexp" value=""/>
                    <label>EXP / SP Rate:
                        <select name="expselect">
                            <option value="1">1x</option>
                            <option value="1.5">1.5x</option>
                            <option value="2">2x</option>
                            <option value="2.5">2.5x</option>
                            <option value="3">3x</option>
                            <option value="3">3.5x</option>
                            <option value="4">4x</option>
                            <option value="4.5">4.5x</option>
                            <option value="5">5x</option>
                            <option value="5.5">5.5x</option>
                            <option value="6">6x</option>
                            <option value="6.5">6.5x</option>
                            <option value="7">7x</option>
                            <option value="7.5">7.5x</option>
                            <option value="8">8x</option>
                            <option value="8.5">8.5x</option>
                            <option value="9">9x</option>
                            <option value="9.5">9.5x</option>
                            <option value="10">10x</option>
                        </select>
                    </label>
                </td>
            </tr>
            <tr bgcolor="#f0f0f0">
                <td align="center" style="border-top: 1px solid #cccccc;">&nbsp;
                    <%
                        if (request.getParameter("process") != null) {
                            if (request.getParameter("process").compareTo("exp") == 0) {              
                                String status = request.getParameter("doubleexp");
                                if (status.isEmpty()) {
                                    out.println("Status is empty!<br>");
                                }

                                boolean success = false;
                                try {
                                    <!-- Double experience = new Double(status); -->
                                    Double experience = new Double(newExpSpModifier);
                                    com.goldhuman.service.GMServiceImpl gm = new com.goldhuman.service.GMServiceImpl();
                                    success = gm.setw2iexperience(experience, new com.goldhuman.service.interfaces.LogInfo());
                                    LogFactory.getLog("index.jsp?page=server&process=exp").info("setdoubleexp, status=" + status + ",result=" + success + ",operator=" + AuthFilter.getRemoteUser(session) );
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                                if( success ) {
                                    out.print("Rates Changed To " + status + "x");
                                } else {
                                    out.print("Saving Rates Failed");
                                }     
                            }
                        }
                    %>
                </td>
            </tr>
            <tr>
                <td colspan="2" align="center" style="border-top: 1px solid #cccccc;">Current Rate: <%=strDoubleExp%>x
                </td>
            </tr>

            <!-- SAVE button for EXP & SP modifier-->
            <tr>
                <td colspan="2" align="center" style="border-top: 1px solid #cccccc;">
					<input align="middle" type="image" src="include/btn_save.jpg" name="doubleexp_button" style="border: 0px;"/>
				</td>
            </tr>
        </table>
    </form>
</body>
</html>