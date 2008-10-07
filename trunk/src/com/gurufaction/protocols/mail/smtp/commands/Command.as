package com.gurufaction.protocols.mail.smtp.commands 
{
	
	/**
	* ...
	* @author Default
	*/
	public class Command 
	{
		public static const EXTENDED_HELLO:String = "EHLO";
		public static const HELLO:String = "HELO";
		public static const AUTHENTICATION:String = "AUTH";
		public static const MAIL:String = "MAIL";
		public static const RECIPIENT:String = "RCPT";
		public static const SEND:String = "SEND";
		public static const SEND_OR_MAIL:String = "SOML";
		public static const SEND_AND_MAIL:String = "SAML";
		public static const DATA:String = "DATA";
		public static const RESET:String = "RSET";
		public static const VERIFY:String = "VRFY";
		public static const EXPAND:String = "EXPN";
		public static const HELP:String = "HELP";
		public static const NOOP:String = "NOOP";
		public static const QUIT:String = "QUIT";
		public static const TURN:String = "TURN";
		public static const END_DATA:String = "\r\n.\r\n";
		
		public function Command() 
		{
			
		}
		
	}
	
}