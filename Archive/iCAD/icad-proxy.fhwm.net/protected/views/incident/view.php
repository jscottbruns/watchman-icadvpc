<?php
$this->breadcrumbs=array(
	'Incidents'=>array('index'),
	$model->IncidentNo,
);

$this->menu=array(
	array('label'=>'List Incident', 'url'=>array('index')),
	array('label'=>'Create Incident', 'url'=>array('create')),
	array('label'=>'Update Incident', 'url'=>array('update', 'id'=>$model->IncidentNo)),
	array('label'=>'Delete Incident', 'url'=>'#', 'linkOptions'=>array('submit'=>array('delete','id'=>$model->IncidentNo),'confirm'=>'Are you sure you want to delete this item?')),
	array('label'=>'Manage Incident', 'url'=>array('admin')),
);
?>

<h1>View Incident #<?php echo $model->IncidentNo; ?></h1>

<?php $this->widget('zii.widgets.CDetailView', array(
	'data'=>$model,
	'attributes'=>array(
		'IncidentNo',
		'Timestamp',
		'EntryTime',
		'OpenTime',
		'CloseTime',
		'Status',
		'EventNo',
		'CallType',
		'Nature',
		'BoxArea',
		'StationGrid',
		'Location',
		'LocationNote',
		'CrossSt1',
		'CrossSt2',
		'Priority',
		'RadioTac',
		'Map',
	),
)); ?>
