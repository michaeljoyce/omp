{**
 * fileForm.tpl
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Attachment Files grid form
 *
 * $Id$
 *}
<!--  Need a random ID to give to modal elements so that they are unique in the DOM (can not use
		fileId like elsewhere in the modal, because there may not be an associated file yet-->
{assign var='randomId' value=1|rand:99999}
{modal_title id="#uploadForm-$randomId" key='grid.reviewAttachments.add' iconClass="fileManagement" canClose=1}

<script type="text/javascript">
	{literal}
	$(function() {
		$('.button').button();
		$('#uploadForm-{/literal}{$randomId}{literal}').parent().dialog('option', 'buttons', null);  // Clear out default modal buttons
		$(".ui-dialog-titlebar-close").remove();  // Hide 'X' close button in dialog
		// Handle upload form
	    $('#uploadForm-{/literal}{$randomId}{literal}').ajaxForm({
	        target: '#uploadOutput-{/literal}{$randomId}{literal}',  // target identifies the element(s) to update with the server response
			iframe: true,
			dataType: 'json',
			beforeSubmit: function() {
				$('#loading').show();
				$('#loadingText-{/literal}{$randomId}{literal}').fadeIn('slow');
	    	},
	        // success identifies the function to invoke when the server response
	        // has been received; here we show a success message and enable the continue button
	        success: function(returnString) {
    			$('#loading').hide();
	    		if (returnString.status == true) {
	    			$('#attachment-{/literal}{$randomId}{literal}').attr("disabled", "disabled");
	    			$('#attachmentFileSubmit-{/literal}{$randomId}{literal}').button("option", "disabled", true);
	    			$("#continueButton-{/literal}{$randomId}{literal}").button("option", "disabled", false);
		    		$('#deleteUrl-{/literal}{$randomId}{literal}').val(returnString.deleteUrl);
		    		$('#saveUrl-{/literal}{$randomId}{literal}').val(returnString.saveUrl);
	    		}
	    		$('#loadingText-{/literal}{$randomId}{literal}').text(returnString.content);  // Set to error or success message
	        }
	    });

		// Set cancel/continue button behaviors
		$("#continueButton-{/literal}{$randomId}{literal}").click(function() {
			saveAndUpdate($('#saveUrl-{/literal}{$randomId}{literal}').val(),
    	    		'append',
    	    		'component-{/literal}{$gridId}{literal}-table',
    	    		'#uploadForm-{/literal}{$randomId}{literal}'
			);
		});

		$("#cancelButton-{/literal}{$randomId}{literal}").click(function() {
			// User has uploaded a file then pressed cancel--delete the file
			newFile = $('#newFile-{/literal}{$randomId}{literal}').val();
			deleteUrl = $('#deleteUrl-{/literal}{$randomId}{literal}').val();
			if(deleteUrl != undefined && newFile != undefined && deleteUrl != "" && newFile != "") {
				$.post(deleteUrl);
			}

			$('#uploadForm-{/literal}{$randomId}{literal}').parent().dialog('close');
		});

		$("#okButton-{/literal}{$randomId}{literal}").click(function() {
			// User is looking at an existing file, just close when okay is clicked
			$('#uploadForm-{/literal}{$randomId}{literal}').parent().dialog('close');
		});
	});
	{/literal}
</script>


<form name="uploadForm" id="uploadForm-{$randomId}" action="{url router=$smarty.const.ROUTE_COMPONENT op="saveFile" monographId=$monographId reviewId=$reviewId}" method="post">
	<!-- Max file size of 5 MB -->
	<input type="hidden" name="MAX_FILE_SIZE" value="5242880" />
	{fbvFormArea id="file"}
		{if !$attachmentFile}
			{fbvFormSection title="common.file"}
				<input type="file" id="attachment-{$randomId}" name="attachment" />
				<input type="submit" name="attachmentFileSubmit-{$randomId}" value="{translate key="common.upload"}" class="button uploadFile" />
			{/fbvFormSection}
		{else}
			{fbvFormSection title="common.file"}
				{include file="controllers/grid/files/reviewAttachments/form/fileInfo.tpl"}
			{/fbvFormSection}
		{/if}
	{/fbvFormArea}
	<div id="uploadOutput-{$randomId}">
		<div id='loading' class='throbber' style="margin: 0px;"></div>
		<ul><li id='loadingText-{$randomId}' style='display:none;'>{translate key='submission.loadMessage'}</li></ul>
	</div>
	{init_button_bar id="#uploadForm-$randomId" cancelId="#cancelButton-$randomId" submitId="#continueButton-$randomId"}
	{fbvFormArea id="buttons"}
	    {fbvFormSection}
	    	{if !$rowId}
	       		{fbvLink id="cancelButton-$randomId" label="common.cancel"}
	       		{fbvButton id="continueButton-$randomId" label="common.saveAndClose" disabled="disabled" align=$fbvStyles.align.RIGHT}
	       	{else}
	        	{fbvButton id="okButton-$randomId" label="common.saveAndClose" align=$fbvStyles.align.RIGHT}
	        {/if}
	    {/fbvFormSection}
	{/fbvFormArea}
</form>

{if $gridId}
<input type="hidden" name="gridId" value="{$gridId|escape}" />
{/if}
<input type="hidden" id="deleteUrl-{$randomId}" value="" />
<input type="hidden" id="saveUrl-{$randomId}" value="" />
<input type="hidden" id="newFile-{$randomId}" value="{$newFile}" />

