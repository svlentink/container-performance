#!/bin/sh -e

apk add --no-cache python3
ln -s /usr/bin/python3 /usr/bin/python

cat << EOF > /entrypoint
#!/usr/bin/env python
import sys
print(sys.argv[1:])
EOF

chmod +x /entrypoint
