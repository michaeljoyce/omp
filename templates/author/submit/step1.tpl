{**
 * step1.tpl
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Step 1 of author monograph submission.
 *
 * $Id$
 *}
{assign var="pageTitle" value="author.submit.step1"}
{include file="author/submit/submitStepHeader.tpl"}

<form name="submit" method="post" action="{url op="saveSubmit" path=$submitStepAlias}">
{if $monographId}<input type="hidden" name="monographId" value="{$monographId|escape}" />{/if}
<input type="hidden" name="submissionChecklist" value="1" />

{include file="common/formErrors.tpl"}


<!-- Submission Type -->
<h3>{translate key="author.submission.workType"}</h3>

{fbvFormArea id="submissionType"}
	{fbvFormSection layout=$fbvStyles.layout.ONE_COLUMN}
	<p>{translate key="author.submission.workType.description"}</p>
	{fbvElement type="radio" name="isEditedVolume" id="isEditedVolume-0" value="0" checked=$isEditedVolume label="author.submission.workType.editedVolume"}
	{if $isEditedVolume}{assign var=notIsEditedVolume value=0}{else}{assign var=notIsEditedVolume value=1}{/if}
	{fbvElement type="radio" name="isEditedVolume" id="isEditedVolume-1" value="0" checked=$notIsEditedVolume label="author.submission.workType.authoredWork"}
	{/fbvFormSection}
{/fbvFormArea}
<div class="separator"></div>

{if count($supportedSubmissionLocaleNames) == 1}
	{* There is only one supported submission locale; choose it invisibly *}
	{foreach from=$supportedSubmissionLocaleNames item=localeName key=locale}
		<input type="hidden" name="locale" value="{$locale|escape}" />
	{/foreach}
{else}
	{* There are several submission locales available; allow choice *}
	<h3>{translate key="author.submit.submissionLocale"}</h3>
	<p>{translate key="author.submit.submissionLocaleDescription"}</p>
 
	{fbvFormArea id="submissionLocale"}
		{fbvFormSection}
			{fbvElement type="select" id="locale" from=$supportedSubmissionLocaleNames selected=$locale translate=false}
		{/fbvFormSection}
	{/fbvFormArea}

	<div class="separator"></div>
{/if}{* count($supportedSubmissionLocaleNames) == 1 *}

<!-- Submission Placement -->
<h3>{translate key="author.submit.placement"}</h3>

{fbvFormArea id="placement"}
	{fbvFormSection}
		{fbvElement type="select" id="seriesId" from=$seriesOptions selected=$seriesId translate=false}
	{/fbvFormSection}
{/fbvFormArea}


<!-- Submission checklist -->
{if $currentPress->getLocalizedSetting('submissionChecklist')}
<script type="text/javascript">
	{literal}
        $(function(){
        $("#messageBox").hide();
		$("form[name=submit]").validate({
			showErrors: function(errorMap, errorList) {
				$("#messageBox").html("<ul><li class='error'>{/literal}{translate key='author.submit.checklistErrors.begin'}{literal} "
											+ this.numberOfInvalids()
		     								+ " {/literal}{translate key='author.submit.checklistErrors.end'}{literal}</li></ul>");
				if (this.numberOfInvalids() == 0) {
					$("#messageBox").hide('slow');
				}
			}

		});
	});
	{/literal}
</script>
<h3>{translate key="author.submit.submissionChecklist"}</h3>

	<div id="messageBox"></div>

	{fbvFormArea id="checklist"}
	{fbvFormSection layout=$fbvStyles.layout.ONE_COLUMN}
	<p>{translate key="author.submit.submissionChecklistDescription"}</p>
	{foreach name=checklist from=$currentPress->getLocalizedSetting('submissionChecklist') key=checklistId item=checklistItem}
		{if $checklistItem.content}
			{fbvElement type="checkbox" id="checklist-"|concat:$smarty.foreach.checklist.iteration required=true value=$checklistId|escape label=$checklistItem.content translate=false checked=$monographId}
		{/if}
	{/foreach}
	{/fbvFormSection}
	{/fbvFormArea}
	<div class="separator"></div>
{/if}


<!-- Cover Note To Editor-->
<h3>{translate key="author.submit.coverNote"}</h3>

{fbvFormArea id="commentsToEditorContainer"}
	{fbvFormSection for="commentsToEditor"}
	{fbvElement type="textarea" name="commentsToEditor" id="commentsToEditor" size=$fbvStyles.size.MEDIUM measure=$fbvStyles.measure.3OF4}
	{/fbvFormSection}
{/fbvFormArea}


<!-- Privacy Statement -->
<h3>{translate key="author.submit.privacyStatement"}</h3>

{fbvFormArea id="privacyStatement"}
	{fbvFormSection for="privacyStatement"}
	{fbvElement type="textarea" name="privacyStatement" id="privacyStatement" disabled=true value=$currentPress->getLocalizedSetting('privacyStatement') size=$fbvStyles.size.MEDIUM measure=$fbvStyles.measure.3OF4}
	{/fbvFormSection}
{/fbvFormArea}

<div class="separator"></div>


<!-- Continue -->

<p><input type="submit" value="{translate key="common.saveAndContinue"}" class="button defaultButton" /> <input type="button" value="{translate key="common.cancel"}" class="button" onclick="{if $monographId}confirmAction('{url page="author"}', '{translate|escape:"jsparam" key="author.submit.cancelSubmission"}'){else}document.location.href='{url page="author" escape=false}'{/if}" /></p>

<p><span class="formRequired">{translate key="common.requiredField"}</span></p>

</form>
</div>
{include file="common/footer.tpl"}
