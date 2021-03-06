<?php

/**
 * @file controllers/grid/files/submissionFiles/form/SubmissionFilesArtworkMetadataForm.inc.php
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class SubmissionFilesArtworkMetadataForm
 * @ingroup controllers_grid_file_form
 *
 * @brief Form for editing artwork file metadata.
 */

import('lib.pkp.classes.form.Form');

class SubmissionFilesArtworkMetadataForm extends Form {
	/** @var int */
	var $_fileId;

	/** @var int */
	var $_monographId;

	/**
	 * Constructor.
	 */
	function SubmissionFilesArtworkMetadataForm($fileId = null, $monographId = null) {
		parent::Form('controllers/grid/files/submissionFiles/form/artworkMetadataForm.tpl');

		$this->_fileId = $fileId;
		$this->_monographId = $monographId;

		$this->addCheck(new FormValidator($this, 'name', 'required', 'submission.nameRequired'));
		$this->addCheck(new FormValidatorPost($this));
	}

	/**
	 * Fetch the form.
	 */
	function fetch(&$request) {
		$templateMgr =& TemplateManager::getManager();
		$templateMgr->assign('fileId', $this->_fileId);
		$templateMgr->assign('monographId', $this->_monographId);

		//$templateMgr->assign('monographId', $this->_monographId);
		$artworkFileDao =& DAORegistry::getDAO('ArtworkFileDAO');
		$artworkFile =& $artworkFileDao->getByFileId($this->_fileId);
		$templateMgr->assign_by_ref('artworkFile', $artworkFile);

		$monographFileDao =& DAORegistry::getDAO('MonographFileDAO');
		$monographFile =& $monographFileDao->getMonographFile($this->_fileId);
		$templateMgr->assign_by_ref('monographFile', $monographFile);

		// artwork can be grouped by monograph chapter
		if ($artworkFile) {
			$chapterDao =& DAORegistry::getDAO('ChapterDAO');
			$chapters =& $chapterDao->getChapters($artworkFile->getMonographId());
			$chapterOptions = array();
			if($chapters) {
				while($chapter =& $chapters->next()) {
					$chapterId = $chapter->getId();
					$chapterOptions[$chapterId] = $chapter->getLocalizedTitle();
					unset($chapter);
				}
			}
			$templateMgr->assign_by_ref('selectedChapter', $artworkFile->getChapterId());
		} else {
			$chapters = null;
		}
		
		$noteDao =& DAORegistry::getDAO('NoteDAO');
		$notes =& $noteDao->getByAssoc(ASSOC_TYPE_MONOGRAPH_FILE, $this->_fileId);
		$templateMgr->assign('note', $notes->next()); 

		$templateMgr->assign_by_ref('chapterOptions', $chapterOptions);

		return parent::fetch($request);
	}

	/**
	 * Initialize form data.
	 */
	function initData(&$args, &$request) {
		$artworkFileDao =& DAORegistry::getDAO('ArtworkFileDAO');
		$artworkFile =& $artworkFileDao->getByFileId($this->_fileId);
		$this->_data['artworkFile'] =& $artworkFile;

		$monographFileDao =& DAORegistry::getDAO('MonographFileDAO');
		$monographFile =& $monographFileDao->getMonographFile($this->_fileId);
		$this->_data['$monographFile'] =& $monographFile;

		// grid related data
		$this->_data['monographId'] = $this->_monographId;
		$this->_data['fileId'] = $this->_fileId;
		$this->_data['artworkFileId'] = isset($args['artworkFileId']) ? $args['artworkFileId'] : null;
	}

	/**
	 * Assign form data to user-submitted data.
	 */
	function readInputData() {
		$this->readUserVars(array(
			'name', 'artwork', 'artwork_file', 'artwork_caption', 'artwork_credit', 'artwork_copyrightOwner', 'artwork_copyrightOwnerContact', 'artwork_permissionTerms', 'monographId',
			'artwork_type', 'artwork_otherType', 'artwork_contact', 'artwork_placement', 'artwork_otherPlacement', 'artwork_chapterId', 'artwork_placementType', 'note'
		));
		$this->readUserVars(array('artworkFileId'));
	}

	/**
	 * Save settings.
	 */
	function execute() {
		$artworkFileDao =& DAORegistry::getDAO('ArtworkFileDAO');

		// manage artwork permissions file
		import('classes.file.MonographFileManager');
		$monographId = $this->getData('monographId');
		$monographFileManager = new MonographFileManager($monographId);

		$artworkFile =& $artworkFileDao->getByFileId($this->_fileId);

		$permissionFileId = null;
		if ($monographFileManager->uploadedFileExists('artwork_permissionForm')) {
			$permissionFileId = $monographFileManager->uploadArtworkFile('artwork_permissionForm');
		}

		$otherType = $this->getData('artwork_type') == MONOGRAPH_ARTWORK_TYPE_OTHER ? $this->getData('artwork_otherType') : null;
		$otherPlacement = $this->getData('artwork_placementType') == MONOGRAPH_ARTWORK_PLACEMENT_OTHER ? $this->getData('artwork_otherPlacement') : null;

		$artworkFile->setName($this->getData('name'), Locale::getLocale());
		$artworkFile->setFileId($this->_fileId);
		$artworkFile->setMonographId($monographId);
		//
		// FIXME: Should caption, credit, or any other fields be localized?
		//
		$artworkFile->setCaption($this->getData('artwork_caption'));
		$artworkFile->setCredit($this->getData('artwork_credit'));
		$artworkFile->setCopyrightOwner($this->getData('artwork_copyrightOwner'));
		$artworkFile->setCopyrightOwnerContactDetails($this->getData('artwork_copyrightOwnerContact'));
		$artworkFile->setPermissionTerms($this->getData('artwork_permissionTerms'));
		$artworkFile->setPermissionFileId($permissionFileId);
		$artworkFile->setContactAuthor($this->getData('artwork_contact'));
		$artworkFile->setType($this->getData('artwork_type'));

		if ($otherType) {
			$artworkFile->setCustomType($otherType);
		} else {
			$artworkFile->setCustomType(null);
		}

		if ($otherPlacement) {
			$artworkFile->setChapterId(null);
			$artworkFile->setPlacement($otherPlacement);
		} else {
			$artworkFile->setPlacement($this->getData('artwork_placement'));
			$artworkFile->setChapterId($this->getData('artwork_componentId'));
		}

		$artworkFileDao->updateObject($artworkFile);
		
		// Save the note if it exists
		if ($this->getData('note')) {
			$noteDao =& DAORegistry::getDAO('NoteDAO');
			$note = $noteDao->newDataObject();
			$press =& Request::getPress();
			$user =& Request::getUser();
	
			$note->setContextId($press->getId());
			$note->setUserId($user->getId());
			$note->setContents($this->getData('note'));
			$note->setAssocType(ASSOC_TYPE_MONOGRAPH_FILE);
			$note->setAssocId($this->_fileId);
	
		 	$noteDao->insertObject($note);
		}
			
		return $artworkFile->getId();
	}

}

?>