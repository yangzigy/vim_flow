vim_flow
==========

vim工作流，使用vim、bash构建便携式文本编辑工作流，工作流支持windows下gvim、和linux下的vim\neovim包括配置文件、插件、依赖库以及对特定问题的解决方式，可实现便携式运行，windows下无需安装，linux下可不干扰原有配置。  

<div align=center><img src="https://github.com/yangzigy/vim_flow/raw/master/gui.jpg"/></div>

对于windows，实现便携式部署的方式是将gvim.exe放置在vim需要的配置文件环境中（vim80和vimfiles）  
对于linux，通过在~/bin下创建mvim脚本的链接vif来实现不干扰其他用户的部署。mvim脚本中首先改写$HOME使vim和bash的配置文件在局部生效。  
## 文件组织：  
```text
ext_exe:	windows下存放直接可执行的文件（插件需要的）
vim_flow:		根目录，存gvim.exe
	vim80：	基本插件
	vimfilse：	扩展插件
	配置脚本
```
## 脚本列表：  
一个便携脚本：	mvim：在执行depvimrc时生成  
一个部署脚本:	depvimrc  
vim脚本：  
```text
	_gvimrc:	gvim使用的额外配置
	_vimrc_pl:	插件的配置
	_vimnp:		无插件版本
	
	_vimp:		部署用, ->_vimnp,->_vimrc_pl
	_bashrc:	bash的配置文件
```
## 部署：  
	vim的执行文件只要放在vim文件夹下，运行时就能访问到vimfiles里的插件  
1、在windows下部署：  
	直接为目录下的gvim.exe添加关联即可  
2、在linux下部署：  
	可以使用./depvimrc np或者pl或者m来选择部署的类型  
	对于便携式（m）部署，使用vif命令来执行  

## vi工作流的插件：  
一般代码工具：  
```text
	1、snipMate		代码提示和一般代码段录入
	2、AutoComplPop		自动补全
	3、rainbow_parentheses	让括号带不同的颜色
		添加启动触发
	4、multiple_cursors		类似sublime的多个单词选择操作
	5、bufexplorer	文件管理器
	6、NERD_tree	文件管理器
	7、minibufexpl	文件管理器，在与NERD配合的时候，在一个文件夹内启动vim，切换到另一个文件夹打开文件会出现bug，minibufer窗体出现在上半个屏幕且没有内容
		需要修改源代码：
		将所有的    != '-MiniBufExplorer-'    改为    !~ '-MiniBufExplorer-'
					== '-MiniBufExplorer-'    改为    =~ '-MiniBufExplorer-'
	8、conque_term：	在vim中打开shell
		为了在shell中不做代码提示，并加入行号，在autoload/conque_term.vim中：
		搜索并注释conque_term#set_buffer_settings函数中的：setlocal nonumber
		在函数 conque_term#on_focus 中：
			"让acp失效
			if exists('g:loaded_autoload_acp')
				try
					call acp#lock()
				catch
					echo 'on_focus'
				endtry
			endif
		在函数 conque_term#on_blur 中：
			"让acp失效
			if exists('g:loaded_autoload_acp')
				try
					call acp#unlock()
				catch
					echo 'on_blur'
				endtry
			endif
	9、SrcExpl：	利用ctags进行代码查看
		为了让SrcExpl的窗口小，不占用窗口行数，修改源代码，使其窗口出现在本窗口的下方：
		（1）为使窗口出现在当前窗口的下方，而不是永远在所有窗口下方，在srcexpl.vim中：585行左右：
			exe 'silent! rightbelow ' . string(g:SrcExpl_winHeight) . 'split ' . a:wincmd
		（2）原来代码中直接获取最后一个窗口就能得到打开的窗口，现在需要获得刚刚打开的窗口：
			"需要获取最新打开的窗口
			"let srcexpl_win = winnr("$")
			let srcexpl_win = winnr()
		（3）原来代码中初始化时首先找到第一个编辑窗口，而不是当前窗口，这里需要改为当前窗口。
			只需注释掉1473行，不切换窗口即可：
		    "silent! exe l:tmp . "wincmd w"
		（4）发现此脚本生成ctags的时候会修改工作目录，将此功能去除，注释309行：
			"silent! exe "cd " . expand('%:p:h')
		（5）同时需要在脚本中做如下修改：
			let g:SrcExpl_pluginList = [
			        \ "__Tag_List__",
			        \ "_NERD_tree_"
			    \ ]
			nmap <F8>t :SrcExplToggle<CR>
			let g:SrcExpl_winHeight = 6
			let g:SrcExpl_gobackKey = "<f8>b"
			let g:SrcExpl_refreshTime = 500
```
C++开发：  
```text
	clang_complete	代码补全（一般禁止）
		有时候会报找不到buildin include文件夹，可以在libclang.py文件中注释掉相关print语句，	第95行的if
		需要使用clang，windows需要下载libclang.dll，linux需要安装clang，并修改so的软连接
		配置：
			libclang的路径
			部分使能
```

bash的配置：在.bashrc中  
## 自定义配置
### 配置设计
首先通过简化光标移动和字符编辑功能，让vim编辑速度达到使用鼠标的程度。  
光标移动主要是在双手不离开asdf、jkl;大体位置的条件下，实现home\end\pageup\pagedown\up\donw\left\right功能；实现在行首行尾插入功能、找到特定字母、按单词前进后退、重复跳跃、查找、设置书签、按大括号移动、让屏幕移动到以当前行为中心、精确定位行等  
字符编辑主要是原位修改、单词替换、块选择、复制粘贴、删除行移动行、重复操作、撤销重做、替换、注释等功能  
在此基础上，通过vim特有的扩展功能让编辑效率高于鼠标,不可替代:多文件查找替换功能；完全使用键盘利于宏的发挥；json格式化；增加多窗口开关移动速度提高文字编辑复制粘贴效率；与文件管理器紧密结合；内嵌shell，实现命令编辑、结果文字编辑与查询；diff功能；多文件脚本话的宏；  
在快捷键设计上，尽量降低ctrl的使用，降低左手小拇指疲劳，改用alt和space；由于alt在终端上需要配置才能用，个别键与原有快捷键冲突，所以除移动等最常用需要组合键的功能外，常用功能都使用space连按组合键实现；一般功能使用f功能键连按组合实现

### 配置
* 显示行号
* table长度为4
* 不用空格代替tab
* 增量搜索
* 高亮搜索
* 搜索时忽略大小写
* 显示tab为:
* 无备份和交换文件
* 编码为utf8
* 设置当文件被改动时自动载入
* 修改状态栏
* 按键超时时间500ms

### 快捷键

```text
* 编译: F7
* 移动两行：<C-S-Up> <C-S-Down>
* 在插入模式行中间插入新行：<C-CR>
* CTRL-C 复制,CTRL-V 粘贴 CTRL-S保存
* <C-a> <home>
* <C-e> <end>
* jj推出
* 查找定义和后退： gy,gb
* 代替ctrl+r访问寄存器: <A-r>
* 粘贴功能,alt+0、1、'、p访问对应寄存器
* 停止高亮: <Space>;
* 查看当前路径：<Space>c
* 宏放映: <Space>q
* 行内移动,到行首和行尾: <Space>h,<Space>l
* 替换当前单词：<SPACE>s
* 在目录中查找: <SPACE>f
* 插入日期时间: <SPACE>d
* 开diff模式: <SPACE>t
* 更新diff窗口：<SPACE>u
* 选择{块的首部和选择整个块: <space>o,<space>p
* 保存所有，退出，退出不保存:<space>aw,<space>aa,<space>aq
* 复制当前行并注释原来的行：<space>y
* 查看刚才查找的个数:<space>n
* 替换: <f3>h
* 重新加载: <f5>
* 粘贴模式：<f8>p
* wrap： <f8>w
* 将文本变成hex字符：<f8>h
* 设置当前buf是否显示二进制： <f8>b
* json格式化,可视化，紧凑:<f8>j,<f8>m 
* 打开文件查看器：<SPACE>w,<space><space>b,<space><space>m
* 
```
