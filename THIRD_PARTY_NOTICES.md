# Third-party software and trademarks

The MIT license in this repository applies to this project's packaging code,
scripts and documentation. It does not license or relicense the ChatGPT app,
OpenAI artwork, trademarks, or third-party components bundled in that app.

The build retrieves the app from OpenAI, or uses a locally supplied archive
with the same expected checksum. No app binary or OpenAI artwork is included
in this repository or its source release archive.

Use of the app remains subject to the applicable OpenAI terms and the licenses
and notices included with the upstream distribution. The build preserves the
upstream app directory and its bundled notices. Its Nix package metadata
remains `unfree` because the resulting package includes the proprietary app.

ChatGPT and OpenAI names identify the upstream product. This project is
independent and is not affiliated with, endorsed by, or supported by OpenAI.

Upstream documentation: https://learn.chatgpt.com/docs/linux/linux-app
