<div class="wide form">

<?php $form=$this->beginWidget('CActiveForm', array(
	'action'=>Yii::app()->createUrl($this->route),
	'method'=>'get',
)); ?>

	<div class="row">
		<?php echo $form->label($model,'NoteId'); ?>
		<?php echo $form->textField($model,'NoteId',array('size'=>20,'maxlength'=>20)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Timestamp'); ?>
		<?php echo $form->textField($model,'Timestamp'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'IncidentNo'); ?>
		<?php echo $form->textField($model,'IncidentNo',array('size'=>16,'maxlength'=>16)); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'NoteTime'); ?>
		<?php echo $form->textField($model,'NoteTime'); ?>
	</div>

	<div class="row">
		<?php echo $form->label($model,'Note'); ?>
		<?php echo $form->textField($model,'Note',array('size'=>60,'maxlength'=>255)); ?>
	</div>

	<div class="row buttons">
		<?php echo CHtml::submitButton('Search'); ?>
	</div>

<?php $this->endWidget(); ?>

</div><!-- search-form -->