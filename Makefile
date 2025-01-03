# vim: ts=8:sw=8

###########
#         #
# Options #
#         #
###########
CSV		?=
DEFAULT_EDITOR	?= ${EDITOR}

#############
#           #
# Constants #
#           #
#############

SYM_CONFIG_PATH			:= "$(shell cat ENV_HOME_SYM_CONFIG)"
SYM_CONFIG_INSTALL_LOG		:= "$(shell cat ENV_SYM_INSTALL_LOG)"
SYM_CONFIG_INSTALL_LOG_STATUS	:= "$(shell cat ENV_SYM_INSTALL_LOG_STATUS)"
SYM_OUT				:= "$(SYM_CONFIG_PATH)/links-clean.out"
SYM_IGNORE			:= \
	! -path "*.git*" \
	! -name "Session.vim" \
	! -name "*.md" \
	! -path "*plugged/*"

# `Main Paths`
# ============
HOME_DIST	:= ${HOME}
DOTS_PATH	:= ${PWD}/dots
SECRETS_PATH	:= $(HOME_DIST)/projects/secrets/dots
NVIM_PATH	:= $(HOME_DIST)/projects/nvim

# `secrets`
# =========
SECRETS_SRC	:= $(shell find $(SECRETS_PATH) -type f $(SYM_IGNORE) 2> /dev/null)
SECRETS_OUT	:= $(patsubst $(SECRETS_PATH)/%,$(HOME_DIST)/%,$(SECRETS_SRC))

# `nvim`
# ======
HOME_DIST_NVIM	:= $(HOME_DIST)/.config/nvim
NVIM_SRC	:= $(shell find $(NVIM_PATH) -type f $(SYM_IGNORE) 2> /dev/null)
NVIM_OUT	:= $(patsubst $(NVIM_PATH)/%,$(HOME_DIST_NVIM)/%,$(NVIM_SRC))

# `SHs`
# =====
SH_FILES	:= $(shell ${PWD}/src/utils/find-sh-files.sh)

# `dots`
# ======
DOTS_SRC	:= $(shell find $(DOTS_PATH) -type f $(SYM_IGNORE))
DOTS_OUT	:= $(patsubst $(DOTS_PATH)/%,$(HOME_DIST)/%,$(DOTS_SRC))

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
link: link-dots link-secrets link-nvim

.PHONY: clean
clean: $(CLEAN_SRC) post-clean
$(HOME_DIST)/%.clean:
	@printf "x "
	@echo "$@" | sed 's/.clean//' \
		| xargs rm -rfv

.PHONY: update
update: clean link

# INSTALL
#########

.PHONY: install
install: make-dots-config-dir
	@./src/install.sh $(CSV)

.PHONY: install-clean
install-clean:
	@rm -rf $(SYM_CONFIG_INSTALL_LOG)
	@rm -rf $(SYM_CONFIG_INSTALL_LOG_STATUS)

# LOG
#####

.PHONY: log
log:
	@less $(SYM_CONFIG_INSTALL_LOG)

.PHONY: log-raw
log-status:
	@less $(SYM_CONFIG_INSTALL_LOG_STATUS)

# TEST
######

.PHONY: test
test:
	@shellcheck $(SH_FILES)

.PHONY: test-fix
test-fix:
	@shellcheck $(SH_FILES) \
		| grep "^In" \
		| cut -d' ' -f2 \
		| xargs nvim

################
# Helper RuleZ #
################

.PHONY: clean-all
clean-all: clean install-clean

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

.PHONY: link-nvim
link-nvim: make-dots-config-dir $(NVIM_OUT)
$(HOME_DIST_NVIM)/%: $(NVIM_PATH)/%
	$(call do_symlink,$@,$<)

