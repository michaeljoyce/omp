{**
 * copyedit.tpl
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Subtemplate defining the copyediting table.
 *
 * $Id$
 *}
<div id="copyedit">
<h3>{translate key="submission.copyediting"}</h3>

{if $useCopyeditors}
<table width="100%" class="data">
	<tr>
		<td width="20%" class="label">{translate key="user.role.copyeditor"}</td>
		{if $submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL')}<td width="20%" class="value">{$copyeditor->getFullName()|escape}</td>{/if}
		<td class="value"><a href="{url op="selectCopyeditor" path=$submission->getId()}" class="action">{translate key="editor.monograph.selectCopyeditor"}</a></td>
	</tr>
</table>
{/if}

<table width="100%" class="info">
	<tr>
		<td width="28%" colspan="2"><a href="{url op="viewMetadata" path=$submission->getId()}" class="action">{translate key="submission.reviewMetadata"}</a></td>
		<td width="18%" class="heading">{translate key="submission.request"}</td>
		<td width="18%" class="heading">{translate key="submission.underway"}</td>
		<td width="18%" class="heading">{translate key="submission.complete"}</td>
		<td width="18%" class="heading">{translate key="submission.acknowledge"}</td>
	</tr>
	<tr>
		<td width="2%">1.</td>
		{assign var="initialCopyeditSignoff" value=$submission->getSignoff('SIGNOFF_COPYEDITING_INITIAL')}
		<td width="26%">{translate key="submission.copyedit.initialCopyedit"}</td>
		<td>
			{if $useCopyeditors}
				{if $submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL') && $initialCopyeditFile}
					{url|assign:"url" op="notifyCopyeditor" monographId=$submission->getId()}
					{if $initialCopyeditSignoff->getDateUnderway()}
						{translate|escape:"javascript"|assign:"confirmText" key="seriesEditor.copyedit.confirmRenotify"}
						{icon name="mail" onclick="return confirm('$confirmText')" url=$url}
					{else}
						{icon name="mail" url=$url}
					{/if}
				{else}
					{icon name="mail" disabled="disable"}
				{/if}
			{else}
				{if !$initialCopyeditSignoff->getDateNotified() && $initialCopyeditFile}
					<a href="{url op="initiateCopyedit" monographId=$submission->getId()}" class="action">{translate key="common.initiate"}</a>
				{/if}
			{/if}
			{$initialCopyeditSignoff->getDateNotified()|date_format:$dateFormatShort|default:""}
		</td>
		<td>
			{if $useCopyeditors}
				{$initialCopyeditSignoff->getDateUnderway()|date_format:$dateFormatShort|default:"&mdash;"}
			{else}
				{translate key="common.notApplicableShort"}
			{/if}
		</td>
		<td>
			{if $initialCopyeditSignoff->getDateCompleted()}
				{$initialCopyeditSignoff->getDateCompleted()|date_format:$dateFormatShort}
			{elseif !$useCopyeditors}
				<a href="{url op="completeCopyedit" monographId=$submission->getId()}" class="action">{translate key="common.complete"}</a>
			{else}
				&mdash;
			{/if}
		</td>
		<td>
			{if $useCopyeditors}
				{if $submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL') &&  $initialCopyeditSignoff->getDateNotified() && !$initialCopyeditSignoff->getDateAcknowledged()}
					{url|assign:"url" op="thankCopyeditor" monographId=$submission->getId()}
					{icon name="mail" url=$url}
				{else}
					{icon name="mail" disabled="disable"}
				{/if}
				{$initialCopyeditSignoff->getDateAcknowledged()|date_format:$dateFormatShort|default:""}
			{else}
				{translate key="common.notApplicableShort"}
			{/if}
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="5">
			{translate key="common.file"}:
			{if $initialCopyeditFile}
				<a href="{url op="downloadFile" path=$submission->getId()|to_array:$initialCopyeditFile->getFileId():$initialCopyeditFile->getRevision()}" class="file">{$initialCopyeditFile->getFileName()|escape}</a>&nbsp;&nbsp;{$initialCopyeditFile->getDateModified()|date_format:$dateFormatShort}
			{else}
				{translate key="submission.copyedit.mustUploadFileForInitialCopyedit"}
			{/if}
		</td>
	</tr>
	<tr>
		<td colspan="6" class="separator">&nbsp;</td>
	</tr>
	<tr>
		<td>2.</td>
		{assign var="authorCopyeditSignoff" value=$submission->getSignoff('SIGNOFF_COPYEDITING_AUTHOR')}
		<td>{translate key="submission.copyedit.editorAuthorReview"}</td>
		<td>
			{if ($submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL') || !$useCopyeditors) && $initialCopyeditSignoff->getDateCompleted()}
				{url|assign:"url" op="notifyAuthorCopyedit monographId=$submission->getId()}
				{if $authorCopyeditSignoff->getDateUnderway()}
					{translate|escape:"javascript"|assign:"confirmText" key="seriesEditor.author.confirmRenotify"}
					{icon name="mail" onclick="return confirm('$confirmText')" url=$url}
				{else}
					{icon name="mail" url=$url}
				{/if}
			{else}
				{icon name="mail" disabled="disable"}
			{/if}
			{$authorCopyeditSignoff->getDateNotified()|date_format:$dateFormatShort|default:""}
		</td>
		<td>
				{$authorCopyeditSignoff->getDateUnderway()|date_format:$dateFormatShort|default:"&mdash;"}
		</td>
		<td>
				{$authorCopyeditSignoff->getDateCompleted()|date_format:$dateFormatShort|default:"&mdash;"}
		</td>
		<td>
			{if ($submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL') || !$useCopyeditors) && $authorCopyeditSignoff && $authorCopyeditSignoff->getDateNotified() && !$authorCopyeditSignoff->getDateAcknowledged()}
				{url|assign:"url" op="thankAuthorCopyedit monographId=$submission->getId()}
				{icon name="mail" url=$url}
			{else}
				{icon name="mail" disabled="disable"}
			{/if}
			{$authorCopyeditSignoff->getDateAcknowledged()|date_format:$dateFormatShort|default:""}
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="5">
			{translate key="common.file"}:
			{if $editorAuthorCopyeditFile}
				<a href="{url op="downloadFile" path=$submission->getId()|to_array:$editorAuthorCopyeditFile->getFileId():$editorAuthorCopyeditFile->getRevision()}" class="file">{$editorAuthorCopyeditFile->getFileName()|escape}</a>&nbsp;&nbsp;{$editorAuthorCopyeditFile->getDateModified()|date_format:$dateFormatShort}
			{/if}
		</td>
	</tr>
	<tr>
		<td colspan="6" class="separator">&nbsp;</td>
	</tr>
	<tr>
		<td>3.</td>
		{assign var="finalCopyeditSignoff" value=$submission->getSignoff('SIGNOFF_COPYEDITING_FINAL')}
		<td>{translate key="submission.copyedit.finalCopyedit"}</td>
		<td>
			{if $useCopyeditors}
				{if $submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL') && $authorCopyeditSignoff->getDateCompleted()}
					{url|assign:"url" op="notifyFinalCopyedit monographId=$submission->getId()}
					{if $finalCopyeditSignoff->getDateUnderway()}
						{translate|escape:"javascript"|assign:"confirmText" key="seriesEditor.copyedit.confirmRenotify"}
						{icon name="mail" onclick="return confirm('$confirmText')" url=$url}
					{else}
						{icon name="mail" url=$url}
					{/if}
				{else}
					{icon name="mail" disabled="disable"}
				{/if}
			{/if}
			{$finalCopyeditSignoff->getDateNotified()|date_format:$dateFormatShort|default:""}
		</td>
		<td>
			{if $useCopyeditors}
				{$finalCopyeditSignoff->getDateUnderway()|date_format:$dateFormatShort|default:"&mdash;"}
			{else}
				{translate key="common.notApplicableShort"}
			{/if}
		</td>
		<td>
			{if $finalCopyeditSignoff->getDateCompleted()}
				{$finalCopyeditSignoff->getDateCompleted()|date_format:$dateFormatShort}
			{elseif !$useCopyeditors}
				<a href="{url op="completeFinalCopyedit" monographId=$submission->getId()}" class="action">{translate key="common.complete"}</a>
			{else}
				&mdash;
			{/if}
		</td>
		<td>
			{if $useCopyeditors}
				{if $submission->getUserIdBySignoffType('SIGNOFF_COPYEDITING_INITIAL') &&  $finalCopyeditSignoff->getDateNotified() && !$finalCopyeditSignoff->getDateAcknowledged()}
					{url|assign:"url" op="thankFinalCopyedit monographId=$submission->getId()}
					{icon name="mail" url=$url}
				{else}
					{icon name="mail" disabled="disable"}
				{/if}
				{$finalCopyeditSignoff->getDateAcknowledged()|date_format:$dateFormatShort|default:""}
			{else}
				{translate key="common.notApplicableShort"}
			{/if}
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="5">
			{translate key="common.file"}:
			{if $finalCopyeditFile}
				<a href="{url op="downloadFile" path=$submission->getId()|to_array:$finalCopyeditFile->getFileId():$finalCopyeditFile->getRevision()}" class="file">{$finalCopyeditFile->getFileName()|escape}</a>&nbsp;&nbsp;{$finalCopyeditFile->getDateModified()|date_format:$dateFormatShort}
			{/if}
		</td>
	</tr>
	<tr>
		<td colspan="6" class="separator">&nbsp;</td>
	</tr>
</table>

{if $authorCopyeditSignoff->getDateCompleted()}
{assign var="canUploadCopyedit" value="3"}
{elseif $initialCopyeditSignoff->getDateCompleted() && !$authorCopyeditSignoff->getDateCompleted()}
{assign var="canUploadCopyedit" value="2"}
{elseif !$initialCopyeditSignoff->getDateCompleted()}
{assign var="canUploadCopyedit" value="1"}
{/if}
<form method="post" action="{url op="uploadCopyeditVersion"}"  enctype="multipart/form-data">
	<input type="hidden" name="monographId" value="{$submission->getId()}" />
	{translate key="submission.uploadFileTo"}
	<input type="radio" name="copyeditStage" id="copyeditStageInitial" value="initial" checked="checked" /><label for="copyeditStageInitial">{translate key="navigation.stepNumber" step=1}</label>,
	<input type="radio" name="copyeditStage" id="copyeditStageAuthor" value="author"{if $canUploadCopyedit == 1} disabled="disabled"{else} checked="checked"{/if} /><label for="copyeditStageAuthor"{if $canUploadCopyedit == 1} class="disabled"{/if}>{translate key="navigation.stepNumber" step=2}</label>, {translate key="common.or"}
	<input type="radio" name="copyeditStage" id="copyeditStageFinal" value="final"{if $canUploadCopyedit != 3} disabled="disabled"{else} checked="checked"{/if} /><label for="copyeditStageFinal"{if $canUploadCopyedit != 3} class="disabled"{/if}>{translate key="navigation.stepNumber" step=3}</label>
	{if !$canUploadCopyedit} {assign var="isDisabled" value="disabled"} {/if}
	{fbvFileInput id="upload" submit="submit" disabled=$isDisabled}
</form>

{translate key="submission.copyedit.copyeditComments"}
{if $submission->getMostRecentCopyeditComment()}
	{assign var="comment" value=$submission->getMostRecentCopyeditComment()}
	<a href="javascript:openComments('{url op="viewCopyeditComments" path=$submission->getId() anchor=$comment->getCommentId()}');" class="icon">{icon name="comment"}</a>{$comment->getDatePosted()|date_format:$dateFormatShort}
{else}
	<a href="javascript:openComments('{url op="viewCopyeditComments" path=$submission->getId()}');" class="icon">{icon name="comment"}</a>{translate key="common.noComments"}
{/if}

{if $currentPress->getLocalizedSetting('copyeditInstructions')}
&nbsp;&nbsp;
<a href="{url op="instructions" path="copy"}" class="action openHelp">{translate key="submission.copyedit.instructions"}</a>
{/if}
</div>
