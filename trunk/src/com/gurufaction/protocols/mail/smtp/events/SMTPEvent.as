package com.gurufaction.protocols.mail.smtp.events 
{
	import com.gurufaction.protocols.mail.smtp.replies.ReplyCode;
	import flash.events.Event;
	import com.docsultant.logging.Logger;
	
	/**
	* ...
	* @author Default
	*/
	public class SMTPEvent extends Event
	{
		public static const MAIL_READY:String = "Ready";
		public static const MAIL_ERROR:String = "Error";
		public static const MAIL_SENT:String = "Sent";
		public static const MAIL_AUTH:String = "Auth";
		public static const MAIL_CONNECTED:String = "Connected";
		public static const MAIL_DISCONNECTED:String = "Disconnected";
		
		public var replyCode:ReplyCode;
		
		public function SMTPEvent(event:String, code:ReplyCode) 
		{
			super(event);
			replyCode = code;
		}
		
	}
	
}