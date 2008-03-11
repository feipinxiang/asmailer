package com.gurufaction.protocols.base.handlers 
{
	import com.gurufaction.protocols.base.packets.PacketQueue;
	import com.docsultant.logging.Logger;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	* ...
	* @author Default
	*/
	public class Handler extends EventDispatcher
	{
		protected var _successor:Handler;
		
		public function Handler() 
		{
			
		}
		
		public function get successor():Handler 
		{ 
			return _successor;
		}
		
		public function set successor(value:Handler):void 
		{
			_successor = value;
		}
		
		public function handleRequest(queue:PacketQueue, data:ByteArray):void
		{
			Logger.debug(data);
			if ( this.successor != null )
			{
				this.successor.handleRequest(queue, data);
			}
		}
		
	}
	
}