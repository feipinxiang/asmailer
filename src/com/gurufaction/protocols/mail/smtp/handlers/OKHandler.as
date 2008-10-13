﻿package com.gurufaction.protocols.mail.smtp.handlers 
{
	import com.gurufaction.protocols.base.Protocol;
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import com.gurufaction.protocols.base.packets.CommandPacket;
	import com.gurufaction.protocols.mail.smtp.commands.Command;
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
			
			for each( var line:String in response.split("\r\n") )
			{
				
				var replyCode:ReplyCode = ReplyCode.parse( line );

				if ( replyCode.code == 250 )
				{
					if ( replyCode.message.indexOf("queued") != -1 )
					{
						protocol.dispatchEvent( new SMTPEvent( SMTPEvent.MAIL_SENT, replyCode) );
					}
				}
				else if ( replyCode.code == 354 ) {
					protocol.processPacket();
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