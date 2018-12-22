var soundPlayer = null;

shinyjs.playMusic = function() {
  soundPlayer = new Audio("rocky.wav");
  soundPlayer.addEventListener('ended', function() {
    this.currentTime = 0;
    this.play();
}, false);
  soundPlayer.play();
};

shinyjs.stopMusic = function() {
  soundPlayer.pause();
  soundPlayer.currentTime = 0;
};