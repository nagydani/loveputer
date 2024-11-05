// https://github.com/tapio/live-server
const { start } = require('live-server')

const params = {
  port: 8080,
  host: '0.0.0.0',
  root: '../dist/web',
  open: false,
  ignore: '',
  wait: 100, // Waits for all changes, before reloading. Defaults to 0 sec.
  middleware: [
    function (_req, res, next) {
      res.setHeader('Cross-Origin-Opener-Policy', 'same-origin')
      res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp')
      next()
    }
  ]
}

start(params)
