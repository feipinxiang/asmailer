﻿package com.gurufaction.protocols.mail.smtp.handlers 
{
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import flash.utils.ByteArray;
	import com.gurufaction.protocols.mail.smtp.replies.ReplyCode;
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.PacketQueue;
	import com.docsultant.logging.Logger;
	
	/**
	* ...
	* @author Default
	*/
	public class ServiceReadyHandler extends Handler
	{
		
		public function ServiceReadyHandler() 
		{
			
		}
		
		override public function handleRequest(queue:PacketQueue, data:ByteArray):void 
		{
			data.position = 0;
			var response:String = data.readUTFBytes( data.bytesAvailable );
			
			for each( var line:String in response.split("\r\n") )
			{
				var replyCode:ReplyCode = ReplyCode.parse( line );
			
				if ( replyCode.code == 220 )
				{
					this.dispatchEvent( new SMTPEvent( SMTPEvent.READY, replyCode) );
				}
				else if ( this.successor != null )
				{
					var unhandledData:ByteArray = new ByteArray();
					unhandledData.writeUTFBytes(line);
					this.successor.handleRequest(queue, unhandledData);
				}
			}
		}
		
	}
	
}