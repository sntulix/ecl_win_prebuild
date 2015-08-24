;;;;  thread.lsp -- thread top level and utilities
;;;;
;;;;  Copyright (c) 1990, Giuseppe Attardi.
;;;;  Copyright (c) 2015, Daniel Kochmański.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.

(in-package "EXT")

;;; ----------------------------------------------------------------------
;;; Utilities

(defmacro spawn (function &rest args)
  `(resume (make-continuation (make-thread ,function)) ,@ args))

(defun pass (&rest args)
  (%disable-scheduler)
  (apply 'resume args)
  (%suspend))

(defmacro let/cc (cont body)
  `(let ((,cont (make-continuation (current-thread))))
    ,@body
    (%suspend)))

(defmacro without-scheduling (&rest body)
  `(unwind-protect
       (progn 
	 (%disable-scheduler)
	 (progn ,@body))
     (%enable-scheduler)))

(defmacro wait-in (place)
  `(progn
     (setf ,place (make-continuation (current-thread)))
     (%suspend)))

(defun wait (&rest threads)
  (labels ((wait-all-internal (threads)
	     (or (null threads)
		 (and (eq (thread-status (first threads)) 'DEAD)
		      (wait-all-internal (rest threads))))))
    (funcall #'%thread-wait #'wait-all-internal threads)))

(defun wait-some (&rest threads)
  (labels ((wait-some-internal (threads)
	     (or (null threads)
		 (eq (thread-status (first threads)) 'DEAD)
		 (wait-some-internal (rest threads)))))
    (funcall #'%thread-wait #'wait-some-internal threads)))

;;; ----------------------------------------------------------------------
;;; Examples
#|
(defvar *producer* (make-thread 'producer))
(defvar *consumer* (make-thread 'consumer))

(defun producer ()
  (dotimes (i 20)
    (print 'producer)
    ;; produce
    (resume (make-continuation *consumer*) i)
    (%suspend)))

(defun consumer ()
  (let (i)
    (loop
     (print 'consumer)
     (resume (make-continuation *producer*))
     (setq i (%suspend))
     ;; consume
     (print i))))

(resume (make-continuation *producer*))
|#
