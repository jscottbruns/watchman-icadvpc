<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('NoteId')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->NoteId), array('view', 'id'=>$data->NoteId)); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Timestamp')); ?>:</b>
	<?php echo CHtml::encode($data->Timestamp); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('IncidentNo')); ?>:</b>
	<?php echo CHtml::encode($data->IncidentNo); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('NoteTime')); ?>:</b>
	<?php echo CHtml::encode($data->NoteTime); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Note')); ?>:</b>
	<?php echo CHtml::encode($data->Note); ?>
	<br />


</div>