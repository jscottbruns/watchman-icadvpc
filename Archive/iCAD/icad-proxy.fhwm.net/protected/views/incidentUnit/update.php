<?php
$this->breadcrumbs=array(
	'Incident Units'=>array('index'),
	$model->UnitId=>array('view','id'=>$model->UnitId),
	'Update',
);

$this->menu=array(
	array('label'=>'List IncidentUnit', 'url'=>array('index')),
	array('label'=>'Create IncidentUnit', 'url'=>array('create')),
	array('label'=>'View IncidentUnit', 'url'=>array('view', 'id'=>$model->UnitId)),
	array('label'=>'Manage IncidentUnit', 'url'=>array('admin')),
);
?>

<h1>Update IncidentUnit <?php echo $model->UnitId; ?></h1>

<?php echo $this->renderPartial('_form', array('model'=>$model)); ?>