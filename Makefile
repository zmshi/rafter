
.PHONY: test deps

REBAR=$(shell which rebar > /dev/null 2>&1 && echo "rebar" || "./rebar")

rafter:
	$(REBAR) compile
deps:
	$(REBAR) get-deps
test:
	$(REBAR) eunit skip_deps=true

APPS = kernel stdlib sasl erts ssl tools os_mon runtime_tools crypto inets \
	xmerl webtool eunit syntax_tools compiler
PLT = rafter_dialyzer.plt

check_plt:
	dialyzer --check_plt --plt $(PLT) --apps $(APPS)

build_plt:
	dialyzer --build_plt --output_plt $(PLT) --apps $(APPS)

dialyzer:
	@echo
	@echo Use "'make check_plt'" to check PLT prior to using this target.
	@echo Use "'make build_plt'" to build PLT prior to using this target.
	@echo
	@sleep 1
	dialyzer -Wno_return -Wunmatched_returns -Wrace_conditions \
		--plt $(PLT) deps/*/ebin ebin | \
	    tee .dialyzer.raw-output

cleanplt:
	@echo
	@echo "Are you sure?  It takes about 1/2 hour to re-build."
	@echo Deleting $(PLT) in 5 seconds.
	@echo
	sleep 5
	rm $(PLT)

xref: compile
	$(REBAR) xref skip_deps=true | grep -v unused | egrep -v -f ./xref.ignore-warnings

