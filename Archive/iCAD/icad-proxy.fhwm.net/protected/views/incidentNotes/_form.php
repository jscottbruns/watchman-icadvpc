<div class="form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'id'=>'incident-notes-form',
	'enableAjaxValidation'=>false,
)); ?>

	<p class="note">Fields with <span class="required">*</span> are required.</p>

	<?php echo $form->errorSummary($model); ?>

	<div class="row">
		<?php echo $form->labelEx($model,'NoteId'); ?>
		<?php echo $form->textField($model,'NoteId',array('size'=>20,'maxlength'=>20)); ?>
		<?php echo $form->error($model,'NoteId'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Timestamp'); ?>
		<?php echo $form->textField($model,'Timestamp'); ?>
		<?php echo $form->error($model,'Timestamp'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'IncidentNo'); ?>
		<?php echo $form->textField($model,'IncidentNo',array('size'=>16,'maxlength'=>16)); ?>
		<?php echo $form->error($model,'IncidentNo'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'NoteTime'); ?>
		<?php echo $form->textField($model,'NoteTime'); ?>
		<?php echo $form->error($model,'NoteTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Note'); ?>
		<?php echo $form->textField($model,'Note',array('size'=>60,'maxlength'=>255)); ?>
		<?php echo $form->error($model,'Note'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton($model->isNewRecord ? 'Create' : 'Save'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- form -->