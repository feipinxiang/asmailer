package com.gurufaction.protocols.mail.smtp.handlers 
{
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	import mx.utils.Base64Decoder;
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
	public class AuthHandler extends Handler
	{
		public static const LOGIN:String = "LOGIN";
		public static const PLAIN:String = "PLAIN";
		
		public var username:String = null;
		public var password:String = null;
		public var authType:String = PLAIN;
		
		
		public function AuthHandler() 
		{
			
		}
		
		override public function handleRequest(protocol:Protocol, data:ByteArray):void 
		{
			data.position = 0;
			var response:String = data.readUTFBytes( data.bytesAvailable );
			
			for each( var line:String in response.split("\r\n") )
			{
				
				var replyCode:ReplyCode = ReplyCode.parse( line );
				
				if ( replyCode.code == 334 )
				{
					var decoder:Base64Decoder = new Base64Decoder();
					var encoder:Base64Encoder = new Base64Encoder();
					var login:ByteArray = new ByteArray();
					
					switch( authType )
					{
						case LOGIN:
							decoder.decode(replyCode.message);
							var prompt:String = decoder.toByteArray().toString()
							
							if ( prompt == "Username:") {
								encoder.reset();
								encoder.encodeUTFBytes(username);
								login.writeUTFBytes( encoder.toString() + "\r\n");
								protocol.queue.enqueue( login );
							}else if ( prompt == "Password:") {
								encoder.reset();
								encoder.encodeUTFBytes(password);
								login.writeUTFBytes( encoder.toString() + "\r\n");
								protocol.queue.enqueue( login );
							}
							break;
						case PLAIN:
							login.writeByte(0);
							login.writeUTFBytes(username);
							login.writeByte(0)
							login.writeUTFBytes(password);
							encoder.reset();
							encoder.encodeBytes(login);
							protocol.queue.enqueue( new CommandPacket( encoder.toString() ) );
							break;
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