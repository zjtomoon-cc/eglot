;;; hui-xe-but.el ---  XEmacs button highlighting and flashing support
;;
;; Author:       Bob Weiner
;;
;; Orig-Date:    21-Aug-92
;;
;; Copyright (C) 1992-2016  Free Software Foundation, Inc.
;; See the "HY-COPY" file for license information.
;;
;; This file is part of GNU Hyperbole.

;;; Commentary:
;;
;;   Can't use read-only buttons here because then outline-mode
;;   becomes unusable.
;;

;;; Code:

(or hyperb:xemacs-p
    (error "(hui-xe-but.el):  Load only when running XEmacs."))

;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************

(require 'custom) ;; For defface.
(require 'hbut)

;;; XEmacs 19.12 renamed x-color-display-p to x-display-color-p.
(if (and (fboundp 'x-color-display-p)
	 (not (fboundp 'x-display-color-p)))
    (defalias 'x-display-color-p 'x-color-display-p))

(defun hproperty:background ()
  "Returns default background color for selected frame."
  (face-background (get-face 'default)))

(defun hproperty:foreground ()
  "Returns default foreground color for selected frame."
  (face-foreground (get-face 'default)))

;;; ************************************************************************
;;; Public variables
;;; ************************************************************************

(defcustom hproperty:but-emphasize-p nil
  "*Non-nil means visually emphasize that button under mouse cursor is selectable."
  :type 'boolean
  :group 'hyperbole-buttons)

(defcustom hproperty:but-flash-time 1000
  "*Machine specific value for empty loop counter, Emacs button flash delay."
  :type '(integer :match (lambda (_widget value) (and (integerp value) (> value 0))))
  :group 'hyperbole-buttons)

(defcustom hproperty:item-highlight-color (hproperty:foreground)
  "Color with which to highlight list/menu selections.
Call (hproperty:set-item-highlight <color>) to change value."
  :type 'color
  :initialize (lambda (_symbol _value) (hproperty:foreground))
  :group 'hyperbole-buttons)

;;; ************************************************************************
;;; Public functions
;;; ************************************************************************

(defun hproperty:but-add (start end face)
  "Add between START and END a button using FACE in current buffer.
If `hproperty:but-emphasize-p' is non-nil when this is called, emphasize that
button is selectable whenever the mouse cursor moves over it."
  (let ((but (make-extent start end)))
    (set-extent-face but face)
    (set-extent-property but 'highlight hproperty:but-emphasize-p)))

(defun hproperty:but-color ()
  "Return current color of buffer's buttons."
  (if hproperty:color-ptr
      (car hproperty:color-ptr)
    (hproperty:foreground)))

(defun hproperty:but-clear ()
  "Delete all Hyperbole buttons from current buffer."
  (interactive)
  (map-extents (lambda (extent unused-arg)
		 (if (eq (extent-face extent) 'hbut)
		     (delete-extent extent)))))

(defun hproperty:but-create (&optional start-delim end-delim regexp-match)
  "Highlight all hyper-buttons in buffer using XEmacs extents.
Will use optional strings START-DELIM and END-DELIM instead of default values.
If END-DELIM is a symbol, e.g. t, then START-DELIM is taken as a regular
expression which matches an entire button string.
If REGEXP-MATCH is non-nil, only buttons matching this argument are
highlighted.

If `hproperty:but-emphasize-p' is non-nil when this is called, emphasize that
button is selectable whenever the mouse cursor moves over it."
  (interactive)
  (hproperty:but-clear)
  (hproperty:but-create-all start-delim end-delim regexp-match))

(defun hproperty:but-create-all (&optional start-delim end-delim regexp-match)
  "Mark all hyper-buttons in buffer as XEmacs buttons, for later highlighting.
Will use optional strings START-DELIM and END-DELIM instead of default values.
If END-DELIM is a symbol, e.g. t, then START-DELIM is taken as a regular
expression which matches an entire button string.
If REGEXP-MATCH is non-nil, only buttons matching this argument are
highlighted."
  (ebut:map (lambda (lbl start end)
	      (hproperty:but-add start end hproperty:but-face))
	    start-delim end-delim regexp-match 'include-delims))
	       
(defun hproperty:but-delete (&optional pos)
  (let ((extent (extent-at (or pos (point)))))
    (if extent (delete-extent extent))))

;;; ************************************************************************
;;; Private functions
;;; ************************************************************************

(defsubst hproperty:list-cycle (list-ptr list)
  "Move LIST-PTR to next element in LIST or when at end to first element."
  (or (and list-ptr (setq list-ptr (cdr list-ptr)))
      (setq list-ptr list)))

;;; ************************************************************************
;;; Private variables
;;; ************************************************************************

(defconst hproperty:color-list
  '("red" "blue" "paleturquoise4" "mediumpurple2"
    "lightskyblue3" "springgreen2" "salmon" "yellowgreen" "darkorchid2"
    "aquamarine4" "slateblue4" "slateblue1" "olivedrab1" "goldenrod4"
    "goldenrod3" "cadetblue2" "burlywood1" "slategrey" "mistyrose"
    "limegreen" "lightcyan" "goldenrod" "gainsboro" "skyblue1" "honeydew"
    "yellow2" "tomato3" "skyblue" "purple4" "orange3" "bisque3" "bisque2"
    "grey34" "gray99" "gray63" "gray44" "gray37" "gray33" "gray26" "azure1"
    "snow4" "peru" "red" "lightgoldenrod4" "mediumseagreen" "blush"
    "mediumorchid2" "lightskyblue1" "darkslateblue" "midnightblue"
    "lightsalmon1" "lemonchiffon" "yellow" "lightsalmon" "coral"
    "dodgerblue3" "darkorange4" "blue" "royalblue4" "red" "green" "cyan"
    "darkviolet" "darksalmon" "darkorange" "blue" "pink" "magenta2"
    "sienna4" "khaki2" "grey75" "grey74" "grey73" "grey69" "grey68" "grey35"
    "grey13" "gray90" "gray81" "gray55" "gray51" "gray31" "snow2" "pink3"
    "grey7" "gray1" "red4" "red3" "tan" "red" "yellow" "mediumvioletred"
    "lightslategrey" "lavenderblush4" "turquoise" "darkturquoise"
    "darkslategrey" "lightskyblue" "lightsalmon4" "lightsalmon3"
    "forestgreen" "dodgerblue4" "orchid" "rosybrown4" "brown" "peachpuff3"
    "palegreen3" "orangered2" "rose" "lightcyan4" "indianred4" "indianred3"
    "seagreen2" "indianred" "deeppink1" "navyblue" "lavender" "grey"
    "deeppink" "salmon4" "salmon3" "oldlace" "grey78" "grey77" "grey54"
    "grey45" "grey21" "gray97" "gray96" "gray95" "gray88" "gray87" "gray86"
    "gray70" "gray57" "gray38" "gray12" "gray11" "plum3" "linen" "gray9"
    "gray8" "blue4" "beige" "turquoise" "blue" "lemonchiffon4"
    "darkseagreen1" "antiquewhite3" "mediumorchid" "springgreen"
    "turquoise4" "steelblue3" "mistyrose2" "lightcyan2" "red" "firebrick2"
    "royalblue" "cadetblue" "skyblue3" "yellow3" "salmon1" "orange4"
    "hotpink" "grey90" "gray56" "gray39" "gray18" "gray14" "plum4" "grey6"
    "gray6" "gold3" "gold1" "blue2" "tan2" "cyan" "mediumspringgreen"
    "darkolivegreen2" "goldenrod" "lightsteelblue" "brown" "whip"
    "chartreuse3" "violetred4" "royalblue2" "royalblue1" "papayawhip"
    "mistyrose3" "lightcyan1" "aquamarine" "skyblue4" "hotpink4" "hotpink3"
    "hotpink2" "dimgray" "tomato" "grey66" "grey65" "grey64" "grey33"
    "grey27" "gray76" "gray69" "gray68" "grey0" "azure" "green"
    "darkgoldenrod4" "darkgoldenrod3" "darkgoldenrod2" "darkgoldenrod"
    "brown" "lightsalmon2" "deepskyblue4" "deepskyblue3" "deepskyblue2"
    "deepskyblue" "darkorange1" "violetred3" "violetred2" "violetred1"
    "slateblue3" "slateblue2" "drab" "indianred1" "firebrick1" "cadetblue4"
    "violetred" "rosybrown" "blue" "firebrick" "grey100" "wheat4" "grey79"
    "grey76" "grey61" "gray93" "gray84" "gray65" "gray36" "gray32" "gray13"
    "gray10" "azure3" "snow1" "tan1" "gray" "darkolivegreen1" "blue"
    "almond" "lavenderblush3" "lavenderblush2" "lavenderblush1"
    "darkolivegreen" "lavenderblush" "aquamarine2" "red" "olivedrab2"
    "mistyrose4" "mistyrose1" "lightcyan3" "lightcoral" "chartreuse"
    "peachpuff" "palegreen" "mintcream" "skyblue2" "moccasin" "tomato1"
    "orchid3" "maroon3" "salmon" "grey81" "grey62" "grey39" "grey38"
    "grey37" "gray92" "gray83" "gray66" "gray54" "gray50" "gray30" "gray19"
    "gray15" "azure4" "grey3" "tan3" "pink" "gray" "blue" "lightsteelblue2"
    "lightsteelblue1" "green" "lightslategray" "lemonchiffon2"
    "springgreen1" "greenyellow" "chartreuse2" "grey" "royalblue3"
    "powderblue" "peachpuff2" "palegreen2" "cream" "slateblue" "seashell2"
    "deeppink2" "darkkhaki" "maroon4" "sienna" "grey71" "grey67" "grey18"
    "gray59" "gray43" "gray25" "bisque" "red1" "mediumslateblue"
    "lightgoldenrod1" "goldenrod" "paleturquoise3" "lightskyblue4" "green"
    "yellow" "smoke" "blue" "white" "steelblue4" "rosybrown3" "peachpuff1"
    "palegreen1" "blueviolet" "seashell4" "sienna3" "grey40" "gray91"
    "gray82" "gray5" "cyan2" "cyan1" "blue1" "snow" "lightgoldenrod2"
    "lightslateblue" "mediumorchid3" "darkseagreen4" "springgreen3" "green"
    "slategray4" "slategray3" "slategray2" "blue" "peachpuff4" "palegreen4"
    "green" "orangered3" "goldenrod1" "ghostwhite" "firebrick4" "firebrick3"
    "cadetblue3" "slategray" "seashell3" "honeydew3" "cornsilk4" "cornsilk2"
    "purple1" "dimgrey" "khaki1" "ivory3" "grey70" "grey60" "grey32"
    "grey22" "grey12" "gray98" "gray89" "gray71" "gray64" "gray60" "gray49"
    "azure2" "gray3" "paleturquoise1" "mediumpurple1" "purple"
    "lemonchiffon1" "blue" "navajowhite3" "darkorchid1" "orange"
    "goldenrod2" "khaki" "chocolate2" "burlywood2" "honeydew1" "darkgreen"
    "thistle3" "thistle2" "thistle1" "thistle" "maroon2" "maroon1" "grey53"
    "grey44" "grey25" "gray74" "gray45" "gray41" "gray35" "gray27" "gray23"
    "gray16" "brown4" "wheat" "coral" "tan4" "lightgoldenrodyellow" "blue"
    "green" "gray" "palevioletred3" "mediumpurple4" "mediumpurple3"
    "saddlebrown" "blue" "darkorchid4" "darkorchid3" "puff" "olivedrab4"
    "lightblue4" "lightpink" "lightgray" "honeydew2" "cornsilk1" "lace"
    "sienna1" "bisque4" "orchid" "khaki3" "grey84" "grey83" "grey82"
    "grey72" "grey52" "grey43" "grey26" "grey14" "grey10" "gray75" "gray53"
    "gray21" "gray20" "brown3" "grey8" "red2" "navy" "grey" "gold"
    "mediumaquamarine" "lightgoldenrod" "darkslategray4" "darkseagreen3"
    "darkseagreen2" "antiquewhite4" "white" "springgreen4" "lightyellow4"
    "white" "aquamarine1" "turquoise3" "steelblue2" "rosybrown2" "pink"
    "gray" "indianred2" "dodgerblue" "green" "seagreen1" "deeppink4"
    "aliceblue" "magenta1" "pink" "sienna2" "orchid1" "gray100" "grey97"
    "grey94" "grey87" "grey86" "grey51" "grey42" "grey19" "gray94" "gray85"
    "gray61" "brown2" "khaki" "grey1" "gold4" "blue" "green" "grey"
    "turquoise" "paleturquoise" "mediumorchid4" "antiquewhite2"
    "lightyellow2" "violet" "salmon" "chartreuse1" "turquoise1" "sandybrown"
    "orangered1" "lightpink1" "lightblue2" "lightblue1" "grey" "seagreen4"
    "seagreen3" "lightblue" "deeppink3" "burlywood" "seashell" "hotpink1"
    "gray" "yellow4" "yellow" "purple" "orange" "ivory4" "grey99" "grey89"
    "grey63" "grey58" "grey49" "grey31" "grey24" "grey20" "green4" "green1"
    "gray73" "gray67" "coral3" "coral2" "plum2" "pink4" "ivory" "gray4"
    "gray2" "gold2" "aquamarine" "grey" "lightgoldenrod3" "darkolivegreen3"
    "darkgoldenrod1" "goldenrod" "orchid" "chiffon" "navajowhite4"
    "deepskyblue1" "lightyellow" "floralwhite" "blue" "mediumblue"
    "chocolate4" "chocolate3" "burlywood4" "turquoise" "steelblue" "green"
    "lawngreen" "honeydew4" "seagreen" "orchid4" "wheat1" "violet" "ivory1"
    "grey88" "grey85" "grey57" "grey56" "grey55" "grey48" "grey47" "grey46"
    "grey30" "grey17" "gray47" "gray29" "pink2" "grey5" "grey4" "green"
    "gray0" "brown" "lightsteelblue4" "darkolivegreen4" "palevioletred4"
    "blue" "darkslategray3" "darkslategray2" "darkslategray1"
    "blanchedalmond" "palegoldenrod" "blue" "lightseagreen" "lemonchiffon3"
    "darkslategray" "green" "darkseagreen" "antiquewhite" "darkorange2"
    "chartreuse4" "blue" "rosybrown1" "olivedrab3" "lightpink2" "orangered"
    "thistle4" "blue" "cornsilk" "salmon2" "orchid2" "ivory2" "grey93"
    "grey92" "grey91" "grey36" "grey29" "grey28" "grey16" "gray79" "gray78"
    "gray77" "gray48" "gray17" "coral4" "coral1" "plum1" "pink1" "grey9"
    "grey2" "gray7" "cyan4" "blue3" "plum" "cornflowerblue" "lightskyblue2"
    "antiquewhite1" "navajowhite2" "navajowhite1" "lightyellow3"
    "navajowhite" "darkorange3" "whitesmoke" "turquoise2" "steelblue1"
    "lightpink4" "lightblue3" "green" "chocolate1" "blue" "olivedrab"
    "lightgrey" "chocolate" "magenta4" "magenta3" "yellow1" "purple3"
    "purple2" "orange2" "orange1" "magenta" "bisque1" "wheat2" "maroon"
    "khaki4" "grey96" "grey95" "grey80" "grey50" "grey41" "grey15" "grey11"
    "gray80" "gray58" "gray40" "gray34" "gray22" "brown1" "snow3"
    "mediumturquoise" "lightsteelblue3" "palevioletred2" "palevioletred1"
    "paleturquoise2" "green" "palevioletred" "mediumorchid1" "white"
    "mediumpurple" "lightyellow1" "dodgerblue2" "dodgerblue1" "violet"
    "aquamarine3" "slategray1" "gray" "orangered4" "lightpink3" "blue"
    "darkorchid" "cadetblue1" "burlywood3" "seashell1" "cornsilk3" "tomato4"
    "tomato2" "wheat3" "grey98" "grey59" "grey23" "green3" "green2" "gray72"
    "gray62" "gray52" "gray46" "gray42" "gray28" "gray24" "white" "cyan3"
    "black"))

(defvar hproperty:color-ptr nil
  "Pointer to current color name table to use for Hyperbole buttons in XEmacs.")

(defconst hproperty:good-colors
  '(
    "medium violet red" "indianred4" "firebrick1" "DarkGoldenrod" "NavyBlue"
    "darkorchid" "tomato3" "mediumseagreen" "deeppink" "forestgreen"
    "mistyrose4" "slategrey" "purple4" "dodgerblue3" "mediumvioletred"
    "lightsalmon3" "orangered2" "turquoise4" "Gray55"
    )
  "Good colors for contrast against wheat background and black foreground.")


;;; ************************************************************************
;;; Public functions
;;; ************************************************************************

(defun hproperty:cycle-but-color (&optional color)
  "Switches button color to optional COLOR name or next item referenced by hproperty:color-ptr."
  (interactive "sHyperbole button color: ")
  (if (not (or (and (fboundp 'device-class) (eq (device-class) 'color))
	       (x-display-color-p)))
      nil
    (if color (setq hproperty:color-ptr nil))
    (set-face-foreground
     hproperty:but-face
     (or color (car (hproperty:list-cycle
		     hproperty:color-ptr hproperty:good-colors))))
    (hproperty:set-flash-color)
    (sit-for 0)  ;; Force display update
    t))

(defun hproperty:set-flash-color ()
  "Set button flashing colors based upon current color set."
  (if (not (x-display-color-p))
      nil
    (set-face-background hproperty:flash-face (hproperty:but-color))
    (set-face-foreground hproperty:flash-face (hproperty:background))))

(defun hproperty:but-flash ()
  "Flash a XEmacs Hyperbole button at or near point to indicate selection."
  (interactive)
  (let ((ibut) (prev)
	(start (hattr:get 'hbut:current 'lbl-start))
	(end   (hattr:get 'hbut:current 'lbl-end))
	(b) (a))
    (if (and start end (setq prev (extent-at start)
			     ibut t))
	(progn (if (not prev) (hproperty:but-add start end hproperty:but-face))
	       (setq b (and start (extent-at start))))
      (setq b (extent-at (point))))
    (if (setq a (and (extentp b) (extent-face b)))
	(unwind-protect
	    (progn
	      (set-extent-face b hproperty:flash-face)
	      (sit-for 0);; Force display update
	      ;; Delay before redraw button
	      (let ((i 0)) (while (< i hproperty:but-flash-time) (setq i (1+ i)))))
	  (set-extent-face b a)
	  (sit-for 0))) ;; Force display update
    (if (and ibut (not prev)) (hproperty:but-delete start))))

(defun hproperty:set-item-highlight (&optional background foreground)
  "Setup or reset item highlight face using optional BACKGROUND and FOREGROUND."
  (make-local-variable 'hproperty:item-face)
  (if background (setq hproperty:item-highlight-color background))
  (if (not hproperty:highlight-face)
      (progn 
	(setq hproperty:highlight-face
	      (or (find-face 'hproperty:highlight-face)
		  (face-name
		   (defface hproperty:highlight-face nil
		     "Item highlighting face.  Use (hproperty:set-item-highlight) to set."))))
	(set-face-foreground hproperty:highlight-face
			     (or foreground (hproperty:background)))
	(set-face-underline-p hproperty:highlight-face nil)))

  (let* ((tty (and (fboundp 'device-type)
		   (eq 'tty (device-type (selected-device)))))
	 (specifiers-function
	  (if (fboundp 'specifier-specs) 'specifier-specs 'identity))
	 (color-function
	  (if (fboundp 'color-name) 'color-name 'identity))
	 (update-hyrolo-highlight-flag
	  (and (boundp 'hyrolo-highlight-face) (find-face hyrolo-highlight-face)
	       (or (null 
		    (funcall specifiers-function
			     (face-foreground hyrolo-highlight-face)))
		   (equal
		    (funcall color-function
			     (face-foreground hyrolo-highlight-face))
		    (funcall color-function (face-foreground 'default)))
		   (face-equal hproperty:highlight-face hyrolo-highlight-face)))))
    (if tty
	(copy-face 'italic 'hproperty:highlight-face)
      (if (and (funcall specifiers-function
			(face-background hproperty:highlight-face))
	       (equal (funcall color-function
			       (face-background hproperty:highlight-face))
		      hproperty:item-highlight-color))
	  nil
	(set-face-background hproperty:highlight-face
			     hproperty:item-highlight-color))
      (and background (not (equal (face-background
				   hproperty:highlight-face) background))
	   (set-face-background hproperty:highlight-face background))
      (and foreground (not (equal (face-foreground
				   hproperty:highlight-face) foreground))
	   (set-face-foreground hproperty:highlight-face foreground)))
    ;; If no colors are specified under InfoDock, use the default color
    ;; scheme.
    (or background foreground (not (fboundp 'id-set-face))
	(id-set-face hproperty:highlight-face))
    (setq hproperty:item-face hproperty:highlight-face)
    (if update-hyrolo-highlight-flag
	(if tty
	    (copy-face 'italic 'hyrolo-highlight-face)
	  (copy-face hproperty:highlight-face hyrolo-highlight-face)))))

(defun hproperty:select-item (&optional pnt)
  "Select item in current buffer at optional position PNT using hproperty:item-face."
  (if hproperty:item-button
      nil
    (set-extent-face (setq hproperty:item-button (make-extent (point) (point)))
		     hproperty:item-face))
  (if pnt (goto-char pnt))
  (skip-chars-forward " \t")
  (skip-chars-backward "^ \t\n\r")
  (let ((start (point)))
    (save-excursion
      (skip-chars-forward "^ \t\n\r")
      (set-extent-endpoints hproperty:item-button start (point))))
  ;; Force display update
  (sit-for 0))

(defun hproperty:select-line (&optional pnt)
  "Select line in current buffer at optional position PNT using hproperty:item-face."
  (if hproperty:item-button
      nil
    (set-extent-face (setq hproperty:item-button (make-extent (point) (point)))
		     hproperty:item-face))
  (if pnt (goto-char pnt))
  (save-excursion
    (beginning-of-line)
    (set-extent-endpoints
     hproperty:item-button (point) (progn (end-of-line) (point))))
  ;; Force display update
  (sit-for 0))

;;; ************************************************************************
;;; Private variables
;;; ************************************************************************

(defvar hproperty:but-face
  (face-name (defface hproperty:but-face nil
	       "Face for hyper-buttons."))
  "Face for hyper-buttons.")
(setq hproperty:but hproperty:but-face)

;; Init. files may set face properties, so run this after emacs initialization.
(defun hproperty:set-face-after-init ()
  (if (and (fboundp 'device-type)
	   (eq 'tty (device-type (selected-device))))
      (copy-face 'italic 'hproperty:but-face)
    (set-face-foreground hproperty:but-face (hproperty:but-color))
    (set-face-background hproperty:but-face (hproperty:background))))
(if after-init-time
    (hproperty:set-face-after-init)
  (add-hook 'after-init-hook #'hproperty:set-face-after-init))

(defvar hproperty:flash-face
  (face-name (defface hproperty:flash-face nil
	       "Face for flashing hyper-buttons."))
  "Face for flashing hyper-buttons.")
(hproperty:set-flash-color)

(defvar hproperty:item-button nil
  "Button used to highlight an item in a listing buffer.")
(make-variable-buffer-local 'hproperty:item-button)

(defvar hproperty:item-face nil
  "Item marking face.")
(or hproperty:item-face
    (setq hproperty:item-face
	  (face-name (defface hproperty:item-face nil "Item marking face."))))

(unless (boundp 'hproperty:highlight-face)
(defvar hproperty:highlight-face nil
  "Item highlighting face.  Use (hproperty:set-item-highlight) to set.")
(if hproperty:highlight-face
    nil
  (setq hproperty:highlight-face
	(face-name
	 (defface hproperty:highlight-face nil
	   "Item highlighting face.  Use (hproperty:set-item-highlight) to set.")))
  ;; Reverse foreground and background colors for default block-style highlighting.
  (hproperty:set-item-highlight (hproperty:foreground) (hproperty:background))))

(provide 'hui-xe-but)


;; Local Variables:
;; no-byte-compile: t
;; End:

;;; hui-xe-but.el ends here