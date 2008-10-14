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
	public class SMTPHandler extends Handler
	{
		public static const AUTH_LOGIN:String = "LOGIN";
		public static const AUTH_PLAIN:String = "PLAIN";
		public var host:String = null;
		public var username:String = null;
		public var password:String = null;
		public var authType:String = AUTH_PLAIN;
		public var requiresAuth:Boolean = false;
		
		private var digest:Object = new Object();
		
		public function SMTPHandler() 
		{
			
		}
		
		override public function handleRequest(protocol:Protocol, data:ByteArray):void 
		{
			data.position = 0;
			var response:String = data.readUTFBytes( data.bytesAvailable );
			
			for each( var line:String in response.split("\r\n") )
			{
				
				var replyCode:ReplyCode = ReplyCode.parse( line );
				
				switch( replyCode.code ) 
				{
					case 220:
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
						break;
					case 250:
						if ( replyCode.message.indexOf("queued") != -1 )
						{
							protocol.dispatchEvent( new SMTPEvent( SMTPEvent.MAIL_SENT, replyCode) );
						}
						break;
					case 334:
						var decoder:Base64Decoder = new Base64Decoder();
						var encoder:Base64Encoder = new Base64Encoder();
						decoder.reset();
						switch( authType )
						{
							case "LOGIN":
								decoder.decode(replyCode.message);
								var prompt:String = decoder.toByteArray().toString()
								
								if ( prompt == "Username:") {
									encoder.reset();
									encoder.encodeUTFBytes(username);
									protocol.queue.enqueue( new CommandPacket( encoder.toString() ) );
								}else if ( prompt == "Password:") {
									encoder.reset();
									encoder.encodeUTFBytes(password);
									protocol.queue.enqueue( new CommandPacket( encoder.toString() ) );
								}
								break;
							case "PLAIN":
								var login:ByteArray = new ByteArray();
								login.writeByte(0);
								login.writeUTFBytes(username);
								login.writeByte(0)
								login.writeUTFBytes(password);
								encoder.reset();
								encoder.encodeBytes(login);
								protocol.queue.enqueue( new CommandPacket( encoder.toString() ) );
								break;
							case "DIGEST-MD5":
								decoder.reset()
								decoder.decode(replyCode.message);
								var digest_challenge:String = decoder.toByteArray().toString();
								Logger.debug( digest );
								var directives:Array = digest_challenge.split(",");
								for each( var directive:String in directives ) {
									var attribute:String = directive.split("=");
									var key:String = attribute[1];
									var value:String attribute[2];
									digest[key] = value;
								}
								break;
						}
						break;
					case 354:
						protocol.processPacket();
						break;
					default:
						if ( this.successor != null )
						{
							var unhandledData:ByteArray = new ByteArray();
							unhandledData.writeUTFBytes(line);
							this.successor.handleRequest(protocol, unhandledData);
						}
						break;
				}
			}
		}
	}
	
}