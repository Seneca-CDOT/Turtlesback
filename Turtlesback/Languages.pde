/***** Define Keys Below *****/
String[] keyList = new String[] {
  //Screen Titles
  "ScreenTitle_Game1",
  "ScreenTitle_Game2",
  "ScreenTitle_Game3",
  "ScreenTitle_Game4",
  "ScreenTitle_MainMenu",
  
  //Help Text
  "Help_Game1HelpText",
  "Help_Game2HelpText",
  "Help_Game3HelpText",
  "Help_Game4HelpText",
  
  //Narration Scripts
  "Script_Introduction"
};

/***** Define Languages Below *****/

/***** ENGLISH - CANADA *****/
Language en_CA = new Language(
  keyList,
  new String[]{
    "Uprooted EN", //ScreenTitle_Game1
    "Descent EN",  //ScreenTitle_Game2
    "Gifted EN",   //ScreenTitle_Game3
    "Grounded EN", //ScreenTitle_Game4
    "",   //Main Menu title
    
    "", //Help_Game1HelpText
    "", //Help_Game2HelpText
    "Give him the stick -- DONT GIVE HIM THE STICK! AHHHHHHHHHHH~~~", //Help_Game3HelpText
    "", //Help_Game4HelpText
    
    "Welcome to the game." //Script_Introduction
  }
);

/***** FRENCH - CANADA *****/
Language fr_CA = new Language(
  keyList,
  new String[]{
    "Uprooted FR", //ScreenTitle_Game1
    "Descent FR", //ScreenTitle_Game2
    "Gifted FR", //ScreenTitle_Game3
    "Grounded FR", //"ScreenTitle_Game4
    "French Main Menu",   //Main Menu title
    
    "", //Help_Game1HelpText
    "", //Help_Game2HelpText
    "Give le person ze stick -- NE PAS GIVE LE PERSON ZE STICK! AHHHHHHHHHHH~~~", //Help_Game3HelpText
    "", //Help_Game4HelpText
    
    "Bienvenue sur le jeu." //Script_Introduction
  }
);
