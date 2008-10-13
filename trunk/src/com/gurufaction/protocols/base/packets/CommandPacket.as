package com.gurufaction.protocols.base.packets 
{
	import flash.utils.ByteArray;
	import mx.utils.StringUtil;
	/**
	* ...
	* @author Default
	*/
	public class CommandPacket extends ByteArray
	{
		public static const CRLF:String = "\r\n";
		
		public function CommandPacket(cmd:String, arg:String = "" ) 
		{
			this.writeUTFBytes (StringUtil.trim(cmd + " " + arg) + CommandPacket.CRLF);
		}
		
	}
	
}