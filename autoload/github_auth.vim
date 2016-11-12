let s:V = vital#github_auth#new()
let s:GitHub = s:V.import('Web.API.GitHub')
let s:Cache = s:V.import('System.Cache')

function! github_auth#make_token() abort
  let client = s:get_client_instance()
  call client.login(g:github_auth#username)
  call github_auth#set_token_variables()
endfunction

function! github_auth#set_token_variables() abort
  let client = s:get_client_instance()
  let token = client.get_token(g:github_auth#username)
  for key in g:github_auth#variables
    if empty(token)
      if exists(string(key))
        silent execute printf('unlet %s', key)
      end
    else
      silent execute printf('let %s = %s', key, string(token))
    endif
  endfor
endfunction

function! s:get_client_instance() abort
  if !exists('s:client')
    let cache = s:Cache.new('file', {
        \ 'cache_dir': expand(g:github_auth#cache_dir)
        \ })
    let s:client = s:GitHub.new({
        \ 'token_cache': cache
        \ })
  end
  return s:client
endfunction

function! s:define_variables(key, value) abort
  let global_key = 'g:github_auth#' . a:key
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

" Web.API.GitHub settings
call s:GitHub.set_config({
    \ 'authorize_scopes': ['repo'],
    \ 'authorize_note': printf('github_auth.vim@%s', hostname()),
    \ 'authorize_note_url': 'https://github.com/momo-lab/github_auth.vim',
    \ 'skip_authentication': 1,
    \ })
