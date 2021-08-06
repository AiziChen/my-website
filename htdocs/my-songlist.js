let howl = null;
let playList = [];
let currentIndex = 0;
let lrcPanel = null;
let timeoutArrs = [];

const playLyric = (player) => {
  if (howl != null && howl != undefined) {
    for (const obj of player.getLyrics()) {
      let toutFd = setTimeout(() => {
        if (howl.playing()) {
          lrcPanel.innerText = obj.text;
        }
      }, obj.timestamp * 1000 - howl.seek() * 1000);
      timeoutArrs.push(toutFd);
    }
  }
};

const stopLyric = () => {
  for (const v of timeoutArrs) {
    clearTimeout(v);
  }
  timeoutArrs = [];
}

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
          stopLyric();
          if (currentIndex++ < playList.length) {
            playMusic(playList[currentIndex].url);
          } else {
            console.log('music list all played done.');
          }
        },
        onplay: () => {
          stopLyric();
          fetch("http://43.128.26.51:5000/api/music/get-lyric.lrc?url=" + playList[currentIndex].lrc, {
            method: 'get'
          })
          .then(res => {
            return res.text();
          })
          .then(res => {
            lrcPlayer = new Lyrics(res);
            // make lyric animatly
            playLyric(lrcPlayer);
            // change the window title
            document.title = `${playList[currentIndex].name} - ${playList[currentIndex].artist}`;
          })
          .catch(e => {
            console.error('request lyric error');
          });
        },
        onseek: () => {
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