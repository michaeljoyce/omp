<?php

/**
 * @file classes/controllers/reviewerSelector/ReviewerSelectorHandler.inc.php
 *
 * Copyright (c) 2000-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class GridHandler
 * @ingroup controllers_grid
 *
 * @brief Handler for a reviewer selector element that lets editors choose reviewers for a monograph.
 */

// import the base Handler
import('classes.handler.Handler');

// import JSON class for use with all AJAX requests
import('lib.pkp.classes.core.JSON');

class ReviewerSelectorHandler extends Handler {

	/**
	 * Constructor.
	 */
	function ReviewerSelectorHandler() {
		parent::Handler();
		$this->addRoleAssignment(ROLE_ID_AUTHOR,
				$authorOperations = array());
		$this->addRoleAssignment(ROLE_ID_PRESS_ASSISTANT,
				$pressAssistantOperations = array_merge($authorOperations, array()));
		$this->addRoleAssignment(array(ROLE_ID_SERIES_EDITOR, ROLE_ID_PRESS_MANAGER),
				array_merge($pressAssistantOperations,
				array('fetchForm')));
	}

	//
	// Implement template methods from PKPHandler.
	//
	/**
	 * @see PKPHandler::authorize()
	 */
	function authorize(&$request, &$args, $roleAssignments) {
		import('classes.security.authorization.OmpWorkflowStagePolicy');
		$this->addPolicy(new OmpWorkflowStagePolicy($request, $args, $roleAssignments));
		return parent::authorize($request, $args, $roleAssignments);
	}


	/**
	 * Display the reviewer filtering form
	 */
	function fetchForm(&$args, &$request) {
		$monographId = $request->getUserVar('monographId');
		$interestDao =& DAORegistry::getDAO('InterestDAO');

		$templateMgr =& TemplateManager::getManager();
		$templateMgr->assign('monographId', $monographId);
		$templateMgr->assign('existingInterests', implode(",", $interestDao->getAllUniqueInterests()));

		Locale::requireComponents(array(LOCALE_COMPONENT_PKP_MANAGER));

		// Form handling
		import('controllers.reviewerSelector.form.ReviewerSelectorForm');
		$reviewerSelectorForm = new ReviewerSelectorForm($monographId);
		$reviewerSelectorForm->initData();

		$json = new JSON('true', $reviewerSelectorForm->fetch($request));
		return $json->getString();
	}


}
?>