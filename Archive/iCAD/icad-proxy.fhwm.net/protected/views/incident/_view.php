<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('IncidentNo')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->IncidentNo), array('view', 'id'=>$data->IncidentNo)); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Timestamp')); ?>:</b>
	<?php echo CHtml::encode($data->Timestamp); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('EntryTime')); ?>:</b>
	<?php echo CHtml::encode($data->EntryTime); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('OpenTime')); ?>:</b>
	<?php echo CHtml::encode($data->OpenTime); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('CloseTime')); ?>:</b>
	<?php echo CHtml::encode($data->CloseTime); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Status')); ?>:</b>
	<?php echo CHtml::encode($data->Status); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('EventNo')); ?>:</b>
	<?php echo CHtml::encode($data->EventNo); ?>
	<br />

	<?php /*
	<b><?php echo CHtml::encode($data->getAttributeLabel('CallType')); ?>:</b>
	<?php echo CHtml::encode($data->CallType); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Nature')); ?>:</b>
	<?php echo CHtml::encode($data->Nature); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('BoxArea')); ?>:</b>
	<?php echo CHtml::encode($data->BoxArea); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('StationGrid')); ?>:</b>
	<?php echo CHtml::encode($data->StationGrid); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Location')); ?>:</b>
	<?php echo CHtml::encode($data->Location); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('LocationNote')); ?>:</b>
	<?php echo CHtml::encode($data->LocationNote); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('CrossSt1')); ?>:</b>
	<?php echo CHtml::encode($data->CrossSt1); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('CrossSt2')); ?>:</b>
	<?php echo CHtml::encode($data->CrossSt2); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Priority')); ?>:</b>
	<?php echo CHtml::encode($data->Priority); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('RadioTac')); ?>:</b>
	<?php echo CHtml::encode($data->RadioTac); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('Map')); ?>:</b>
	<?php echo CHtml::encode($data->Map); ?>
	<br />

	*/ ?>

</div>