#!/usr/bin/env bash
# Pin 1Password's groups to fixed GIDs.
#
# The 1Password RPMs run `groupadd` at build time, which hands out whatever GID
# is free in the build container (1000, 1001...). On a real install /etc/group
# is persistent and those GIDs belong to other groups (1000 = the first user),
# so the setgid helpers end up owned by the wrong group and 1Password refuses
# to talk to the browser extension and the CLI.
#
# Fix: chgrp the helpers to fixed numeric GIDs and ship a sysusers.d config so
# the groups exist with those same GIDs on every machine.
set -oue pipefail

ONEPASSWORD_GID=958
ONEPASSWORD_MCP_GID=957
ONEPASSWORD_CLI_GID=956

cat > /usr/lib/sysusers.d/onepassword.conf <<CONF
g onepassword ${ONEPASSWORD_GID}
g onepassword-mcp ${ONEPASSWORD_MCP_GID}
g onepassword-cli ${ONEPASSWORD_CLI_GID}
CONF

APP_DIR=/usr/lib/opt/1Password
[ -d "$APP_DIR" ] || APP_DIR=/opt/1Password

chgrp "$ONEPASSWORD_GID" "$APP_DIR/1Password-BrowserSupport"
chmod g+s "$APP_DIR/1Password-BrowserSupport"

chgrp "$ONEPASSWORD_MCP_GID" "$APP_DIR/1password-mcp"
chmod g+s "$APP_DIR/1password-mcp"

chgrp "$ONEPASSWORD_CLI_GID" /usr/bin/op
chmod g+s /usr/bin/op
