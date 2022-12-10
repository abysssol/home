;;; doom-purity-theme.el --- a simple dark theme -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;;; Commentary:
;;
;; A simple dark theme.
;;
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup doom-purity-theme nil
  "Options for the `doom-purity' theme."
  :group 'doom-themes)

(defcustom doom-purity-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-purity-theme
  :type 'boolean)

(defcustom doom-purity-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-purity-theme
  :type 'boolean)

(defcustom doom-purity-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'doom-purity-theme
  :type '(choice integer boolean))


;;
;;; Theme definition

(def-doom-theme doom-purity
  "A simple dark theme."

  (
   ;; These should represent a spectrum from bg to fg, where base0 is a starker
   ;; bg and base8 is a starker fg. For example, if bg is light grey and fg is
   ;; dark grey, base0 should be white and base8 should be black.
;;  name          default   256          16
   (base0       '("#000000" "#000000"    "black"        ))
   (base1       '("#101010" "#101010"    "black"        ))
   (base2       '("#202020" "#202020"    "brightblack"  ))
   (base3       '("#404040" "#404040"    "brightblack"  ))
   (base4       '("#808080" "#808080"    "brightblack"  ))
   (base5       '("#c0c0c0" "#c0c0c0"    "white"        ))
   (base6       '("#e0e0e0" "#e0e0e0"    "white"        ))
   (base7       '("#f0f0f0" "#f0f0f0"    "brightwhite"  ))
   (base8       '("#ffffff" "#ffffff"    "brightwhite"  ))

   (red         '("#ff0040" "#ff0040"    "red"          ))
   (orange      '("#ff4000" "#ff4000"    "brightred"    ))
   (green       '("#40ff00" "#40ff00"    "green"        ))
   (teal        '("#00ff40" "#00ff40"    "brightgreen"  ))
   (yellow      '("#ffc000" "#ffc000"    "yellow"       ))
   (lime        '("#c0ff00" "#c0ff00"    "brightyellow" ))
   (blue        '("#0040ff" "#0040ff"    "blue"         ))
   (dark-blue   '("#4000ff" "#4000ff"    "brightblue"   ))
   (violet      '("#c000ff" "#c000ff"    "magenta"      ))
   (magenta     '("#ff00c0" "#ff00c0"    "brightmagenta"))
   (dark-cyan   '("#00c0ff" "#00c0ff"    "cyan"         ))
   (cyan        '("#00ffc0" "#00ffc0"    "brightcyan"   ))

   (bg          base1)
   (fg          base7)

   (grey        base4)
   (comments    (if doom-purity-brighter-comments dark-cyan base5))

   ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
   ;; but can also be useful as a basis for subtle highlights (e.g. for hl-line
   ;; or region), especially when paired with the `doom-darken', `doom-lighten',
   ;; and `doom-blend' helper functions.
   (bg-alt      base2)
   (fg-alt      base6)

   ;; These are the "universal syntax classes" that doom-themes establishes.
   ;; These *must* be included in every doom themes, or your theme will throw an
   ;; error, as they are used in the base theme defined in doom-themes-base.
   (highlight    base7)
   (vertical-bar base1)
   (selection    red)
   (comments     comments)
   (doc-comments (doom-lighten comments 0.2))
   (builtin      red)
   (constants    (doom-lighten blue 0.3))
   (functions    dark-cyan)
   (keywords     lime)
   (methods      violet)
   (operators    orange)
   (type         yellow)
   (strings      cyan)
   (variables    fg)
   (numbers      magenta)

   (region       `(,(doom-lighten (car bg-alt) 0.15) ,@(doom-lighten (cdr base1) 0.35)))
   (error        red)
   (warning      yellow)
   (success      green)
   (vc-modified  yellow)
   (vc-added     green)
   (vc-deleted   red)

   ;; These are extra color variables used only in this theme; i.e. they aren't
   ;; mandatory for derived themes.
   (modeline-fg              fg)
   (modeline-fg-alt          base5)
   (modeline-bg              (if doom-purity-brighter-modeline
                                 (doom-darken blue 0.45)
                               (doom-darken bg-alt 0.1)))
   (modeline-bg-alt          (if doom-purity-brighter-modeline
                                 (doom-darken blue 0.475)
                               `(,(doom-darken (car bg-alt) 0.15) ,@(cdr bg))))
   (modeline-bg-inactive     `(,(car bg-alt) ,@(cdr base1)))
   (modeline-bg-inactive-alt `(,(doom-darken (car bg-alt) 0.1) ,@(cdr bg)))

   (-modeline-pad
    (when doom-purity-padded-modeline
      (if (integerp doom-purity-padded-modeline) doom-purity-padded-modeline 4))))


  ;;;; Base theme face overrides
  (((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground fg)
   ((font-lock-comment-face &override)
    :background (if doom-purity-brighter-comments (doom-lighten bg 0.05)))
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis :foreground (if doom-purity-brighter-modeline base8 highlight))

   ;;;; css-mode <built-in> / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)
   ;;;; doom-modeline
   (doom-modeline-bar :background (if doom-purity-brighter-modeline modeline-bg highlight))
   (doom-modeline-buffer-file :inherit 'mode-line-buffer-id :weight 'bold)
   (doom-modeline-buffer-path :inherit 'mode-line-emphasis :weight 'bold)
   (doom-modeline-buffer-project-root :foreground green :weight 'bold)
   ;;;; elscreen
   (elscreen-tab-other-screen-face :background "#353a42" :foreground "#1e2022")
   ;;;; ivy
   (ivy-current-match :background dark-blue :distant-foreground base0 :weight 'normal)
   ;;;; LaTeX-mode
   (font-latex-math-face :foreground green)
   ;;;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground red)
   ((markdown-code-face &override) :background (doom-lighten base3 0.05))
   ;;;; rjsx-mode
   (rjsx-tag :foreground red)
   (rjsx-attr :foreground orange)
   ;;;; solaire-mode
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-alt))))

  ;;;; Base theme variable overrides-
  ())

;;; doom-purity-theme.el ends here
