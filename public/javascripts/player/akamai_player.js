(function( $ ){
	
	var settings = {
		'width'			: '360',
		'height'		: '240',
		'volume'		: 'auto',		// auto: use volume stored in Cookie, OR use a value 0.0-1.0, default is 0.8
		'volumeControl': 'vertical',
		'loop'			: 'false',
		'autostart'	: 'true',
		'bgcolors'	: '#e96864,#b61e1a',	// '#xxxxxx' for single color, '#xxxxxx,#xxxxxx' for gradient color
		'showMeter'	: 'true',	// show/hide meter button
		'videosrc'	: '',				// Full URL starts with http:// OR relative path used with 'baseurl'
		'baseurl'		: '',				// if empty, use the path of this file. This attribute is ignored if 'videosrc' is a full URL beginning with http://, https://, rtmp:// or rtmpe://
		'iossrc'		: '',
		'quality'		: 'sq',			// sq=Standard Quality, hq=High Quality
		'qualityBtn': 'true',   // show/hide quality select button
		'language'	: 'cht'			// eng=English, cht=Trad.Chinese, chs=Simp.Chinese
	};
	
	var ios = false;
	
  var methods = {
		init : function( options ) {
			var deviceAgent = navigator.userAgent.toLowerCase();
			if (deviceAgent.match(/(iphone|ipod|ipad)/)) {
				ios = true;
			}
		},
		loadVideo: function( options ) {
			return this.each(function() {
				$.extend(settings, options);
				var s = settings;
				rnd = Math.floor(Math.random()*999999999);
				var video_content = "";
				var videourl = "";
				if (s.videosrc.match(/^(http|https|rtmp|rtmpe)(:\/\/)/)) {
					videourl = s.videosrc;
				} else {
					if (s.baseurl.length > 0) {
						videourl = s.baseurl + s.videosrc;
					} else {
						var pathname = window.location.pathname.replace(/(\/)$/,"");
						if (pathname.lastIndexOf(".") > pathname.lastIndexOf("/")) {
							videourl = window.location.origin + pathname.substring(0,pathname.lastIndexOf("/")) + s.videosrc;
						} else {
							videourl = window.location.origin + pathname + s.videosrc;
						}
					}
				}
				// console.log("videourl: " + videourl);
				if (ios) {
					// console.log(s.iossrc);
					video_content = "<video id='video" + rnd + "' src='" + s.iossrc + "'width='" + s.width + "' height='" + s.height + "' controls autoplay></video>";
				} else {
					video_content = "<object classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' id='HDExamplePlayer' width='" + s.width + "' height='" + s.height + "' codebase='http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab'> <param name='movie' value='http://www.hkjc.com/chinese/press/HKJCPlayer.swf/HKJCPlayer.swf?src=" + videourl + "&math=" + rnd + "&volume=" + s.volume + "&volumeControl=" + s.volumeControl + "&loop=" + s.loop + "&autostart=" + s.autostart + "&bgcolors=" + s.bgcolors + "&showMeter=" + s.showMeter + "&streamQuality=" + s.quality + "&qualityBtn=" + s.qualityBtn + "&language=" + s.language + "' /> <param name='quality' value='high' /> <param name='bgcolor' value='#111111' /> <param name='allowScriptAccess' value='sameDomain' /> <param name='allowFullScreen' value='true' /> <embed src='http://www.hkjc.com/chinese/press/HKJCPlayer.swf?src=" + videourl + "&math=" + rnd + "&volume=" + s.volume + "&volumeControl=" + s.volumeControl + "&loop=" + s.loop + "&autostart=" + s.autostart + "&bgcolors=" + s.bgcolors + "&showMeter=" + s.showMeter + "&streamQuality=" + s.quality + "&qualityBtn=" + s.qualityBtn + "&language=" + s.language + "' quality='high' bgcolor='#111111' width='" + s.width + "' height='" + s.height + "' name='HDExamplePlayer' align='middle' play='true' loop='false' quality='high' allowScriptAccess='sameDomain' allowFullScreen='true' type='application/x-shockwave-flash' pluginspage='http://www.adobe.com/go/getflashplayer'> </embed> </object>";
				}
				$(this).html(video_content);
			});
		}
  };

  $.fn.Akamai = function( method ) {
    
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.Akamai' );
    }
  
  };

})( jQuery );
