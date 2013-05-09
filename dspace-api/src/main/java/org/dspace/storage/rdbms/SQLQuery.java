/*
 * SQLQuery.java
 *
 * Version: $Revision: 1000 $
 *
 * Date: $Date: 2009-04-15 21:48:00 -0700 (Web, 15 Apr 2009) $
 *
 * Copyright (c) 2007-2009, NCCULIAS DLLL LAB (http://dlll.nccu.edu.tw).
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.dspace.storage.rdbms;

import org.dspace.core.Context;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

public class SQLQuery
{
	private Context context = null;
	private Statement statement = null;
	
	public SQLQuery(Context c)
	{
		context = c;
	}
	
	public ResultSet query(String query) throws SQLException   
    {
		try{
			if (statement != null)
			{
				statement.close();
			}
			statement = context.getDBConnection().createStatement();
			ResultSet rs = statement.executeQuery(query);
			return rs;
		}
		catch (SQLException sqle)
        {
            throw sqle;
        }
		
    }
    
    public static ResultSet singleQuery(Context context, String query) throws SQLException   
    {
		try{
			Statement statement = context.getDBConnection().createStatement();
			ResultSet rs = statement.executeQuery(query);
			return rs;
		}
		catch (SQLException sqle)
        {
            throw sqle;
        }
    }
    
    public static ResultSet singleQuery(String query) throws SQLException   
    {
    	Context context = new Context();
		try{
			Statement statement = context.getDBConnection().createStatement();
			ResultSet rs = statement.executeQuery(query);
			return rs;
		}
		catch (SQLException sqle)
        {
            throw sqle;
        }
		
    }
}