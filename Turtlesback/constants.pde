// Constants used by game

// game setup
final int MAX_FRAMERATE = 30;
static final int RESOLUTIONX = 960;
static final int RESOLUTIONY = 600;
static final int HALF_WIDTH = RESOLUTIONX/2;
static final int HALF_HEIGHT = RESOLUTIONY/2;
static final String LOCKED_BUTTON_IMAGE = "data/general/lock.png";

// modal choices for ModalPopup
final int MODAL_NOTHING = 0;
final int MODAL_CANCEL  = 1;
final int MODAL_OK      = 2;

// modal modes for ModalPopup
final int MODAL_INFORM = 0;
final int MODAL_CHOICE = 1;
final int MODAL_HELP   = 2;
final int MODAL_TRAIT  = 3;
final int MODAL_LOAD   = 4;
final int MODAL_HELP_LARGE = 5;

// standard font settings
final String STANDARD_FONT_NAME = "data/HammersmithOne.ttf";
final int    STANDARD_FONT_SIZE = 17;
final color  STANDARD_FONT_COLOR = color(#000000);
final int    MODAL_TEXT_FONT_SIZE = 26;
final int    MODAL_TEXT_LEADING = 30;
final int    MODAL_HELP_FONT_SIZE = 20;
final int    MODAL_HELP_LEADING = 32;
final int    MODAL_BUTTON_FONT_SIZE = 32;

// descent game constants
final float DESCENT_GAME_DURATION = 120000;  // 120 seconds
final float DESCENT_JUMP_HEIGHT = 1200;

// gifted game constants
final color GIFTED_GAME_BLACK = color(0,0,0);
final color GIFTED_GAME_GREEN = color(0,255,0);
final int   GIFTED_MAX_OBSTACLE_COUNT = 10;
final int   GIFTED_MIN_OBSTACLE_INTERVAL = 1500;

final int    GIFTED_MUSKRAT_START_HEIGHT = 125;
final String GIFTED_GAME_BACKGROUND = "data/gifted/Background.png";
final String GIFTED_GAME_IMAGE_CORAL = "data/gifted/Coral_Reef-228x321";
final String GIFTED_GAME_IMAGE_LIGHTRAY = "data/gifted/Light_Rays";

final String GIFTED_GAME_IMAGE_MUSKRAT = "data/gifted/MuskratSwimDown_Sprite-162x247";
final String GIFTED_GAME_IMAGE_MUSKRAT_CHILLING = "data/gifted/Muskrat_Chillin";
final String GIFTED_GAME_IMAGE_MUSKRAT_GRAB = "data/gifted/MuskratGrab_sprite_220x346";
final String GIFTED_GAME_IMAGE_MUSKRAT_HAS = "data/gifted/MuskratSwimUp_Sprite_162x365";
final String GIFTED_GAME_IMAGE_MUSKRAT_HIT_UP = "data/gifted/MuskratSwimUpHIT_Sprite.png";
final String GIFTED_GAME_IMAGE_MUSKRAT_HIT_DOWN = "data/gifted/MuskratSwimDownHIT_Sprite.png";
final String GIFTED_GAME_IMAGE_EARTH_DROP = "data/gifted/DroppedMud_Sprite-100x280";
//final String GIFTED_GAME_IMAGE_TURTLE = "data/gifted/WaterTurtle_NEW_Sprite-219x378";
final String GIFTED_GAME_IMAGE_TURTLE = "data/gifted/WaterTurtle_NEW_Sprite-219x378-2";
final String GIFTED_MOUNTAIN_PREFIX = "data/gifted/mountain/mountain-";

final String GIFTED_GAME_IMAGE_FISH = "data/gifted/SchoolFish_Sprite-280x260";
final String GIFTED_GAME_IMAGE_WHALE = "data/gifted/Whale_Sprite-330x209";
final String GIFTED_GAME_IMAGE_SALMON = "data/gifted/Salmon_Sprite-2127x107";
final String GIFTED_GAME_IMAGE_SHARK = "data/gifted/Shark_Sprite-434x195";
final String GIFTED_GAME_IMAGE_EEL = "data/gifted/Eel_Sprite-175x35";
final String GIFTED_GAME_IMAGE_BUBBLE = "data/gifted/bubbles_sprite-183x381";

final int GIFTED_GAME_MAX_DRAWY = RESOLUTIONY - 50;
final int GIFTED_GAME_MIN_DRAWY = 150;




