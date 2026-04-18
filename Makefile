PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin

.PHONY: install uninstall check test help

help:
	@echo "targets:"
	@echo "  make install [PREFIX=...]    install deadman to \$$PREFIX/bin (default /usr/local)"
	@echo "  make uninstall [PREFIX=...]  remove deadman from \$$PREFIX/bin"
	@echo "  make check                   bash syntax check"
	@echo "  make test                    alias for check"

install:
	install -d "$(BINDIR)"
	install -m 755 deadman "$(BINDIR)/deadman"
	@echo "installed: $(BINDIR)/deadman"

uninstall:
	rm -f "$(BINDIR)/deadman"
	@echo "removed: $(BINDIR)/deadman"

check:
	bash -n deadman
	@echo "syntax OK"

test: check
