#!/bin/sh -e

apk add --no-cache bash

cat << 'EOF' > /entrypoint
#!/usr/bin/env bash
echo '{"input":"$@"}'
EOF

chmod +x /entrypoint
