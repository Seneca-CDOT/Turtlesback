
// javascript reference to our sketch
var pjs = undefined;
var bound = false;

// bind JS to the p5 sketch for two way communication
function bindJavaScript() {
  if(Processing) { pjs = Processing.getInstanceById("turtlesback"); }
  if (pjs !== undefined && pjs.bindJavaScript !== undefined) {
    pjs.bindJavaScript(this);
    bound = true; }
  if(!bound) setTimeout(bindJavaScript, 250);
}

// schedule binding
bindJavaScript();

// language setting
var chosenLanguage = "";

// set the overall language
function setLanguage(l) {
  chosenLanguage = l;
  showGame();
}

function showGame() {
  var real = document.getElementById('realcontent');
      text = real.innerHTML.trim();
      len = text.length;
  text = text.substring(4,len-4);
  // clear language picker
  var lp = document.getElementById('languagepicker');
  lp.parentNode.removeChild(lp);
  // get going!
  real.innerHTML = text;
  real.style.display = "block";
  // make sure the correct language is used on the loading screen
  if(chosenLanguage==="french") {
    document.querySelector("#loadtitle").innerHTML = "Chargement";
  }
  // start the games
  Processing.init();
}

// check what the overall language is
function getLanguage() {
  return chosenLanguage;
}

// movie loading
function loadMovie(movietitle) {
  // hide games
  var turtlesback = document.getElementById("turtlesback");
  turtlesback.style.display = "none";

  // show video element
  var element = document.createElement("video");
  element.style.display = "block";
  element.width = 960;
  element.height = 600;
  element.id = movietitle;
  element.setAttribute("controls", "controls");

  // set up mp4 video source
  var source = document.createElement("source");
  source.setAttribute("src", "data/general/movies/" + (chosenLanguage==="french" ? "french/" : "") + "mp4/" + movietitle + ".mp4");
  source.setAttribute("type", "video/mp4");
  element.appendChild(source);

  // set up theora video source
  source = document.createElement("source");
  source.setAttribute("src", "data/general/movies/" + (chosenLanguage==="french" ? "french/" : "") + "theora/" + movietitle + ".ogv");
  source.setAttribute("type", "video/ogg");
  element.appendChild(source);

  // add video element to page
  document.getElementById("centerdiv").appendChild(element);

  // popcorn-play the movie, and go back to the game when it's done.
  var movie = Popcorn("#"+movietitle);
  movie.on("ended", function(){
    var element = document.getElementById(movietitle);
    document.getElementById("centerdiv").removeChild(element);
    turtlesback.style.display = "block";

    pjs.runScreen();
  });
  movie.play();
}

// THIS IS CUSTOM CODE SO THAT WE CAN LISTEN TO PRELOAD PROGRESS
var preloadCount=1000000,
    preloadsLeft=0,
    percentage = 0;

window.setPreloadsLeft = function(count) {
  if(preloadCount==1000000) { preloadCount = count; }
  preloadsLeft = count;
  percentage = 1000*(1 - (preloadsLeft/preloadCount));
  percentage = (percentage | 0)/10;
  document.getElementById('percentage').innerHTML = percentage;
}

window.imagePreloaded = function(text, remaining) {
  document.getElementById("latest").innerHTML = text + " ("+remaining+" remaining)";
}

window.onPreloadComplete = function() {
  var div = document.getElementById('canvastext');
  div.style.display = "none";
  loadMovie("first");
}
// THIS IS CUSTOM CODE SO THAT WE CAN LISTEN TO PRELOAD PROGRESS
