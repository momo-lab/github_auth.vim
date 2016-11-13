" Generate GitHub Private access token.
" Version: 0.1.0
" Author: momo-lab <momotaro.n@gmail.com> <https://github.com/momo-lab>
" License: MIT

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#github_auth#new()

function! github_auth#generate_token() abort
  call s:login(g:github_auth_username)
  call github_auth#set_token_variables()
endfunction

function! github_auth#remove_token() abort
  call s:get_cache_instance().remove(g:github_auth_username)
  call github_auth#set_token_variables()
endfunction

function! github_auth#set_token_variables() abort
  let token = s:get_token()
  for key in g:github_auth_variables
    if empty(token)
      silent execute printf('unlet! %s', key)
    else
      silent execute printf('let %s = %s', key, string(token))
    endif
  endfor
endfunction

function! s:get_cache_instance() abort
  if !exists('s:cache')
    let s:cache = s:V.import('System.Cache').new('file', {
          \ 'cache_dir': expand(g:github_auth_cache_dir)
          \ })
  endif
  return s:cache
endfunction

function! s:get_token() abort
  return s:get_cache_instance().get(g:github_auth_username)
endfunction

function! s:login(username) abort
  if !exists('s:client')
    let s:client = s:V.import('Web.API.GitHub').new({
          \ 'token_cache': s:get_cache_instance(),
          \ 'authorize_scopes': ['repo'],
          \ 'authorize_note': printf('github_auth.vim@%s', hostname()),
          \ 'authorize_note_url': 'https://github.com/momo-lab/github_auth.vim',
          \ })
  endif
  call s:client.login(a:username, {'force': 1})
endfunction

function! s:define_variables(key, value) abort
  let global_key = 'g:github_auth_' . a:key
  if !exists(global_key)
    silent execute printf('let %s = %s', global_key, string(a:value))
  endif
endfunction

function! s:get_github_user() abort
  return substitute(system('git config github.user'), '\n', '', 'mg')
endfunction

" Default settings
call s:define_variables('cache_dir', '~/.cache/github_auth.vim')
call s:define_variables('username', s:get_github_user())
call s:define_variables('variables', ['g:github_access_token'])

let &cpo = s:save_cpo
unlet s:save_cpo
