<div class="wide form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'action'=>Yii::app()->createUrl($this->route),
	'method'=>'get',
)); ?>

	<div class="row">
		<?php echo $form->label($model,'UnitId'); ?>
		<?php echo $form->textField($model,'UnitId',array('size'=>20,'maxlength'=>20)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Timestamp'); ?>
		<?php echo $form->textField($model,'Timestamp'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Unit'); ?>
		<?php echo $form->textField($model,'Unit',array('size'=>12,'maxlength'=>12)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'IncidentNo'); ?>
		<?php echo $form->textField($model,'IncidentNo',array('size'=>16,'maxlength'=>16)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'AlertTrans'); ?>
		<?php echo $form->textField($model,'AlertTrans'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Dispatch'); ?>
		<?php echo $form->textField($model,'Dispatch'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Enroute'); ?>
		<?php echo $form->textField($model,'Enroute'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'OnScene'); ?>
		<?php echo $form->textField($model,'OnScene'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'InService'); ?>
		<?php echo $form->textField($model,'InService'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Status'); ?>
		<?php echo $form->textField($model,'Status'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Closed'); ?>
		<?php echo $form->textField($model,'Closed'); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton('Search'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- search-form -->