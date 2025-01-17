<%@ page import="java.io.*" %>
<%@ page import="java.util.Scanner" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="java.io.PrintWriter" %>

<%
    String confFilePath = "/home/gamed/ptemplate.conf";
    String message = "";
    String traceLog = ""; // Initialize trace log

    if(request.getParameter("process") != null) {
        if(request.getParameter("process").compareTo("save_rates") == 0) {
            String newExp = request.getParameter("exp_rate");
            String newDrop = request.getParameter("drop_rate");
            String newMoney = request.getParameter("coins_rate");
            String newSp = request.getParameter("sp_rate");

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
    <form action="index.jsp?page=server&process=save_rates" method="post" style="margin: 0px;">
        <table cellpadding="2" cellspacing="0" style="border: 1px solid #cccccc;">

<%
    int exp_rate = 0;
    int sp_rate = 0;
    int drop_rate = 0;
    int coins_rate = 0;
	try{
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
                <td colspan="2" align="center" class="base-rate-info">Base Value is: 1</td>
            </tr>
            <tr>
                <td>SP Rate:</td>
                <td><input type="text" name="sp_rate" value="<%= sp_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
              <tr>
                <td colspan="2" align="center" class="base-rate-info">Base Value is: 1</td>
            </tr>
            <tr>
                <td>Drop Rate:</td>
                <td><input type="text" name="drop_rate" value="<%= drop_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
              <tr>
                <td colspan="2" align="center" class="base-rate-info">Base Value is: 1</td>
            </tr>
             <tr>
                <td>Coins Rate:</td>
                <td><input type="text" name="coins_rate" value="<%= coins_rate %>" style="width: 60px; text-align: center;"></td>
            </tr>
             <tr>
                <td colspan="2" align="center" class="base-rate-info">Base Value is: 1</td>
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
</body>
</html>