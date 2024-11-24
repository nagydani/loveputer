#!/usr/bin/env just --justfile

default:
  @just --list

LOVE := "/usr/bin/love"
MON := "nodemon"
PRODUCT_NAME := "Compy"
PRODUCT_NAME_SC := "compy"
FAVI := "favicon.ico"

DIST := "dist"
WEBDIST := "./dist/web"
WEBDIST-c := "./dist/web-c"

# run unit tests on file change
unit_test:
  @{{MON}} --exec 'echo -en "\n\n\n\n------------- BUSTED -------------\n"; busted tests' -e 'lua'
unit_test_tag TAG:
  @{{MON}} -e lua --exec 'echo -en "\n\n\n\n------------- BUSTED -------------\n" ; busted tests --tags {{TAG}}'
# run unit tests of this tag once
ut TAG:
  @busted tests --tags {{TAG}}
ut_all:
  @busted tests

# run app on file change
dev:
  @{{MON}} --exec '{{LOVE}} src' -e 'lua'
dev-atest:
  @{{MON}} --exec 'clear; {{LOVE}} src --autotest' -e 'lua'
dev-atest-dbg:
  @DEBUG=1 just dev-atest
dev-autotest: dev-atest

dev-dtest:
  @{{MON}} --exec 'clear; {{LOVE}} src --drawtest' -e 'lua'
dev-drawtest: dev-dtest

dev-allt:
  @{{MON}} --exec 'clear; {{LOVE}} src --drawtest --autotest' -e 'lua'

dev-size:
  @{{MON}} --exec '{{LOVE}} src --size' -e 'lua'

# install examples to projects folder (same as in-app)
deploy-examples:
  #!/usr/bin/env -S bash
  PROJ_PATH="$HOME/Documents/{{PRODUCT_NAME_SC}}/projects"
  EX_PATH="src/examples"

  for i in "$EX_PATH"/*/main.lua
  do
    P="$(basename $(dirname $i))"
    # du -sh "$PROJ_PATH/$P"
    cp -r "$EX_PATH/$P" "$PROJ_PATH/"
  done
# copy examples from project folder to dist and examples folder
snap-examples:
  #!/usr/bin/env -S bash
  PROJ_PATH="$HOME/Documents/{{PRODUCT_NAME_SC}}/projects"
  EX_PATH="src/examples"

  TS="$(date +"%F_%T")"
  TS=${TS//:/-}
  DIR="dist/examples/$TS"
  mkdir -p "$DIR"

  for i in "$EX_PATH"/*/main.lua
  do
    P="$(basename $(dirname $i))"
    # du -sh "$PROJ_PATH/$P"
    rsync -r --checksum "$PROJ_PATH/$P/" "$EX_PATH/$P/"
    cp -r "$PROJ_PATH/$P" "$DIR"/
  done

dev-dogfood-examples:
  @{{MON}} --verbose \
    --exec '{{LOVE}} src --autotest; just snap-examples' \
    -e 'lua' -w 'src'

# run webserver on 8080 with hot reload
dev-js:
  @{{MON}} --exec 'just package-js' -e lua &
  @cd web ; node server.js
# run webserver on 8080 with hot reload (compat mode)
dev-js-c:
  @{{MON}} --exec 'just package-js-c' -e lua &
  @cd {{WEBDIST-c}} ; \
    live-server --no-browser --watch="../../src"

# install prerequisites for running/packaging js verison
setup-web-dev:
  cd web ; npm install

one:
  @{{LOVE}} src
one-atest:
  @{{LOVE}} src --autotest
one-dtest:
  @{{LOVE}} src --drawtest
one-allt:
  @{{LOVE}} src --drawtest --autotest
one-size:
  @{{LOVE}} src --size


package:
  @7z a {{DIST}}/game.love ./src/* > /dev/null
  @echo packaged:
  @ls -lh {{DIST}}/game.love

package-web: package-js
  @rm -f {{DIST}}/{{PRODUCT_NAME}}-web.zip
  @7z a {{DIST}}/{{PRODUCT_NAME}}-web.zip {{WEBDIST}}/* \
    > /dev/null
  @echo packaged:
  @ls -lh {{DIST}}/{{PRODUCT_NAME}}-web.zip

package-js-dir DT:
  #!/usr/bin/env -S bash
  WEB={{DT}}
  unset C
  [[ $WEB =~ "-c" ]] && C='-c'
  pushd web &> /dev/null
  npx love.js $C ../src ../$WEB \
    --title "{{PRODUCT_NAME}}" --memory 67108864
  popd &> /dev/null
  test -f $WEB/{{FAVI}} || \
    cp -f res/"{{PRODUCT_NAME_SC}}".ico $WEB/{{FAVI}}
  mkdir -p $WEB/doc
  cp -r doc/interface $WEB/doc/
  cd web
  node render_md.js
  rm ../$WEB/theme/bg.png
  cp index.html ../$WEB
  cat head.html \
      ../{{DIST}}/_readme.html \
      tail.html > ../$WEB/readme.html
  cp love.css ../$WEB/theme/

package-js: (package-js-dir WEBDIST)
# compat mode
package-js-c: (package-js-dir WEBDIST-c)

import? 'local.just'

# Create git hooks
setup-hooks:
  #!/usr/bin/env -S bash
  HDIR=.git/hooks
  cat > $HDIR/pre-commit << EOF
  #!/bin/sh
  just ut_all
  EOF
  chmod +x $HDIR/pre-commit
