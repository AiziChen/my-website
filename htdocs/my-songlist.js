let howl = null;
function playMusic(src) {
  howl = new Howl({
     src: [src],
        format: ['mp3', 'aac', 'mpeg', 'opus', 'ogg', 'oga', 'wav', 'aac', 'caf', 'm4a', 'mp4', 'weba', 'webm',
          'bolby', 'flac'
        ],
        onload: () => {
          howl.play();
        }
  });
}


window.onload = () => {
  const arrs = document.getElementsByClassName('play-div');
  for (const ele of arrs) {
    ele.addEventListener('click', (e) => {
      if (howl != null) {
        howl.unload();
      }
      playMusic(e.target.getAttribute('src'));
    });
  }
}