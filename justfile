#!/usr/bin/env just --justfile
# vim: set noet:

LOVE := "/usr/bin/love"
MON := "nodemon"
PRODUCT_NAME := "Compy"
PRODUCT_NAME_SC := "compy"

unit_test:
	{{MON}} --exec 'echo -en "\n\n\n\n------------- BUSTED -------------\n"; busted tests' -e 'lua'
unit_test_tag TAG:
	{{MON}} -e lua --exec 'echo -en "\n\n\n\n------------- BUSTED -------------\n" ; busted tests --tags {{TAG}}'
ut TAG:
	busted tests --tags {{TAG}}


dev:
	{{MON}} --exec '{{LOVE}} src' -e 'lua'
dev-atest:
	{{MON}} --exec 'clear; {{LOVE}} src --autotest' -e 'lua'
dev-autotest: dev-atest

dev-dtest:
	{{MON}} --exec 'clear; {{LOVE}} src --drawtest' -e 'lua'
dev-drawtest: dev-dtest

dev-allt:
	{{MON}} --exec 'clear; {{LOVE}} src --drawtest --autotest' -e 'lua'

dev-size:
	{{MON}} --exec '{{LOVE}} src --size' -e 'lua'

dev-js-c:
	{{MON}} --exec 'just package-js-c' -e lua &
	cd web/dist-c ; live-server --no-browser --watch="../src"
dev-js:
	{{MON}} --exec 'just package-js' -e lua &
	cd web ; node server.js

setup-web-dev:
	cd web; npm install

one:
	{{LOVE}} src
one-atest:
	{{LOVE}} src --autotest
one-dtest:
	{{LOVE}} src --drawtest
one-allt:
	{{LOVE}} src --drawtest --autotest
one-size:
	{{LOVE}} src --size
one-js-c: package-js-c
	cd web/dist-c; live-server --no-browser --watch='../../src'


package:
	7z a dist/game.love ./src/* > /dev/null


FAVI := "favicon.ico"
DIST := "./web/dist"
DIST-c := "./web/dist-c"

package-js:
	love.js ./src {{DIST}} \
		--title "{{PRODUCT_NAME}}" --memory 67108864
	test -f {{DIST}}/{{FAVI}} || \
		cp -f res/"{{PRODUCT_NAME_SC}}".ico {{DIST}}/{{FAVI}}
package-js-c: # compat mode
	love.js ./src {{DIST-c}} \
		--title "{{PRODUCT_NAME}}" --memory 67108864
	test -f {{DIST-c}}/{{FAVI}} || \
		cp -f res/"{{PRODUCT_NAME_SC}}".ico {{DIST-c}}/{{FAVI}}
