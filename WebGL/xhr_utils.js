function load(method, items, timeout, on_result, on_complete) {
	items.count = 0;
	for (var i = 0; i < items.length; i++) {
		var xhr = new XMLHttpRequest();
		xhr.open(method, items[i].src);
		xhr.timeout = timeout;
		xhr.onload = function(item) {
			return function(e) {
				items.count++;
				on_result(item, e);
				if (items.count === items.length) {
					on_complete();
				}
			};
		}(items[i]);
		xhr.onerror = xhr.onload;
		xhr.ontimeout = xhr.onerror;
		xhr.onabort = xhr.onerror;
		xhr.send();
	}
}
