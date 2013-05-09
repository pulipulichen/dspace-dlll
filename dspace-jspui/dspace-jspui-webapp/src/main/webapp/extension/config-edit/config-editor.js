ConfigEditor = {
	cacge: null,
	readConfig: function () {
		var config = ConfigEditor.cache;
		if (config == null)
		{
			var configTextarea = jQuery("textarea#source");
			if (configTextarea.hasClass("need-unescape"))
			{
				var v = configTextarea.val();
				v = unescape(v);
				configTextarea.val(v);
				configTextarea.removeClass("need-unescape");
			}
		
			config = configTextarea.val();
			config = jQuery.trim(config);
			if (config != "")
				config = config.split("\n");
			
			ConfigEditor.cache = config;
		}
		return config;
	},
	writeConfig: function (config) {
		var text = "";
		for (var i = 0; i < config.length; i++)
		{
			if (typeof(config[i]) != "undefined")
				text = text + config[i] + "\n";
		}
		jQuery("textarea#source").val(text);
		//delete ConfigEditor.cache;
		ConfigEditor.cache = null;
	},
	getProperty: function (property){
		if (ConfigEditor.isList(property) == false)
		{
			var config = ConfigEditor.readConfig();
			
			var value = "";
			var appendValue = false;
			for (var i = 0; i < config.length; i++)
			//for (var i = 0; i < 5; i++)
			{
				var c = config[i];
				if (ConfigEditor.isComment(c) == true
					|| jQuery.trim(c) == "")
					continue;
				
				//var needle = "webui.itemdisplay.default";
				//if (c.substring(0, needle.length) == needle)
				
				if (appendValue == false)
				{
					if (ConfigEditor.matchProperty(c, property) == true)
					{
						value = ConfigEditor.getPropertyValue(c, true);
						if (ConfigEditor.hasContinueValue(c) == false)
						{
							break;
						}
						else
						{
							appendValue = true;
						}
					}
				}
				else	//appendValue == true;
				{
					var v = ConfigEditor.getPropertyValue(c, false);
					value = value + v;
					if (ConfigEditor.hasContinueValue(c) == false)
					{
						break;
					}
				}
			}
			
			if (value == "")
				value = null;
				
			return value;
		}
		else
		{
			var index = 1;
			var header = ConfigEditor.getListHeader(property);
			var value = "";
			var v = ConfigEditor.getProperty(header + index);
			while (typeof(v) != "undefined" && v != "" && v != null)
			{
				if (value != "")
					value = value + ", ";
				value = value + v;
				
				index++;
				
				v = ConfigEditor.getProperty(header + index);
			}
			return value;
		}
	},
	setProperty: function (property, value)
	{
		if (jQuery.trim(value) == "")
			return;
		
		if (ConfigEditor.isList(property) == false)
		{
			var config = ConfigEditor.readConfig();
			
			var deleteContinueValue = false;
			var found = false;
			for (var i = 0; i < config.length; i++)
			{
				var c = config[i];
				if (ConfigEditor.isComment(c) == true)
					continue;
				
				if (deleteContinueValue == false)
				{
					if (ConfigEditor.matchProperty(c, property) == true)
					{
						c = ConfigEditor.setPropertyValue(c, value);
						config[i] = c;
						
						//delete ConfigEditor.cache;
						ConfigEditor.cache = null;
						found = true;
						if (ConfigEditor.hasContinueValue(c) == false)
						{
							break;
						}
						else
						{
							deleteContinueValue = true;
						}
					}
				}
				else	//deleteContinueValue == true;
				{
					delete config[i];
					if (ConfigEditor.hasContinueValue(c) == false)
					{
						break;
					}
				}
			}
			
			if (found == false)
			{
				var line = property + " = " + value;
				config.push("");
				config.push(line);
			}
			
			ConfigEditor.writeConfig(config);
		}
		else
		{
			var indexes = ConfigEditor.deleteConfig(property);
			
			var header = ConfigEditor.getListHeader(property);
			
			var config = ConfigEditor.readConfig();
			var beforeConfig = config.slice(0, indexes.first);
			var afterConfig = config.slice(indexes.last, config.length);
			
			var values = value.split(",");
			var valueConfig = new Array;
			for (var i = 0; i < values.length; i++)
			{
				var v = jQuery.trim(values[i]);
				if (v == "")
					continue;
				var p = header + eval(i+1) + " = " + v;
				valueConfig.push(p);
			}
			//alert([config.length, valueConfig.length, afterConfig.length]);
			config = beforeConfig.concat(valueConfig, afterConfig);
			ConfigEditor.writeConfig(config);
		}
	},
	deleteConfig: function(property)
	{
		if (ConfigEditor.isList(property) == false)
		{
			var config = ConfigEditor.readConfig();
			
			var deleteContinueValue = false;
			var found = false;
			var deleteIndex = -1;
			for (var i = 0; i < config.length; i++)
			{
				var c = config[i];
				if (ConfigEditor.isComment(c) == true)
					continue;
				
				if (deleteContinueValue == false)
				{
					if (ConfigEditor.matchProperty(c, property) == true)
					{
						deleteIndex = i;
						delete config[i];
						//delete ConfigEditor.cache;
						ConfigEditor.cache = null;
						found = true;
						if (ConfigEditor.hasContinueValue(c) == false)
						{
							break;
						}
						else
						{
							deleteContinueValue = true;
						}
					}
				}
				else	//deleteContinueValue == true;
				{
					delete config[i];
					if (ConfigEditor.hasContinueValue(c) == false)
					{
						break;
					}
				}
			}	//for (var i = 0; i < config.length; i++)
			
			ConfigEditor.writeConfig(config);
			return deleteIndex;
		}	//if (ConfigEditor.isList(property) == false)
		else
		{
			var index = 1;
			var header = ConfigEditor.getListHeader(property);
			var p = header + index;
			var deleteIndex = ConfigEditor.deleteConfig(p);
			var firstDeleteIndex = deleteIndex;
			while (deleteIndex != -1)
			{
				index++;
				p = header + index;
				deleteIndex = ConfigEditor.deleteConfig(p);
			}
			
			if (deleteIndex == -1)
			{
				//deleteIndex = firstDeleteIndex + 1;
				deleteIndex = firstDeleteIndex;
			}
			
			
			//if (property == "search.index.*") {
			//	alert(firstDeleteIndex + "+" + deleteIndex);
			//}
			
			return {
				first: firstDeleteIndex,
				last: deleteIndex
			};
		}
	},
	matchProperty: function(c, property)
	{
		c = jQuery.trim(c);
		if (c.indexOf("=") > 0)
		{
			
			var key = c.substring(0
					, c.indexOf("="));
				key = jQuery.trim(key);
			
			if (ConfigForm.utils.startsWith(key, "#"))
			{
				key = jQuery.trim(key.substring(1, key.length));
			}
			
			if (key == property)
			{
				return true;
			}
		}
		
		return false;
	},
	isComment: function(line)
	{
		line = jQuery.trim(line);
		if (line.substring(0, 1) == "#" 
			&& line.indexOf("=") == -1)
			return true;
		else
			return false;
	},
	isList: function (property)
	{
		property = jQuery.trim(property);
		var len = property.length;
		if (property.substring(len-1, len) == "*")
			return true;
		else
			return false;
	},
	getListHeader: function (property)
	{
		property = jQuery.trim(property);
		var len = property.length;
		if (property.substring(len-1, len) == "*")
			return property.substring(0, len-1);
		else
			return property;
	},
	getPropertyValue: function (line, isFirstLine)
	{
		if (isFirstLine
			&& line.indexOf("=") > 0)
		{
			line = line.substring(line.indexOf("=")+1
				, line.length);
		}
		
		var value = jQuery.trim(line);
		var len = value.length;
		if (value.substring(len-1, len) == "\\")
			value = value.substring(0, len-1);
		value = MessageUtils.decode(value);
		return value;
	},
	setPropertyValue: function (line, value)
	{
		line = jQuery.trim(line);
		value = jQuery.trim(value);
		if (value == "")
			return "";
		
		value = MessageUtils.encode(value);
		value = ConfigEditor.formatValue(value);
		var header = "";
		var key = jQuery.trim(line.substring(0, line.indexOf("=") + 1));
		if (key.substring(0, 1) == "#")
			key = jQuery.trim(key.substring(1, key.length));
		
		if (line.indexOf("=") != -1)
			line = key  + " " + value;
		else
			line = value;
		return line;
	},
	hasContinueValue: function (line)
	{
		line = jQuery.trim(line);
		var len = line.length;
		if (line.substring(len-1, len) == "\\") {
			return true;
		}
		else {
			//var needle = "webui.feed.item.description";
			//if (line.substr(0, needle.length) == needle) {
			//	alert(line);
			//}
			return false;
		}
	},
	formatValue: function(value)
	{
		var lines = value.split(",");
		
		var output = lines[0];
		for (var i = 1; i < lines.length; i++)
		{
			var l = jQuery.trim(lines[i]);
			output = output + ", \\" + "\n" + "\t" + l;
		}	
		return output;
	}
};