package com.gurufaction.protocols.mail.smtp 
{
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.CommandPacket;
	import com.gurufaction.protocols.mail.smtp.commands.Command;
	import com.gurufaction.protocols.base.Protocol;
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import com.gurufaction.protocols.mail.smtp.handlers.AuthHandler;
	import com.gurufaction.protocols.mail.smtp.handlers.ErrorHandler;
	import com.gurufaction.protocols.mail.smtp.handlers.OKHandler;
	import com.gurufaction.protocols.mail.smtp.handlers.ServiceReadyHandler;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	
	/**
	* ...
	* @author Default
	*/
	public class SMTP extends Protocol
	{
		public var host:String = null;
		public var port:int = 25;
		public var username:String = null;
		public var password:String = null;
		private var readyHandler:ServiceReadyHandler = new ServiceReadyHandler();
		private var okHandler:OKHandler = new OKHandler();
		private var errorHandler:ErrorHandler = new ErrorHandler();
		private var authHandler:AuthHandler = new AuthHandler();
		
		public function SMTP(host:String = null, username:String = null, password:String = null, port:int = 25) 
		{
			super(null, 0)
			this.host = host;
			this.port = port;
			this.username = username;
			this.password = password;
			readyHandler.host = host;
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
			this.processPacket(true);
			
		}
		
		public function help(cmd:String):void
		{
			this.queue.enqueue( new CommandPacket( Command.HELP, cmd) );
			this.processPacket();
		}
		
		private function authenticate( username:String, password:String ):void {
			authHandler.username = username;
			authHandler.password = password;
			this.queue.enqueue( new CommandPacket( Command.AUTHENTICATION, "LOGIN" ) );
			this.processPacket(true);
		}
		
		override protected function initializeHandlers():Handler 
		{
			readyHandler.successor = okHandler;
			okHandler.successor = errorHandler;
			errorHandler.successor = authHandler;
			
			readyHandler.addEventListener( SMTPEvent.READY, eventHandler );
			errorHandler.addEventListener( SMTPEvent.MAIL_ERROR, eventHandler );
			okHandler.addEventListener( SMTPEvent.MAIL_SENT, eventHandler );
			
			return readyHandler;
		}
		
		public function eventHandler( event:SMTPEvent ):void
		{
			dispatchEvent( new SMTPEvent(event.type, event.replyCode) );
		}
		
	}
	
}