;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Define handler functions that are common to the (relatively)
;; standard chess engine communication protocol:
;;
;;   http://www.tim-mann.org/xboard/engine-intf.html
;;
;; $Revision$

(require 'chess-engine)

(defvar chess-common-temp-files nil)
(make-variable-buffer-local 'chess-common-temp-files)

(defmacro chess-with-temp-file (&rest body)
  `(let ((file (make-temp-file "chess")))
     (with-temp-file file
       ,@body)
     (push file chess-common-temp-files)
     file))

(put 'chess-with-temp-file 'lisp-indent-function 1)

(chess-message-catalog 'english
  '((starting-engine	   . "Starting chess program '%s'...")
    (starting-engine-done  . "Starting chess program '%s'...done")
    (could-not-find-engine . "Cannot find %s executable; check `%s'")
    (draw-offer-declined   . "Your draw offer was declined")
    (illegal-move          . "Illegal move")))

(defun chess-common-handler (event &rest args)
  "Initialize the network chess engine."
  (cond
   ((eq event 'initialize)
    (let* ((name (car args))
	   (path (intern (concat "chess-" name "-path")))
	   proc)
      (chess-message 'starting-engine name)
      (unless (boundp path)
	(chess-error 'could-not-find-engine name path))
      (setq proc (start-process (concat "chess-" name)
				(current-buffer) (symbol-value path)))
      (chess-message 'starting-engine-done name)
      proc))

   ((eq event 'ready)
    (chess-game-set-data chess-engine-game 'active t))

   ((eq event 'shutdown)
    (chess-engine-send nil "quit\n")
    (dolist (file chess-common-temp-files)
      (if (file-exists-p file)
	  (delete-file file)))
    (setq chess-common-temp-files nil))

   ((eq event 'pass)
    (chess-engine-send nil "go\n"))

   ((eq event 'resign)
    (chess-engine-send nil "resign\n"))

   ((eq event 'draw)
    (chess-message 'draw-offer-declined))

   ((memq event '(resign abort))
    (chess-engine-send nil "new\n")
    (chess-engine-set-position nil))

   ((eq event 'undo)
    (dotimes (i (car args))
      (chess-engine-send nil "undo\n"))
    (if (= 1 (mod (car args) 2))
	(chess-engine-send nil "go\n"))

    ;; prevent use from handling the `undo' event which this triggers
    (let ((chess-engine-handling-event t))
      (chess-game-undo chess-engine-game (car args))))

   ((eq event 'move)
    (chess-engine-send nil (concat (chess-ply-to-algebraic (car args)) "\n"))
    (if (chess-game-over-p chess-engine-game)
	(chess-game-set-data chess-engine-game 'active nil)))))

(provide 'chess-common)

;;; chess-common.el ends here
