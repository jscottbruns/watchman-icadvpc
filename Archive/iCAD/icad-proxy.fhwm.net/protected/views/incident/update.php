<?php
$this->breadcrumbs=array(
	'Incidents'=>array('index'),
	$model->IncidentNo=>array('view','id'=>$model->IncidentNo),
	'Update',
);

$this->menu=array(
	array('label'=>'List Incident', 'url'=>array('index')),
	array('label'=>'Create Incident', 'url'=>array('create')),
	array('label'=>'View Incident', 'url'=>array('view', 'id'=>$model->IncidentNo)),
	array('label'=>'Manage Incident', 'url'=>array('admin')),
);
?>

<h1>Update Incident <?php echo $model->IncidentNo; ?></h1>

<?php echo $this->renderPartial('_form', array('model'=>$model)); ?>