" {{{ Initialization
if !exists("g:essentials_web_google_open")
  if has("win32")
    let g:essentials_web_google_open = "start"
  elseif substitute(system('uname'), "\n", "", "") == 'Darwin'
    let g:essentials_web_google_open = "open"
  else
    let g:essentials_web_google_open = "xdg-open"
  endif
endif

if !exists("g:essentials_web_google_query_url")
    let g:essentials_web_google_query_url = "http://google.com/search?q="
endif

" }}}

" {{{1 Exposed Functions
" {{{2 StackOverflow
function! essentials#web#StackOverflow(...)
    " If we don't have python three we will stop here
    if !has('python3')
        call essentials#utils#warn('Web-StackOverflow required vim compiled with +python3')
        return
    endif

	" Check Extra arguments passed in.
	" If empty we proceed to query using visual selection else join all args.
	if a:0 == 0
		let query = essentials#utils#get_visual_select()
	else
		let query = join(a:000, " ")
	endif

    " create tab and set buftype to avoid saving file
    let tab_name = 'E_StackOverflow'
	execute 'tabnew ' . tab_name
    setlocal buftype=nofile
    setlocal nonumber

	" create amapping only for buffer to close fold move up one line
    nnoremap <buffer> o zak<cr>

	" we have to call this to delete previous contents
    normal! ggdG
    silent echom 'Searching for ' . query

python3 << EOF
import vim, urllib.parse, urllib.request, json, io, gzip, re

query = vim.eval("query")

QUESTION_URL = "http://api.stackexchange.com/2.2/search/excerpts?order=desc&sort=relevance&q=%s&accepted=true&site=stackoverflow"
ANSWER_URL = "http://api.stackexchange.com/2.2/questions/%s/?order=desc&sort=votes&site=stackoverflow&filter=!)Rw3MeNsaTmNs*UdDXqKh*Ci"
TIMEOUT = 10

def search(query):
    questions = get_questions(query)
    question_ids = [q['question_id'] for q in questions['items']]
    all_question_data = get_answers(question_ids)

    for a in all_question_data['items']:
        a['answers'] = sorted(a['answers'], key=lambda x: x['score'], reverse=True)
    return all_question_data

def get_questions(query):
    url = QUESTION_URL % urllib.parse.quote(query)
    questions = get_content(url)
    return questions

def get_answers(question_ids):
    qids = ';'.join(map(str, question_ids))
    url = ANSWER_URL % qids
    answers = get_content(url)
    return answers

def html2list(html):
    clean = clean_html(html)
    split_text = clean.split('\n')
    return split_text

def format_answers(answers):
    answerer = lambda x: x['owner']['display_name']
    score = lambda x: x['score']
    bodies = [80*'='+'\n'
              + 'Answered by: ' + answerer(a) + '\n'
              + 'Score: ' + str(score(a)) + '\n\n'
              + a['body'] for a in answers]
    split_text = [html2list(b) for b in bodies]
    # text_list = []
    # map(text_list.extend, split_text)
    # print(text_list[:200])
    return split_text

def get_content(url):
    try:
        response = urllib.request.urlopen(url, None, TIMEOUT)
        if response.info().get('Content-Encoding') == 'gzip':
            content = gzip.decompress(response.read())
        else:
            content = response.read()
        json_response = json.loads(content)

        return json_response
    except Exception as e:
        print(e)

def clean_html(html):
    codes = {
        r'</?p>': '',
        r'</?b>': '',
        r'</?em>': '',
        '<br>': '',
        r'<h\d>(.*?)</h\d>': r'\1',
        r'</?strong>': '',
        r'</?code>': '',
        r'</?blockquote>': '',
        r'<pre.*?>': '<CODE>\n',
        '</pre>': '</CODE>',
        r'[\n]*</?ul>[\n]*': '',
        r'<li>(.*?)</li>': r'* \1',
        r'<a href="(.*?)".*?>(.*?)</a>': r'[\2](\1)',
        '&quot;' : '"',
        '&#39;': "'",
        '&hellip;': '...',
        '&amp;': '&',
        '&gt;': '>',
        '&lt;': '<'
    }

    for code in codes:
        html = re.sub(code, codes[code], html)

    return html


# Populate result buffer window
vim.current.buffer[0] = "RESULTS FOR %s" % query
questions = search(query)['items']
for i, q in enumerate(questions):
    # KEYS
    #[u'body', u'is_answered', u'question_score', u'tags', u'title', u'excerpt', u'last_activity_date', u'answer_count', u'creation_date', u'item_type', u'score', u'has_accepted_answer', u'is_accepted', u'question_id']

    title = clean_html(q['title'])
    answer_count = q['answer_count']

    vim.current.buffer.append("Q%d. %s (%d answers)" % (i+1, title, answer_count))
    vim.current.buffer.append(html2list(q['body']))
    answers = format_answers(q['answers'])
    for i in answers:
        vim.current.buffer.append(i)

EOF
    " Setting fold so it can be used for better view
	" Each line will be evaluation for expression
    setlocal foldmethod=expr
	" Expression used to match for folds
    setlocal foldexpr=essentials#utils#markdown_fold()
	" Text shown on top of the fold
    setlocal foldtext=getline(v:foldstart)
    setlocal foldcolumn=1
endfunction
" }}}

" {{{2 Google
fun! essentials#web#Google(ft, ...)
    " Checks current position == visual mode start,
    " then return selections need to be made to the end selection
    " else set sel to empty
    let sel = getpos('.') == getpos("'<") ? getline("'<")[getpos("'<")[2] - 1 : getpos("'>")[2] - 1] : ''

    " if initial argument to the function is not provided
    if a:0 == 0
        " set words to be sel from previous visual select if not empty else use
        " the current word under cursor
        let words = [a:ft, empty(sel) ? expand("<cword>") : sel]
    else
        " Join all arguments passed to the function and replace all quotes
        let query = join(a:000, " ")
        " replace all characters that are not \" to count num left.
        let quotes = len(substitute(query, '[^"]', '', 'g'))
        let words = [a:ft, query, sel]
        " ensure the quotes are closed for evaluation
        if quotes > 0 && quotes % 2 != 0
            call add(words, '"')
        endif

        " remove empty value from the list, ex., empty ft or query
        call filter(words, 'len(v:val)')
    endif

    " remove spaces and use less greedy match few possible \{-} front and back
    let query = substitute(join(words, " "), '^\s*\(.\{-}\)\s*$', '\1', '')
    " escape quotes for all quotes
    let query = substitute(query, '"', '\\"', 'g')

    if has('win32')
        silent! execute "! " . g:essentials_web_google_open . " \"\" \"" . g:essentials_web_google_query_url  . query . "\""
    else
        " escape urlEncode to ensure % is quoted as \% and surrounded by '' so
        " that vim will not treat all special characters as it is
        " Also assign to goo_query in order for '' to be removed so the search
        " query will be <searchWord> instead of '<searchWord>'
        silent! execute "! goo_query=". shellescape(s:urlEncode(query),1) . " && " . g:essentials_web_google_open . ' "' . g:essentials_web_google_query_url . "$goo_query" . '" > /dev/null 2>&1 &'
    endif
    redraw!
endfun


" URL encode a string. ie. Percent-encode characters as necessary.
function! s:urlEncode(string)
    let result = ""
    let characters = split(a:string, '.\zs')
    for character in characters
        if character == " "
            let result = result . "+"
        elseif s:characterRequiresUrlEncoding(character)
            let i = 0
            while i < strlen(character)
                let byte = strpart(character, i, 1)
                let decimal = char2nr(byte)
                let result = result . "%" . printf("%02x", decimal)
                let i += 1
            endwhile
        else
            let result = result . character
        endif
    endfor
    return result
endfunction

" Returns 1 if the given character should be percent-encoded in a URL encoded
" string.
function! s:characterRequiresUrlEncoding(character)
    let ascii_code = char2nr(a:character)
    if ascii_code >= 48 && ascii_code <= 57
        return 0
    elseif ascii_code >= 65 && ascii_code <= 90
        return 0
    elseif ascii_code >= 97 && ascii_code <= 122
        return 0
    elseif a:character == "-" || a:character == "_" || a:character == "." || a:character == "~"
        return 0
    endif
    return 1
endfunction
" }}}
" }}}
