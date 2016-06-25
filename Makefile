.PHONY: usage
usage:
	@echo Take a look at the Makefile and install the things you want.

.PHONY: update-submodules
update-submodules:
	git submodule update --init --recursive

.PHONY: git
git:
	ln -sf $$(pwd)/git/gitconfig ~/.gitconfig
	ln -sf $$(pwd)/git/globalgitignore ~/.globalgitignore

.PHONY: zsh
zsh: update-submodules
	ln -snf $$(pwd)/zsh/zprezto ~/.zprezto
	ln -sf $$(pwd)/zsh/zprezto/runcoms/zlogin ~/.zlogin
	ln -sf $$(pwd)/zsh/zprezto/runcoms/zlogout ~/.zlogout
	ln -sf $$(pwd)/zsh/zprezto/runcoms/zprofile ~/.zprofile
	ln -sf $$(pwd)/zsh/zprezto/runcoms/zshenv ~/.zshenv
	ln -sf $$(pwd)/zsh/zshrc ~/.zshrc
	ln -sf $$(pwd)/zsh/zpreztorc ~/.zpreztorc

.PHONY: i3
i3:
	mkdir -p ~/.config/i3
	ln -sf $$(pwd)/i3/config ~/.config/i3/config

.PHONY: terminator
terminator:
	mkdir -p ~/.config/terminator
	ln -sf $$(pwd)/terminator/config ~/.config/terminator/config

.PHONY: fonts
fonts:
	@echo Please install Consolas manually.

.PHONY: hidpi
hidpi:
	ln -sf $$(pwd)/hidpi/xprofile ~/.xprofile
	ln -sf $$(pwd)/hidpi/Xresources ~/.Xresources

.PHONY: macbook
macbook: git zsh

.PHONY: ubuntuvm
ubuntuvm: git zsh i3 terminator hidpi fonts
