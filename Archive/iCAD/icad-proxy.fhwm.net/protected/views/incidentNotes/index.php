<?php
$this->breadcrumbs=array(
	'Incident Notes',
);

$this->menu=array(
	array('label'=>'Create IncidentNotes', 'url'=>array('create')),
	array('label'=>'Manage IncidentNotes', 'url'=>array('admin')),
);
?>

<h1>Incident Notes</h1>

<?php $this->widget('zii.widgets.CListView', array(
	'dataProvider'=>$dataProvider,
	'itemView'=>'_view',
)); ?>
