<%@page contentType="text/html; charset=UTF-8" %>
<%@page import="java.sql.*"%>
<%@page import="protocol.*"%>
<%@page import="java.io.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.goldhuman.Common.Octets"%>
<%@page import="com.goldhuman.IO.Protocol.Rpc.Data.DataVector"%>
<%@page import="com.goldhuman.auth.*"%>
<%@page import="com.goldhuman.util.ConfigUtil"%>
<%@page import="com.goldhuman.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@include file="WEB-INF/.pwadminconf.jsp"%>

<%
	String message = "<br>";
	boolean allowed = false;
    String debugOutput = ""; // For accumulating debugging info

	if(request.getSession().getAttribute("ssid") == null)
	{
		out.println("<p align=\"right\"><font color=\"#ee0000\"><b>Login for Character administration...</b></font></p>");
	}
	else
	{
		allowed = true;
	}

	int id = -1;
	String xml = "";

	if(allowed && request.getParameter("ident") != null)
	{
		try
		{
			id = Integer.parseInt(request.getParameter("ident"));
			debugOutput += "<br>Debug: Character ID = " + id;

			if(request.getParameter("process") != null && request.getParameter("process").compareTo("save") == 0)
			{
				//### Apply Modifications
                 debugOutput += "<br>Debug: Saving XML";
				try
				{
					xml = request.getParameter("xml");
                     debugOutput += "<br>Debug: XML received = " + xml;

                     if(xml == null || xml.trim().isEmpty()){
                          message = "<font color=\"#ee0000\"><b>Saving Character Data Failed: XML is empty</b></font>";
                            debugOutput += "<br>Debug: XML is empty, cannot save";
                     }
                     else{

                        // Path
                        File workingDir = new File(pw_server_path + "/gamedbd/");
                        debugOutput += "<br>Debug: Working Directory = " + workingDir.getAbsolutePath();
                        String command = "./gamedbd ./gamesys.conf importrole " + id;
                        debugOutput += "<br>Debug: Command = " + command;

                        // Use ProcessBuilder
                        ProcessBuilder processBuilder = new ProcessBuilder("/bin/bash", "-c", command);
                        processBuilder.directory(workingDir); // Set working directory

                       Process process = null;
                       BufferedWriter writer = null;
                        BufferedReader errorReader = null;


                        try{
                            process = processBuilder.start();
                            writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream()));
                            errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));

                             //Write data to process
                           writer.write(xml);
                           writer.flush();
                           writer.close();


                           StringBuilder errorResult = new StringBuilder();
                             String line;
                            while ((line = errorReader.readLine()) != null) {
                                errorResult.append(line).append("\n");
                                debugOutput += "<br>Debug: Process error: " + line;
                            }



                            int exitCode = process.waitFor();
                             debugOutput += "<br>Debug: Process Exit Code = " + exitCode;
                            if(exitCode != 0){
                                 debugOutput += "<br>Debug: Process Error Output = " + errorResult.toString();
                                message = "<font color=\"#ee0000\"><b>Process exited with error</b></font>";

                            } else{
                                 message = "<font color=\"#00cc00\"><b>Character Data Saved</b></font>";
                            }


                        } catch(Exception e){
                           message = "<font color=\"#ee0000\"><b>Saving Character Data Failed: Process failed</b></font>";
                           debugOutput += "<br>Debug: Exception while executing process: " + e.getMessage();
                            StringWriter sw = new StringWriter();
                            PrintWriter pw = new PrintWriter(sw);
                            e.printStackTrace(pw);
                            debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
                        }
                        finally {
                            if(writer != null){
                                try{
                                     writer.close();
                                      debugOutput += "<br>Debug: writer closed";
                                }
                                catch(IOException ioe){
                                      debugOutput += "<br>Debug: IOException closing writer: " + ioe.getMessage();
                                }
                            }

                             if(errorReader != null){
                                try{
                                     errorReader.close();
                                     debugOutput += "<br>Debug: errorReader closed";
                                }
                                catch(IOException ioe){
                                     debugOutput += "<br>Debug: IOException closing error reader: " + ioe.getMessage();
                                }
                            }

                            if(process != null){
                                 process.destroy();
                                  debugOutput += "<br>Debug: Process Destroyed";
                            }
                        }
                   }
				}
				catch(Exception e)
				{
					message = "<font color=\"#ee0000\"><b>Saving Character Data Failed: " + e.getMessage() + "</b></font>";
                      debugOutput += "<br>Debug: Exception while saving: " + e.getMessage();
                     StringWriter sw = new StringWriter();
                     PrintWriter pw = new PrintWriter(sw);
                     e.printStackTrace(pw);
                      debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";

				}
			}
			else
			{
				//### Get Values
                debugOutput += "<br>Debug: Loading XML";
				try
				{
					if(id > 15)
    				{
        				// Path
        				File workingDir = new File(pw_server_path + "/gamedbd/");
                        debugOutput += "<br>Debug: Working Directory = " + workingDir.getAbsolutePath();
        				String command = "./gamedbd ./gamesys.conf exportrole " + id;
                         debugOutput += "<br>Debug: Command = " + command;
        				// Use ProcessBuilder 
        				ProcessBuilder processBuilder = new ProcessBuilder("/bin/bash", "-c", command);
        				processBuilder.directory(workingDir); // Set direktori kerja

        				 Process process = null;
                         BufferedReader reader = null;
                         BufferedReader errorReader = null;

                         try{
                              process = processBuilder.start();
                              reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                              errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));
                              StringBuilder result = new StringBuilder();
                              StringBuilder errorResult = new StringBuilder();
                              String line;
                              while ((line = reader.readLine()) != null) {
                                  result.append(line).append("\n");
                              }
                                while ((line = errorReader.readLine()) != null) {
                                    errorResult.append(line).append("\n");
                                }
                              reader.close();
                             errorReader.close();
                             int exitCode = process.waitFor();
                             debugOutput += "<br>Debug: Process Exit Code = " + exitCode;
                            if(exitCode != 0){
                                debugOutput += "<br>Debug: Process Error Output = " + errorResult.toString();
                                message = "<font color=\"#ee0000\"><b>Process exited with error</b></font>";
                            }
                             xml = result.toString();
                             debugOutput += "<br>Debug: XML = " + xml;

                         } catch(Exception ex){
                            message = "<font color=\"#ee0000\"><b>Loading Character Data Failed (Process Error): " + ex.getMessage() + "</b></font>";
                            debugOutput += "<br>Debug: Exception while loading: " + ex.getMessage();
                             StringWriter sw = new StringWriter();
                             PrintWriter pw = new PrintWriter(sw);
                             ex.printStackTrace(pw);
                            debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
                         }
                          finally {
                            if(reader != null){
                                try{
                                     reader.close();
                                }
                                catch(IOException ioe){
                                    //Log exception for debugging purposes only
                                     debugOutput += "<br>Debug: Error closing input stream: " + ioe.getMessage();
                                }
                            }
                             if(errorReader != null){
                                try{
                                    errorReader.close();
                                }
                                catch(IOException ioe){
                                    //Log exception for debugging purposes only
                                     debugOutput += "<br>Debug: Error closing error stream: " + ioe.getMessage();
                                }
                            }

                            if(process != null){
                                 process.destroy();
                            }
                        }

    				}
                    else{
                         message = "<font color=\"#ee0000\"><b>Character ID <= 15 skipping process execution</b></font>";
                         debugOutput += "<br>Debug: Character ID <= 15 skipping process execution";
                    }

				}
				catch(Exception e)
				{
					message = "<font color=\"#ee0000\"><b>Loading Character Data Failed: " + e.getMessage() + "</b></font>";
                      debugOutput += "<br>Debug: Exception while loading: " + e.getMessage();
                     StringWriter sw = new StringWriter();
                     PrintWriter pw = new PrintWriter(sw);
                     e.printStackTrace(pw);
                      debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
				}
			}
		}
		catch(Exception e)
		{
			message = "<font color=\"#ee0000\"><b>Invalid Character ID: " + e.getMessage() + "</b></font>";
            debugOutput += "<br>Debug: Exception on parsing ID: " + e.getMessage();
              StringWriter sw = new StringWriter();
              PrintWriter pw = new PrintWriter(sw);
             e.printStackTrace(pw);
               debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
		}
	}
%>

<table width="800" cellpadding="0" cellspacing="0" border="0">

	<tr>
		<td colspan="3">
			<br>
		</td>
	</tr>

	<tr>
		<th height="1" align="left" valign="middle" style="padding: 5px;">
			<font size="+1"><b>
			<%
				out.print("Character ID: " + id);
			%>
			</b></font>
		</th>
		<form action="index.jsp?page=role&show=details" method="post" style="margin: 0px;">
		<th height="1" colspan="2" align="right" valign="middle" style="padding: 5px;">
			<table cellpadding="0" cellspacing="2" border="0">
				<tr>
					<td width="1"><input name="ident" type="text" value="<% out.print(id); %>"style="width: 75px; text-align: center;"></input></td>
					<td width="1"><select name="type" style="width: 75px; text-align: center;"><option value="id">by ID</option><option value="name">by NAME</option></select></td>
					<td width="1"><input type="image" src="include/btn_goto.jpg" style="border: 0px;"></input></td>
				</tr>
			</table>
		</th>
		</form>
	</tr>

	<tr bgcolor="#f0f0f0">
		<td colspan="3" align="center" style="padding: 5px;">
			<%= message %>
		</td>
	</tr>
	
	<form name="update" action="index.jsp?page=rolexml&ident=<%out.print(id);%>&process=save" method="post" style="margin: 0px;">

	<tr>
		<td colspan="3" align="left" valign="top">
			<textarea name="xml" rows="24" style="width: 100%;"><%out.print(StringEscapeUtils.escapeHtml(xml));%></textarea>
		</td>
	</tr>

	<tr>
		<td colspan="3">
			<br>
		</td>
	</tr>

	<%
		if(allowed)
		{
			out.println("<tr>");
				out.println("<td colspan=\"3\" align=\"center\" style=\"border-top: 1px solid #cccccc; border-bottom: 1px solid #cccccc; padding: 2px;\"><input type=\"image\" src=\"include/btn_save.jpg\" style=\"border: 0;\"></input></td>");
			out.println("</tr>");
		}
	%>

	</form>
      <tr>
		<td colspan="3">
           <div style="white-space: pre-wrap; font-family: monospace; font-size: 0.8em; background-color: #f0f0f0; padding: 10px;">
		        <%=debugOutput%>
           </div>
		</td>
	</tr>
</table>