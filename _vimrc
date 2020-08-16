"实现带插件的vim配置

if has("win32")
	source $VIM/_vimnp
	source $VIM/_vimrc_pl
else
	source $HOME/_vimnp
	source $HOME/_vimrc_pl
endif
