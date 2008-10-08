package com.gurufaction.protocols.mail.smtp.replies 
{
	/**
	* ...
	* @author Default
	*/
	
	public class ReplyCode 
	{
		private var _code:int;
		private var _message:String;
		
		public function ReplyCode(code:int, message:String) 
		{
			this.code = code;
			this.message = message;
		}
		
		public function get code():int { return _code; }
		
		public function set code(value:int):void 
		{
			_code = value;
		}
		
		public function get message():String { return _message; }
		
		public function set message(value:String):void 
		{
			_message = value;
		}
		
		public static function parse( reply:String ):ReplyCode
		{
			var keys:Array = reply.split(" ",2);
			var code:int= parseInt(keys[0]);
			var message:String = keys[1];
			
			return new ReplyCode(code, message);
		}
		
		public function toString():String 
		{
			return this.code.toString() + ": " + this.message;
		}
		
	}
	
}