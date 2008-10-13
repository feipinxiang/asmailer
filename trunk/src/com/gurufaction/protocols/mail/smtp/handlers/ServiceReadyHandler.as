package com.gurufaction.protocols.mail.smtp.handlers 
{
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import flash.utils.ByteArray;
	import com.gurufaction.protocols.base.packets.CommandPacket;
	import com.gurufaction.protocols.mail.smtp.commands.Command;
	import com.gurufaction.protocols.mail.smtp.replies.ReplyCode;
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.Protocol;
	import com.docsultant.logging.Logger;
	
	/**
	* ...
	* @author Default
	*/
	public class ServiceReadyHandler extends Handler
	{
		public var host:String = "";
		public var requiresAuth:Boolean = false;
		public var authType:String = "";
		
		public function ServiceReadyHandler() 
		{
			
		}
		
		override public function handleRequest(protocol:Protocol, data:ByteArray):void 
		{
			data.position = 0;
			var response:String = data.readUTFBytes( data.bytesAvailable );
			
			for each( var line:String in response.split("\r\n") )
			{
				var replyCode:ReplyCode = ReplyCode.parse( line );
			
				if ( replyCode.code == 220 )
				{
					if( replyCode.message.indexOf("ESMTP") != -1 ){
						protocol.queue.enqueue( new CommandPacket( Command.EXTENDED_HELLO, this.host) );
					}else {
						protocol.queue.enqueue( new CommandPacket( Command.HELLO, this.host) );
					}
					if ( requiresAuth) {
						protocol.queue.enqueue( new CommandPacket( Command.AUTHENTICATION, authType ) );
					}else {
						protocol.dispatchEvent( new SMTPEvent( SMTPEvent.READY, replyCode) );
					}
				}
				else if ( this.successor != null )
				{
					var unhandledData:ByteArray = new ByteArray();
					unhandledData.writeUTFBytes(line);
					this.successor.handleRequest(protocol, unhandledData);
				}
			}
		}
		
	}
	
}