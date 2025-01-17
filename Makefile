include .project/go-project.mk
export GO111MODULE=off

CERTS_PREFIX=test_${PROJ_NAME}_

.PHONY: *

.SILENT:

default: help

all: clean gopath tools generate hsmconfig gen_test_certs covtest

gettools:
	mkdir -p ${TOOLS_SRC}
	$(call httpsclone,${GITHUB_HOST},golang/tools,             ${TOOLS_SRC}/golang.org/x/tools,              release-branch.go1.11)
	$(call httpsclone,${GITHUB_HOST},go-phorce/cov-report,     ${TOOLS_SRC}/github.com/go-phorce/cov-report, master)
	$(call httpsclone,${GITHUB_HOST},golang/lint,              ${TOOLS_SRC}/golang.org/x/lint,               06c8688daad7faa9da5a0c2f163a3d14aac986ca)
	$(call httpsclone,${GITHUB_HOST},mattn/goveralls,          ${TOOLS_SRC}/github.com/mattn/goveralls,      88fc0d50edb2e4cf09fe772457b17d6981826cff)
	$(call httpsclone,${GITHUB_HOST},cloudflare/cfssl,         ${TOOLS_SRC}/github.com/cloudflare/cfssl,     ff56ab5eb62a17e335045646238665367267a678)
	#$(call httpsclone,${GITHUB_HOST},jstemmer/go-junit-report, ${TOOLS_SRC}/github.com/jstemmer/go-junit-report, 385fac0ced9acaae6dc5b39144194008ded00697)
	#$(call httpsclone,${GITHUB_HOST},golangci/golangci-lint,   ${TOOLS_SRC}/github.com/golangci/golangci-lint,   master)

tools: gettools
	GOPATH=${TOOLS_PATH} go install golang.org/x/tools/cmd/stringer
	GOPATH=${TOOLS_PATH} go install github.com/go-phorce/cov-report/cmd/cov-report
	GOPATH=${TOOLS_PATH} go install golang.org/x/lint/golint
	GOPATH=${TOOLS_PATH} go install github.com/mattn/goveralls
	GOPATH=${TOOLS_PATH} go install github.com/cloudflare/cfssl/cmd/cfssl
	GOPATH=${TOOLS_PATH} go install github.com/cloudflare/cfssl/cmd/cfssljson
	#GOPATH=${TOOLS_PATH} go install github.com/golangci/golangci-lint/cmd/golangci-lint
	#GOPATH=${TOOLS_PATH} go install github.com/jstemmer/go-junit-report

version:
	gofmt -r '"GIT_VERSION" -> "$(GIT_VERSION)"' version/current.template > version/current.go

build:
	echo "*** running build"
	cd ${TEST_DIR} && go build -o ${PROJ_ROOT}/bin/dollypki ./cmd/dollypki

hsmconfig:
	echo "*** Running hsmconfig"
	mkdir -p ~/softhsm2
	.project/config-softhsm.sh --pin-file ~/softhsm2/pin_unittest.txt --generate-pin -s dolly_unittest -o ./etc/dev/softhsm_unittest.json --list-slots --list-object --delete

gen_test_certs:
	echo "*** Running gen_test_certs"
	.project/gen_test_certs.sh --ca-config $(PROJ_ROOT)/etc/dev/ca-config.dev.json --out-dir $(PROJ_ROOT) --prefix $(CERTS_PREFIX) --root-ca --ca --server --client --peers --admin

dep-update:
	cd ${TEST_DIR} && dep ensure -update
