<?php
$this->breadcrumbs=array(
	'Incident Notes'=>array('index'),
	$model->NoteId=>array('view','id'=>$model->NoteId),
	'Update',
);

$this->menu=array(
	array('label'=>'List IncidentNotes', 'url'=>array('index')),
	array('label'=>'Create IncidentNotes', 'url'=>array('create')),
	array('label'=>'View IncidentNotes', 'url'=>array('view', 'id'=>$model->NoteId)),
	array('label'=>'Manage IncidentNotes', 'url'=>array('admin')),
);
?>

<h1>Update IncidentNotes <?php echo $model->NoteId; ?></h1>

<?php echo $this->renderPartial('_form', array('model'=>$model)); ?>