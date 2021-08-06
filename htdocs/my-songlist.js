let howl = null;
let playList = [];
let currentIndex = 0;
let lrcPanel = null;
let lrcPlayer = null;

const step = () => {
  if (howl != null && howl != undefined && howl.playing() && lrcPlayer != null) {
    let pos = howl.seek();
    let ctObj = lrcPlayer.getLyrics()[lrcPlayer.select(pos)];
    if (ctObj != undefined) {
       lrcPanel.innerText = ctObj.text;
    }
    requestAnimationFrame(step);
  }
};

function playMusic(src) {
  if (howl != null && howl != undefined) {
    howl.unload();
  }
  howl = new Howl({
     src: src,
        format: ['mp3', 'aac', 'mpeg', 'opus', 'ogg', 'oga', 'wav', 'caf', 'm4a', 'mp4', 'weba', 'webm',
          'bolby', 'flac'
        ],
        html5: true,
        loop: false,
        onload: () => {
          howl.play();
        },
        onend: () => {
          if (currentIndex++ < playList.length) {
            playMusic(playList[currentIndex].url);
          } else {
            console.log('music list all played done.');
          }
        },
        onplay: () => {
          fetch("http://43.128.26.51:5000/api/music/get-lyric.lrc?url=" + playList[currentIndex].lrc, {
            method: 'get'
          })
          .then(res => {
            return res.text();
          })
          .then(res => {
            lrcPlayer = new Lyrics(res);
            // make lyric animatly
            requestAnimationFrame(step);
            // change the window title
            document.title = `${playList[currentIndex].name} - ${playList[currentIndex].artist}`;
          })
          .catch(e => {
            console.error('request lyric error');
          });
        },
        onseek: () => {
          //requestAnimationFrame(step);
        }
  });
}

window.onload = () => {
  lrcPanel = document.getElementById('lrc-panel');
  const eles = document.getElementsByClassName('play-div');
  for (let i = 0; i < eles.length; ++i) {
      /*playList.push({
        cover: t.getAttribute('cover'),
        lrc: t.getAttribute('lrc'),
        time: t.getAttribute('time')
      });*/
    playList.push({
      url: eles[i].getAttribute('url'),
      lrc: eles[i].getAttribute('lrc'),
      name: eles[i].getAttribute('name'),
      artist: eles[i].getAttribute('artist')
    });
    eles[i].addEventListener('click', (e) => {
      let t = e.target;
      if (t.tagName !== "DIV") {
        t = t.parentElement;
      }
      playMusic(t.getAttribute('url'));
      currentIndex = i;
    });
  }
}