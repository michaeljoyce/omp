<?php

/**
 * @file classes/i18n/Locale.inc.php
 *
 * Copyright (c) 2003-2010 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class Locale
 * @ingroup i18n
 *
 * @brief Provides methods for loading locale data and translating strings identified by unique keys
 *
 */

// $Id$


import('lib.pkp.classes.i18n.PKPLocale');

define('LOCALE_COMPONENT_APPLICATION_COMMON',	0x00000101);
define('LOCALE_COMPONENT_OMP_MANAGER',		0x00000102);
define('LOCALE_COMPONENT_OMP_AUTHOR',   	0x00000104);
define('LOCALE_COMPONENT_OMP_EDITOR',   	0x00000108);
define('LOCALE_COMPONENT_OMP_ADMIN',   		0x0000010F);
define('LOCALE_COMPONENT_OMP_DEFAULT_SETTINGS',	0x00000111);
define('LOCALE_COMPONENT_OMP_SETTINGS', 	0x0000010A);

class Locale extends PKPLocale {
	/**
	 * Get all supported UI locales for the current context.
	 * @return array
	 */
	function getSupportedLocales() {
		static $supportedLocales;
		if (!isset($supportedLocales)) {
			if (defined('SESSION_DISABLE_INIT') || !Config::getVar('general', 'installed')) {
				$supportedLocales = Locale::getAllLocales();
			} elseif (($press =& Request::getPress())) {
				$supportedLocales = $press->getSupportedLocaleNames();
			} else {
				$site =& Request::getSite();
				$supportedLocales = $site->getSupportedLocaleNames();
			}
		}
		return $supportedLocales;
	}

	/**
	 * Get all supported form locales for the current context.
	 * @return array
	 */
	function getSupportedFormLocales() {
		static $supportedFormLocales;
		if (!isset($supportedFormLocales)) {
			if (defined('SESSION_DISABLE_INIT') || !Config::getVar('general', 'installed')) {
				$supportedFormLocales = Locale::getAllLocales();
			} elseif (($press =& Request::getPress())) {
				$supportedFormLocales = $press->getSupportedFormLocaleNames();
			} else {
				$site =& Request::getSite();
				$supportedFormLocales = $site->getSupportedLocaleNames();
			}
		}
		return $supportedFormLocales;
	}

	/**
	 * Return the key name of the user's currently selected locale (default
	 * is "en_US" for U.S. English).
	 * @return string
	 */
	function getLocale() {
		static $currentLocale;
		if (!isset($currentLocale)) {
			if (defined('SESSION_DISABLE_INIT') || !Config::getVar('general', 'installed')) {
				// If the locale is specified in the URL, allow
				// it to override. (Necessary when locale is
				// being set, as cookie will not yet be re-set)
				$locale = Request::getUserVar('setLocale');
				if (empty($locale) || !in_array($locale, array_keys(Locale::getSupportedLocales()))) $locale = Request::getCookieVar('currentLocale');
			} else {
				$sessionManager =& SessionManager::getManager();
				$session =& $sessionManager->getUserSession();
				$locale = $session->getSessionVar('currentLocale');

				$press =& Request::getPress();
				$site =& Request::getSite();

				if (!isset($locale)) {
					$locale = Request::getCookieVar('currentLocale');
				}

				if (isset($locale)) {
					// Check if user-specified locale is supported
					if ($press != null) {
						$locales =& $press->getSupportedLocaleNames();
					} else {
						$locales =& $site->getSupportedLocaleNames();
					}

					if (!in_array($locale, array_keys($locales))) {
						unset($locale);
					}
				}

				if (!isset($locale)) {
					// Use press/site default
					if ($press != null) {
						$locale = $press->getPrimaryLocale();
					}

					if (!isset($locale)) {
						$locale = $site->getPrimaryLocale();
					}
				}
			}

			if (!Locale::isLocaleValid($locale)) {
				$locale = LOCALE_DEFAULT;
			}

			$currentLocale = $locale;
		}
		return $currentLocale;
	}

	/**
	 * Get the stack of "important" locales, most important first.
	 * @return array
	 */
	function getLocalePrecedence() {
		static $localePrecedence;
		if (!isset($localePrecedence)) {
			$localePrecedence = array(Locale::getLocale());

			$press =& Request::getPress();
			if ($press && !in_array($press->getPrimaryLocale(), $localePrecedence)) $localePrecedence[] = $press->getPrimaryLocale();

			$site =& Request::getSite();
			if ($site && !in_array($site->getPrimaryLocale(), $localePrecedence)) $localePrecedence[] = $site->getPrimaryLocale();
		}
		return $localePrecedence;
	}

	/**
	 * Retrieve the primary locale of the current context.
	 * @return string
	 */
	function getPrimaryLocale() {
		$press =& Request::getPress();

		if (isset($press)) {
			$locale = $press->getPrimaryLocale();
		}

		if (!isset($locale)) {
			$site =& Request::getSite();
			$locale = $site->getPrimaryLocale();
		}

		if (!isset($locale) || !Locale::isLocaleValid($locale)) {
			$locale = LOCALE_DEFAULT;
		}

		return $locale;
	}

	/**
	 * Install support for an existing locale.
	 * @param $locale string
	 */
	function installLocale($locale) {
		parent::installLocale($locale);

		$bookFileTypeDao =& DAORegistry::getDAO('BookFileTypeDAO');
		$bookFileTypeDao->installLocale($locale);

		$publicationFormatDao =& DAORegistry::getDAO('PublicationFormatDAO');
		$publicationFormatDao->installLocale($locale);

		$userGroupDao =& DAORegistry::getDAO('UserGroupDAO');
		$userGroupDao->installLocale($locale);
	}

	/**
	 * Uninstall support for a new locale.
	 * @param $locale string
	 */
	function uninstallLocale($locale) {
		parent::uninstallLocale($locale);

		$bookFileTypeDao =& DAORegistry::getDAO('BookFileTypeDAO');
		$bookFileTypeDao->uninstallLocale($locale);

		$publicationFormatDao =& DAORegistry::getDAO('PublicationFormatDAO');
		$publicationFormatDao->uninstallLocale($locale);

		$userGroupDao =& DAORegistry::getDAO('UserGroupDAO');
		$userGroupDao->deleteSettingsByLocale($locale);
	}

	/**
	 * Make a map of components to their respective files.
	 * @param $locale string
	 * @return array
	 */
	function makeComponentMap($locale) {
		$componentMap = parent::makeComponentMap($locale);
		$baseDir = "locale/$locale/";
		$componentMap[LOCALE_COMPONENT_APPLICATION_COMMON] = $baseDir . 'locale.xml';
		$componentMap[LOCALE_COMPONENT_OMP_MANAGER] = $baseDir . 'manager.xml';
		$componentMap[LOCALE_COMPONENT_OMP_AUTHOR] = $baseDir . 'author.xml';
		$componentMap[LOCALE_COMPONENT_OMP_EDITOR] = $baseDir . 'editor.xml';
		$componentMap[LOCALE_COMPONENT_OMP_ADMIN] = $baseDir . 'admin.xml';
		$componentMap[LOCALE_COMPONENT_OMP_SETTINGS] = $baseDir . 'settings.xml';
		$componentMap[LOCALE_COMPONENT_OMP_DEFAULT_SETTINGS] = $baseDir . 'defaultSettings.xml';
		return $componentMap;
	}
}

?>