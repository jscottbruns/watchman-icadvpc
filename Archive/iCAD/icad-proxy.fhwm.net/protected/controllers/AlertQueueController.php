<?php
require_once('includes/xml.class.php');
class AlertQueueController extends Controller
{

	/**
	 * This is the action to handle external exceptions.
	 */
	public function actionError()
	{
	    if($error=Yii::app()->errorHandler->error)
	    {
	    	if(Yii::app()->request->isAjaxRequest)
	    		echo $error['message'];
	    	else
	        	$this->render('error', $error);
	    }
	}

	public function actionIndex()
	{
		if ( isset($_POST['OpenTime']) )
		{
			$PostTime = $_POST['OpenTime'];
			$IncDate = date('Y-m-d');
			$sql = "OpenTime > '$PostTime'";
		}
		else
		{
			$IncDate = date('Y-m-d');
			$sql = "Timestamp > DATE_FORMAT( DATE_SUB(NOW(), INTERVAL 10 MINUTE), '%Y-%m-%d %T')";
		}

		$dataProvider=new CActiveDataProvider(
			'Incident',
			array(
				'criteria'	=> array(
					'condition'	=> "$sql OR Timestamp > 0",
					'order'		=> 'OpenTime DESC'
				)
			)
		);

		$xml = new XML_Builder('text/xml', 'UTF-8');
		$xml->add_group('AlertQueue');

		$xml->add_tag('IncidentDate', $IncDate);
		$xml->add_tag('PollingTimestamp', time());
		$xml->add_tag('Total', $dataProvider->itemCount);

		if ( $dataProvider->itemCount > 0 )
		{
			$xml->add_group('IncidentListing');

			for ( $i = 0; $i < $dataProvider->itemCount; $i++ )
			{
				$location = $dataProvider->data[$i]->Location;
				if ( $location && $dataProvider->data[$i]->CrossSt1 && $dataProvider->data[$i]->CrossSt2 )
					$location .= " (" . $dataProvider->data[$i]->CrossSt1 . " & " . $dataProvider->data[$i]->CrossSt2 . ")";

				$xml->add_tag(
					'Incident',
					'',
					array(
						'Timestamp'		=> $dataProvider->data[$i]->Timestamp,
						'IncidentNo'	=> $dataProvider->data[$i]->IncidentNo,
						'CallNo'		=> $dataProvider->data[$i]->EventNo,
						'Status'		=> $dataProvider->data[$i]->Status,
						'OpenTime'		=> $dataProvider->data[$i]->OpenTime,
						'CloseTime'		=> $dataProvider->data[$i]->CloseTime,
						'Pri'			=> $dataProvider->data[$i]->Priority,
						'CallType'		=> $dataProvider->data[$i]->CallType,
						'Nature'		=> $dataProvider->data[$i]->Nature,
						'BoxArea'		=> $dataProvider->data[$i]->BoxArea,
						'Location'		=> htmlspecialchars_uni( $location )
					)
				);
			}

			$xml->close_group();
		}
		#echo $dataProvider->data[0]->IncidentNo;exit;
		$xml->close_group();

		$xml->print_xml();
	}
}