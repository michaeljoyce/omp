<?php

/**
 * @file controllers/grid/submit/submissionsList/ReviewerSubmissionsListGridHandler.inc.php
 *
 * Copyright (c) 2000-2009 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class ReviewerSubmissionsListGridHandler
 * @ingroup controllers_grid_submissionContributor
 *
 * @brief Handle reviewer submissions lsit grid requests.
 */

// import grid base classes
import('controllers.grid.submit.submissionsList.SubmissionsListGridHandler');

class ReviewerSubmissionsListGridHandler extends SubmissionsListGridHandler {
	/**
	 * Constructor
	 */
	function ReviewerSubmissionsListGridHandler() {
		parent::GridHandler();
		$this->roleId = ROLE_ID_REVIEWER;
	}

	//
	// Getters/Setters
	//
	/**
	 * @see PKPHandler::getRemoteOperations()
	 * @return array
	 */
	function getRemoteOperations() {
		return array_merge(parent::getRemoteOperations(), array('deleteSubmission'));
	}

	//
	// Overridden methods from PKPHandler
	//

	/*
	 * Configure the grid
	 * @param PKPRequest $request
	 */
	function initialize(&$request) {
		parent::initialize($request);

		// Load submission-specific translations
		Locale::requireComponents(array(LOCALE_COMPONENT_APPLICATION_COMMON, LOCALE_COMPONENT_OMP_AUTHOR));

		$router =& $request->getRouter();
		$press =& $router->getContext($request);
		$user =& $request->getUser();

		$this->setData($this->_getSubmissions($request, $user->getId(), $press->getId()));

		// Add reviewer-specific columns
		$emptyColumnActions = array();
		$cellProvider = new SubmissionsListGridCellProvider();
		$this->addColumn(
			new GridColumn(
				'dateAssigned',
				'common.status',
				$emptyColumnActions,
				'controllers/grid/gridCell.tpl',
				$cellProvider
			)
		);
		$this->addColumn(
			new GridColumn(
				'dateDue',
				'common.status',
				$emptyColumnActions,
				'controllers/grid/gridCell.tpl',
				$cellProvider
			)
		);
		$this->addColumn(
			new GridColumn(
				'reviewRound',
				'common.status',
				$emptyColumnActions,
				'controllers/grid/gridCell.tpl',
				$cellProvider
			)
		);

	}


	//
	// Public SubmissionsList Grid Actions
	//

	/**
	 * Delete a submission
	 * @param $args array
	 * @param $request PKPRequest
	 * @return string
	 */
	function deleteSubmission(&$args, &$request) {
		//FIXME: Implement
		
		return false;
	}
	
	//
	// Private helper functions
	//
	function _getSubmissions(&$request, $userId, $pressId) {
		//$rangeInfo =& Handler::getRangeInfo('submissions');
		$page = $request->getUserVar('status');
		switch($page) {
			case 'completed':
				$active = false;
				$this->setTitle('common.queue.long.completed');
				break;
			default:
				$page = 'active';
				$this->setTitle('common.queue.long.active');
				$active = true;
		}

		$reviewerSubmissionDao =& DAORegistry::getDAO('ReviewerSubmissionDAO');
		$submissions = $reviewerSubmissionDao->getReviewerSubmissionsByReviewerId($userId, $pressId, $active);
		$data = array();
		while($submission =& $submissions->next()) {
			$submissionId = $submission->getId();
			$data[$submissionId] = $submission;
			unset($submision);
		}

		return $data;
	}
}