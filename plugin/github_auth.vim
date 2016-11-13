let s:save_cpo = &cpo
set cpo&vim

call github_auth#set_token_variables()

command! -nargs=0 GithubAuthGenerateToken call github_auth#generate_token()

let &cpo = s:save_cpo
unlet s:save_cpo
