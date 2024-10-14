# vim: ts=8:sw=8

###########
#         #
# Options #
#         #
###########
CSV		?=
PASSWORD	?=
DEFAULT_EDITOR	?= ${EDITOR}

#############
#           #
# Constants #
#           #
#############

SYM_CONFIG_PATH	:= "$(shell cat ENV_HOME_SYM_CONFIG)"
SYM_OUT		:= "$(SYM_CONFIG_PATH)/links-clean.out"

# `Main Paths`
# ============
HOME_DIST	:= ${HOME}
DOTS_PATH	:= ${PWD}/dots
SECRETS_PATH	:= ${PWD}/src/secrets/

# `secrets`
# =========
SECRETS_IGNORE	:= ! -wholename "*.git/*" ! -name "Session.vim"
SECRETS_SRC	:= $(shell find $(SECRETS_PATH) -type f $(SECRETS_IGNORE) 2> /dev/null)
SECRETS_OUT	:= $(patsubst $(SECRETS_PATH)/%,$(HOME_DIST)/%,$(SECRETS_SRC))

# `dots`
# ======
DOTS_SRC	:= $(shell find $(DOTS_PATH) -type f $(DOTS_IGNORE))
DOTS_OUT	:= $(patsubst $(DOTS_PATH)/%,$(HOME_DIST)/%,$(DOTS_SRC))
DOTS_IGNORE	:= \
	! -name "*.md" \
	! -path "*plugged/*" \
	! -name "Session.vim" \
	! -path "*.git*"

# `clean`
# =======
CLEAN_SRC	:= $(shell cat $(SYM_OUT) 2> /dev/null)

#############
#           #
# Functions #
#           #
#############

define do_symlink
	@mkdir -p $(dir $(1))
	@ln -sfv $(2) $(1)
	@#prepare symlinks for cleaning when needed
	@[ -f $(SYM_OUT) ] || touch $(SYM_OUT)
	@echo $(1).clean >> $(SYM_OUT)
endef

#########
#       #
# RuleZ #
#       #
#########

# LINK
######

.PHONY: link
link: link-dots link-secrets

.PHONY: clean
clean: $(CLEAN_SRC) post-clean
$(HOME_DIST)/%.clean:
	@printf "x "
	@echo "$@" | sed 's/.clean//' \
		| xargs rm -rfv

.PHONY: update
update: clean link

# LOG
#####

.PHONY: log
log:
	@less $(SYM_CONFIG_PATH)/install.log

.PHONY: log-raw
log-raw:
	@less $(SYM_CONFIG_PATH)/install-raw.log

################
# Helper RuleZ #
################

.PHONY: make-dots-config-dir
make-dots-config-dir:
	@mkdir -p $(SYM_CONFIG_PATH)

.PHONY: post-clean
post-clean:
	@rm -f $(SYM_OUT)

.PHONY: link-dots
link-dots: make-dots-config-dir $(DOTS_OUT)
$(HOME_DIST)/%: $(DOTS_PATH)/%
	$(call do_symlink,$@,$<)

.PHONY: link-secrets
link-secrets: make-dots-config-dir $(SECRETS_OUT)
$(HOME_DIST)/%: $(SECRETS_PATH)/%
	$(call do_symlink,$@,$<)

