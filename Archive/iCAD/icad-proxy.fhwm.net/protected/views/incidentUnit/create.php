<?php
$this->breadcrumbs=array(
	'Incident Units'=>array('index'),
	'Create',
);

$this->menu=array(
	array('label'=>'List IncidentUnit', 'url'=>array('index')),
	array('label'=>'Manage IncidentUnit', 'url'=>array('admin')),
);
?>

<h1>Create IncidentUnit</h1>

<?php echo $this->renderPartial('_form', array('model'=>$model)); ?>