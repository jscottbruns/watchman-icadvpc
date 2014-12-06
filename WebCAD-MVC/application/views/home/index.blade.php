@layout('layouts.default')

@section('pagenav')
	<ul class="nav">
    	<h3>Menu</h3>
		<li><a href="#">Menu Option 1</a></li>
		<li><a href="#">Menu Option 2</a></li>
		<li><a href="#">Menu Option 3</a></li>
		<li><a href="#">Menu Option 4</a></li>
	</ul>
@endsection

@section('navlinks')
	<a href="#" class="link">Link here</a>
@endsection

@section('action_buttons')
	<a href="#" class="button">ADD NEW </a>
@endsection

@section('header_title')
		
@endsection

@section('breadcrumbs')
	<div class="breadcrumbs"><a href="#">Homepage</a> / <a href="#">Contents</a></div>
@endsection

@section('title')
	Watchman WebCAD
@endsection