let howl = null;
let playList = [];
let currentIndex = 0;
let lrcPanel = null;
let currentLrcText = "";

const step = () => {
  if (currentLrcText !== null) {
    // TODO: implement playing lyric
    lrcPanel.innerText = new Date();//currentLrcText.substr(1, 10);
  }
  if (howl != null && howl.playing()) {
    requestAnimationFrame(step);
  }
};

function playMusic(src) {
  if (howl != null) {
    howl.unload();
  }
  howl = new Howl({
     src: src,
        format: ['mp3', 'aac', 'mpeg', 'opus', 'ogg', 'oga', 'wav', 'aac', 'caf', 'm4a', 'mp4', 'weba', 'webm',
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
            currentLrcText = res;
            requestAnimationFrame(step);
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
        url: t.getAttribute('url'),
        name: t.getAttribute('name'),
        arties: t.getAttribute('artist'),
        cover: t.getAttribute('cover'),
        lrc: t.getAttribute('lrc'),
        time: t.getAttribute('time')
      });*/
    playList.push({
      url: eles[i].getAttribute('url'),
      lrc: eles[i].getAttribute('lrc')
    });
    eles[i].addEventListener('click', (e) => {
      const t = e.target;
      playMusic(t.getAttribute('url'));
      currentIndex = i;
    });
  }
}