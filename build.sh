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

# 下载前启动code-server服务,否则语言包的languagepacks.json文件无法下载
nohup /usr/local/code-server/bin/code-server \
  --extensions-dir /usr/local/code-server-extensions \
  --user-data-dir /usr/local/code-server-users \
  --bind-addr 0.0.0.0:8081 \
  --auth none > /dev/null 2>&1 &
# 等待3秒,保证启动完毕
sleep 3
# 仅仅启动也没用,需要模拟一次访问,此时code-server才会在user-data-dir中生成运行时文件,后续安装语言包才能生成languagepacks.json文件
curl http://localhost:8081 > /dev/null

# 以下插件直接通过名称安装出现找不到的错误,因此手动下载,通过指定vsix安装
curl -J -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/cwan/vsextensions/native-ascii-converter/1.0.9/vspackage | gunzip > /tmp/native-ascii-converter-1.0.9.vsix
curl -J -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/adpyke/vsextensions/vscode-sql-formatter/1.4.4/vspackage | gunzip > /tmp/adpyke.vscode-sql-formatter-1.4.4.vsix
curl -J -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools/0.23.0/vspackage | gunzip > /tmp/mtxr.sqltools-0.23.0.vsix
curl -J -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/0.2.0/vspackage | gunzip > /tmp/mtxr.sqltools-driver-pg-0.2.0.vsix
curl -J -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/zaaack/vsextensions/markdown-editor/0.1.7/vspackage | gunzip > /tmp/zaaack.markdown-editor-0.1.7.vsix
curl -J -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/hediet/vsextensions/vscode-drawio/1.4.0/vspackage | gunzip > /tmp/hediet.vscode-drawio-1.4.0.vsix
/usr/local/code-server/bin/code-server \
  --extensions-dir /usr/local/code-server-extensions \
  --user-data-dir /usr/local/code-server-users \
  --install-extension MS-CEINTL.vscode-language-pack-zh-hans \
  --install-extension k--kato.intellij-idea-keybindings \
  --install-extension ahmadawais.shades-of-purple \
  --install-extension GitHub.github-vscode-theme \
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
  --install-extension mubaidr.vuejs-extension-pack \
  --install-extension formulahendry.auto-close-tag \
  --install-extension formulahendry.auto-rename-tag \
  --install-extension xabikos.JavaScriptSnippets \
  --install-extension christian-kohler.path-intellisense \
  --install-extension ecmel.vscode-html-css \
  --install-extension HookyQR.beautify \
  --install-extension GabrielBB.vscode-lombok \
  --install-extension Pivotal.vscode-boot-dev-pack \
  --install-extension OBKoro1.korofileheader \
  --install-extension dbaeumer.vscode-eslint \
  --install-extension ms-azuretools.vscode-docker \
  --install-extension samuelcolvin.jinjahtml \
  --install-extension /tmp/native-ascii-converter-1.0.9.vsix \
  --install-extension /tmp/adpyke.vscode-sql-formatter-1.4.4.vsix \
  --install-extension /tmp/mtxr.sqltools-0.23.0.vsix \
  --install-extension /tmp/mtxr.sqltools-driver-pg-0.2.0.vsix \
  --install-extension /tmp/zaaack.markdown-editor-0.1.7.vsix \
  --install-extension /tmp/hediet.vscode-drawio-1.4.0.vsix

echo "INFO: all extensions install finished."

/usr/local/code-server/bin/code-server \
  --extensions-dir /usr/local/code-server-extensions \
  --user-data-dir /usr/local/code-server-users \
  --list-extensions --show-versions

echo "INFO: ls -lh /usr/local/code-server-users"
ls -lh /usr/local/code-server-users

echo "INFO: ls -lh /usr/local/code-server-users/User"
ls -lh /usr/local/code-server-users/User

# 停止code-server服务
ps -ef | grep code-server | grep 8081 | awk '{print $2}' | xargs kill > /dev/null 2>&1 || echo '0'

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
