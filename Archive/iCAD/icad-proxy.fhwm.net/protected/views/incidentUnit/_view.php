<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('UnitId')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->UnitId), array('view', 'id'=>$data->UnitId)); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Timestamp')); ?>:</b>
	<?php echo CHtml::encode($data->Timestamp); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Unit')); ?>:</b>
	<?php echo CHtml::encode($data->Unit); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('IncidentNo')); ?>:</b>
	<?php echo CHtml::encode($data->IncidentNo); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('AlertTrans')); ?>:</b>
	<?php echo CHtml::encode($data->AlertTrans); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Dispatch')); ?>:</b>
	<?php echo CHtml::encode($data->Dispatch); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Enroute')); ?>:</b>
	<?php echo CHtml::encode($data->Enroute); ?>
	<br />

	<?php /*
	<b><?php echo CHtml::encode($data->getAttributeLabel('OnScene')); ?>:</b>
	<?php echo CHtml::encode($data->OnScene); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('InService')); ?>:</b>
	<?php echo CHtml::encode($data->InService); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Status')); ?>:</b>
	<?php echo CHtml::encode($data->Status); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Closed')); ?>:</b>
	<?php echo CHtml::encode($data->Closed); ?>
	<br />

	*/ ?>

</div>