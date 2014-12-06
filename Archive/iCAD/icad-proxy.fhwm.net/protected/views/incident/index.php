<?php
$this->breadcrumbs=array(
	'Recent Incidents',
);

#$this->menu=array(
#	array('label'=>'Create Incident'),
#	array('label'=>'Manage Incident' ),
#);
?>

<h3 style="margin-bottom:0;">Recent Incident Listing</h3>

<?php $this->widget('zii.widgets.grid.CGridView', array(
	'dataProvider'=>$dataProvider,
	'columns'	=> array(
		array(
			'name'	=> 'EventNo',
			'htmlOptions'	=> array('style'=>'text-align: left'),
		),
		'IncidentNo',
		'OpenTime',
		'CloseTime',
		'CallType',
		'Nature',
		'BoxArea'
	)
)); ?>
