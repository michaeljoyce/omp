<?php

/**
 * @file classes/submission/form/comment/PeerReviewCommentForm.inc.php
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class PeerReviewCommentForm
 * @ingroup submission_form
 *
 * @brief Comment form.
 */

// $Id$


import('classes.submission.form.comment.CommentForm');

class PeerReviewCommentForm extends CommentForm {

	/** @var int the ID of the review assignment */
	var $reviewId;

	/** @var array the IDs of the inserted comments */
	var $insertedComments;

	/**
	 * Constructor.
	 * @param $monograph object
	 */
	function PeerReviewCommentForm($monograph, $reviewId, $roleId) {
		parent::CommentForm($monograph, COMMENT_TYPE_PEER_REVIEW, $roleId, $reviewId);
		$this->reviewId = $reviewId;
	}

	/**
	 * Display the form.
	 */
	function display() {
		$reviewAssignmentDao =& DAORegistry::getDAO('ReviewAssignmentDAO');
		$reviewAssignment =& $reviewAssignmentDao->getById($this->reviewId);
		$reviewLetters =& $reviewAssignmentDao->getReviewIndexesForRound($this->monograph->getId(), $this->monograph->getCurrentReviewType(), $this->monograph->getCurrentRound());

		$templateMgr =& TemplateManager::getManager();
		$templateMgr->assign('commentType', 'peerReview');
		$templateMgr->assign('pageTitle', 'submission.comments.review');
		$templateMgr->assign('commentAction', 'postPeerReviewComment');
		$templateMgr->assign('commentTitle', strip_tags($this->monograph->getLocalizedTitle()));
		$templateMgr->assign('isLocked', isset($reviewAssignment) && $reviewAssignment->getDateCompleted() != null);
		$templateMgr->assign('canEmail', false); // Previously, editors could always email.
		$templateMgr->assign('showReviewLetters', ($this->roleId == ROLE_ID_EDITOR || $this->roleId == ROLE_ID_SERIES_EDITOR) ? true : false);
		$templateMgr->assign('reviewLetters', $reviewLetters);
		$templateMgr->assign('reviewer', ROLE_ID_REVIEWER);
		$templateMgr->assign('hiddenFormParams', 
			array(
				'monographId' => $this->monograph->getId(),
				'reviewId' => $this->reviewId
			)
		);

		parent::display();
	}

	/**
	 * Assign form data to user-submitted data.
	 */
	function readInputData() {
		$this->readUserVars(
			array(
				'commentTitle',
				'authorComments',
				'comments'
			)
		);
	}

	/**
	 * Add the comment.
	 */
	function execute() {
		// Personalized execute() method since now there are possibly two comments contained within each form submission.

		$commentDao =& DAORegistry::getDAO('MonographCommentDAO');
		$this->insertedComments = array();

		// Assign all common information	
		$comment = new MonographComment();
		$comment->setCommentType($this->commentType);
		$comment->setRoleId($this->roleId);
		$comment->setMonographId($this->monograph->getId());
		$comment->setAssocId($this->assocId);
		$comment->setAuthorId($this->user->getId());
		$comment->setCommentTitle($this->getData('commentTitle'));
		$comment->setDatePosted(Core::getCurrentDate());

		// If comments "For authors and editor" submitted
		if ($this->getData('authorComments') != null) {
			$comment->setComments($this->getData('authorComments'));
			$comment->setViewable(1);
			array_push($this->insertedComments, $commentDao->insertMonographComment($comment));
		}		

		// If comments "For editor" submitted
		if ($this->getData('comments') != null) {
			$comment->setComments($this->getData('comments'));
			$comment->setViewable(null);
			array_push($this->insertedComments, $commentDao->insertMonographComment($comment));
		}
	}
}

?>
