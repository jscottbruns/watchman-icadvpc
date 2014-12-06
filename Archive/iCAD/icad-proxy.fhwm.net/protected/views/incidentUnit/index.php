<?php
$this->breadcrumbs=array(
	'Incident Units',
);

$this->menu=array(
	array('label'=>'Create IncidentUnit', 'url'=>array('create')),
	array('label'=>'Manage IncidentUnit', 'url'=>array('admin')),
);
?>

<h1>Incident Units</h1>

<?php $this->widget('zii.widgets.CListView', array(
	'dataProvider'=>$dataProvider,
	'itemView'=>'_view',
)); ?>
