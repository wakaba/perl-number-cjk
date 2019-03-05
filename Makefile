all: build

WGET = wget
CURL = curl
GIT = git

updatenightly: local/bin/pmbp.pl build-clean
	$(CURL) -s -S -L https://gist.githubusercontent.com/wakaba/34a71d3137a52abb562d/raw/gistfile1.txt | sh
	$(GIT) add t_deps/modules
	perl local/bin/pmbp.pl --update
	$(GIT) add config
	$(CURL) -sSLf https://raw.githubusercontent.com/wakaba/ciconfig/master/ciconfig | RUN_GIT=1 REMOVE_UNUSED=1 perl

clean: build-clean

## ------ Setup ------

deps: git-submodules pmbp-install

git-submodules:
	$(GIT) submodule update --init

PMBP_OPTIONS=

local/bin/pmbp.pl:
	mkdir -p local/bin
	$(CURL) -s -S -L https://raw.githubusercontent.com/wakaba/perl-setupenv/master/bin/pmbp.pl > $@
pmbp-upgrade: local/bin/pmbp.pl
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update-pmbp-pl
pmbp-update: git-submodules pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --update
pmbp-install: pmbp-upgrade
	perl local/bin/pmbp.pl $(PMBP_OPTIONS) --install \
            --create-perl-command-shortcut @perl \
            --create-perl-command-shortcut @prove

## ------ Build ------

build: lib/Number/CJK/_Classes.pm t_deps/lib/TestData.pm
build-clean:
	rm -fr lib/Number/CJK/_Classes.pm t_deps/lib/TestData.pm

lib/Number/CJK/_Classes.pm:
	echo 'package Number::CJK::Parser;' > $@
	curl -f -L -X POST https://chars.suikawiki.org/set/perlrevars \
	    --form 'item=$$Digit=$$numbers:CJK-digit' \
	    --form 'item=$$TenQuadrillion=$$numbers:CJK-ten-quadrillion' \
	    --form 'item=$$Trillion=$$numbers:CJK-trillion' \
	    --form 'item=$$HundredMillion=$$numbers:CJK-hundred-million' \
	    --form 'item=$$TenThousand=$$numbers:CJK-ten-thousand' \
	    --form 'item=$$Thousand=$$numbers:CJK-thousand' \
	    --form 'item=$$Hundred=$$numbers:CJK-hundred' \
	    --form 'item=$$Ten=$$numbers:CJK-ten' \
	    --form 'item=$$MultipleTens=$$numbers:CJK-multiple-tens' >> $@
	curl -f -L https://raw.githubusercontent.com/manakai/data-chars/master/data/number-values.json | \
	curl -f -L -X POST --data-binary @- https://misc-tools.herokuapp.com/json2perl | \
	perl -e 'local $$/; $$data = eval <>; use Data::Dumper; $$Data::Dumper::Sortkeys = 1; print q{$$Value = }, Dumper {map { $$_ => $$data->{$$_}->{cjk_numeral} } grep { defined $$data->{$$_}->{cjk_numeral} } keys %$$data}; print q{;};' >> $@
	echo "1;" >> $@

t_deps/lib/TestData.pm:
	echo '$$Tests = ' > $@
	curl -f -L https://raw.githubusercontent.com/manakai/data-chars/master/data/tests/cjk-numbers.json | \
	curl -f -L -X POST --data-binary @- https://misc-tools.herokuapp.com/json2perl >> $@
	echo '; 1;' >> $@

## ------ Tests ------

PROVE = ./prove

test: test-deps test-main

test-deps: deps

test-main:
	$(PROVE) t/*.t

## License: Public Domain.
