{**
 * submissionContributorForm.tpl
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Submission Contributor grid form
 *
 *}
<form name="editSubmissionContributorForm" id="editSubmissionContributor" method="post" action="{url op="updateSubmissionContributor" submissionContributorId=$authorId}">
{include file="common/formErrors.tpl"}

{fbvFormArea id="profile"}
	{fbvFormSection title="user.name" layout=$fbvStyles.layout.THREE_COLUMN}
		{fbvElement type="text" label="user.firstName" id="firstName" value=$firstName|escape maxlength="40" size=$fbvStyles.size.MEDIUM}
		{fbvElement type="text" label="user.middleName" id="middleName" value=$middleName|escape maxlength="40" size=$fbvStyles.size.MEDIUM}
		{fbvElement type="text" label="user.lastName" id="lastName" value=$lastName|escape maxlength="40" size=$fbvStyles.size.MEDIUM}
	{/fbvFormSection}
	{fbvFormSection title="about.contact" layout=$fbvStyles.layout.TWO_COLUMN}
		{fbvElement type="text" label="user.email" id="email" value=$email|escape maxlength="90" size=$fbvStyles.size.MEDIUM}
		{fbvElement type="text" label="user.url" id="url" value=$url|escape maxlength="90" size=$fbvStyles.size.MEDIUM}
	{/fbvFormSection}
	{fbvFormSection title="common.other" layout=$fbvStyles.layout.TWO_COLUMN}
		{fbvElement type="text" label="user.affiliation" id="affiliation" value=$affiliation|escape maxlength="40" size=$fbvStyles.size.MEDIUM}
		{fbvElement type="select" label="common.country" id="country" from=$countries selected=$country translate=false}
	{/fbvFormSection}
	<div style="width:550px;">
	{fbvFormSection layout=$fbvStyles.layout.ONE_COLUMN}
		{fbvElement type="textArea" label="user.biography" id="biography" value=$biography|escape size=$fbvStyles.size.MEDIUM}
	{/fbvFormSection}
	</div>
{/fbvFormArea}
{fbvFormArea id="submissionSpecific"}
	{fbvFormSection layout=$fbvStyles.layout.ONE_COLUMN}
		{fbvElement type="select" label="author.users.contributor.role" id="userGroupId" from=$authorUserGroups selected=$authorUserGroups translate=false}
		{fbvElement type="checkbox" label="author.submit.selectPrincipalContact" id="primaryContact" checked=$primaryContact}
	{/fbvFormSection}
{/fbvFormArea}

{if $monographId}
	<input type="hidden" name="monographId" value="{$monographId|escape}" />
{/if}
{if $gridId}
	<input type="hidden" name="gridId" value="{$gridId|escape}" />
{/if}
{if $rowId}
	<input type="hidden" name="rowId" value={$rowId|escape} />
{/if}
</form>