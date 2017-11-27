NAME = "main"
GOFILES = $(shell find . -name '*.go' -not -path './vendor/*')
GOPACKAGES = $(shell go list ./... | grep -v /vendor/)
LDFLAGS := "-s -w -X \"main.Version=$(VERSION)\" -X \"main.Revision=$(REVISION)\" -extldflags \"-static\""
DOCKERTAG="test01"

defult: build

.PHONY: depinit
depinit:
	go get -u github.com/golang/dep/...
	dep init

.PHONY: dep
dep: 
	go get -u github.com/golang/dep/...
	dep ensure

.PHONY: depup
depup:
	go get -u github.com/golang/dep/...
	dep ensure -update

.PHONY: build-linux
build-linux: main.go dep
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -tags netgo -installsuffix netgo -ldflags $(LDFLAGS) -o bin/$(NAME)

.PHONY: build-windows-64bit
build-windows-64bit: main.go dep
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -a -tags netgo -installsuffix netgo -ldflags $(LDFLAGS) -o bin/$(NAME)

.PHONY: build-mac
build-mac: main.go dep
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -a -tags netgo -installsuffix netgo -ldflags $(LDFLAGS) -o bin/$(NAME)

.PHONY: install
install: main.go dep
	go install -ldflags $(LDFLAGS)

.PHONY: clean
clean:
	rm -rf ./bin
	rm -rf vendor/*

.PHONY: lint
lint:
	@go get -v github.com/golang/lint/golint
	$(foreach file,$(GOFILES),golint $(file) || exit;)

.PHONY: vet
vet:
	$(foreach file,$(GOFILES),go vet $(file) || exit;)

.PHONY: fmtcheck
fmtcheck:
	gofmt -d $(GOFILES)

.PHONY: fmt
fmt:
	gofmt -w $(GOFILES)

.PHONY: pretest
pretest: lint vet fmtcheck

.PHONY: test
test:
	$(foreach package,$(GOPACKAGES),go test -cover -v $(package) || exit;)

.PHONY: cov
cov:
	@go get -v github.com/axw/gocov/gocov
	@go get golang.org/x/tools/cmd/cover
	gocov test | gocov report

.PHONY: build-docker
build-docker:
	docker build -t ${DOCKERTAG} .
