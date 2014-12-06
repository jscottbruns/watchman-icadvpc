<div class="wide form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'action'=>Yii::app()->createUrl($this->route),
	'method'=>'get',
)); ?>

	<div class="row">
		<?php echo $form->label($model,'IncidentNo'); ?>
		<?php echo $form->textField($model,'IncidentNo',array('size'=>16,'maxlength'=>16)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Timestamp'); ?>
		<?php echo $form->textField($model,'Timestamp'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'EntryTime'); ?>
		<?php echo $form->textField($model,'EntryTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'OpenTime'); ?>
		<?php echo $form->textField($model,'OpenTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'CloseTime'); ?>
		<?php echo $form->textField($model,'CloseTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Status'); ?>
		<?php echo $form->textField($model,'Status',array('size'=>16,'maxlength'=>16)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'EventNo'); ?>
		<?php echo $form->textField($model,'EventNo',array('size'=>16,'maxlength'=>16)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'CallType'); ?>
		<?php echo $form->textField($model,'CallType',array('size'=>24,'maxlength'=>24)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Nature'); ?>
		<?php echo $form->textField($model,'Nature',array('size'=>60,'maxlength'=>80)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'BoxArea'); ?>
		<?php echo $form->textField($model,'BoxArea',array('size'=>6,'maxlength'=>6)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'StationGrid'); ?>
		<?php echo $form->textField($model,'StationGrid',array('size'=>12,'maxlength'=>12)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Location'); ?>
		<?php echo $form->textField($model,'Location',array('size'=>60,'maxlength'=>255)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'LocationNote'); ?>
		<?php echo $form->textField($model,'LocationNote',array('size'=>60,'maxlength'=>255)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'CrossSt1'); ?>
		<?php echo $form->textField($model,'CrossSt1',array('size'=>60,'maxlength'=>255)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'CrossSt2'); ?>
		<?php echo $form->textField($model,'CrossSt2',array('size'=>60,'maxlength'=>255)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Priority'); ?>
		<?php echo $form->textField($model,'Priority',array('size'=>3,'maxlength'=>3)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'RadioTac'); ?>
		<?php echo $form->textField($model,'RadioTac',array('size'=>6,'maxlength'=>6)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Map'); ?>
		<?php echo $form->textField($model,'Map',array('size'=>12,'maxlength'=>12)); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton('Search'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- search-form -->