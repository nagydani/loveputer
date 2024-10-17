// https://github.com/tapio/live-server
// import { start } from 'live-server'
const liveServer = require('live-server')

const params = {
  port: 8080, // Set the server port. Defaults to 8080.
  host: '0.0.0.0',
  root: 'dist',
  open: false,
  ignore: 'scss,my/templates',
  // wait: 100, // Waits for all changes, before reloading. Defaults to 0 sec.
  // mount: [['/components', './node_modules']], // Mount a directory to a route.
  // logLevel: 2, // 0 = errors only, 1 = some, 2 = lots
  middleware: [
    function (_req, res, next) {
      res.setHeader('Cross-Origin-Opener-Policy', 'same-origin')
      res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp')
      next()
    }
  ]
}

liveServer.start(params)
