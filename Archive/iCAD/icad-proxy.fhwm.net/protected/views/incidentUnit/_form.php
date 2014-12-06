<div class="form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'id'=>'incident-unit-form',
	'enableAjaxValidation'=>false,
)); ?>

	<p class="note">Fields with <span class="required">*</span> are required.</p>

	<?php echo $form->errorSummary($model); ?>

	<div class="row">
		<?php echo $form->labelEx($model,'UnitId'); ?>
		<?php echo $form->textField($model,'UnitId',array('size'=>20,'maxlength'=>20)); ?>
		<?php echo $form->error($model,'UnitId'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Timestamp'); ?>
		<?php echo $form->textField($model,'Timestamp'); ?>
		<?php echo $form->error($model,'Timestamp'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Unit'); ?>
		<?php echo $form->textField($model,'Unit',array('size'=>12,'maxlength'=>12)); ?>
		<?php echo $form->error($model,'Unit'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'IncidentNo'); ?>
		<?php echo $form->textField($model,'IncidentNo',array('size'=>16,'maxlength'=>16)); ?>
		<?php echo $form->error($model,'IncidentNo'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'AlertTrans'); ?>
		<?php echo $form->textField($model,'AlertTrans'); ?>
		<?php echo $form->error($model,'AlertTrans'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Dispatch'); ?>
		<?php echo $form->textField($model,'Dispatch'); ?>
		<?php echo $form->error($model,'Dispatch'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Enroute'); ?>
		<?php echo $form->textField($model,'Enroute'); ?>
		<?php echo $form->error($model,'Enroute'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'OnScene'); ?>
		<?php echo $form->textField($model,'OnScene'); ?>
		<?php echo $form->error($model,'OnScene'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'InService'); ?>
		<?php echo $form->textField($model,'InService'); ?>
		<?php echo $form->error($model,'InService'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Status'); ?>
		<?php echo $form->textField($model,'Status'); ?>
		<?php echo $form->error($model,'Status'); ?>
	</div>

	<div class="row">
		<?php echo $form->labelEx($model,'Closed'); ?>
		<?php echo $form->textField($model,'Closed'); ?>
		<?php echo $form->error($model,'Closed'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton($model->isNewRecord ? 'Create' : 'Save'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- form -->