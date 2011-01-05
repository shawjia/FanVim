" ==============================================================
" FanVim - Post Status to Fanfou from Vim
" Language: Vim Script
" Maintainer: Shawjia <sogood5460@gmail.com>
" Modified From: TwitVim
" Created: Dec 12, 2010
" Last Change: Dec 22, 2010
" ==============================================================

" Load this module only once
if exists("loaded_fanvim")
  finish
endif
let loaded_fanvim = 1

" Set defalult login info and char_limit
let s:login = ""
let s:char_limit = 140

" For more api, check the site below
" http://code.google.com/p/fanfou-api/wiki/ApiDocumentation
let s:ffupdate = 'http://api.fanfou.com/statuses/update.xml'

function! s:get_config()
    if exists('g:fanvim_login')
		let s:login = "-u " . g:fanvim_login
    else
		call s:errormsg('add config first: let fanvim_login="USER:PASS"')
		return -1
    endif
    return 0
endfunction

" Get the length of string
function! s:mbstrlen(s)
    return strlen(substitute(a:s, ".", "x", "g"))
endfunction

" Display an error message in the message area.
function! s:errormsg(msg)
    redraw
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction

function! s:post_fanfou(mesg)
    let rc = s:get_config()
    if rc < 0
		return -1
    endif

    let mesg = a:mesg
	let mesglen = s:mbstrlen(mesg)

	if mesglen > s:char_limit
		call s:errormsg('Too many characters, the max length is 140, yours is '.mesglen)
		return -1
	elseif mesglen < 1
		call s:errormsg('Empty status is not allowed')
		return -1
	endif
	
	let output = system("curl ".s:login.' -d "source=fanvim&status='.mesg.'" '.s:ffupdate)
	if output !~ 'error'
		echo 'Post status to Fanfou successfully :)'
	else
		call s:errormsg('Login fail, please check your setting')
	endif
endfunction

function! s:CmdLine_Fanfou()
    let rc = s:get_config()
    if rc < 0
	return -1
    endif

    call inputsave()
    let mesg = input("Your status: ")
    call inputrestore()
    call s:post_fanfou(mesg)
endfunction

command! PosttoFanfou :call <SID>CmdLine_Fanfou()
command! CPosttoFanfou :call <SID>post_fanfou(getline('.'))
command! BPosttoFanfou :call <SID>post_fanfou(join(getline(1, "$")))

" vim:set tw=0:
