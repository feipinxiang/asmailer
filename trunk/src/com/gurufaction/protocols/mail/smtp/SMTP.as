package com.gurufaction.protocols.mail.smtp 
{
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.CommandPacket;
	import com.gurufaction.protocols.mail.smtp.commands.Command;
	import com.gurufaction.protocols.base.Protocol;
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
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
		
		public function SMTP(host:String = null, port:int = 25) 
		{
			super(null, 0)
			this.host = host;
			this.port = port;
			this.connect(host, port);
		}
		
		public function send( from:String, to:String, subject:String, message:String ):void
		{
			this.queue.enqueue( new CommandPacket( Command.EXTENDED_HELLO, this.host) );
			this.queue.enqueue( new CommandPacket( Command.AUTHENTICATION, "LOGIN" ) );
			this.queue.enqueue( new CommandPacket( Base64.encode("michael_ramirez44") ) );
			//this.queue.enqueue( new CommandPacket( Base64.encode("mr5871") ) );
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
			this.processPacket();
			
		}
		
		public function help(cmd:String):void
		{
			this.queue.enqueue( new CommandPacket( Command.HELP, cmd) );
			this.processPacket();
		}
		
		override protected function initializeHandlers():Handler 
		{
			var readyHandler:Handler = new ServiceReadyHandler();
			var okHandler:Handler = new OKHandler();
			var errorHandler:Handler = new ErrorHandler();
			
			readyHandler.successor = okHandler;
			okHandler.successor = errorHandler;
			readyHandler.addEventListener( SMTPEvent.READY, eventHandler );
			errorHandler.addEventListener( SMTPEvent.MAIL_ERROR, eventHandler );
			okHandler.addEventListener( SMTPEvent.MAIL_SENT, eventHandler );
			return readyHandler;
		}
		
		public function eventHandler( event:SMTPEvent ):void
		{
			dispatchEvent( new SMTPEvent(event.type,event.replyCode) );
		}
		
	}
	
}