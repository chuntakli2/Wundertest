//
//  Config.swift
//  Wundertest
//
//  Created by Chun Tak Li on 24/10/2016.
//  Copyright © 2016 Chun Tak Li. All rights reserved.
//

import UIKit

// Get AppDelegate
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

// Return the Document Directory Path
let kDocumentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first

// Return the Cache Directory Path
let kCacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

let IOS_VERSION = (UIDevice.current.systemVersion as NSString).floatValue

let IPHONE_PLUS_WIDTH: CGFloat = 414.0
let IPHONE_PLUS_HEIGHT: CGFloat = 736.0
let IS_IPHONE_PLUS = (UIScreen.main.bounds.width * UIScreen.main.bounds.height == IPHONE_PLUS_WIDTH * IPHONE_PLUS_HEIGHT)

// MARK: - Font start

let BASE_FONT_NAME = "Avenir-Medium"
let BASE_FONT_NAME_LIGHT = "Avenir-LightOblique"
let BASE_FONT_NAME_BOLD = "Avenir-Heavy"
let BASE_FONT_NAME_ROMAN = "Avenir-Roman"


let FONT_SIZE_SMALL: CGFloat = 12.0
let FONT_SIZE_MEDIUM: CGFloat = 15.0
let FONT_SIZE_LARGE: CGFloat = 18.0
let FONT_SIZE_XLARGE: CGFloat = 25.0

let FONT_SMALL = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_SMALL)
let FONT_MEDIUM = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_MEDIUM)
let FONT_LARGE = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_LARGE)
let FONT_XLARGE = UIFont(name: BASE_FONT_NAME, size: FONT_SIZE_XLARGE)

let FONT_SMALL_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_SMALL)
let FONT_MEDIUM_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_MEDIUM)
let FONT_LARGE_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_LARGE)
let FONT_XLARGE_BOLD = UIFont(name: BASE_FONT_NAME_BOLD, size: FONT_SIZE_XLARGE)

let GRAY_COLOUR = "EEEEEE"
let DARK_GRAY_COLOUR = "757575"
let APP_COLOUR = "202D44"
let APP_GRAY_COLOUR = UIColor.colour(fromHexString: GRAY_COLOUR)
let APP_DARK_GRAY_COLOUR = UIColor.colour(fromHexString: DARK_GRAY_COLOUR)
let TINT_COLOUR = UIColor.colour(fromHexString: APP_COLOUR)
let NAVIGATION_BAR_COLOUR = UIColor.colour(fromHexString: APP_COLOUR)
let FONT_COLOUR_BLACK = UIColor.black
let FONT_COLOUR_WHITE = UIColor.white
let FONT_COLOUR_LIGHT_GRAY = UIColor.lightGray
let FONT_COLOUR_DARK_GRAY = UIColor.darkGray
let FONT_COLOUR_RED = UIColor.red

let FONT_ATTR_SMALL_WHITE = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_SMALL_WHITE_BOLD = [NSFontAttributeName: FONT_SMALL_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_SMALL_BLACK = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_SMALL_BLACK_BOLD = [NSFontAttributeName: FONT_SMALL_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_SMALL_RED = [NSFontAttributeName: FONT_SMALL!, NSForegroundColorAttributeName: FONT_COLOUR_RED]

let FONT_ATTR_MEDIUM_WHITE = [NSFontAttributeName: FONT_MEDIUM!, NSForegroundColorAttributeName:FONT_COLOUR_WHITE]
let FONT_ATTR_MEDIUM_WHITE_BOLD = [NSFontAttributeName: FONT_MEDIUM_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_MEDIUM_BLACK = [NSFontAttributeName: FONT_MEDIUM!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_MEDIUM_BLACK_BOLD = [NSFontAttributeName: FONT_MEDIUM_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]

let FONT_ATTR_LARGE_WHITE = [NSFontAttributeName: FONT_LARGE!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_LARGE_WHITE_BOLD = [NSFontAttributeName: FONT_LARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_LARGE_BLACK = [NSFontAttributeName: FONT_LARGE!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_LARGE_BLACK_BOLD = [NSFontAttributeName: FONT_LARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]

let FONT_ATTR_XLARGE_WHITE = [NSFontAttributeName: FONT_XLARGE!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_XLARGE_WHITE_BOLD = [NSFontAttributeName: FONT_XLARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_WHITE]
let FONT_ATTR_XLARGE_BLACK = [NSFontAttributeName: FONT_XLARGE!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]
let FONT_ATTR_XLARGE_BLACK_BOLD = [NSFontAttributeName: FONT_XLARGE_BOLD!, NSForegroundColorAttributeName: FONT_COLOUR_BLACK]

// MARK: - General Config

let GENERAL_SPACING: CGFloat = 10.0
let SMALL_SPACING: CGFloat = GENERAL_SPACING / 2.0
let LARGE_SPACING: CGFloat = 2.0 * GENERAL_SPACING
let BACK_BUTTON_SPACING: CGFloat = 8.0
let GENERAL_ITEM_WIDTH: CGFloat = 44.0
let GENERAL_ITEM_HEIGHT: CGFloat = GENERAL_ITEM_WIDTH
let SMALL_ITEM_WIDTH: CGFloat = GENERAL_ITEM_WIDTH / 2.0
let SMALL_ITEM_HEIGHT: CGFloat = SMALL_ITEM_WIDTH
let GENERAL_CELL_HEIGHT: CGFloat = 56.0
let NAVIGATION_BAR_HEIGHT: CGFloat = 64.0
let LOADING_DIAMETER: CGFloat = 10.0
let LOADING_RADIUS: CGFloat = LOADING_DIAMETER / 2.0
let CORNER_RADIUS: CGFloat = 10.0
let PULL_TO_ADD_VIEW_HEIGHT: CGFloat = 60.0
let COMPOSE_TASK_VIEW_WIDTH: CGFloat = 280.0
let TEXT_VIEW_HEIGHT: CGFloat = 64.0

let ANIMATION_DURATION = 0.3

let WHITESPACE = " "
let MAXIMUM_TEXT_COUNT = 140

// MARK: - Keys

let SETTINGS_KEY = "Settingsv1.0.0_Key"
let DEVICE_TOKEN_KEY = "DeviceToken_Key"
let IOS_VERSION_KEY = "iOSVersion_Key"
let IS_JAILBROKEN_KEY = "IsJailbroken_Key"
let DEVICE_LANGUAGE_KEY = "DeviceLanguage_Key"
let IS_TUTORIAL_MODE_KEY = "IsTutorialMode_Key"
let IS_NEWLY_INSTALLED_KEY = "IsNewlyInstalled_Key"
let PHOTOS_COUNT_KEY = "PhotosCount_Key"
let LAST_PHOTO_UNIQUE_ID_KEY = "LastPhotoUniqueId_Key"

// MARK: - Errors
