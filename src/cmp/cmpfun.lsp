;;;;  CMPFUN  Library functions.

;;;;  Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
;;;;  Copyright (c) 1990, Giuseppe Attardi and William F. Schelter.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.


(in-package "COMPILER")

(defvar *princ-string-limit* 80)

(defun c1princ (args)
  (check-args-number 'PRINC args 1 2)
  (let ((object (first args))
	(stream (if (endp (rest args))
		    (c1nil)
		    (c1expr (second args)))))
    (if (and (or (and (stringp object)
		      (<= (length object) *princ-string-limit*))
		 (characterp object))
	     (or (endp (rest args))
		 (eq (c1form-name stream) 'VAR)))
	(make-c1form* 'C2PRINC :args object (c1form-arg 0 stream) stream)
	(c1call-global 'PRINC args))))

(defun c2princ (string stream-var stream)
  (cond ((eq *destination* 'TRASH)
	 (cond ((characterp string)
		(wt-nl "princ_char(" (char-code string) "," stream-var ");"))
	       ((= (length string) 1)
		(wt-nl "princ_char(" (char-code (aref string 0)) ","
		       stream-var ");"))
	       (t
		(wt-nl "princ_str(\"")
		(dotimes (n (length string))
		  (declare (fixnum n))
		  (let ((char (schar string n)))
		       (cond ((char= char #\\) (wt "\\\\"))
			     ((char= char #\") (wt "\\\""))
			     ((char= char #\Newline) (wt "\\n"))
			     (t (wt char)))))
		(wt "\"," stream-var ");")))
	 (unwind-exit nil))
	((eql string #\Newline) (c2call-global 'TERPRI (list stream) nil t))
	(t (c2call-global
	    'PRINC
	    (list (make-c1form 'LOCATION *info*
			       (list 'VV (add-object string)))
		  stream) nil t))))

(defun c1terpri (args &aux stream)
  (check-args-number 'TERPRI args 0 1)
  (setq stream (if (endp args)
		   (c1nil)
		   (c1expr (first args))))
  (if (or (endp args)
	  (and (eq (c1form-name stream) 'VAR)
	       (member (var-kind (c1form-arg 0 stream)) '(GLOBAL SPECIAL))))
      (make-c1form* 'C2PRINC :args  #\Newline
		    (if (endp args) nil (c1form-arg 0 stream))
		    stream)
      (c1call-global 'TERPRI args)))

(defun c1apply (args)
  (check-args-number 'APPLY args 2)
  (let* ((fun (first args))
	 (arguments (rest args)))
    (cond ((and (consp fun)
		(eq (first fun) 'LAMBDA))
	   (c1expr (optimize-funcall/apply-lambda (cdr fun) arguments t)))
	  ((and (consp fun)
		(eq (first fun) 'LAMBDA-BLOCK))
	   (setf fun (macroexpand-1 fun))
	   (c1expr (optimize-funcall/apply-lambda (cdr fun) arguments t)))
	  ((and (consp fun)
		(eq (first fun) 'FUNCTION)
		(consp (second fun))
		(member (caadr fun) '(LAMBDA LAMBDA-BLOCK)))
	   (c1apply (list* (second fun) arguments)))
	  (t
	   (c1funcall (list* '#'APPLY args))))))

(defun c1rplaca (args)
  (check-args-number 'RPLACA args 2 2)
  (make-c1form* 'RPLACA :args (c1args* args)))

(defun c2rplaca (args &aux (*inline-blocks* 0) x y)
  (setq args (coerce-locs (inline-args args))
	x (first args)
	y (second args))
  (safe-compile
   (wt-nl "if(ATOM(" x "))"
	  "FEtype_error_cons(" x ");"))
  (wt-nl "CAR(" x ") = " y ";")
  (unwind-exit x)
  (close-inline-blocks))

(defun c1rplacd (args)
  (check-args-number 'RPLACD args 2 2)
  (make-c1form* 'RPLACD :args (c1args* args)))

(defun c2rplacd (args &aux (*inline-blocks* 0) x y)
  (setq args (coerce-locs (inline-args args))
	x (first args)
	y (second args))
  (safe-compile
   (wt-nl "if(ATOM(" x "))"
	  "FEtype_error_cons(" x ");"))
  (wt-nl "CDR(" x ") = " y ";")
  (unwind-exit x)
  (close-inline-blocks))

(defun c1member (args)
  (check-args-number 'MEMBER args 2)
  (cond ((endp (cddr args))
	 (make-c1form* 'MEMBER!2 :args 'EQL (c1args* args)))
	((and (eq (third args) :test)
	      (= (length args) 4)       ; Beppe
	      (member (fourth args) '('EQ #'EQ 'EQUAL #'EQUAL 'EQL #'EQL)
		      :test #'EQUAL))	; arg4 = (QUOTE EQ)
	 (make-c1form* 'MEMBER!2 :args (second (fourth args))
		       (c1args* (list (car args) (second args)))))
	(t
	 (c1call-global 'MEMBER args))))

(defun c2member!2 (fun args
		       &aux (*inline-blocks* 0))
  (unwind-exit
   (produce-inline-loc (inline-args args) '(T T) :object
	 (case fun
	   (EQ "si_memq(#0,#1)")
	   (EQL "memql(#0,#1)")
	   (EQUAL "member(#0,#1)"))
	 nil ; side effects?
	 t)) ; one liner?
  (close-inline-blocks))

(defun c1assoc (args)
  (check-args-number 'ASSOC args 2)
  (cond ((endp (cddr args))
	 (make-c1form* 'ASSOC!2 :args 'EQL (c1args* args)))
	((and (eq (third args) ':TEST)
	      (= (length args) 4)       ; Beppe
	      (member (fourth args) '('EQ #'EQ 'EQUAL #'EQUAL
				      'EQUALP #'EQUALP 'EQL #'EQL)
		      :test 'EQUAL))
	 (make-c1form* 'ASSOC!2 :args (second (fourth args))
		       (c1args* (list (car args) (second args)))))
	(t
	 (c1call-global 'ASSOC args))))

(defun c2assoc!2 (fun args
		      &aux (*inline-blocks* 0))
  (unwind-exit
   (produce-inline-loc (inline-args args) '(T T) :object
	 (case fun
	   (eq "assq(#0,#1)")
	   (eql "assql(#0,#1)")
	   (equal "assoc(#0,#1)")
	   (equalp "assqlp(#0,#1)"))
	 nil ; side effects?
	 t
	 ))
  (close-inline-blocks))

(defun co1nth (args)
  (and (not (endp args))
       (not (endp (cdr args)))
       (endp (cddr args))
       (numberp (car args))
       (<= 0 (car args) 7)
       (c1expr (case (car args)
		     (0 (cons 'CAR (cdr args)))
		     (1 (cons 'CADR (cdr args)))
		     (2 (cons 'CADDR (cdr args)))
		     (3 (cons 'CADDDR (cdr args)))
		     (4 (list 'CAR (cons 'CDDDDR (cdr args))))
		     (5 (list 'CADR (cons 'CDDDDR (cdr args))))
		     (6 (list 'CADDR (cons 'CDDDDR (cdr args))))
		     (7 (list 'CADDDR (cons 'CDDDDR (cdr args))))
		     ))))

(defun co1nthcdr (args)
  (and (not (endp args))
       (not (endp (cdr args)))
       (endp (cddr args))
       (numberp (car args))
       (<= 0 (car args) 7)
       (c1expr (case (car args)
		 (0 (second args))
		 (1 (cons 'CDR (cdr args)))
		 (2 (cons 'CDDR (cdr args)))
		 (3 (cons 'CDDDR (cdr args)))
		 (4 (cons 'CDDDDR (cdr args)))
		 (5 (list 'CDR (cons 'CDDDDR (cdr args))))
		 (6 (list 'CDDR (cons 'CDDDDR (cdr args))))
		 (7 (list 'CDDDR (cons 'CDDDDR (cdr args))))))))

(defun c1rplaca-nthcdr (args)
  (check-args-number 'SYS:RPLACA-NTHCDR args 3 3)
  (if (and (numberp (second args)) (<= 0 (second args) 10))
      (make-c1form* 'RPLACA-NTHCDR-IMMEDIATE
		    :args (second args)
		    (c1args* (list (car args) (third args))))
      (c1call-global 'SYS:RPLACA-NTHCDR args)))

(defun c2rplaca-nthcdr-immediate (index args
					&aux (*inline-blocks* 0))
  (declare (fixnum index))
  (setq args (coerce-locs (inline-args args)))
  (if *safe-compile*
      (progn
       (wt-nl "{cl_object l= ")
       (dotimes (i index) (declare (fixnum i)) (wt "cl_cdr("))
       (wt (car args))
       (dotimes (i index)(declare (fixnum i)) (wt ")"))
       (wt ";")
       (wt-nl "if(ATOM(l)) FEtype_error_cons(l);")
       (wt-nl "CAR(l)= " (second args) ";}"))
      (progn
	(wt-nl "CAR(")
       (dotimes (i index) (declare (fixnum i)) (wt "CDR("))
       (wt (car args))
       (dotimes (i index) (declare (fixnum i)) (wt ")"))
       (wt ")= " (second args) ";")))
  (unwind-exit (second args))
  (close-inline-blocks))

(defun c1list-nth (args)
  (check-args-number 'LIST-NTH args 2 2)
  (if (and (numberp (car args)) (<= 0 (car args) 10))
      (make-c1form* 'LIST-NTH-IMMEDIATE
		    :args (car args) (c1args* (list (second args))))
      (c1call-global 'SYS:LIST-NTH args)))

(defun c2list-nth-immediate (index args &aux (l (make-lcl-var))
					     (*inline-blocks* 0))
  (declare (fixnum index))
  (setq args (coerce-locs (inline-args args)))
  (wt-nl "{cl_object " l "= ")
  (if *safe-compile*
      (progn
       (dotimes (i index) (declare (fixnum i)) (wt "cl_cdr("))
       (wt (car args))
       (dotimes (i index) (declare (fixnum i)) (wt ")"))
       (wt ";")
       (wt-nl "if(ATOM(" l "))")
       (wt-nl " FEtype_error_cons(" l ");")
       )
      (progn
       (dotimes (i index) (declare (fixnum i)) (wt "CDR("))
       (wt (car args))
       (dotimes (i index) (declare (fixnum i)) (wt ")"))
       (wt ";")))
  (unwind-exit (list 'CAR l))
  (wt "}")
  (close-inline-blocks))

;----------------------------------------------------------------------

(defun co1ash (args)
  (let ((shamt (second args)) type fun)
    (when (cond ((and (constantp shamt)
		      (sys::fixnump (setq shamt (eval shamt))))
		 (setq fun (if (< shamt 0) 'SHIFT>> 'SHIFT<<)))
		((and (consp shamt)
		      (eq (car shamt) 'THE)
		      (or (subtypep (setq type (second shamt))
				    '(INTEGER 0 100))
			  (and (boundp 'SYS::*ASH->>*) sys::*ash->>*
			       (subtypep type '(INTEGER -100 0)))))
		 (setq fun
		       ;; it had to be a (the type..)
		       (cond ((subtypep type '(INTEGER 0 100))
			      'SHIFT<<)
			     ((subtypep type '(INTEGER -100 0))
			      'SHIFT>>)))))
      (c1expr (cons fun args)))))

(setf (symbol-function 'shift<<) #'ash)
(setf (symbol-function 'shift>>) #'ash)

;----------------------------------------------------------------------

(defun co1boole (args)
   (and (not (endp (cddr args)))
	(endp (cdddr args))
	(let ((op-code (first args))
	      c1args string)
	  (and (constantp op-code)
	       (sys:fixnump (setq op-code (eval op-code)))
	       (setq c1args (c1args* (rest args)))
	       (eq 'FIXNUM (c1form-type (second c1args)))
	       (eq 'FIXNUM (c1form-type (third c1args)))
	       `(C-INLINE ,c1args (T T) FIXNUM
		 ,(boole-inline-string op-code)
		 :side-effects nil
		 :one-liner t)))))

(defun boole-inline-string (op-code)
  (ecase op-code
    (#. boole-clr "(0)")
    (#. boole-set "(1)")
    (#. boole-1 "(#0)")
    (#. boole-2 "(#1)")
    (#. boole-c1 "(~(#0))")
    (#. boole-c2 "(~(#1))")
    (#. boole-and "((#0) & (#1))")
    (#. boole-ior "((#0) | (#1))")
    (#. boole-xor "((#0) ^ (#1))")
    (#. boole-eqv   "(~((#0) ^ (#1)))")
    (#. boole-nand "(~((#0) & (#1)))")
    (#. boole-nor   "(~((#0)|(#1)))")
    (#. boole-andc1 "((~(#0))&(#1))")
    (#. boole-andc2 "(((#0))&(~(#1)))")
    (#. boole-orc1  "(~(#0) | (#1))")
    (#. boole-orc2  "((#0) | (~(#1)))")))

;----------------------------------------------------------------------

(defun co1coerce (args &aux expr type (info (make-info)))
  (and args (cdr args) (endp (cddr args))
       (let ((expr (first args))
	     (type (second args)))
	 (and (listp type)
	      (eq (car type) 'QUOTE)
	      (case (second type)
		((CHARACTER BASE-CHAR) (c1expr `(CHARACTER ,expr)))
		(FLOAT (c1expr `(FLOAT ,expr)))
		((SINGLE-FLOAT SHORT-FLOAT) (c1expr `(FLOAT ,expr 0.0S0)))
		((DOUBLE-FLOAT LONG-FLOAT) (c1expr `(FLOAT ,expr 0.0L0))))))))

;----------------------------------------------------------------------
;; turn repetitious cons's into a list*

(defun co1cons (args &aux temp)
  (labels ((cons-to-lista (x)
	     (let ((tem (last x)))
	       (if (and (consp tem)
			(consp (car tem))
			(eq (caar tem) 'CONS)
			(eql (length (cdar tem)) 2))
		   (cons-to-lista (append (butlast x) (cdar tem)))
		   x))))
    (and (eql (length args) 2)
	 (not (eq args (setq temp (cons-to-lista args))))
	 (c1expr (if (equal '(nil) (last temp))
		     (cons 'LIST (butlast temp))
		     (cons 'LIST* temp))))))

;----------------------------------------------------------------------

;; Return the most particular type we can EASILY obtain from x.  
(defun result-type (x)
  (cond ((symbolp x)
	 (c1form-type (c1expr x)))
	((constantp x)
	 (type-filter (type-of x)))
	((and (consp x) (eq (car x) 'the))
	 (type-filter (second x)))
	(t t)))

;----------------------------------------------------------------------

(defun co1ldb (args &aux (arg1 (first args))
		    (len (* 8 (round (integer-length most-positive-fixnum) 8)))
		    size pos)
    (and (consp arg1)
	 (eq 'BYTE (car arg1))
	 (integerp (setq size (second arg1)))
	 (integerp (setq pos (third arg1)))
	 (<= (+ size pos) len)
	 (subtypep (result-type (second args)) 'FIXNUM)
	 (c1expr `(the fixnum (ldb1 ,size ,pos ,(second args))))))

(put-sysprop 'ldb1 :INLINE-ALWAYS
	     '(((fixnum fixnum fixnum) fixnum nil nil
		"((((~(-1 << (#0))) << (#1)) & (#2)) >> (#1))")
	       ((fixnum fixnum fixnum) T nil nil
		"MAKE_FIXNUM((((~(-1 << (#0))) << (#1)) & (#2)) >> (#1))")))

;----------------------------------------------------------------------

(defun co1vector-push (args) (co1vector-push1 nil args))
(defun co1vector-push-extend (args) (co1vector-push1 t args))
(defun co1vector-push1 (extend args)
  (unless (or *safe-compile*
	      (> *space* 3)
	      (null (cdr args)))
    (let ((*space* 10))
      (c1expr
       `(let* ((.val ,(car args))
	       (.vec ,(second args))
	       (.i (fill-pointer .vec))
	       (.dim (array-total-size .vec)))
	 (declare (fixnum .i .dim)
	  (type ,(result-type (second args)) .vec)
	  (type ,(result-type (car args)) .val))
	 (cond ((< .i .dim)
		(the fixnum (sys::fill-pointer-set .vec (the fixnum (+ 1 .i))))
		(sys::aset .val .vec .i)
		.i)
	       (t ,(when extend
		     `(vector-push-extend .val .vec ,@(cddr args))))))))))

;;; ----------------------------------------------------------------------

(put-sysprop 'princ 'C1 'c1princ)
(put-sysprop 'c2princ 'C2 'c2princ)
(put-sysprop 'terpri 'C1 'c1terpri)

(put-sysprop 'apply 'C1 'c1apply)

(put-sysprop 'rplaca 'C1 'c1rplaca)
(put-sysprop 'rplaca 'C2 'c2rplaca)
(put-sysprop 'rplacd 'C1 'c1rplacd)
(put-sysprop 'rplacd 'C2 'c2rplacd)

(put-sysprop 'member 'C1 'c1member)
(put-sysprop 'member!2 'C2 'c2member!2)
(put-sysprop 'assoc 'C1 'c1assoc)
(put-sysprop 'assoc!2 'C2 'c2assoc!2)

(put-sysprop 'nth 'C1CONDITIONAL 'co1nth)
(put-sysprop 'nthcdr 'C1CONDITIONAL 'co1nthcdr)
(put-sysprop 'sys:rplaca-nthcdr 'C1 'c1rplaca-nthcdr)
(put-sysprop 'rplaca-nthcdr-immediate 'C2 'c2rplaca-nthcdr-immediate)
(put-sysprop 'sys:list-nth 'C1 'c1list-nth)
(put-sysprop 'list-nth-immediate 'C2 'c2list-nth-immediate)

(put-sysprop 'ash 'C1CONDITIONAL 'co1ash)
(put-sysprop 'boole 'C2 'c2boole)
(put-sysprop 'boole 'C1CONDITIONAL 'co1boole)
(put-sysprop 'coerce 'C1CONDITIONAL 'co1coerce)
(put-sysprop 'cons 'C1CONDITIONAL 'co1cons)
(put-sysprop 'ldb 'C1CONDITIONAL 'co1ldb)
(put-sysprop 'vector-push 'C1CONDITIONAL 'co1vector-push)
(put-sysprop 'vector-push-extend 'C1CONDITIONAL 'co1vector-push-extend)
