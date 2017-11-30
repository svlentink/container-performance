#!/bin/sh -e

apk add --no-cache nodejs

cat << EOF > /entrypoint
#!/usr/bin/env node
var process = require('process')
console.log(process.argv)
EOF

chmod +x /entrypoint
