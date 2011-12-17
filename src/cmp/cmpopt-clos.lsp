;;;;  -*- Mode: Lisp; Syntax: Common-Lisp; Package: C -*-
;;;;
;;;;  CMPOPT-CLOS. Optimization of CLOS related operations

;;;;  Copyright (c) 201. Juan Jose Garcia-Ripol
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.

(in-package "COMPILER")

(defun clos-compiler-macro-expand (fname args)
  (when (and (si::valid-function-name-p fname)
	     (fboundp fname))
    (let ((function (fdefinition fname)))
      (when (typep function 'generic-function)
	(generic-function-macro-expand function (list* fname args))))))

(defmethod generic-function-macro-expand ((g standard-generic-function) whole)
  (let* ((output (optimizable-slot-accessor g whole))
	 (success (and output t)))
    (values output success)))

(defun optimizable-slot-reader (method whole)
  (when (typep method 'clos:standard-reader-method)
    (let ((class (first (clos:method-specializers method))))
      (when (clos::class-sealedp class)
	(let* ((slotd (clos:accessor-method-slot-definition method))
	       (location (clos:slot-definition-location slotd)))
	  (when (si::fixnump location)
	    (let ((object (gentemp)))
	      `(let ((,object ,(second whole)))
		 (locally (declare (notinline ,(first whole)))
		   (if (typep ,object ',(class-name class))
		       (si::instance-ref ,object ,location)
		       (,(first whole) ,object)))))))))))

(defun optimizable-slot-writer (method whole)
  (when (typep method 'clos:standard-writer-method)
    (let ((class (second (method-specializers method))))
      (when (clos::class-sealedp class)
	(let* ((slotd (clos:accessor-method-slot-definition method))
	       (location (clos:slot-definition-location slotd)))
	  (when (si::fixnump location)
	    (let* ((object (gentemp))
		   (value (gentemp)))
	      `(let ((,value ,(second whole))
		     (,object ,(third whole)))
		 (locally (declare (notinline ,(first whole)))
		   (if (typep ,object ',(class-name class))
		       (si::instance-set ,object ,location ,value)
		       (funcall #',(first whole) ,value ,object)))))))))))

(defun optimizable-slot-accessor (g whole)
  (and (policy-inline-slot-access)
       (let ((methods (clos:generic-function-methods g)))
	 (and methods
	      (null (rest methods))
	      (let* ((principal (first methods)))
		(or (optimizable-slot-reader principal whole)
		    (optimizable-slot-writer principal rest)))))))