package com.gurufaction.protocols.mail.smtp.handlers 
{
	import com.gurufaction.protocols.mail.smtp.events.SMTPEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import mx.utils.Base64Encoder;
	import mx.utils.Base64Decoder;
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.MD5;
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
		public var host:String = null;
		public var username:String = null;
		public var password:String = null;
		public var authType:String = AUTH_PLAIN;
		public var requiresAuth:Boolean = false;
		
		private var digest:Object = new Object();
		private var digest_challenge:String;
		private var digest_response:String;
		
		
		public function SMTPHandler() 
		{
			digest["nonce"] = "";
			digest["cnonce"] = "";
			digest["digest-uri"] = "";
			digest["realm"] = "";
			digest["qop"] = "auth";
			digest["nc"] = "00000001";
			digest["charset"] = "";
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
					case 235:
						protocol.dispatchEvent( new SMTPEvent( SMTPEvent.MAIL_AUTH, replyCode) );
						protocol.dispatchEvent( new SMTPEvent( SMTPEvent.READY, replyCode) );
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
								digest_challenge = decoder.toByteArray().toString();
								Logger.debug( digest_challenge );
								var directives:Array = digest_challenge.split(",");
								for each( var directive:String in directives ) {
									var attribute:Array = directive.split("=");
									var key:String = attribute[0];
									var value:String = String(attribute[1]);
									digest[key] = value;
								}
								var A1:String = MD5.hash(username + ":" + digest["realm"] + ":" + password) + digest["nonce"] + digest["cnonce"];
								var A2:String = "AUTHENTICATE:" + digest["digest-uri"];
								digest["response"] = MD5.hash(MD5.hash(A1) + digest["nonce"] + ":" + digest["nc"] + ":" + digest["cnonce"] + ":" + digest["qop"] + MD5.hash(A2));
								digest_response = "charset=" + digest["charset"] + ",username=\"" + username + "\",realm=\"" + digest["realm"]  + "\",nonce=\"" + digest["nonce"] + "\",nc=" + digest["nc"] + ",cnonce=\"" + digest["cnonce"] + "\",digest-uri=\"" + digest["digest-uri"] + "\",response=" + digest["response"] + ",qop=" + digest["qop"];
								Logger.debug(digest_response);
								encoder.reset();
								encoder.encode(digest_response);
								protocol.queue.enqueue( new CommandPacket( encoder.toString() ) );
								break;
							case "CRAM-MD5":

								decoder.reset()
								decoder.decode(replyCode.message);
								var challenge:String = decoder.toByteArray().toString();
								
								digest_response = username + " " + HMAC.hash(password,challenge);
								
								encoder.reset();
								encoder.encode(digest_response);
								protocol.queue.enqueue( new CommandPacket( encoder.toString() ) );
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