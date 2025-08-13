;;; PREAMBEL
(local core (require :nfnl.core))
(local assoc core.assoc)
(local empty? core.empty?)
(local nil? core.nil?)
(local table? core.table?)
(local string? core.string?)
(local function? core.function?)
(fn not-nil? [x] (not (nil? x)))
(fn not-empty? [x] (not (empty? x)))
(fn pumvisible? [] (not= (tonumber vim.fn.pumvisible) 0))

(fn keymap [lhs rhs opts mode]
  (let [opts (if (string? opts) {:desc opts}
                 (vim.tbl_extend :error (or opts {})
                                 {:noremap true :silent true}))
        lhs (if (table? lhs) lhs [lhs])]
    (each [_ l (ipairs lhs)]
      (vim.keymap.set (or mode :n) l rhs opts))))

(fn git-repo? [] (vim.fn.system "git rev-parse --is-inside-work-tree")
  (= vim.v.shell_error 0))

(fn feedkeys [keys]
  (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes keys true false true)
                         :n true))

(fn fzf-search [extcmd exit-fn]
  (let [vapi vim.api
        vfn vim.fn
        width (if (> (- vim.o.columns 2) 120) 120
                  (- vim.o.columns 2))
        height 12
        buf (vapi.nvim_create_buf false true)
        file (vfn.tempname)]
    (vapi.nvim_set_option_value :bufhidden :wipe {: buf})
    (vapi.nvim_set_option_value :modifiable true {: buf})
    (keymap :<esc> ":bd!<cr>" {:desc :exit :buffer buf} :i)
    (vapi.nvim_open_win buf true
                        {:relative :editor
                         :style :minimal
                         :noautocmd true
                         : width
                         : height
                         :col (math.min (/ (- vim.o.columns width) 2))
                         :row (- vim.o.lines height)})
    (vapi.nvim_command :startinsert!)
    (vfn.jobstart (.. extcmd " > " file)
                  {:term true
                   :on_exit (fn []
                              (with-open [f (io.open file :r)]
                                (exit-fn (f:read :*all)))
                              (os.remove file))})))

(fn file-search []
  (let [extcmd (if (git-repo?) "git ls-files" "find . type -f")]
    (fzf-search (.. extcmd " | fzf --height=12 --reverse --border=none")
                (fn [stdout]
                  (let [(selected _) (stdout:gsub "\n" "")]
                    (when (not-empty? selected) (vim.cmd :bd!)
                      (vim.cmd (.. "e " selected))))))))

(fn scratch-to-qf []
  (let [vapi vim.api
        vfn vim.fn
        bufnr (vapi.nvim_get_current_buf)]
    (var items [])
    (each [_ line (ipairs (vapi.nvim_buf_get_lines bufnr 0 -1 false))]
      (when (not-empty? line)
        (let [(filename lnum text) (line:match "^([^:]+):(%d+):(.*)$")]
          (if (and filename lnum)
              (table.insert items {: filename :lnum (tonumber lnum) : text})
              (let [(lnum text) (line:match "^(%d+):(.*)$")]
                (if (and lnum text)
                    (table.insert items
                                  {:filename (vfn.bufname (vfn.bufnr "#"))
                                   :lnum (tonumber lnum)
                                   : text})
                    (table.insert items
                                  {:filename (vfn.fnamemodify line ":p")
                                   :lnum 1
                                   :text ""}))))))
      (vapi.nvim_buf_delete bufnr {:force true})
      (vfn.setqflist items :r)
      (vim.cmd "copen | cc"))))

(fn extcmd-to-scratch [extcmd quickfix?]
  (let [output (if (table? extcmd)
                   (vim.fn.systemlist extcmd)
                   [vim.fn.system (vim.split extcmd "\n")])]
    (when (not-empty? output)
      (vim.cmd :vnew)
      (vim.api.nvim_buf_set_lines 0 0 -1 false output)
      (assoc vim.bo :buftype :nofile :bufhidden :wipe :swapfile false)
      (when quickfix? scratch-to-qf))))

(fn find-root [new-markers]
  (let [markers [:.git/]]
    (vim.list_extend markers new-markers)
    (vim.fs.dirname (. (vim.fs.find markers
                                    {:path (vim.fn.expand "%:p :h")
                                     :upward true}) 1))))

(let [tabstop 4
      undodir (.. (os.getenv :HOME) :/.local/share/vim/undodir)
      g {:mapleader " " :maplocalleader "," :netrw_banner 0 :netrw_liststyle 3}
      opts {:mouse :a
            : tabstop
            :shiftwidth tabstop
            :softtabstop tabstop
            :wildoptions [:fuzzy :pum :tagfile]
            :confirm false
            :splitbelow true
            :splitright false
            :swapfile false
            :undofile true
            : undodir
            :guicursor ""
            :number true
            :relativenumber true
            :winborder :single
            :colorcolumn :80
            :signcolumn :no
            :cursorline true
            :cursorlineopt :screenline
            :scrolloff 5
            :laststatus 3
            :foldenable true
            :foldlevel 99
            :foldmethod :expr
            :foldexpr "v:lua.vim.treesitter.foldexpr()"
            :foldtext ""
            :foldcolumn :0
            :completeopt [:fuzzy
                          :menu
                          :menuone
                          :noselect
                          :noinsert
                          :popup
                          :preview]
            :pumheight 20
            :pumwidth 45}]
  (each [k v (pairs g)]
    (assoc vim.g k v))
  (each [k v (pairs opts)]
    (assoc vim.opt k v))
  (vim.diagnostic.config {:virtual_text {:current_line true}})
  (vim.opt.fillchars:append {:fold " "})
  (when (= (vim.fn.isdirectory undodir) 0) (vim.fn.mkdir undodir :p)))

(local ft-settings
       [{:pattern :fennel :tform "fnlfmt --fix"}
        {:pattern [:c :cpp] :tform "clang-format -i"}
        {:pattern :go :misc #(assoc vim.bo :expandtab false)}
        {:pattern :python
         :tform #(.. "poetry --project " (find-root [:pyproject.toml]))}
        {:pattern :rust :tform "cargo fmt"}
        {:pattern :zig :tform "zig fmt"}
        {:pattern [:bash :sh] :tform :shellharden}
        {:pattern :lua :tform :stylua}
        {:pattern :nix :tform :nixpkgs-fmt}
        {:pattern [:javascript
                   :javascriptreact
                   :typescript
                   :typescriptreact
                   :html
                   :css
                   :scss
                   :json
                   :jsonc
                   :markdown]
         :tform "prettier -w"}
        {:pattern [:man :help] :misc #(keymap :q ":q<cr>")}
        {:pattern :gitcommit
         :misc (fn [] (assoc vim.bo :textwidth 72)
                 (assoc vim.wo :colorcolumn :+0 :spell true))}])

(let [km [[:<leader>w ":w<cr>"]
          [:<leader>a ":e #<cr>" "switch to alternate file"]
          [:<leader>A ":sf #<cr>" "split find alternate file"]
          [:<leader>n ":set relativenumber!<cr>"]
          [:<esc> ":noh<cr>" "remove hlsearch"]
          [:n :nzzzv]
          [:N :Nzzzv]
          ["*" :*zzzv]
          ["#" "#zzzv"]
          [:g* :g*zzzv]
          ["g#" "g#zzzv"]
          [:<c-d> :<c-d>zz]
          [:<c-u> :<c-u>zz]
          [:P "\"_dP" "paste over something without overwriting register" :v]
          [:<leader>d "\"_d" "d without overwriting register" [:n :v :x]]
          [:<leader>x "\"_x" "x without overwriting register" [:n :v :x]]
          [:Y :yg$]
          [:<leader>y "\"+y" "yank into clipboard" [:n :v]]
          [:<leader>Y "\"+yg$" "yank till end of line into clipboard" :n]
          [:<leader>p "\"+p" "paste from clipboard" [:n :v]]
          [:J "mzJ`z"]
          [:<m-j> ":m .+1<cr>==" "move line down" :n]
          [:<m-k> ":m .+1<cr>==" "move line up" :n]
          [:<m-j> ":m '>+1<cr>gv=gv" "move block down" :v]
          [:<m-k> ":m '<-2<cr>gv=gv" "move block up" :v]
          ["<" :<gv :de-indent [:n :v]]
          [">" :>gv :indent [:n :v]]
          [:jk "<c-\\><c-n>" "normal mode" :t]
          [:<c-h> :<c-w>h]
          [:<c-j> :<c-w>j]
          [:<c-k> :<c-w>k]
          [:<c-l> :<c-w>l]
          [:<m-H> "<cmd>vertical resize -2<cr>"]
          [:<m-J> "<cmd>resize +2<cr>"]
          [:<m-K> "<cmd>resize -2<cr>"]
          [:<m-L> "<cmd>vertical resize +2<cr>"]
          [:<c-s><c-s> ":split<cr>"]
          [:<c-s><c-v> ":vsplit<cr>"]
          [["]c" :<F8>] ":cnext<cr>"]
          [["[c" :<F7>] ":cprev<cr>"]
          [:<F6> ":cclose<cr>"]
          [:<leader>fd ":Ex<cr>"]
          [:<leader>ff file-search]
          [:<leader>x scratch-to-qf]
          [:<leader>ggd
           #(extcmd-to-scratch [:git :diff])
           "send git diff to scratch"]
          [:<leader>ggb
           #(extcmd-to-scratch [:git :blame (vim.fn.expand "%")])
           "send git blame to scratch"]
          [:<leader>sf
           #(vim.ui.input {:prompt "> "}
                          #(when ($1) (vim.cmd (.. "Tgrep " $1))))
           "grep and send to qf"]
          [:<leader>ss
           #(vim.ui.input {:prompt "> "}
                          #(when ($1) (vim.cmd (.. "Tscratch " $1))))
           "grep and send to scratch"]
          ["<leader>;f" ":Tform %<cr>" "run formatter"]
          ["<leader>;t" ":Ttest<cr>" "run tests"]
          ["<leader>;c" ":Tcheck<cr>" "run lints"]
          ["<leader>;m" ":make<cr>" "run makeprg"]
          [:<leader>mp :mP "mark P"]
          [:<leader>mf :mF "mark F"]
          [:<leader>mw :mW "mark W"]
          [:<leader>mq :mQ "mark Q"]
          [:<leader>mb :mB "mark B"]
          [:<m-p> "`P" "goto mark P"]
          [:<m-f> "`F" "goto mark F"]
          [:<m-w> "`W" "goto mark W"]
          [:<m-q> "`Q" "goto mark Q"]
          [:<m-b> "`B" "goto mark B"]
          [:<c-n>
           #(if (pumvisible?) (feedkeys :<c-n>)
                (empty? vim.bo.omnifunc) (feedkeys :<c-x><c-n>)
                (feedkeys :<c-x><c-o>))
           "trigger/next completion"
           :i]
          [:<c-e>
           #(if (pumvisible?) (feedkeys :<c-p>)
                (empty? vim.bo.omnifunc) (feedkeys :<c-x><c-p>)
                (feedkeys :<c-x><c-o>))
           "trigger/prev completion"
           :i]
          [:<c-i>
           #(if (pumvisible?) :<c-e> :<c-i>)
           {:expr true :desc "cancel completion"}
           :i]
          [:<c-u> :<c-x><c-n> "buffer completions" :i]]]
  (each [_ v (ipairs km)] (keymap (. v 1) (. v 2) (. v 3) (. v 4))))

(local lspmaps {:gs vim.diagnostic.setqflist
                :gS vim.diagnostic.setloclist
                :gh vim.diagnostic.open_float
                :gd vim.lsp.buf.definition
                :gD vim.lsp.buf.declaration
                :gwd ":vsplit | lua vim.lsp.buf.definition()<cr>"
                :gwD ":vsplit | lua vim.lsp.buf.declaration()<cr>"
                :gt vim.lsp.buf.type_definition
                :gi vim.lsp.buf.implementation})

;;; USERCOMMANDS
(let [create-au vim.api.nvim_create_autocmd
      create-cmd vim.api.nvim_create_user_command]
  (create-cmd :Tgrep
              #(if (git-repo?)
                   (extcmd-to-scratch [:git :grep :-nE $1.args] (not $1.bang))
                   (extcmd-to-scratch [:rg
                                       :--vimgrep
                                       :--no-column
                                       :-ne
                                       $1.args]
                                      (not $1.bang)))
              {:nargs "+"
               :bang true
               :desc "grep recursively; bang sends the results to a scratch buffer"})
  (each [_ ft (ipairs ft-settings)]
    (create-au :FileType
               {:pattern ft.pattern
                :callback (fn []
                            (when (not-nil? ft.tform)
                              (let [tform (.. ":silent !"
                                              (if (function? ft.tform)
                                                  (ft.tform)
                                                  ft.tform))]
                                (create-cmd :Tform
                                            #(vim.cmd (.. tform " "
                                                          (. $1.fargs 1)))
                                            {:nargs 1 :desc "Format file"})))
                            (when (not-nil? ft.misc) (ft.misc)))})))

;;; AUTOCMDS
(let [vapi vim.api
      set-cursor vapi.nvim_win_set_cursor
      usergroup (vapi.nvim_create_augroup :UserConfig {})
      gitgroup (vapi.nvim_create_augroup :Git {})
      au [{:e :TextYankPost :g usergroup :c vim.highlight.on_yank}
          {:e :BufReadPost
           :g usergroup
           :c #(let [mark (vapi.nvim_buf_get_mark 0 "\"")
                     lcount (vapi.nvim_buf_line_count 0)]
                 (when (and (> (. mark 1) 0) (<= (. mark 1) lcount))
                   (pcall set-cursor 0 mark)))}
          {:e :BufWritePre
           :g usergroup
           :c #(let [dir (vim.fn.expand "<afile>:p:h")]
                 (when (= (vim.fn.isdirectory dir) 0)
                   (vim.fn.mkdir dir :p)))}
          {:e [:BufEnter :BufNewFile :BufRead]
           :p :*.mdx
           :c #(vim.bo.filetype :markdown)}
          {:e :BufEnter
           :g gitgroup
           :p :COMMIT_EDITMSG
           :c (fn []
                (assoc vim.wo :spell true)
                (set-cursor 0 [1 0])
                (when (empty? (vim.fn.getline 1))
                  (vim.cmd :startinsert!)))}]]
  (each [_ x (ipairs au)]
    (vapi.nvim_create_autocmd x.e
                              {:group x.g :pattern (?. x.p) :callback #(x.c)})))

;;; LSP
(fn on-lsp-attach [ev]
  (let [vlsp vim.lsp
        cenable vlsp.completion.enable
        snip vim.snippet
        bufnr ev.buf
        client (vlsp.get_client_by_id ev.data.client_id)]
    (set (. vim :bo bufnr :omnifunc) "v:lua.vim.lsp.omnifunc")
    (when (and client (client:supports_method :textDocument/completion))
      (cenable true ev.data.client_id bufnr
               {:convert (fn [item]
                           (var abbr item.label)
                           (set abbr (abbr:gsub "%b()"))
                           (set abbr (abbr:gsub "%b{}"))
                           (set abbr (or (abbr:match "[%w_.]+.*") abbr))
                           (when (> (length abbr) 15)
                             (set abbr (abbr:sub 1 14)))
                           (var menu (or item.detail ""))
                           (when (> (length menu) 15)
                             (set menu (menu:sub 1 14)))
                           {: abbr : menu})}))
    (each [k v (pairs lspmaps)] (keymap k v {:buffer bufnr}))
    (keymap :<tab> #(if (snip.active {:direction 1}) (snip.jump 1)
                        (feedkeys :<tab>)) {:buffer bufnr}
            [:i :s])
    (keymap :<s-tab> #(if (snip.active {:direction -1}) (snip.jump -1)
                          (feedkeys :<s-tab>))
            {:buffer bufnr} [:i :s])
    (keymap :<bs> :<c-o>s {:buffer bufnr} :s)))

(vim.api.nvim_create_autocmd :LspAttach {:callback on-lsp-attach})

(fn pyright-set-python-path [path]
  (var clients (vim.lsp.get_clients {:bufnr (vim.api.nvim_get_current_buf)
                                     :name :pyright}))
  (each [_ client (ipairs clients)]
    (if (client.settings)
        (set client.settings.python
             (vim.tbl_deep_extend :force client.settings.python
                                  {:pythonPath path}))
        (set client.settings.config
             (vim.tbl_deep_extend :force client.config.settings
                                  {:python {:pythonPath path}})))))

(fn pyright-attach [client bufnr]
  (let [create-buf-cmd vim.api.nvim_buf_create_user_command]
    (create-buf-cmd bufnr :LspPyrightOrganizeImports
                    #(client:exe_cmd {:command :pyright.organizeimports
                                      :arguments [(vim.uri_from_bufnr bufnr)]})
                    {:nargs 1 :desc "organize imports" :complete :file})
    (create-buf-cmd bufnr :LspPyrightSetPythonPath pyright-set-python-path
                    {:nargs 1
                     :desc "Reconfigure pyright with the provided python path"
                     :complete :file})))

(fn pyright-new-config [config root-dir]
  (let [env (vim.trim (vim.fn.system (.. "cd \"" (or root-dir ".")
                                         "\" | ; poetry env info --executable 2>/dev/null")))]
    (when (not-empty? env) (set config.settings.python.pythonPath env))))

(let [vlsp vim.lsp
      get-rt-file vim.api.nvim_get_runtime_file
      configs {:pyright {:cmd [:pyright-langserver :--stdio]
                         :filetypes [:python]
                         :root_markers [:pyproject.toml :.git]
                         :settings {:python {:analysis {:autoSearchPaths true
                                                        :useLibraryCodeForTypes true
                                                        :diagnosticMode :openFilesOnly}}}
                         :on_attach pyright-attach
                         :on_new_config pyright-new-config}
               :lua_ls {:cmd [:lua-language-server]
                        :filetypes [:lua]
                        :root_markers [:.git]
                        :settings {:Lua {:workspace {:library (get-rt-file ""
                                                                           true)}}}}
               :rust_analyzer {:cmd [:rust-analyzer]
                               :filetypes [:rust]
                               :root_markers [:Cargo.toml :.git]}}]
  (each [k v (pairs configs)] (vlsp.enable k) (vlsp.config k v)))
