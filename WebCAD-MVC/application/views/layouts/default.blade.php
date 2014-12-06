<!DOCTYPE html>
<html>
<head>
    <title>@yield('title') :: Firehouse Automation, LLC</title>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
    <link  href="css/admin.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <div id="main" >
        <div id="header">        
            <a href="#" class="logo"><img src="img/logo_rgb185.png" /></a>            
            <ul id="top-navigation">            
                {{ Auth::check() ? '<li><a href="#" class="active">HOME</a></li>' : '' }}
                {{ Auth::check() ? '<li><a href="#">WebCAD LIVE</a></li>' : '' }}
                {{ Auth::check() ? '<li><a href="#">iCAD ALERTS</a></li>' : '' }}
                {{ Auth::check() ? '<li><a href="#">ADMINISTRATION</a></li>' : '' }}
            </ul>            
        </div>     
        <div style="margin-top:-25px">   
        <div id="middle">
            <div id="left-column">
            	@yield('left-content')
	            @yield('pagenav')                
                @yield('navlinks')
            </div>
            <div id="center-column">
                <div class="top-bar">
                    @yield('action_buttons')
                    <h1>@yield('header_title')</h1>
					@yield('breadcrumbs')
                </div>
                @yield('content')               
            </div>
        </div>
        <div id="footer"><p>Allegheny County, PA iCAD Virtual Platform :: <a href="http://www.firehouseautomation.com" target="_blank">Firehouse Automation, LLC</a></p></div>
        </div>
    </div>
</body>
</html>