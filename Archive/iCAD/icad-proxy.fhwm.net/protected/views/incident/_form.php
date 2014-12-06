<div class="form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'id'=>'incident-form',
	'enableAjaxValidation'=>false,
)); ?>

	<p class="note">Fields with <span class="required">*</span> are required.</p>

	<?php echo $form->errorSummary($model); ?>

	<div class="row">
		<?php echo $form->labelEx($model,'IncidentNo'); ?>
		<?php echo $form->textField($model,'IncidentNo',array('size'=>16,'maxlength'=>16)); ?>
		<?php echo $form->error($model,'IncidentNo'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Timestamp'); ?>
		<?php echo $form->textField($model,'Timestamp'); ?>
		<?php echo $form->error($model,'Timestamp'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'EntryTime'); ?>
		<?php echo $form->textField($model,'EntryTime'); ?>
		<?php echo $form->error($model,'EntryTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'OpenTime'); ?>
		<?php echo $form->textField($model,'OpenTime'); ?>
		<?php echo $form->error($model,'OpenTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'CloseTime'); ?>
		<?php echo $form->textField($model,'CloseTime'); ?>
		<?php echo $form->error($model,'CloseTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Status'); ?>
		<?php echo $form->textField($model,'Status',array('size'=>16,'maxlength'=>16)); ?>
		<?php echo $form->error($model,'Status'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'EventNo'); ?>
		<?php echo $form->textField($model,'EventNo',array('size'=>16,'maxlength'=>16)); ?>
		<?php echo $form->error($model,'EventNo'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'CallType'); ?>
		<?php echo $form->textField($model,'CallType',array('size'=>24,'maxlength'=>24)); ?>
		<?php echo $form->error($model,'CallType'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Nature'); ?>
		<?php echo $form->textField($model,'Nature',array('size'=>60,'maxlength'=>80)); ?>
		<?php echo $form->error($model,'Nature'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'BoxArea'); ?>
		<?php echo $form->textField($model,'BoxArea',array('size'=>6,'maxlength'=>6)); ?>
		<?php echo $form->error($model,'BoxArea'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'StationGrid'); ?>
		<?php echo $form->textField($model,'StationGrid',array('size'=>12,'maxlength'=>12)); ?>
		<?php echo $form->error($model,'StationGrid'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Location'); ?>
		<?php echo $form->textField($model,'Location',array('size'=>60,'maxlength'=>255)); ?>
		<?php echo $form->error($model,'Location'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'LocationNote'); ?>
		<?php echo $form->textField($model,'LocationNote',array('size'=>60,'maxlength'=>255)); ?>
		<?php echo $form->error($model,'LocationNote'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'CrossSt1'); ?>
		<?php echo $form->textField($model,'CrossSt1',array('size'=>60,'maxlength'=>255)); ?>
		<?php echo $form->error($model,'CrossSt1'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'CrossSt2'); ?>
		<?php echo $form->textField($model,'CrossSt2',array('size'=>60,'maxlength'=>255)); ?>
		<?php echo $form->error($model,'CrossSt2'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Priority'); ?>
		<?php echo $form->textField($model,'Priority',array('size'=>3,'maxlength'=>3)); ?>
		<?php echo $form->error($model,'Priority'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'RadioTac'); ?>
		<?php echo $form->textField($model,'RadioTac',array('size'=>6,'maxlength'=>6)); ?>
		<?php echo $form->error($model,'RadioTac'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Map'); ?>
		<?php echo $form->textField($model,'Map',array('size'=>12,'maxlength'=>12)); ?>
		<?php echo $form->error($model,'Map'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton($model->isNewRecord ? 'Create' : 'Save'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- form -->