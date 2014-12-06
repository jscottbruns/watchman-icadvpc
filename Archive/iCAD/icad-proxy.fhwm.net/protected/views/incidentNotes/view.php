<?php
$this->breadcrumbs=array(
	'Incident Notes'=>array('index'),
	$model->NoteId,
);

$this->menu=array(
	array('label'=>'List IncidentNotes', 'url'=>array('index')),
	array('label'=>'Create IncidentNotes', 'url'=>array('create')),
	array('label'=>'Update IncidentNotes', 'url'=>array('update', 'id'=>$model->NoteId)),
	array('label'=>'Delete IncidentNotes', 'url'=>'#', 'linkOptions'=>array('submit'=>array('delete','id'=>$model->NoteId),'confirm'=>'Are you sure you want to delete this item?')),
	array('label'=>'Manage IncidentNotes', 'url'=>array('admin')),
);
?>

<h1>View IncidentNotes #<?php echo $model->NoteId; ?></h1>

<?php $this->widget('zii.widgets.CDetailView', array(
	'data'=>$model,
	'attributes'=>array(
		'NoteId',
		'Timestamp',
		'IncidentNo',
		'NoteTime',
		'Note',
	),
)); ?>
