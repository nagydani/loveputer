const { Converter } = require('showdown')
const fs = require('fs')

// Create a converter instance with GitHub flavor enabled
const converter = new Converter({
  tables: true,
  strikethrough: true
})

function convertMarkdownToHtml (inputFile, outputFile) {
  fs.readFile(inputFile, 'utf8', (err, data) => {
    if (err) {
      console.error(`Error reading file: ${err}`)
      return
    }

    const html = converter.makeHtml(data)

    fs.writeFile(outputFile, html, err => {
      if (err) {
        console.error(`Error writing file: ${err}`)
        return
      }
    })
  })
}

const inputMarkdownFile = '../README.md'
const outputHtmlFile = '../dist/_readme.html'

convertMarkdownToHtml(inputMarkdownFile, outputHtmlFile)
