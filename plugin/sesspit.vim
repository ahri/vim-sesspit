" sesspit.vim - Continuously updated project session files
" Homepage:     http://github/ahri/vim-sesspit
" Maintainer:   Adam Piper <adam@ahri.net>
" Version:      0.1.0

if exists("s:loaded_sesspit") || v:version < 700 || &compatible
  finish
endif
let s:loaded_sesspit = 1
let s:active = 0

" Sensible defaults
let s:filename = ".vimsession~"
let s:sessionoptions = "buffers"
let s:project_markers = ".git"

command! -bar -nargs=0 SessPit
      \ call s:save()

function! sesspit#set_filename(filename)
        let s:filename = a:filename
endfunction

function! sesspit#set_sessionoptions(sessionoptions)
        let s:sessionoptions = a:sessionoptions
endfunction

function! sesspit#set_project_markers(project_markers)
        let s:project_markers = a:project_markers
endfunction

function! s:location()
        let testpath = ""
        while empty(testpath) || isdirectory(testpath)
                for marker in split(s:project_markers, ",")
                        let path = testpath . marker
                        if isdirectory(path) || filereadable(path)
                                return testpath . s:filename
                        endif
                endfor

                let testpath .= "../"
        endwhile

        return s:filename
endfunction

function! s:pretty_location(location)
        return fnamemodify(a:location, ":~")
endfunction

function! s:write_session(location)
        let backup = &sessionoptions
        try
                let &sessionoptions = s:sessionoptions

                execute "mksession! " . a:location
                let s:active = 1
        finally
                let &sessionoptions = backup
        endtry
endfunction

function! s:save()
        let location = s:location()
        call s:write_session(location)
        echo "Saved session to " . s:pretty_location(location)
endfunction

function! s:auto_save_silent()
        if !s:active
                return
        endif

        let location = s:location()
        if filereadable(s:location())
                call s:write_session(location)
                return location
        endif
endfunction

function! s:auto_save()
        let location = s:auto_save_silent()
        if !empty(location)
                echo "Saved session to " . s:pretty_location(location)
        endif
endfunction

function! s:auto_load()
        let location = s:location()
        if filereadable(location)
                let cur = @%
                execute "source " . location
                if !empty(cur)
                        execute "edit " . cur
                end
                filetype detect
                let s:active = 1

                echo "Loaded session from " . s:pretty_location(location)
        endif
endfunction

augroup sesspit
        autocmd!
        autocmd TabEnter,BufEnter,FocusLost * call s:auto_save_silent()
        autocmd VimLeave * call s:auto_save()
        autocmd VimEnter * call s:auto_load()
augroup END
