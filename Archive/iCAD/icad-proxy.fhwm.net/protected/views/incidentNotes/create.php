<?php
$this->breadcrumbs=array(
	'Incident Notes'=>array('index'),
	'Create',
);

$this->menu=array(
	array('label'=>'List IncidentNotes', 'url'=>array('index')),
	array('label'=>'Manage IncidentNotes', 'url'=>array('admin')),
);
?>

<h1>Create IncidentNotes</h1>

<?php echo $this->renderPartial('_form', array('model'=>$model)); ?>