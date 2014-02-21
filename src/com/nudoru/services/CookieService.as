package com.nudoru.services
{
	import com.nudoru.debug.Debugger;

	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 * Class for creating, loading, saving and clearing locally shared objects (flash cookies)
	 * Based off of techniques in this article: http://drawlogic.com/2008/01/10/howto-sharedobjects-for-local-storage-as3/
	 * 
	 * @author Matt Perkins
	 */
	public class CookieService implements ICookieService  {

		/**
		 * @private
		 */
		public function CookieService() {
		}

		/**
		 * Saves data to the local computer
		 * @param	id	ID of the shared object to write to/create
		 * @param	d	Data to save. Will be compressed and not saved as plain text.
		 * @return	True of successful, false if not.
		 */
		public function save(id:String, d:String):Boolean {
			var so:SharedObject;
			
			try {
				so = SharedObject.getLocal(id);
			} catch (e:*) {
				Debugger.instance.add("CAN'T GET/save LSO: '" + id + "'", CookieService);
				return false;
			}
			so.data.thedata = d; // StringUtilities.compress(d);
			
			var flstat:String;
			
			try {
				flstat = so.flush();
			} catch (e:*) {
				Debugger.instance.add("CAN'T WRITE LSO: '" + id + "'", CookieService);
				return false;
			}
			if (flstat == SharedObjectFlushStatus.PENDING) {
				// need more space
				Debugger.instance.add("CAN'T WRITE LSO, status pending", CookieService);
				return false;
			}
			
			so.close();
			
			return true;
		}
		
		/**
		 * Clears any data saved under the ID
		 * @param	id	ID of the shared object to clear.
		 * @return	True if successful, false if not
		 */
		public function clear(id:String):Boolean {
			var so:SharedObject;
			
			try {
				so = SharedObject.getLocal(id);
			} catch (e:*) {
				Debugger.instance.add("CAN'T GET/clear LSO: '" + id + "'", CookieService);
				return false;
			}
			so.clear();
			so.close();
			Debugger.instance.add("LSO cleared: " + id);
			return true;
		}
		
		/**
		 * Get any data saved under the shared object with the ID
		 * @param	id	ID of the object to retrieve data from
		 * @return	The data in the shared object as string
		 */
		public function load(id:String):String {
			var so:SharedObject;
			
			try {
				so = SharedObject.getLocal(id);
			} catch (e:*) {
				Debugger.instance.add("CAN'T GET/get LSO: '" + id + "'", CookieService);
				return undefined;
			}
			so.close();
			Debugger.instance.add("data ret: '" + so.data.thedata + "'", CookieService);
			
			return so.data.thedata;
			
			//if (so.data.thedata == undefined) return undefined;
			
			//return StringUtilities.decompress(so.data.thedata);
		}

		
	}
}