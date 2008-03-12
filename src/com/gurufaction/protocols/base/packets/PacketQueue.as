package com.gurufaction.protocols.base.packets 
{
	import de.polygonal.ds.LinkedQueue;
	import flash.utils.ByteArray;
	/**
	* ...
	* @author Default
	*/
	public class PacketQueue 
	{
		private var queue:LinkedQueue = new LinkedQueue();
		
		public function PacketQueue() 
		{
			
		}
		
		public function enqueue( packet:ByteArray ):void
		{
			queue.enqueue(packet);
		}
		
		public function dequeue():ByteArray
		{
			return queue.dequeue() as ByteArray;
		}
		
		public function peek():ByteArray
		{
			return queue.peek();
		}
		
		public function back():ByteArray
		{
			return queue.back();
		}
		
		public function clear():void
		{
			queue.clear();
		}
		
		public function isEmpty():Boolean
		{
			return queue.isEmpty();
		}
		
		public function get size():int
		{
			return queue.size;
		}
	}
	
}