package com.gurufaction.protocols.mail.smtp.handlers 
{
	import com.gurufaction.protocols.base.Protocol;
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import flash.utils.ByteArray;
	import com.gurufaction.protocols.mail.smtp.replies.ReplyCode;
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.docsultant.logging.Logger;
	
	/**
	* ...
	* @author Default
	*/
	public class OKHandler extends Handler
	{
		
		public function OKHandler() 
		{
			
		}
		
		override public function handleRequest(protocol:Protocol, data:ByteArray):void 
		{
			data.position = 0;
			var response:String = data.readUTFBytes( data.bytesAvailable );
			var requiresAuth:Boolean = false;
			
			for each( var line:String in response.split("\r\n") )
			{
				
				var replyCode:ReplyCode = ReplyCode.parse( line );
				
				if ( replyCode.code == 250 )
				{
					if ( replyCode.message.indexOf("queued") > 0 )
					{
						this.dispatchEvent( new SMTPEvent( SMTPEvent.MAIL_SENT, replyCode) );
					}
					
					if ( replyCode.message.indexOf("AUTH") > 0 ) {
						requiresAuth = true;
						protocol.queue.enqueue( new CommandPacket( Command.AUTHENTICATION, "LOGIN" ) );
					}
					
					if ( replyCode.message.indexOf("OK") > 0 ) {
						protocol.processPacket();
						if ( requiresAuth == false ) {
							this.dispatchEvent( new SMTPEvent( SMTPEvent.READY, replyCode) );
						}
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