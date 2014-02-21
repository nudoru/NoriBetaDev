package com.nudoru.noriplugins.bindablemodel.model.bind
{
	/**
	 * @author Matt Perkins
	 */
	public class PropertyChangedVO
	{
		public var name:String;
		public var value:*;
		public var oldvalue:*;
		
		public function PropertyChangedVO(n:String, v:*, ov:*=undefined):void
		{
			name = n;
			value = v;
			oldvalue = ov;
		}
	}
}
