package com.gurufaction.protocols.base
{
	import com.gurufaction.protocols.base.handlers.Handler;
	import com.gurufaction.protocols.base.packets.PacketQueue;
	import com.docsultant.logging.Logger;
	import flash.net.Socket;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	import flash.events.ProgressEvent;
	
	/**
	* ...
	* @author Default
	*/
	public class Protocol extends Socket
	{
		public var queue:PacketQueue = new PacketQueue();
		protected var defaultHandler:Handler;
		
		public function Protocol(host:String = null , port:int = 0) 
		{
			super(host, port);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler );
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			addEventListener(IOErrorEvent.IO_ERROR, socketErrorHandler );
			addEventListener(Event.CONNECT, socketConnectHandler );
			addEventListener(Event.CLOSE, socketCloseHandler );
			defaultHandler = initializeHandlers();
		}
		
		private function socketDataHandler( event:ProgressEvent ):void 
		{
			var data:ByteArray = new ByteArray();
			event.target.readBytes(data);
			Logger.debug("<<" + data);
			defaultHandler.handleRequest(this, data)
			processPacket();
		}
		
		private function socketSecurityErrorHandler( event:SecurityErrorEvent ):void {
			Logger.debug( event.text );
		}
		
		private function socketErrorHandler( event:IOErrorEvent ):void {
			Logger.debug( event.text );
		}
		
		private function socketConnectHandler( event:Event ):void {
			Logger.debug( "CONNECTED");
		}
		
		private function socketCloseHandler( event:Event ):void {
			Logger.debug( "CLOSED" );
		}
		
		protected function initializeHandlers():Handler
		{
			return new Handler();
		}
		
		public function processPacket(all:Boolean = false):void
		{
			if ( queue != null )
			{
				if ( queue.size > 0 )
				{
					if ( all )
					{
						while( !queue.isEmpty() )
						{
							Logger.debug(">>" + queue.peek());
							this.writeBytes(queue.dequeue());
						}
						this.flush();
					}
					else
					{
						Logger.debug(">>" + queue.peek());
						this.writeBytes(queue.dequeue());
						this.flush();
					}
				}
			}
		}
	}
	
}