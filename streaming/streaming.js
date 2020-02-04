var http = require('http');
var fs = require('fs');
const express = require('express');
var torrentStream = require('torrent-stream');
let path;
let pathfinish;

const streamTorrent = function(req, res, fl) {
  const fileSize = fl.length
  const range = req.headers.range

  console.log('stream torrent');
  if (range) {
    console.log('RANGE OK');
    let write = fs.createWriteStream(path);
    const parts = range.replace(/bytes=/, "").split("-")
    const start = parseInt(parts[0], 10)
    const end = parts[1]
      ? parseInt(parts[1], 10)
      : fileSize - 1
    const chunksize = (end - start) + 1
    const file = fl.createReadStream({ start, end })
    const head = {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': 'video/mp4',
    }
    res.writeHead(206, head);
    console.log('streaming directly from torrent')
    file.pipe(res);
    file.pipe(write).on('finish', function () { console.log("TEST") });
  } else {
    console.log('!RANGE OK');

    const head = {
      'Content-Length': fileSize,
      'Content-Type': 'video/mp4',
    }
    res.writeHead(200, head)
    fs.createReadStream(path).pipe(res);
  }
}

let app = express();

app.get('/', function(req, res){

  var magnet = req.query.torrent;
  var title = req.query.title;
  if (!magnet)
    res.send('Incorrect magnet');
 if (!title)
    res.send('Incorrect title');

  var engine = torrentStream(magnet);
  engine.on('ready', function () {
    engine.files.forEach(function (file) {
      console.log('filename:', file.name)
      if (file.name.includes('.mp4')) {

        path = './tmp/' + title + '.mp4';
        pathfinish = './tmp/' + title + '_finished.mp4';
        var dir = './tmp';
        if (!fs.existsSync(dir)){
          fs.mkdirSync(dir);
        }
        fs.writeFile(path, '', function (err) {
          console.log('File is created successfully.');
        }); 
        fileSize = file.length;
        file.select()
        streamTorrent(req, res, file)
      }
    })
  })

});

let server = app.listen(8080, function() {
    console.log('Server is listening on port 8080')
});

 

