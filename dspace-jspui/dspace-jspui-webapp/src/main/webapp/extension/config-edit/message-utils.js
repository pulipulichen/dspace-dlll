MessageUtils = {
	encode: function (source)
	{
	  //var source = document.getElementById("source").value;
	  var utf = "";
	  
	  //轉換成UTF8碼
	  for (var i = 0; i < source.length; i++)
	  {
		char = source.substr(i, 1);
		var encoded = source.charCodeAt(i).toString(16);
		if (encoded.length == 4)
			utf = utf + "\\u" + encoded;
		else
	   		utf = utf + char;
	  }
	  var result = utf;;
	  return result;
	},
	decode: function(source)
	{
	  var utf = "";
		for (var i = 0; i < source.length; i++)
		{
			var char = source.substr(i, 1);
			
			if (char == "\\" && i < source.length - 1)
			{
				char = source.substr(i, 2);
			   
			   if (char == "\\u" && i < source.length - 5)
			   {
					code = source.substr(eval(i+2), 4);
					if (code.indexOf("\\") == -1 && code.indexOf(" ") == -1)
					{
						utf = utf + String.fromCharCode(MessageUtils.HEXtoDEC(code));
						i = i + 5;
					}
					else
						utf = utf + char;
				}
				else
					utf = utf + char;
			}
			else
				utf = utf + char;
		}
	  
	  var result = utf;
	  return result;
	},
	HEXtoDEC: function(six)
	{
		  var ten = 0;
		  
		  for (var i = 0; i < six.length; i++)
		  {
			char = six.substr(i, 1);
		 number = 0;
		 
		 switch (char)
		 {
		   case 'a':
			 number = 10;break;
		   case 'b':
			 number = 11;break;
		   case 'c':
			 number = 12;break;
		   case 'd':
			 number = 13;break;
		   case 'e':
			 number = 14;break;
		   case 'f':
			 number = 15;break;  
		   default:
			 number = char;break;
		 }
		
		 for (var j = 0; j < (six.length - i - 1); j++)
		 {
		   number = number * 16;
		 }
		 ten = ten + parseInt(number);
		  }
		  
		  return ten;
	}
};