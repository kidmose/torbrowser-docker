#!/bin/bash
USERNAME="torbrowser"

echo "torbrowser: Starting with UID:GID $LOCAL_USER_ID:$LOCAL_GROUP_ID"
usermod -u $LOCAL_USER_ID $USERNAME
usermod -g $LOCAL_GROUP_ID $USERNAME
export HOME=/home/$USERNAME

gosu $USERNAME "/usr/bin/torbrowser-launcher"
/bin/bash
