package com.gurufaction.protocols.base
{
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.PacketQueue;
	import com.docsultant.logging.Logger;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.ProgressEvent;
	
	/**
	* ...
	* @author Default
	*/
	public class Protocol extends Socket
	{
		protected var queue:PacketQueue = new PacketQueue();
		protected var defaultHandler:Handler;
		
		public function Protocol(host:String = null , port:int = 0) 
		{
			super(host, port);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			defaultHandler = initializeHandlers();
		}
		
		private function socketDataHandler ( event:ProgressEvent ):void 
		{
			var data:ByteArray = new ByteArray();
			event.target.readBytes(data);
			Logger.debug(data);
			defaultHandler.handleRequest(queue, data)
			
			this.processPacket();
		}
		
		protected function initializeHandlers():Handler
		{
			return new Handler();
		}
		
		protected function processPacket():void
		{
			if ( queue != null )
			{
				if ( queue.size > 0 )
				{
					Logger.debug(queue.peek());
					this.writeBytes(queue.dequeue());
					this.flush();
				}
			}
		}
	}
	
}