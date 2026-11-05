set mouse=
syntax on
set nocompatible

set number          " Affiche les numéros de ligne absolus
set ruler           " Affiche la position curseur (ligne, colonne) en bas à droite
set showcmd         " Affiche les commandes incomplètes en cours de frappe
set cursorline      " Surligne visuellement la ligne active
set showmatch       " Met en surbrillance la parenthèse/accolade correspondante

set expandtab       " Remplace automatiquement les tabulations par des espaces
set tabstop=2       " Largeur d'une tabulation (2 pour YAML, ou 4 pour Python/Bash)
set shiftwidth=2    " Largeur d'indentation lors de l'utilisation de >> ou <<
set autoindent      " Conserve l'indentation de la ligne précédente à la nouvelle ligne

set incsearch       " Recherche incrémentale (surligne dès la saisie)
set hlsearch        " Garde les résultats surlignés après validation
set ignorecase      " Recherche insensible à la casse...
set smartcase       " ...sauf si une majuscule est tapée explicitement

set nobackup        " Ne crée pas de fichier backup.txt~
set nowritebackup
set noswapfile      " Désactive les fichiers .swp (évite les conflits dans les partages)

" Désactiver la surbrillance de recherche avec Échap en mode normal
nnoremap <silent> <Esc> :nohlsearch<CR>

" Activer/désactiver le mode paste avec F2 (évite l'indentation en escalier lors d'un collage)
set pastetoggle=<F2>

set termguicolors    " Active les couleurs 24-bit (vraies couleurs RVB)
set background=dark  " Ajuste les contrastes pour un fond sombre (dark ou light)
colorscheme desert   " Classique, contrasté et reposant
" Autres alternatives intégrées : ron, slate, industry, habamax (sur Vim 9+)

filetype plugin indent on    " Active la détection de type, plugins et indentations dédiées

" Exemple : associer des fichiers de config spécifiques à la syntaxe YAML ou Bash
autocmd BufRead,BufNewFile *.compose,*.stack set filetype=yaml
autocmd BufRead,BufNewFile *.env* set filetype=sh

" Affiche une ligne repère verticale ou colore la colonne limite
" set colorcolumn=80
" Personnalisation de sa couleur (fond gris discret) :
highlight ColorColumn ctermbg=darkgray guibg=#2d2d2d

" Surligne les espaces en fin de ligne en rouge vif
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

set showmatch       " Fait brièvement sauter le curseur sur la parenthèse ouvrante
set matchtime=2     " Durée du saut en dixièmes de seconde (ici 0.2s)


