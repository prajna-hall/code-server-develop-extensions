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
  --install-extension MS-CEINTL.vscode-language-pack-zh-hans \
  --install-extension k--kato.intellij-idea-keybindings \
  --install-extension ahmadawais.shades-of-purple \
  --install-extension pkief.material-icon-theme \
  --install-extension eamodio.gitlens \
  --install-extension donjayamanne.python-extension-pack \
  --install-extension vscjava.vscode-java-pack \
  --install-extension SonarSource.sonarlint-vscode \
  --install-extension redhat.vscode-xml \
  --install-extension redhat.vscode-yaml \
  --install-extension bungcip.better-toml \
  --install-extension scala-lang.scala \
  --install-extension scalameta.metals \
  --install-extension aaron-bond.better-comments \
  --install-extension yzhang.markdown-all-in-one \
  --install-extension goessner.mdmath \
  --install-extension coenraads.bracket-pair-colorizer-2 \
  --install-extension editorconfig.editorconfig \
  --install-extension streetsidesoftware.code-spell-checker \
  --install-extension octref.vetur \
  --install-extension formulahendry.auto-close-tag \
  --install-extension formulahendry.auto-rename-tag \
  --install-extension xabikos.JavaScriptSnippets \
  --install-extension christian-kohler.path-intellisense \
  --install-extension ecmel.vscode-html-css \
  --install-extension HookyQR.beautify \
  --install-extension GabrielBB.vscode-lombok \
  --install-extension Pivotal.vscode-boot-dev-pack \
  --install-extension OBKoro1.korofileheader \
  --install-extension hediet.vscode-drawio \
  --install-extension ${GITHUB_WORKSPACE}/cwan.native-ascii-converter-1.0.9.vsix

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
