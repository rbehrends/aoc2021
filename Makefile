WAF=tools/waf
LIB=$(wildcard lib/*.d)

all build: .FORCE
	$(WAF) build
opt: .FORCE
	$(WAF) build --opt
clean: .FORCE
	$(WAF) clean
run%: bin/day% .FORCE
	bin/day$(call variant,$@) input/input$(call num,$@).txt
test%: bin/day% .FORCE
	bin/day$(call variant,$@) input/test$(call num,$@).txt
bin/day%: src/day%.d $(LIB)
	$(WAF) build --targets="$(PWD)/$@"
opt%: .FORCE
	$(WAF) build --opt --targets="$(PWD)/bin/day$(call variant,$@)"
build%: .FORCE
	$(WAF) build --targets="$(PWD)/bin/day$(call variant,$@)"
distclean:
	$(WAF) distclean

.FORCE:
.PRECIOUS: bin/day%

num=$(shell echo $(1) | sed -e 's/[^0-9]//g')
variant=$(shell echo $(1) | sed -e 's/[^0-9]*//')
