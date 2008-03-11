package com.gurufaction.protocols.mail.smtp 
{
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.CommandPacket;
	import com.gurufaction.protocols.mail.smtp.commands.Command;
	import com.gurufaction.protocols.base.Protocol;
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import com.gurufaction.protocols.mail.smtp.handlers.ErrorHandler;
	import com.gurufaction.protocols.mail.smtp.handlers.ServiceReadyHandler;
	
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
			this.queue.enqueue( new CommandPacket( Command.HELLO, this.host) );
			this.queue.enqueue( new CommandPacket( Command.MAIL, "FROM: <" + from + ">") );
			this.queue.enqueue( new CommandPacket( Command.RECIPIENT, "TO:<" + to + ">") );
			this.queue.enqueue( new CommandPacket( Command.DATA ) );
			this.queue.enqueue( new CommandPacket( "", "From :" + from) );
			this.queue.enqueue( new CommandPacket( "", "To :" + to) );
			this.queue.enqueue( new CommandPacket( "", "Subject :" + subject) );
			this.queue.enqueue( new CommandPacket( "", "Mime-Version: 1.0") );
			this.queue.enqueue( new CommandPacket( "", "Content-Type: text/html; charset=UTF-8; format=flowed") );
			this.queue.enqueue( new CommandPacket( "", message ) );
			this.queue.enqueue( new CommandPacket( "", "." ) );
			this.processPacket();
			
		}
		
		public function help(cmd:String):void
		{
			this.queue.enqueue( new CommandPacket( Command.HELP, cmd) );
			this.processPacket();
		}
		
		override protected function initializeHandlers():Handler 
		{
			var ready:Handler = new ServiceReadyHandler()
			var error:Handler = new ErrorHandler();
			ready.successor = error;
			ready.addEventListener( SMTPEvent.READY, eventHandler );
			error.addEventListener( SMTPEvent.MAIL_ERROR, eventHandler );
			return ready;
		}
		
		public function eventHandler( event:SMTPEvent ):void
		{
			dispatchEvent( new SMTPEvent(event.type,event.replyCode) );
		}
		
	}
	
}