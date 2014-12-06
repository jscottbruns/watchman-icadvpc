<?php
$this->breadcrumbs=array(
	'Incident Units'=>array('index'),
	$model->UnitId,
);

$this->menu=array(
	array('label'=>'List IncidentUnit', 'url'=>array('index')),
	array('label'=>'Create IncidentUnit', 'url'=>array('create')),
	array('label'=>'Update IncidentUnit', 'url'=>array('update', 'id'=>$model->UnitId)),
	array('label'=>'Delete IncidentUnit', 'url'=>'#', 'linkOptions'=>array('submit'=>array('delete','id'=>$model->UnitId),'confirm'=>'Are you sure you want to delete this item?')),
	array('label'=>'Manage IncidentUnit', 'url'=>array('admin')),
);
?>

<h1>View IncidentUnit #<?php echo $model->UnitId; ?></h1>

<?php $this->widget('zii.widgets.CDetailView', array(
	'data'=>$model,
	'attributes'=>array(
		'UnitId',
		'Timestamp',
		'Unit',
		'IncidentNo',
		'AlertTrans',
		'Dispatch',
		'Enroute',
		'OnScene',
		'InService',
		'Status',
		'Closed',
	),
)); ?>
