﻿package com.gurufaction.protocols.mail.smtp 
{
	import flash.system.Security;
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.CommandPacket;
	import com.gurufaction.protocols.mail.smtp.commands.Command;
	import com.gurufaction.protocols.base.Protocol;
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import com.gurufaction.protocols.mail.smtp.handlers.ErrorHandler;
	import com.gurufaction.protocols.mail.smtp.handlers.SMTPHandler;
	import flash.utils.ByteArray;
	
	/**
	* ...
	* @author Default
	*/
	public class SMTP extends Protocol
	{
		public static const AUTH_LOGIN:String = "LOGIN";
		public static const AUTH_PLAIN:String = "PLAIN";
		public static const AUTH_DIGEST_MD5:String = "DIGEST-MD5";
		
		public var host:String = null;
		public var port:int = 25;
		public var username:String = null;
		public var password:String = null;
		private var errorHandler:ErrorHandler = new ErrorHandler();
		private var handler:SMTPHandler = new SMTPHandler();
		
		
		public function SMTP(host:String = null, username:String = null, password:String = null,auth:String = null, port:int = 25) 
		{
			super(null, 0)
			this.host = host;
			this.port = port;
			this.username = username;
			this.password = password;
			handler.host = host;
			
			if ( username != null && password != null) {
				handler.requiresAuth = true;
				if ( auth == null ) {
					handler.authType = AUTH_LOGIN;
				}else{
					handler.authType = auth;
				}
				handler.username = username;
				handler.password = password;
			}
			
			this.connect(host, port);
		}
		
		public function send( from:String, to:String, subject:String, message:String ):void
		{
			this.queue.enqueue( new CommandPacket( Command.MAIL, "FROM:<" + from + ">") );
			this.queue.enqueue( new CommandPacket( Command.RECIPIENT, "TO:<" + to + ">") );
			this.queue.enqueue( new CommandPacket( Command.DATA ) );
			var msg:ByteArray = new ByteArray();
			msg.writeUTFBytes( "From :" + from + CommandPacket.CRLF )
			msg.writeUTFBytes( "To :" + to + CommandPacket.CRLF);
			msg.writeUTFBytes( "Subject :" + subject + CommandPacket.CRLF);
			msg.writeUTFBytes( "Mime-Version: 1.0" + CommandPacket.CRLF);
			msg.writeUTFBytes( "Content-Type: text/html; charset=UTF-8; format=flowed" + CommandPacket.CRLF);
			msg.writeUTFBytes( message);
			this.queue.enqueue( msg );
			this.queue.enqueue( new CommandPacket( Command.END_DATA ) );
			this.queue.enqueue( new CommandPacket( Command.QUIT ) );
		}
		
		public function help(cmd:String):void
		{
			this.queue.enqueue( new CommandPacket( Command.HELP, cmd) );
			this.processPacket();
		}
		
		override protected function initializeHandlers():Handler 
		{
			handler.successor = errorHandler;
			return handler;
		}
		
	}
	
}