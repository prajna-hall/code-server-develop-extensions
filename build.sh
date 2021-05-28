#!/usr/bin/env bash
set -euo pipefail

# if [[ $# -ne 1 ]];then
#   echo "ERROR: input args not equal 1!"
#   exit 1
# fi

GITHUB_WORKSPACE="${1}"
CODE_SERVER_VERSION="${2}"
VERSION="${3:-}"
if [[ ${VERSION} != "" ]]; then
  echo "INFO: VERSION: ${VERSION}"
fi

echo "INFO: start build..."
echo "INFO: CODE_SERVER_VERSION: ${CODE_SERVER_VERSION}"

echo "INFO: work space dir: ${GITHUB_WORKSPACE}"
mkdir -p /usr/local/code-server
mkdir -p /usr/local/code-server-extensions
mkdir -p /usr/local/code-server-users

mkdir -p /tmp
wget -P /tmp "https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz"
tar zxf /tmp/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz --strip-components 1 -C /usr/local/code-server

/usr/local/code-server/bin/code-server \
  --extensions-dir /usr/local/code-server-extensions \
  --user-data-dir /usr/local/code-server-users \
  --enable-proposed-api cwan.native-ascii-converter@1.0.9\
  --force

echo "INFO: all extensions install finished."

/usr/local/code-server/bin/code-server \
  --extensions-dir /usr/local/code-server-extensions \
  --user-data-dir /usr/local/code-server-users \
  --list-extensions --show-versions

echo "INFO: ls -lh /usr/local/code-server-users"
ls -lh /usr/local/code-server-users

echo "INFO: ls -lh /usr/local/code-server-users/User"
ls -lh /usr/local/code-server-users/User


if [[ ${VERSION} != "" ]]; then
  #output
  FINAL_NAME=code-server-v${CODE_SERVER_VERSION}-develop-extensions-${VERSION}
  TARGET_DIR=$GITHUB_WORKSPACE/target
  OUTPUT_DIR=${TARGET_DIR}/${FINAL_NAME}
  mkdir -p ${OUTPUT_DIR}

  #copy assest
  /bin/cp -rf /usr/local/code-server-users/languagepacks.json ${OUTPUT_DIR}/
  /bin/cp -rf /usr/local/code-server-extensions ${OUTPUT_DIR}/

  #build tarball
  tar zcpf ${TARGET_DIR}/${FINAL_NAME}.tar.gz -C ${TARGET_DIR} ${FINAL_NAME}
  chmod 777 ${TARGET_DIR}/${FINAL_NAME}.tar.gz
  echo "INFO: ls -lh ${TARGET_DIR}"
  ls -lh ${TARGET_DIR}
  echo "INFO: build for release finished."
else
    echo "INFO: build for ci finished."
fi
