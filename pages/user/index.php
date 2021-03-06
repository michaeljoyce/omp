<?php

/**
 * @defgroup pages_user
 */
 
/**
 * @file pages/user/index.php
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @ingroup pages_user
 * @brief Handle requests for user functions. 
 *
 */

// $Id$

switch ($op) {
	//
	// Profiles
	//
	case 'profile':
	case 'saveProfile':
	case 'changePassword':
	case 'savePassword':
		import('pages.user.ProfileHandler');
		define('HANDLER_CLASS', 'ProfileHandler');
		break;
	//
	// Registration
	//
	case 'register':
	case 'registerUser':
	case 'activateUser':
		import('pages.user.RegistrationHandler');
		define('HANDLER_CLASS', 'RegistrationHandler');
		break;
	//
	// Email
	//
	case 'email':
		import('pages.user.EmailHandler');
		define('HANDLER_CLASS', 'EmailHandler');
		break;	
	case 'index':
	case 'setLocale':
	case 'become':
	case 'viewCaptcha':
	case 'viewPublicProfile':
		define('HANDLER_CLASS', 'UserHandler');
		import('pages.user.UserHandler');
		break;
}

?>
