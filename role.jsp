<%@page contentType="text/html; charset=UTF-8" %>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.goldhuman.Common.Octets"%>
<%@page import="com.goldhuman.IO.Protocol.Rpc.Data.DataVector"%>
<%@page import="com.goldhuman.auth.*"%>
<%@page import="com.goldhuman.*"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@include file="WEB-INF/.pwadminconf.jsp"%>

<div align="left" id="sqltip" style="background: #ffffff; border: 1px solid #000000; white-space: nowrap; visibility: hidden; padding: 5px; position: absolute;">
	<b><u>Synchronize GameDB with MySQL Role Table</u></b><br>
	<b>? </b>Make sure Perfect World Server is running<br>
	<b>? </b>Make sure maps are stopped (inconsistence & lag)<br>
	<b>? </b>Process may take a while depending on role amount
</div>

<script type="text/javascript">

	function move_tip(id, event)
	{
		document.getElementById(id).style.left = event.clientX -5 + document.body.scrollLeft;
		document.getElementById(id).style.top = event.clientY + 25 + document.body.scrollTop;
	}

	function show_tip(id)
	{
		document.getElementById(id).style.visibility = "visible";
	}

	function hide_tip(id)
	{
		document.getElementById(id).style.visibility = "hidden";
	}

	function select_item(itemname, itemgroup, itemindex, itemid, itemguid1, itemguid2, itemmask, itemproctype, itempos, itemcount, itemcountmax, itemexpire, itemdata)
	{
		document.getElementById("itemname").href = "http://www.pwdatabase.com/items/" + itemid;
		document.getElementById("itemname").innerHTML = itemname;
		if(itemgroup == "equipment")
		{
			document.update.itemgroup[0].selected = "1";
		}
		if(itemgroup == "inventory")
		{
			document.update.itemgroup[1].selected = "1";
		}
		if(itemgroup == "storage")
		{
			document.update.itemgroup[2].selected = "1";
		}
		document.update.itemindex.value = itemindex;
		document.update.itemid.value = itemid;
		document.update.itemguid1.value = itemguid1;
		document.update.itemguid2.value = itemguid2;
		document.update.itemmask.value = itemmask;
		document.update.itemproctype.value = itemproctype;
		document.update.itempos.value = itempos;
		document.update.itemcount.value = itemcount;
		document.update.itemcountmax.value = itemcountmax;
		document.update.itemexpire.value = itemexpire;
		document.update.itemdata.value = itemdata;
	}

</script>


<%!
	HashMap<Integer, Integer[]> loadPvP(String logfile)
	{
		HashMap<Integer, Integer[]> pvp_table = new HashMap<Integer, Integer[]>();

		try
		{
			String line;
			int victim;
			int attacker;

			Integer[] pvp_entry;

			BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(logfile)));

			while((line = br.readLine()) != null)
			{
				if(line.indexOf(":die:") > -1 && line.indexOf("type=2") > -1) // i.e. "type=258" -> killed by player, "type=4" -> killed by mob
				{
					victim = Integer.parseInt(line.substring(line.indexOf("roleid=")+7, line.indexOf(":type=")));
					attacker = Integer.parseInt(line.substring(line.indexOf("attacker=")+9));

					if(pvp_table.containsKey(victim))
					{
						pvp_entry = pvp_table.get(victim);
						pvp_entry[1]++;
						pvp_table.put(victim, pvp_entry);
					}
					else
					{
						pvp_table.put(victim, new Integer[]{0, 1});
					}

					if(pvp_table.containsKey(attacker))
					{
						pvp_entry = pvp_table.get(attacker);
						pvp_entry[0]++;
						pvp_table.put(attacker, pvp_entry);
					}
					else
					{
						pvp_table.put(attacker, new Integer[]{1, 0});
					}
				}
			}

			br.close();
		}
		catch(Exception e)
		{
			// Error loading file
		}

		return pvp_table;
	}
%>

<%!
 	String toHexString(byte[] x)
  	{
    		StringBuffer sb = new StringBuffer(x.length * 2);
    		for (int i = 0; i < x.length; ++i)
    		{
      			byte n = x[i];
      			int nibble = n >> 4 & 0xF;
      			sb.append((char)((nibble >= 10) ? 97 + nibble - 10 : 48 + nibble));
      			nibble = n & 0xF;
      			sb.append((char)((nibble >= 10) ? 97 + nibble - 10 : 48 + nibble));
    		}
    		return sb.toString();
  	}
%>

<%!
	byte[] hextoByteArray(String x)
  	{
    		if (x.length() < 2)
		{
      			return new byte[0];
		}
    		if (x.length() % 2 != 0)
		{
      			System.err.println("hextoByteArray error! hex size=" + Integer.toString(x.length()));
    		}
    		byte[] rb = new byte[x.length() / 2];
   		for (int i = 0; i < rb.length; ++i)
    		{
      			rb[i] = 0;

      			int n = x.charAt(i + i);
      			if ((n >= 48) && (n <= 57))
        			n -= 48;
      			else
				if ((n >= 97) && (n <= 102))
        				n = n - 97 + 10;
      					rb[i] = (byte)(rb[i] | n << 4 & 0xF0);

      					n = x.charAt(i + i + 1);
      					if ((n >= 48) && (n <= 57))
        					n -= 48;
      					else
					if ((n >= 97) && (n <= 102))
        					n = n - 97 + 10;
      				rb[i] = (byte)(rb[i] | n & 0xF);
    	}
    	return rb;
  }
%>

<%!
	String int2occupation(String mode, int c)
	{
		if(mode.compareTo("pwi") == 0)
		{
	    		switch(c)
	    		{
				case 0: return "Blademaster";
				case 1: return "Wizard";
				case 2: return "Psychic";
				case 3: return "Venomancer";
				case 4: return "Barbarian";
				case 5: return "Assassin";
				case 6: return "Archer";
				case 7: return "Cleric";
				case 8: return "Seeker";
				case 9: return "Mystic";
				case 10: return "Dudskblade";
				case 11: return "Stormbringer";
	    		}
		}
		else
		{
	    		switch(c)
	    		{
				case 0: return "Blademaster";
				case 1: return "Wizard";
				case 2: return "Psychic";
				case 3: return "Venomancer";
				case 4: return "Barbarian";
				case 5: return "Assassin";
				case 6: return "Archer";
				case 7: return "Cleric";
				case 8: return "Seeker";
				case 9: return "Mystic";
				case 10: return "Dudskblade";
				case 11: return "Stormbringer";
	    		}
		}
		return "unknown";
	}
%>

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
	int uid = -1;
    String xml = "";
	String name = "<br>";
	String level = "";
	String reputation = "";
	String health = "";
	String mana = "";
	String exp = "";
	String spirit = "";
	String[] cultivation = new String[33];
	String vigor = "<option value=\"0\"></option>";
	String race = "";
	String occupation = "";
	String gender = "";
	String spouse = "";
	String faction = "";
	String attribute = "";
	String constitution = "";
	String intelligence = "";
	String strength = "";
	String agility = "";
	String patk_min = "";
	String patk_max = "";
	String pdef = "";
	String matk_min = "";
	String matk_max = "";
	String mdef = "";

	String status = "";
	String creationtime = "";
	String deletiontime = "";
	String lastlogin = "";
	String world = "";
	String coordinateX = "";
	String coordinateY = "";
	String coordinateZ = "";
	String cubiamount = "";
	String cubipurchased = "";
	String cubibought = "";
	String cubiused = "";
	String cubisold = "";
	String pkmode = "";
	String pkinvadertime = "";
	String pkpariahtime = "";

	int breakcol = 6;

	String equipment = "<option value=\"0\"></option>";
	String inventory = "<option value=\"0\"></option>";
	String storage = "<option value=\"0\"></option>";
	String pocket_coins = "";
	String storehouse_coins = "";

    debugOutput += "<br>Debug: Page Loaded";

	if(allowed && request.getParameter("process") != null && request.getParameter("process").compareTo("sqlsync") == 0)
	{
        message = "<font color=\"#ee0000\"><b>SQL sync disabled for now</b></font>";
         debugOutput += "<br>Debug: SQL sync disabled for now";
    }
   

	if(request.getParameter("show") != null && request.getParameter("show").compareTo("details") == 0)
	{
		//### Get Values

		try
		{
            debugOutput += "<br>Debug: Showing character details";
			if(request.getParameter("type") != null && request.getParameter("type").compareTo("id") == 0)
			{
				id = Integer.parseInt(request.getParameter("ident"));
                debugOutput += "<br>Debug: Getting character by id: " + id;
			}
			else
			{
                message = "<font color=\"#ee0000\"><b>Getting character by name is disabled for now</b></font>";
                debugOutput += "<br>Debug: Getting character by name is disabled for now";
                id = -1;
			}

             if (id > 15){
                  debugOutput += "<br>Debug: Loading XML using gamedbd";
                // Path
                File workingDir = new File(pw_server_path + "/gamedbd/");
                debugOutput += "<br>Debug: Working Directory = " + workingDir.getAbsolutePath();
                String command = "./gamedbd ./gamesys.conf exportrole " + id;
                debugOutput += "<br>Debug: Command = " + command;
                   
                // Use ProcessBuilder
                ProcessBuilder processBuilder = new ProcessBuilder("/bin/bash", "-c", command);
                processBuilder.directory(workingDir); // Set working directory

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
                         debugOutput += "<br>Debug: Process output: " + line;
                    }
                    while ((line = errorReader.readLine()) != null) {
                        errorResult.append(line).append("\n");
                         debugOutput += "<br>Debug: Process error: " + line;
                    }

                    int exitCode = process.waitFor();
                    debugOutput += "<br>Debug: Process Exit Code = " + exitCode;
                     if(exitCode != 0){
                        debugOutput += "<br>Debug: Process Error Output = " + errorResult.toString();
                        message = "<font color=\"#ee0000\"><b>Process exited with error</b></font>";
                    }
                    xml = result.toString();
                     debugOutput += "<br>Debug: XML = " + xml;

                      try{
                         //Extract Data from XML
                         String nameTag = "<name>";
                         int start = xml.indexOf(nameTag);
                         if (start > -1){
                             int end = xml.indexOf("</name>", start);
                             if (end > -1){
                                name =  StringEscapeUtils.escapeHtml(xml.substring(start + nameTag.length(), end));
                                  debugOutput += "<br>Debug: Character Name = " + name;
                             }
                         }

                           String levelTag = "<level>";
                             start = xml.indexOf(levelTag);
                             if (start > -1){
                                 int end = xml.indexOf("</level>", start);
                                   if (end > -1){
                                        level = xml.substring(start + levelTag.length(), end);
                                         debugOutput += "<br>Debug: Character Level = " + level;
                                    }
                             }
                           String repTag = "<reputation>";
                            start = xml.indexOf(repTag);
                             if (start > -1){
                                 int end = xml.indexOf("</reputation>", start);
                                  if (end > -1){
                                        reputation = xml.substring(start + repTag.length(), end);
                                       debugOutput += "<br>Debug: Character Reputation = " + reputation;
                                    }
                            }

                             String maxHpTag = "<max_hp>";
                             start = xml.indexOf(maxHpTag);
                            if(start > -1){
                                 int end = xml.indexOf("</max_hp>", start);
                                    if(end > -1){
                                        health = xml.substring(start + maxHpTag.length(), end);
                                        debugOutput += "<br>Debug: Character Health = " + health;
                                    }
                            }

                              String maxMpTag = "<max_mp>";
                            start = xml.indexOf(maxMpTag);
                            if(start > -1){
                                 int end = xml.indexOf("</max_mp>", start);
                                if(end > -1){
                                    mana = xml.substring(start + maxMpTag.length(), end);
                                    debugOutput += "<br>Debug: Character Mana = " + mana;
                                }
                            }

                             String expTag = "<exp>";
                             start = xml.indexOf(expTag);
                            if(start > -1){
                                 int end = xml.indexOf("</exp>", start);
                                if(end > -1){
                                    exp = xml.substring(start + expTag.length(), end);
                                    debugOutput += "<br>Debug: Character Exp = " + exp;
                                }
                             }

                            String spTag = "<sp>";
                            start = xml.indexOf(spTag);
                            if(start > -1){
                                 int end = xml.indexOf("</sp>", start);
                                    if(end > -1){
                                       spirit = xml.substring(start + spTag.length(), end);
                                        debugOutput += "<br>Debug: Character Spirit = " + spirit;
                                   }
                            }

                               String level2Tag = "<level2>";
                            start = xml.indexOf(level2Tag);
                            if(start > -1){
                                int end = xml.indexOf("</level2>", start);
                                    if(end > -1){
                                        String level2 = xml.substring(start + level2Tag.length(), end);
                                       for(int i=0; i<cultivation.length; i++)
                                        {
                                            if(i == Integer.parseInt(level2))
                                            {
                                                cultivation[i] = " selected=\"selected\"";
                                            }
                                            else
                                            {
                                                cultivation[i] = "";
                                            }
                                        }
                                      debugOutput += "<br>Debug: Character level2 = " + level2;
                                    }
                            }


                             String vigorTag = "<max_ap>";
                            start = xml.indexOf(vigorTag);
                             if(start > -1){
                                 int end = xml.indexOf("</max_ap>", start);
                                 if(end > -1){
                                   String ap = xml.substring(start + vigorTag.length(), end);
                                     switch(Integer.parseInt(ap))
                                       {
                                            case 99:	vigor = "<option value=\"0\">000</option><option value=\"99\" selected=\"selected\">099</option><option value=\"199\">199</option><option value=\"299\">299</option><option value=\"399\">399</option>"; break;
                                            case 199:	vigor = "<option value=\"0\">000</option><option value=\"99\">099</option><option value=\"199\" selected=\"selected\">199</option><option value=\"299\">299</option><option value=\"399\">399</option>"; break;
                                           case 299:	vigor = "<option value=\"0\">000</option><option value=\"99\">099</option><option value=\"199\">199</option><option value=\"299\" selected=\"selected\">299</option><option value=\"399\">399</option>"; break;
                                            case 399:	vigor = "<option value=\"0\">000</option><option value=\"99\">099</option><option value=\"199\">199</option><option value=\"299\">299</option><option value=\"399\" selected=\"selected\">399</option>"; break;
                                           default:	vigor = "<option value=\"0\" selected=\"selected\">000</option><option value=\"99\">099</option><option value=\"199\">199</option><option value=\"299\">299</option><option value=\"399\">399</option>"; break;
                                       }
                                       debugOutput += "<br>Debug: Character Vigor = " + ap;
                                 }
                            }



                            String raceTag = "<race>";
                             start = xml.indexOf(raceTag);
                            if(start > -1){
                                int end = xml.indexOf("</race>", start);
                                  if(end > -1){
                                    String r = xml.substring(start + raceTag.length(), end);
                                        switch(Integer.parseInt(r))
                                           {
                                               case 0:	race = "Human"; break;
                                               case 1:	race = "Beast"; break;
                                               case 2:	race = "Beast"; break;
                                               case 3:	race = "Tideborn"; break;
                                                case 4:	race = "Elf"; break;
                                              case 5:	race = "Elf"; break;
                                               default:	race = "Unknown";
                                           }
                                       debugOutput += "<br>Debug: Character Race = " + r;
                                  }
                           }


                          String clsTag = "<cls>";
                            start = xml.indexOf(clsTag);
                           if(start > -1){
                             int end = xml.indexOf("</cls>", start);
                             if(end > -1){
                               String cl = xml.substring(start + clsTag.length(), end);
                                 occupation = int2occupation(item_labels, Integer.parseInt(cl));
                                  debugOutput += "<br>Debug: Character Class = " + cl;
                            }
                           }

                           String genderTag = "<gender>";
                           start = xml.indexOf(genderTag);
                             if(start > -1){
                                int end = xml.indexOf("</gender>", start);
                                 if(end > -1){
                                    String gen = xml.substring(start + genderTag.length(), end);
                                     gender = (Integer.parseInt(gen) == 0) ? "Male" : "Female";
                                       debugOutput += "<br>Debug: Character Gender = " + gen;
                                   }
                            }

                         String spouseTag = "<spouse>";
                            start = xml.indexOf(spouseTag);
                            if(start > -1){
                                int end = xml.indexOf("</spouse>", start);
                                if (end > -1){
                                   String sp = xml.substring(start + spouseTag.length(), end);
                                     if(Integer.parseInt(sp) != 0)
                                        {
                                        try
                                        {
                                            File workingDir2 = new File(pw_server_path + "/gamedbd/");
                                              String command2 = "./gamedbd ./gamesys.conf exportrole " + sp;
                                                ProcessBuilder processBuilder2 = new ProcessBuilder("/bin/bash", "-c", command2);
                                                processBuilder2.directory(workingDir2);

                                                Process process2 = processBuilder2.start();
                                                BufferedReader reader2 = new BufferedReader(new InputStreamReader(process2.getInputStream()));
                                                StringBuilder result2 = new StringBuilder();
                                                 String line2;
                                                 while ((line2 = reader2.readLine()) != null) {
                                                       result2.append(line2).append("\n");
                                                  }
                                                reader2.close();
                                                 String xml2 = result2.toString();
                                                     String nameTag2 = "<name>";
                                                    int start2 = xml2.indexOf(nameTag2);
                                                    if (start2 > -1){
                                                        int end2 = xml2.indexOf("</name>", start2);
                                                        if (end2 > -1){
                                                            spouse = StringEscapeUtils.escapeHtml(xml2.substring(start2 + nameTag2.length(), end2));
                                                             debugOutput += "<br>Debug: Character Spouse = " + spouse;
                                                        }
                                                   }
                                                 process2.destroy();

                                        }
                                        catch(Exception e)
                                        {
                                            spouse = "INVALID";
                                            debugOutput += "<br>Debug: Error getting spouse: " + e.getMessage();
                                             StringWriter sw = new StringWriter();
                                              PrintWriter pw = new PrintWriter(sw);
                                            e.printStackTrace(pw);
                                              debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";

                                        }
                                     }
                                }
                           }



                           String attributeTag = "<pp>";
                           start = xml.indexOf(attributeTag);
                            if(start > -1){
                                int end = xml.indexOf("</pp>", start);
                                if(end > -1){
                                    attribute = xml.substring(start + attributeTag.length(), end);
                                      debugOutput += "<br>Debug: Character Attribute Points = " + attribute;
                                  }
                           }

                          String constitutionTag = "<vitality>";
                           start = xml.indexOf(constitutionTag);
                            if(start > -1){
                                int end = xml.indexOf("</vitality>", start);
                                if(end > -1){
                                     constitution = xml.substring(start + constitutionTag.length(), end);
                                      debugOutput += "<br>Debug: Character Constitution = " + constitution;
                                 }
                             }


                             String intelligenceTag = "<energy>";
                           start = xml.indexOf(intelligenceTag);
                           if(start > -1){
                                int end = xml.indexOf("</energy>", start);
                                    if(end > -1){
                                         intelligence = xml.substring(start + intelligenceTag.length(), end);
                                        debugOutput += "<br>Debug: Character Intelligence = " + intelligence;
                                    }
                           }

                           String strengthTag = "<strength>";
                           start = xml.indexOf(strengthTag);
                            if(start > -1){
                                int end = xml.indexOf("</strength>", start);
                                  if(end > -1){
                                        strength = xml.substring(start + strengthTag.length(), end);
                                         debugOutput += "<br>Debug: Character Strength = " + strength;
                                   }
                             }

                           String agilityTag = "<agility>";
                           start = xml.indexOf(agilityTag);
                            if(start > -1){
                                int end = xml.indexOf("</agility>", start);
                                if(end > -1){
                                   agility = xml.substring(start + agilityTag.length(), end);
                                     debugOutput += "<br>Debug: Character Agility = " + agility;
                                   }
                            }

                           String patkMinTag = "<damage_low>";
                           start = xml.indexOf(patkMinTag);
                             if(start > -1){
                                int end = xml.indexOf("</damage_low>", start);
                                  if(end > -1){
                                      patk_min = xml.substring(start + patkMinTag.length(), end);
                                       debugOutput += "<br>Debug: Character PAtk Min = " + patk_min;
                                   }
                            }

                           String patkMaxTag = "<damage_high>";
                           start = xml.indexOf(patkMaxTag);
                            if(start > -1){
                                int end = xml.indexOf("</damage_high>", start);
                                 if(end > -1){
                                     patk_max = xml.substring(start + patkMaxTag.length(), end);
                                     debugOutput += "<br>Debug: Character PAtk Max = " + patk_max;
                                   }
                           }

                           String pdefTag = "<defense>";
                             start = xml.indexOf(pdefTag);
                            if(start > -1){
                                int end = xml.indexOf("</defense>", start);
                                 if(end > -1){
                                   pdef = xml.substring(start + pdefTag.length(), end);
                                      debugOutput += "<br>Debug: Character PDef = " + pdef;
                                 }
                           }

                          String matkMinTag = "<damage_magic_low>";
                            start = xml.indexOf(matkMinTag);
                             if(start > -1){
                                int end = xml.indexOf("</damage_magic_low>", start);
                                  if(end > -1){
                                    matk_min = xml.substring(start + matkMinTag.length(), end);
                                       debugOutput += "<br>Debug: Character MAtk Min = " + matk_min;
                                  }
                           }


                             String matkMaxTag = "<damage_magic_high>";
                           start = xml.indexOf(matkMaxTag);
                             if(start > -1){
                                 int end = xml.indexOf("</damage_magic_high>", start);
                                  if(end > -1){
                                        matk_max = xml.substring(start + matkMaxTag.length(), end);
                                        debugOutput += "<br>Debug: Character MAtk Max = " + matk_max;
                                  }
                             }

                           String mdefTag = "<resistance>";
                            start = xml.indexOf(mdefTag);
                             if(start > -1){
                                 int end = xml.indexOf("</resistance>", start);
                                 if(end > -1){
                                    mdef = xml.substring(start + mdefTag.length(), end);
                                     debugOutput += "<br>Debug: Character MDef = " + mdef;
                                }
                           }



                           String statusTag = "<status>";
                            start = xml.indexOf(statusTag);
                            if(start > -1){
                                int end = xml.indexOf("</status>", start);
                                if(end > -1){
                                     status = xml.substring(start + statusTag.length(), end);
                                      debugOutput += "<br>Debug: Character Status = " + status;
                                    }
                             }


                            String creationTag = "<create_time>";
                             start = xml.indexOf(creationTag);
                            if(start > -1){
                                 int end = xml.indexOf("</create_time>", start);
                                 if(end > -1){
                                     String t =  xml.substring(start + creationTag.length(), end);
                                        creationtime = (Integer.parseInt(t) <= 0) ? "-" : (new SimpleDateFormat("yyyy-MM-dd - HH:mm:ss")).format(new java.util.Date(1000*(long)Integer.parseInt(t)));
                                         debugOutput += "<br>Debug: Character Creation Time = " + creationtime;
                                   }
                           }


                           String deletionTag = "<delete_time>";
                           start = xml.indexOf(deletionTag);
                           if(start > -1){
                                int end = xml.indexOf("</delete_time>", start);
                                 if(end > -1){
                                     String t =  xml.substring(start + deletionTag.length(), end);
                                   deletiontime = (Integer.parseInt(t) <= 0) ? "-" : (new SimpleDateFormat("yyyy-MM-dd - HH:mm:ss")).format(new java.util.Date(1000*(long)Integer.parseInt(t)));
                                      debugOutput += "<br>Debug: Character Deletion Time = " + deletiontime;
                                   }
                           }

                           String lastLoginTag = "<lastlogin_time>";
                           start = xml.indexOf(lastLoginTag);
                            if(start > -1){
                                int end = xml.indexOf("</lastlogin_time>", start);
                                 if(end > -1){
                                   String t = xml.substring(start + lastLoginTag.length(), end);
                                    lastlogin = (Integer.parseInt(t) <= 0) ? "-" : (new SimpleDateFormat("yyyy-MM-dd - HH:mm:ss")).format(new java.util.Date(1000*(long)Integer.parseInt(t)));
                                     debugOutput += "<br>Debug: Character Last Login Time = " + lastlogin;
                                 }
                            }

                            String worldTag = "<worldtag>";
                            start = xml.indexOf(worldTag);
                            if(start > -1){
                                 int end = xml.indexOf("</worldtag>", start);
                                 if(end > -1){
                                    world = xml.substring(start + worldTag.length(), end);
                                     debugOutput += "<br>Debug: Character World = " + world;
                                  }
                           }

                            String pxTag = "<posx>";
                             start = xml.indexOf(pxTag);
                           if(start > -1){
                                int end = xml.indexOf("</posx>", start);
                                 if(end > -1){
                                   coordinateX =  (new DecimalFormat("#.##")).format(Float.valueOf(xml.substring(start + pxTag.length(), end)));
                                     debugOutput += "<br>Debug: Character X coordinate = " + coordinateX;
                                   }
                           }

                            String pyTag = "<posy>";
                             start = xml.indexOf(pyTag);
                            if(start > -1){
                                int end = xml.indexOf("</posy>", start);
                                 if(end > -1){
                                    coordinateY = (new DecimalFormat("#.##")).format(Float.valueOf(xml.substring(start + pyTag.length(), end)));
                                     debugOutput += "<br>Debug: Character Y coordinate = " + coordinateY;
                                  }
                             }


                            String pzTag = "<posz>";
                            int start = xml.indexOf(pzTag);
                            if(start > -1){
                                int end = xml.indexOf("</posz>", start);
                                 if(end > -1){
                                   coordinateZ = (new DecimalFormat("#.##")).format(Float.valueOf(xml.substring(start + pzTag.length(), end)));
                                     debugOutput += "<br>Debug: Character Z coordinate = " + coordinateZ;
                                 }
                            }
	
			        String cubiBalanceTag = "<cash>";
                     start = xml.indexOf(cubiBalanceTag);
					 if (start > -1){
							int end = xml.indexOf("</cash>", start);
							if (end > -1) {
								cubiamount = (new DecimalFormat("#.##")).format((double)Integer.parseInt(xml.substring(start + cubiBalanceTag.length(), end))/100);
                                debugOutput += "<br>Debug: Cubi Balance = " + cubiamount;
							}
					 }
                    
                    String cubiAddTag = "<cash_add>";
                     start = xml.indexOf(cubiAddTag);
                     if (start > -1){
                         int end = xml.indexOf("</cash_add>", start);
                         if (end > -1) {
                            cubipurchased = (new DecimalFormat("#.##")).format((double)Integer.parseInt(xml.substring(start + cubiAddTag.length(), end))/100);
                              debugOutput += "<br>Debug: Cubi Purchased = " + cubipurchased;
                         }
                    }
                    
                     String cubiBuyTag = "<cash_buy>";
                     start = xml.indexOf(cubiBuyTag);
					 if (start > -1){
							int end = xml.indexOf("</cash_buy>", start);
							if (end > -1) {
								cubibought = (new DecimalFormat("#.##")).format((double)Integer.parseInt(xml.substring(start + cubiBuyTag.length(), end))/100);
                                debugOutput += "<br>Debug: Cubi Bought = " + cubibought;
							}
					 }
                    
                     String cubiUsedTag = "<cash_used>";
                     start = xml.indexOf(cubiUsedTag);
					  if (start > -1){
							int end = xml.indexOf("</cash_used>", start);
							if (end > -1) {
								cubiused = (new DecimalFormat("#.##")).format((double)Integer.parseInt(xml.substring(start + cubiUsedTag.length(), end))/100);
                                  debugOutput += "<br>Debug: Cubi Used = " + cubiused;
							}
					 }
                    
                      String cubiSoldTag = "<cash_sell>";
                     start = xml.indexOf(cubiSoldTag);
					 if (start > -1){
							int end = xml.indexOf("</cash_sell>", start);
							if (end > -1) {
								cubisold = (new DecimalFormat("#.##")).format((double)Integer.parseInt(xml.substring(start + cubiSoldTag.length(), end))/100);
                                debugOutput += "<br>Debug: Cubi Sold = " + cubisold;
							}
					 }
                
                        String pkModeTag = "<invader_state>";
                         start = xml.indexOf(pkModeTag);
                         if(start > -1){
                             int end = xml.indexOf("</invader_state>", start);
                              if(end > -1){
                                 String state = xml.substring(start + pkModeTag.length(), end);
                                 pkmode = (Integer.parseInt(state) == 0) ? "Off" : "On";
                                  debugOutput += "<br>Debug: Character PK mode = " + pkmode;
                                }
                           }
                    
                        String pkInvaderTag = "<invader_time>";
                           start = xml.indexOf(pkInvaderTag);
                             if(start > -1){
                                  int end = xml.indexOf("</invader_time>", start);
                                   if(end > -1){
                                     pkinvadertime = xml.substring(start + pkInvaderTag.length(), end);
                                        debugOutput += "<br>Debug: Character Invader Time = " + pkinvadertime;
                                   }
                             }

                           String pkPariahTag = "<pariah_time>";
                           start = xml.indexOf(pkPariahTag);
                             if(start > -1){
                                 int end = xml.indexOf("</pariah_time>", start);
                                    if(end > -1){
                                         pkpariahtime = xml.substring(start + pkPariahTag.length(), end);
                                          debugOutput += "<br>Debug: Character Pariah Time = " + pkpariahtime;
                                    }
                            }
        
                        String pocketCoinsTag = "<money>";
                         start = xml.indexOf(pocketCoinsTag);
                         if(start > -1){
                             int end = xml.indexOf("</money>", start);
                             if(end > -1){
                                 pocket_coins = xml.substring(start + pocketCoinsTag.length(), end);
                                 debugOutput += "<br>Debug: Character Pocket Coins = " + pocket_coins;
                               }
                         }
                    
                    
                     String storehouseCoinsTag = "<storehouse_money>";
                       start = xml.indexOf(storehouseCoinsTag);
                         if(start > -1){
                             int end = xml.indexOf("</storehouse_money>", start);
                             if(end > -1){
                                storehouse_coins = xml.substring(start + storehouseCoinsTag.length(), end);
                                debugOutput += "<br>Debug: Character Storehouse Coins = " + storehouse_coins;
                             }
                         }

                         
                         
                         
                		String itemsTag = "<equipment>";
					    start = xml.indexOf(itemsTag);
					    equipment = "";
					    if(start > -1){
							 int end = xml.indexOf("</equipment>", start);
							 if(end > -1){
									String items = xml.substring(start + itemsTag.length(), end);
                                    debugOutput += "<br>Debug: Equipment Data = " + items;

                                    String[] item_db = (String[])request.getSession().getAttribute("items");
                                      
									   String[] parts = items.split("<item>");
									    String icon = "";
									    int br = 0;

										for(String part : parts){
											if(part.trim().isEmpty()) continue;
											
											 String idTag = "<id>";
									         int iStart = part.indexOf(idTag);
											 String label = "";
                                             int greId = -1;
										     if(iStart > -1){
												   int iEnd = part.indexOf("</id>", iStart);
												  if (iEnd > -1){
													String id_string = part.substring(iStart + idTag.length(), iEnd);
													 try{
													      greId = Integer.parseInt(id_string);
														    label = item_db[greId];
														 } catch (Exception ex){
														   label = "<span class=\\'item_color0\\'>Item not found</span>";
                                                             debugOutput += "<br>Debug: Item id " + id_string + " not found in database. Exception = " + ex.getMessage();
														 }
                                                      debugOutput += "<br>Debug: Item ID = " + id_string;

												  }
											}
										  
										   if((new File(request.getRealPath("/include/icons/" + greId + ".gif"))).exists())
											{
												icon = "./include/icons/" + greId + ".gif";
											}
											else
											{
												icon = "./include/icons/0.gif";
											}
											
											if(br%breakcol == 0)
											{
												equipment += "<tr>";
											}
										
											equipment += "<td align=\"center\" onclick=\"select_item('" + label + "', 'equipment', '" + br + "', '" + greId + "', '0', '0', '0', '0', '0', '0', '0', '0', '');\"><img title=\"" + greId + "\" src=\"" + icon + "\"></img></td>";
											br++;
											if(br%breakcol == 0)
											{
												equipment += "</tr>";
											}


										}
									if(br%breakcol != 0)
									{
										// Fill Rest
										while(br%breakcol != 0)
										{
											equipment += "<td><br></td>";
											br++;
										}
										equipment += "</tr>";
									}

							  }
						 }
                    
                       itemsTag = "<inventory>";
					    start = xml.indexOf(itemsTag);
					    inventory = "";
					    if(start > -1){
							 int end = xml.indexOf("</inventory>", start);
							 if(end > -1){
									String items = xml.substring(start + itemsTag.length(), end);
                                     debugOutput += "<br>Debug: Inventory Data = " + items;
                                    String[] item_db = (String[])request.getSession().getAttribute("items");

									   String[] parts = items.split("<item>");
									    String icon = "";
									    int br = 0;

										for(String part : parts){
											if(part.trim().isEmpty()) continue;

											 String idTag = "<id>";
									         int iStart = part.indexOf(idTag);
											 String label = "";
                                             int greId = -1;
										     if(iStart > -1){
												   int iEnd = part.indexOf("</id>", iStart);
												  if (iEnd > -1){
													String id_string = part.substring(iStart + idTag.length(), iEnd);
													 try{
													      greId = Integer.parseInt(id_string);
														    label = item_db[greId];
														 } catch (Exception ex){
														   label = "<span class=\\'item_color0\\'>Item not found</span>";
                                                              debugOutput += "<br>Debug: Item id " + id_string + " not found in database. Exception = " + ex.getMessage();
														 }
                                                      debugOutput += "<br>Debug: Item ID = " + id_string;
												  }
											}
                                              if((new File(request.getRealPath("/include/icons/" + greId + ".gif"))).exists())
											{
												icon = "./include/icons/" + greId + ".gif";
											}
											else
											{
												icon = "./include/icons/0.gif";
											}
											if(br%breakcol == 0)
											{
												inventory += "<tr>";
											}
										
											inventory += "<td align=\"center\" onclick=\"select_item('" + label + "', 'inventory', '" + br + "', '" + greId + "', '0', '0', '0', '0', '0', '0', '0', '0', '');\"><img title=\"" + greId + "\" src=\"" + icon + "\"></img></td>";
											br++;
											if(br%breakcol == 0)
											{
												inventory += "</tr>";
											}


										}
										if(br%breakcol != 0)
										{
											// Fill Rest
											while(br%breakcol != 0)
											{
												inventory += "<td><br></td>";
												br++;
											}
											inventory += "</tr>";
										}


							  }
						 }
                       
                       
                        itemsTag = "<storehouse>";
					    start = xml.indexOf(itemsTag);
					    storage = "";
					    if(start > -1){
							 int end = xml.indexOf("</storehouse>", start);
							 if(end > -1){
									String items = xml.substring(start + itemsTag.length(), end);
                                      debugOutput += "<br>Debug: Storehouse Data = " + items;
                                        String[] item_db = (String[])request.getSession().getAttribute("items");

									   String[] parts = items.split("<item>");
									    String icon = "";
									    int br = 0;

										for(String part : parts){
											if(part.trim().isEmpty()) continue;
                                            
											 String idTag = "<id>";
									         int iStart = part.indexOf(idTag);
											 String label = "";
                                              int greId = -1;
										     if(iStart > -1){
												   int iEnd = part.indexOf("</id>", iStart);
												  if (iEnd > -1){
													String id_string = part.substring(iStart + idTag.length(), iEnd);
                                                     try{
													      greId = Integer.parseInt(id_string);
														    label = item_db[greId];
														 } catch (Exception ex){
														   label = "<span class=\\'item_color0\\'>Item not found</span>";
                                                            debugOutput += "<br>Debug: Item id " + id_string + " not found in database. Exception = " + ex.getMessage();
														 }
                                                     debugOutput += "<br>Debug: Item ID = " + id_string;
												  }
											}
                                               if((new File(request.getRealPath("/include/icons/" + greId + ".gif"))).exists())
											{
												icon = "./include/icons/" + greId + ".gif";
											}
											else
											{
												icon = "./include/icons/0.gif";
											}
											if(br%breakcol == 0)
											{
												storage += "<tr>";
											}
										
											storage += "<td align=\"center\" onclick=\"select_item('" + label + "', 'storage', '" + br + "', '" + greId + "', '0', '0', '0', '0', '0', '0', '0', '0', '');\"><img title=\"" + greId + "\" src=\"" + icon + "\"></img></td>";
											br++;
											if(br%breakcol == 0)
											{
												storage += "</tr>";
											}


										}
										if(br%breakcol != 0)
										{
											// Fill Rest
											while(br%breakcol != 0)
											{
												storage += "<td><br></td>";
												br++;
											}
											storage += "</tr>";
										}


							  }
						 }
                   
                     if(request.getParameter("process") != null && allowed)
                    {
                         if(request.getParameter("process").compareTo("save") == 0)
                        {
                             debugOutput += "<br>Debug: Saving character data";
                            message = "";
							boolean error = false;

						  try{

								File workingDir2 = new File(pw_server_path + "/gamedbd/");
                                 debugOutput += "<br>Debug: Working Directory = " + workingDir2.getAbsolutePath();
								String command2 = "./gamedbd ./gamesys.conf importrole " + id;
                                 debugOutput += "<br>Debug: Command = " + command2;
								
								
                                 ProcessBuilder processBuilder2 = new ProcessBuilder("/bin/bash", "-c", command2);
                                 processBuilder2.directory(workingDir2);
                                 
                                 Process process2 = null;
                                 BufferedWriter writer = null;
                                  BufferedReader errorReader = null;
                                  try{
                                       process2 = processBuilder2.start();
                                         writer = new BufferedWriter(new OutputStreamWriter(process2.getOutputStream()));
                                          errorReader = new BufferedReader(new InputStreamReader(process2.getErrorStream()));

                                          //Write data to process
                                         writer.write(xml);
                                         writer.flush();
                                         writer.close();


                                          StringBuilder errorResult = new StringBuilder();
                                            String line2;
                                             while ((line2 = errorReader.readLine()) != null) {
                                                errorResult.append(line2).append("\n");
                                                 debugOutput += "<br>Debug: Process error output : " + line2;
                                             }


                                          int exitCode2 = process2.waitFor();
                                         debugOutput += "<br>Debug: Process exit code = " + exitCode2;
                                        if(exitCode2 != 0){
                                            message += "<font color=\"#ee0000\"><b>Process exited with error</b></font>";
                                             debugOutput += "<br>Debug: Process Error = " + errorResult.toString();
                                          } else{
                                           message = "<font color=\"#00cc00\"><b>Character Data Saved</b></font>";
                                          }

                                  } catch(Exception ex){
                                       message = "<font color=\"#ee0000\"><b>Saving Character Data Failed (Process Error): " + ex.getMessage() + "</b></font>";
                                     debugOutput += "<br>Debug: Exception while saving (Process Error): " + ex.getMessage();
                                      StringWriter sw = new StringWriter();
                                       PrintWriter pw = new PrintWriter(sw);
                                      ex.printStackTrace(pw);
                                       debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
                                  }
                                   finally {
                                    if(writer != null){
                                        try{
                                            writer.close();
                                            debugOutput += "<br>Debug: Writer Closed";
                                        }
                                        catch(IOException ioe){
                                            //Log exception for debugging purposes only
                                            debugOutput += "<br>Debug: IOException closing Writer: " + ioe.getMessage();
                                        }
                                    }

                                     if(errorReader != null){
                                         try{
                                             errorReader.close();
                                              debugOutput += "<br>Debug: Error Reader Closed";
                                        }
                                         catch(IOException ioe){
                                              //Log exception for debugging purposes only
                                               debugOutput += "<br>Debug: IOException closing error reader: " + ioe.getMessage();
                                        }
                                    }


                                    if(process2 != null){
                                       process2.destroy();
                                        debugOutput += "<br>Debug: Process destroyed";
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

                    if(request.getParameter("process").compareTo("delete") == 0)
				    {
					    try
					    {
                             File workingDir2 = new File(pw_server_path + "/gamedbd/");
                                  debugOutput += "<br>Debug: Working Directory = " + workingDir2.getAbsolutePath();
                                  String command2 = "./gamedbd ./gamesys.conf deleterole " + id;
                                  debugOutput += "<br>Debug: Command = " + command2;

                                ProcessBuilder processBuilder2 = new ProcessBuilder("/bin/bash", "-c", command2);
                                 processBuilder2.directory(workingDir2);

                                    Process process2 = processBuilder2.start();
                                    BufferedReader errorReader = new BufferedReader(new InputStreamReader(process2.getErrorStream()));

                                  StringBuilder errorResult = new StringBuilder();
                                     String line2;
                                    while ((line2 = errorReader.readLine()) != null) {
                                          errorResult.append(line2).append("\n");
                                            debugOutput += "<br>Debug: Process error output: " + line2;
                                    }
                                      errorReader.close();
                                   
                                    int exitCode2 = process2.waitFor();
                                     debugOutput += "<br>Debug: Process exit code = " + exitCode2;
                                  if(exitCode2 != 0){
                                        message = "<font color=\"#ee0000\"><b>Deleting Character Failed (process error)</b></font>";
                                       debugOutput += "<br>Debug: Process Error Output = " + errorResult.toString();
                                    } else {
                                      message = "<font color=\"#00cc00\"><b>Character Deleted</b></font>";
                                    }

                                      if(process2 != null){
                                           process2.destroy();
                                          debugOutput += "<br>Debug: Process destroyed";
                                     }

					    }
                        catch(Exception e)
						{
							message = "<font color=\"#ee0000\"><b>Deleting Character Failed: " + e.getMessage() + "</b></font>";
                              debugOutput += "<br>Debug: Exception while deleting character: " + e.getMessage();
                                 StringWriter sw = new StringWriter();
                                  PrintWriter pw = new PrintWriter(sw);
                                 e.printStackTrace(pw);
                                  debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
						}
                    }
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
        finally{
             debugOutput += "<br>Debug: Finished try block";
        }
	}
    debugOutput += "<br>Debug: Starting HTML Rendering";
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
				if(request.getParameter("show") != null && request.getParameter("show").compareTo("details") == 0)
				{
                     debugOutput += "<br>Debug: Printing Character ID";
					out.print("Character ID: " + id);
				}
				else
				{
                    debugOutput += "<br>Debug: Printing Character List Header";
					out.print("Character List:");
				}
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

    <%
		if(request.getParameter("show") != null && request.getParameter("show").compareTo("details") == 0 && allowed && id > 15)
		{
             debugOutput += "<br>Debug: Showing switchable characters, delete buttons";
        
       
             out.println("<tr><td colspan=\"3\" valign=\"middle\" style=\"border-bottom: 1px solid #cccccc;\">");
				out.println("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"2\" border=\"0\"><tr>");
					out.println("<td align=\"left\">Switch to another Characters of this"); 
					try
					{
						Class.forName("com.mysql.jdbc.Driver").newInstance();
						Connection connection = DriverManager.getConnection("jdbc:mysql://" + db_host + ":" + db_port + "/" + db_database, db_user, db_password);
						Statement statement = connection.createStatement();
						ResultSet rs = statement.executeQuery("SELECT zoneid FROM point WHERE uid='" + uid + "'");
                        if(rs.next())
                        {
                             if(rs.getString("zoneid") != null)
                                {
                                    out.print(" <font color=\"#00cc00\">currently Logged in Account</font>");
                                }
                            else
                            {
                                out.print(" <font color=\"#ee0000\">currently Logged out Account</font>");
                            }

                        }

						rs.close();
						statement.close();
						connection.close();
					}
					catch(Exception e)
					{
						out.print(" <font color=\"#ee0000\">currently Logged out Account</font>");
					}
                    
                    debugOutput += "<br>Debug: Printing user id in switchable characters table, uid = " + uid;
					out.print(" ID=" + uid + "</td>");
					out.println("<td width=\"164\"><form name=\"changechar\" action=\"index.jsp?page=role&show=details&type=id\" method=\"post\" style=\"margin: 0px;\">");
						out.println("<select name=\"ident\" onchange=\"document['changechar'].submit();\" style=\"width: 100%; text-align: center;\">");

							// Get all character of current userid
                             try{
                                Class.forName("com.mysql.jdbc.Driver").newInstance();
						        Connection connection = DriverManager.getConnection("jdbc:mysql://" + db_host + ":" + db_port + "/" + db_database, db_user, db_password);
						        Statement statement = connection.createStatement();
                                 ResultSet rs = statement.executeQuery("SELECT uid FROM point WHERE uid='" + uid + "'");
                                if (rs.next()){
                                DataVector dv = GameDB.getRolelist(uid);
                                    if(dv != null)
                                    {
                                        Iterator itr = dv.iterator();
                                        while(itr.hasNext())
                                        {
                                               IntOctets ios = (IntOctets)itr.next();
                                               int roleid = ios.m_int;
                                               String rolename = StringEscapeUtils.escapeHtml(ios.m_octets.getString());
                                            if(roleid == id)
                                            {
                                                out.println("<option value=\"" + roleid + "\" selected=\"selected\">" + rolename + "</option>");
                                            }
                                            else
                                            {
                                                out.println("<option value=\"" + roleid + "\">" + rolename + "</option>");
                                            }
                                        }	
                                    }
                                }
                                 rs.close();
                                    statement.close();
                                    connection.close();
                                debugOutput += "<br>Debug: Successfully loaded the list of characters for user: " + uid;

                            }catch(Exception e){
                                message = "<font color=\"#ee0000\"><b>Error Loading Character List: " + e.getMessage() + "</b></font>";
                                debugOutput += "<br>Debug: Exception while loading character list: " + e.getMessage();
                                 StringWriter sw = new StringWriter();
                                 PrintWriter pw = new PrintWriter(sw);
                                 e.printStackTrace(pw);
                                 debugOutput += "<br>Debug: Stack Trace: <pre>" + StringEscapeUtils.escapeHtml(sw.toString()) + "</pre>";
                            }
						out.println("</select>");
					out.println("</form></td>");
				out.println("</tr></table>");
			out.println("</td></tr>");
             out.println("<tr><td colspan=\"3\" valign=\"middle\" style=\"border-bottom: 1px solid #cccccc;\">");
				out.println("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"2\" border=\"0\"><tr>");
					out.println("<td align=\"left\">Delete this Character</td>");
					out.println("<td width=\"1\"><a href=\"index.jsp?page=role&show=details&ident=" + id + "&type=id&process=delete\"><img src=\"include/btn_delete.jpg\" style=\"border: 0;\"></img></a></td>");
				out.println("</tr></table>");
			out.println("</td></tr>");
       }
    %>

	<tr>
		<td colspan="3" align="center" style="padding: 5px;">
			<%
				if(allowed && id > -1)
				{
                    debugOutput += "<br>Debug: showing link to XML editor";
					out.println("<a href=\"index.jsp?page=rolexml&ident=" + id + "\"><img src=\"include/btn_xml.jpg\" border=\"0\"></img></a>");
				}
				else
				{
					out.println("<br>");
				}
			%>
		</td>
	</tr>
    
      	<%
		if(request.getParameter("show") != null && request.getParameter("show").compareTo("details") == 0 && id > 15)
		{
            debugOutput += "<br>Debug: Showing xml textarea";
			out.println("<form name=\"update\" action=\"index.jsp?page=role&show=details&ident=" + id + "&type=id&process=save\" method=\"post\" style=\"margin: 0px;\">");
				out.println("<tr>");

					out.println("<td colspan=\"3\" align=\"left\" valign=\"top\">");
                    out.println("<textarea name=\"xml\" rows=\"24\" style=\"width: 100%;\"><%out.print(StringEscapeUtils.escapeHtml(xml));%></textarea>");
                    out.println("</td></tr>");
                     if(allowed)
                    {
                        out.println("<tr>");
                            out.println("<td colspan=\"3\" align=\"center\" style=\"border-top: 1px solid #cccccc; border-bottom: 1px solid #cccccc; padding: 2px;\"><input type=\"image\" src=\"include/btn_save.jpg\" style=\"border: 0;\"></input></td>");
                        out.println("</tr>");
                    }
			out.println("</form>");
			
			
			out.println("<tr>");

				out.println("<td width=\"33%\" align=\"left\" valign=\"top\">");
				if(allowed)
				{
					out.println("<table width=\"250\" cellpadding=\"2\" cellspacing=\"0\" style=\"border: 1px solid #cccccc;\">");
					out.println("<tr><th colspan=\"2\" style=\"padding: 5;\">CHARACTER INFO</th></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"2\" align=\"center\"><b>General</b></td></tr>");
					out.println("<tr><td><b>Status:</b></td><td>" + status + "</td></tr>");
					out.println("<tr><td><b>Creation Time:</b></td><td>" + creationtime + "</td></tr>");
					out.println("<tr><td><b>Deletion Time:</b></td><td>" + deletiontime + "</td></tr>");
					out.println("<tr><td><b>Last Login:</b></td><td>" + lastlogin + "</td></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"2\" align=\"center\"><b>Location</b></td></tr>");
					out.println("<tr><td><b>World ID:</b></td><td><input name=\"world\" type=\"text\" value=\"" + world + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Position X:</b></td><td><input name=\"coordinateX\" type=\"text\" value=\"" + coordinateX + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Position Z:</b></td><td><input name=\"coordinateZ\" type=\"text\" value=\"" + coordinateZ + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Altitude:</b></td><td><input name=\"coordinateY\" type=\"text\" value=\"" + coordinateY + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"2\" align=\"center\"><b>Purchase</b></td></tr>");
					out.println("<tr><td><b>Cubi Balance:</b></td><td>" + cubiamount + "</td></tr>");
					out.println("<tr><td><b>Cubi Purchased:</b></td><td>" + cubipurchased + "</td></tr>");
					out.println("<tr><td><b>Cubi Bought:</b></td><td>" + cubibought + "</td></tr>");
					out.println("<tr><td><b>Cubi Used:</b></td><td>" + cubiused + "</td></tr>");
					out.println("<tr><td><b>Cubi Sold:</b></td><td>" + cubisold + "</td></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"2\" align=\"center\"><b>PK</b></td></tr>");
					out.println("<tr><td><b>PK Mode:</b></td><td>" + pkmode + "</td></tr>");
					out.println("<tr><td><b>Invader Time:</b></td><td>" + pkinvadertime + "</td></tr>");
					out.println("<tr><td><b>Pariah Time:</b></td><td>" + pkpariahtime + "</td></tr>");
					out.println("</table>");
				}
				out.println("</td>");

				out.println("<td width=\"34%\" align=\"center\" valign=\"top\">");
					out.println("<table width=\"250\" cellpadding=\"2\" cellspacing=\"0\" style=\"border: 1px solid #cccccc;\">");
					out.println("<tr><th colspan=\"4\" style=\"padding: 5;\">CHARACTER PROPERTIES</th></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"4\" align=\"center\"><font color=\"#000000\"><b>" + name + "</b></font></td></tr>");
					out.println("<tr><td><b>Level:</b></td><td>" + level + "</td><td><b>Reputation:</b></td><td><input name=\"reputation\" type=\"text\" value=\"" + reputation + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr><td width=\"50\"><b>HP:</b></td><td width=\"50\">" + health + "</td><td><b width=\"50\">EXP:</b></td><td><input name=\"exp\" type=\"text\" value=\"" + exp + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>MP:</b></td><td>" + mana + "</td><td><b>SP:</b></td><td><input name=\"sp\" type=\"text\" value=\"" + spirit + "\" style=\"width: 100%; text-align: center;\"></input></td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Cultivation:</b></td><td colspan=\"2\"><select name=\"cultivation\" style=\"width: 100%;\"><option value=\"0\" " + cultivation[0] + ">0 - Inchoation</option><option value=\"1\" " + cultivation[1] + ">9 - Autoscopy</option><option value=\"2\" " + cultivation[2] + ">19 - Transform</option><option value=\"3\" " + cultivation[3] + ">29 - Naissance</option><option value=\"4\" " + cultivation[4] + ">39 - Reborn</option><option value=\"5\" " + cultivation[5] + ">49 - Vigilance</option><option value=\"6\" " + cultivation[6] + ">59 - Doom</option><option value=\"7\" " + cultivation[7] + ">69 - Disengage</option><option value=\"8\" " + cultivation[8] + ">79 - Nirvana</option><option value=\"20\" " + cultivation[20] + ">89 - Prime Immortal</option><option value=\"30\" " + cultivation[30] + ">89 - Daiman Baresark</option><option value=\"21\" " + cultivation[21] + ">99 - Pure Immortal</option><option value=\"31\" " + cultivation[31] + ">99 - Daimon Saint</option><option value=\"22\" " + cultivation[22] + ">109 - Ether Immortal</option><option value=\"32\" " + cultivation[32] + ">109 - Daimon Elder</option></select></td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Vigor Points:</b></td><td colspan=\"2\"><select name=\"vigor\" style=\"width: 100%;\">" + vigor + "</select></td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Race:</b></td><td colspan=\"2\">" + race + "</td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Occupation:</b></td><td colspan=\"2\">" + occupation + "</td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Gender:</b></td><td colspan=\"2\">" + gender + "</td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Spouse:</b></td><td colspan=\"2\"><a href=\"index.jsp?page=role&show=details&ident=" + spouse + "&type=ident\"><u>" + spouse + "</u></a></td></tr>");
					out.println("<tr><td colspan=\"2\"><b>Faction:</b></td><td colspan=\"2\">" + faction + "</td></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"4\" align=\"center\"><b>Attributes</b></td></tr>");
					out.println("<tr><td colspan=\"1\"><b>Points:</b></td><td colspan=\"3\">" + attribute + "</td></tr>");
					out.println("<tr><td><b>CON:</b></td><td>" + constitution + "</td><td><b>INT:</td><td>" + intelligence + "</b></td></tr>");
					out.println("<tr><td><b>STR:</b></td><td>" + strength + "</td><td><b>AGI:</td><td>" + agility + "</b></td></tr>");
					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"4\" align=\"center\"><b>Base Stats</b></td></tr>");
					out.println("<tr><td><b>P-Def:</b></td><td>" + pdef + "</td><td><b>P-Atk:</b></td><td>" + patk_min + " - " + patk_max + "</td></tr>");
					out.println("<tr><td><b>M-Def:</b></td><td>" + mdef + "</td><td><b>M-Atk:</b></td><td>" + matk_min + " - " + matk_max + "</td></tr>");
					out.println("</table>");
				out.println("</td>");

				out.println("<td width=\"33%\" align=\"right\" valign=\"top\">");
				if(allowed)
				{
					out.println("<table width=\"250\" cellpadding=\"2\" cellspacing=\"0\" style=\"border: 1px solid #cccccc;\">");
					out.println("<tr><th colspan=\"4\" style=\"padding: 5;\">CHARACTER ITEMS</th></tr>");
					out.println("<tr><td align=\"center\" colspan=\"4\" style=\"border: 0px solid #cccccc;\"><div style=\"height: 130px; overflow: auto;\">");
						out.println("<table width=\"100%\" cellpadding=\"2\"cellspacing=\"0\" border=\"0\">");
						out.println("<tr><td align=\"center\" colspan=\"" + breakcol + "\" style=\"padding: 5px;\"><b>Equipment</b></td></tr>" + equipment);
						out.println("<tr><td align=\"center\" colspan=\"" + breakcol + "\" style=\"padding: 5px;\"><b>Inventory</b></td></tr>" + inventory);
						out.println("<tr><td align=\"center\" colspan=\"" + breakcol + "\" style=\"padding: 5px;\"><b>Storehouse</b></td></tr>" + storage);
						out.println("</table>");
					out.println("</div></td></tr>");

					out.println("<tr><th colspan=\"4\" style=\"padding: 5;\"><b><a href=\"#\" id=\"itemname\"><br></a><b></th></tr>");

					out.println("<input name=\"itemindex\" type=\"hidden\"></input>");

					out.println("<tr><td><b>Item ID:</b></td><td colspan=\"3\"><input name=\"itemid\" type=\"text\" style=\"width: 65px; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Group:</b></td><td><select name=\"itemgroup\" style=\"width: 65px;\"><option value=\"equipment\">Equipment</option><option value=\"inventory\" selected=\"selected\">Inventory</option><option value=\"storage\">Storage</option></select></td><td><b>Action:</b></td><td align=\"right\"><select name=\"itemaction\" style=\"width: 65px;\"><option value=\"edit\">Edit</option><option value=\"remove\">Delete</option><option value=\"add\">Add New</option></select></td></tr>");
					out.println("<tr><td><b>GuID 1:</b></td><td><input name=\"itemguid1\" type=\"text\" style=\"width: 65px; text-align: center;\"></input></td><td><b>GuID 2:</b></td><td align=\"right\"><input name=\"itemguid2\" type=\"text\" style=\"width: 65px; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Proctype:</b></td><td><input name=\"itemproctype\" type=\"text\" style=\"width: 65px; text-align: center;\"></input></td><td><b>Mask:</b></td><td align=\"right\"><input name=\"itemmask\" type=\"text\" style=\"width: 65px; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Position:</b></td><td><input type=\"text\" name=\"itempos\" style=\"width: 65px; text-align: center;\"></input></td><td><b>Expire:</b></td><td align=\"right\"><input type=\"text\" name=\"itemexpire\" style=\"width: 65px; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>Stacked:</b></td><td><input type=\"text\" name=\"itemcount\" style=\"width: 65px; text-align: center;\"></input></td><td><b>Max:</b></td><td align=\"right\"><input type=\"text\" name=\"itemcountmax\" style=\"width: 65px; text-align: center;\"></input></td></tr>");
					out.println("<tr><td><b>HexData:</b></td><td colspan=\"3\"><input type=\"text\" name=\"itemdata\" style=\"width: 100%;\"></input></td></tr>");

					out.println("<tr bgcolor=\"#f0f0f0\"><td colspan=\"4\" align=\"center\"><b>Coins</b></td></tr>");
					out.println("<tr><td><b>Pocket:</b></td><td><input name=\"pocketcoins\" type=\"text\" value=\"" + pocket_coins + "\" style=\"width: 65px; text-align: center;\"></input></td><td><b>Store:</b></td><td align=\"right\"><input name=\"storehousecoins\" type=\"text\" value=\"" + storehouse_coins + "\" style=\"width: 65px; text-align: center;\"></input></td></tr>");

					out.println("</table>");		
				}
				out.println("</td>");

			out.println("</tr><tr><td colspan=\"3\"><br></td></tr>");

			if(allowed)
			{
				out.println("<tr>");
					out.println("<td colspan=\"3\" align=\"center\" style=\"border-top: 1px solid #cccccc; border-bottom: 1px solid #cccccc; padding: 2px;\"><input type=\"image\" src=\"include/btn_save.jpg\" style=\"border: 0;\"></input></td>");
				out.println("</tr>");
			}

			out.println("</form>");
		}
		else
		{
			out.println("<tr><td colspan=\"3\" align=\"center\" valign=\"top\">");
				out.println("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" valign=\"top\">");
					out.println("<table width=\"350\" cellpadding=\"2\" cellspacing=\"0\" style=\"border: 1px solid #cccccc;\">");
						if(allowed)
						{
							out.println("<tr><th></th><th align=\"center\" style=\"padding: 5;\">PLAYERS</th><th align=\"right\" style=\"padding: 5;\"><a href=\"index.jsp?page=role&process=sqlsync\"><img src=\"include/btn_sync.png\" border=\"0\" onmouseover=\"javascript:show_tip('sqltip');\" onmousemove=\"javascript:move_tip('sqltip', event);\" onmouseout=\"javascript:hide_tip('sqltip');\"></img></a></th></tr>");
						}
						else
						{
							out.println("<tr><th align=\"center\" colspan=\"3\" style=\"padding: 5;\">PLAYERS</th></tr>");
						}
						out.println("<tr bgcolor=\"#f0f0f0\"><td><b><a href=\"index.jsp?page=role&order=role_name\">Name</a></b></td><td><b><a href=\"index.jsp?page=role&order=role_occupation\">Occupation</a></b></td><td align=\"center\"><b><a href=\"index.jsp?page=role&order=role_level\">Level</a></b></td></tr>");
						if(enable_character_list)
						{
								Class.forName("com.mysql.jdbc.Driver").newInstance();
								Connection connection = DriverManager.getConnection("jdbc:mysql://" + db_host + ":" + db_port + "/" + db_database, db_user, db_password);
								Statement statement = connection.createStatement();
								ResultSet rs;

								String sort = "";

								if(request.getParameter("order") != null && request.getParameter("order").compareTo("role_level") == 0)
								{
									sort = " DESC";
								}

								rs = statement.executeQuery("SELECT * FROM roles ORDER BY " + request.getParameter("order") + sort);
			
								while(rs.next())
								{
								       int roleid = rs.getInt("role_id");
									String rolename = StringEscapeUtils.unescapeJava(rs.getString("role_name"));
									int rolelevel = rs.getInt("role_level");
									String roleoccupation = int2occupation(item_labels, rs.getInt("role_occupation"));
									out.println("<tr><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=" + roleid + "&type=id\">" + rolename + "</a></td><td style=\"border-top: 1px solid #cccccc\">" + roleoccupation + "</td><td align=\"center\" style=\"border-top: 1px solid #cccccc\">" + rolelevel + "</td></tr>");
								}

								rs.close();
								statement.close();
								connection.close();
						}
						else
						{
							out.println("<tr><td align=\"center\" colspan=\"3\" style=\"border-top: 1px solid #cccccc\"><font color=\"#ee0000\"><b>Character List is Disabled</b></font></td></tr>");
						}
					out.println("</table>");
				out.println("<td align=\"center\" valign=\"top\">");
					if(allowed)
					{
						out.println("<table width=\"350\" cellpadding=\"2\" cellspacing=\"0\" style=\"border: 1px solid #cccccc;\">");
						if(item_labels.compareTo("pwi") == 0)
						{
							out.println("<tr><th align=\"center\" colspan=\"2\" style=\"padding: 5;\">TEMPLATES</th></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=16&type=id\">TEMPLATE BLADEMASTER</a></td><td style=\"border-top: 1px solid #cccccc\">Human</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=17&type=id\">TEMPLATE MYSTIC</a></td><td style=\"border-top: 1px solid #cccccc\">Earthguard</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=18&type=id\">TEMPLATE SEEKER</a></td><td style=\"border-top: 1px solid #cccccc\">Earthguard</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=19&type=id\">TEMPLATE WIZARD</a></td><td style=\"border-top: 1px solid #cccccc\">Human</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=20&type=id\">TEMPLATE PSYCHIC</a></td><td style=\"border-top: 1px solid #cccccc\">Tideborn</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=21&type=id\">TEMPLATE DUSKBLADE</a></td><td style=\"border-top: 1px solid #cccccc\">None</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=22&type=id\">TEMPLATE STORMBRINGER</a></td><td style=\"border-top: 1px solid #cccccc\">None</td></tr>");							
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=23&type=id\">TEMPLATE VENOMANCER</a></td><td style=\"border-top: 1px solid #cccccc\">Beast</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=24&type=id\">TEMPLATE BARBARIAN</a></td><td style=\"border-top: 1px solid #cccccc\">Beast</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=27&type=id\">TEMPLATE ASSASSIN</a></td><td style=\"border-top: 1px solid #cccccc\">Tideborn</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=28&type=id\">TEMPLATE ARCHER</a></td><td style=\"border-top: 1px solid #cccccc\">Elven</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=31&type=id\">TEMPLATE CLERIC</a></td><td style=\"border-top: 1px solid #cccccc\">Elven</td></tr>");
						}
						else
						{
							out.println("<tr><th align=\"center\" colspan=\"2\" style=\"padding: 5;\">TEMPLATES</th></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=16&type=id\">TEMPLATE WR</a></td><td style=\"border-top: 1px solid #cccccc\">Human</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=17&type=id\">TEMPLATE MY</a></td><td style=\"border-top: 1px solid #cccccc\">Earthguard</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=18&type=id\">TEMPLATE SE</a></td><td style=\"border-top: 1px solid #cccccc\">Earthguard</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=19&type=id\">TEMPLATE MG</a></td><td style=\"border-top: 1px solid #cccccc\">Human</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=20&type=id\">TEMPLATE PS</a></td><td style=\"border-top: 1px solid #cccccc\">Tideborn</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=21&type=id\">TEMPLATE DB</a></td><td style=\"border-top: 1px solid #cccccc\">None</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=22&type=id\">TEMPLATE SB</a></td><td style=\"border-top: 1px solid #cccccc\">None</td></tr>");							
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=23&type=id\">TEMPLATE WF</a></td><td style=\"border-top: 1px solid #cccccc\">Beast</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=24&type=id\">TEMPLATE WB</a></td><td style=\"border-top: 1px solid #cccccc\">Beast</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=27&type=id\">TEMPLATE AS</a></td><td style=\"border-top: 1px solid #cccccc\">Tideborn</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=28&type=id\">TEMPLATE EA</a></td><td style=\"border-top: 1px solid #cccccc\">Elven</td></tr>");
							out.println("<tr bgcolor=\"#f0f0f0\"><td style=\"border-top: 1px solid #cccccc\"><a href=\"index.jsp?page=role&show=details&ident=31&type=id\">TEMPLATE EP</a></td><td style=\"border-top: 1px solid #cccccc\">Elven</td></tr>");
						}
						out.println("</table></td>");
					}
				out.println("</td></tr></table>");
			out.println("</td></tr>");
		}
	%>
     <tr>
		<td colspan="3">
           <div style="white-space: pre-wrap; font-family: monospace; font-size: 0.8em; background-color: #f0f0f0; padding: 10px;">
		        <%=debugOutput%>
           </div>
		</td>
	</tr>
</table>