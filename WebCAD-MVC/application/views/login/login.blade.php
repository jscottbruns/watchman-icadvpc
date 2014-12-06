@layout('layouts.default')

@section('title')
	WebCAD Login 
@endsection

@section('header_title')
	WebCAD Login
@endsection

@section('left-content')
<h3>WebCAD User Interface</h3>	
	<ul class="nav">
		<div style="padding:5px;margin-top:10px;">
			Please login to access WebCAD for Allegheny County, PA. 
		</div>	
	</ul>
@endsection

@section('content')	
	<div style="padding-top:20px;margin:20px">
	{{ Form::open('login') }}	
	<table>
	@if ( $errors->has() )
		<tr>
			<td></td>
			<td class="err">Please check the indicated fields and try again</td>
		</tr>
	@endif
		<tr>
			<td style="text-align:right;" {{ $errors->has('username') ? 'class="err"' : '' }}>{{ Form::label('username', 'Username: ') }}</td>
			<td>{{ Form::text('username', Input::old('username')) }}</td>
		</tr>
		<tr>
			<td style="text-align:right;" {{ $errors->has('password') ? 'class="err"' : '' }}>{{ Form::label('password', 'Password: ') }}</td>
			<td>{{ Form::text('password') }}</td>
		</tr>
		<tr>
			<td colspan="2"><p>{{ Form::input('image', 'login_button', null, array('src' => 'img/login.gif') ) }}{{ Form::token() }}</p></td>
		</tr>
	</table>
	{{ Form::close() }}
	</div>
@endsection