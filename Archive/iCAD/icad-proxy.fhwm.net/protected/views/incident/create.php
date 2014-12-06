<?php
$this->breadcrumbs=array(
	'Incidents'=>array('index'),
	'Create',
);

$this->menu=array(
	array('label'=>'List Incident', 'url'=>array('index')),
	array('label'=>'Manage Incident', 'url'=>array('admin')),
);
?>

<h1>Create Incident</h1>

<?php echo $this->renderPartial('_form', array('model'=>$model)); ?>