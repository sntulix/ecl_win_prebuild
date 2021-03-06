;;;; -*- Mode: Lisp; Syntax: Common-Lisp; indent-tabs-mode: nil; Package: C -*-
;;;; vim: set filetype=lisp tabstop=8 shiftwidth=2 expandtab:

;;;;
;;;;  Copyright (c) 2009, Juan Jose Garcia-Ripoll
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.
;;;;
;;;;  CMPPACKAGE -- Package definitions and exported symbols
;;;;

(si::package-lock "CL" nil)

(pushnew :new-cmp *features*)

(defpackage "C-DATA"
  (:nicknames "COMPILER-DATA")
  (:use "FFI" "CL")
  (:export "*COMPILER-BREAK-ENABLE*"
           "*COMPILE-PRINT*"
           "*COMPILE-TO-LINKING-CALL*"
           "*COMPILE-VERBOSE*"
           "*CC*"
           "*CC-OPTIMIZE*"
           "*SUPPRESS-COMPILER-WARNINGS*"
           "*SUPPRESS-COMPILER-NOTES*"
           "*SUPPRESS-COMPILER-MESSAGES*"
           "PROCLAIMED-ARG-TYPES"
           "PROCLAIMED-RETURN-TYPE"
           "NO-SP-CHANGE"
           "PURE"
           "NO-SIDE-EFFECTS"

           "MAKE-C1FORM*" "C1FORM-ARG"

           "LOCATION-TYPE" "LOCATION-PRIMARY-TYPE"

           "ELIMINATE-FROM-SET-NODES" "ELIMINATE-FROM-READ-NODES"
           "GLOBAL-VAR-P" "UNUSED-VARIABLE-P" "TEMPORAL-VAR-P"
           "FUNCTION-MAY-HAVE-SIDE-EFFECTS"
           "FUNCTION-CLOSURE-VARIABLES"
           "FUN-VOLATILE-P" "FUN-NARG-P" "FUN-FIXED-NARG"

           "PPRINT-C1FORM" "PPRINT-C1FORMS"

           "NEXT-LABEL" "NEXT-LCL" "NEXT-LEX" "NEXT-ENV" "NEXT-CFUN"

           "LEXICAL" "GLOBAL" "SPECIAL" "REPLACED" "DISCARDED" "CLOSURE"
           "LFUN"
           "CMP-NOTINLINE" "CMP-TYPE"
           "C1SPECIAL" "C1TYPE-PROPAGATOR" "C1" "T1" "P1PROPAGATE" "WT-LOC" "C2"

           "MAKE-DISPATCH-TABLE"
           ;;
           ;; Symbols naming possible locations
           ;;
           "TEMP" "LCL" "VV" "VV-TEMP" "TRASH"
           "FIXNUM-VALUE" "CHARACTER-VALUE"
           "LONG-FLOAT-VALUE" "DOUBLE-FLOAT-VALUE" "SINGLE-FLOAT-VALUE"
           "VALUE" "VALUE0" "VALUES+VALUE0" "RETURN" "ACTUAL-RETURN"
           "VA-ARG" "CL-VA-ARG" "KEYVARS"
           "CALL" "CALL-NORMAL" "CALL-INDIRECT"
           "COERCE-LOC"
           "FDEFINITION" "MAKE-CCLOSURE"
           "JMP-TRUE" "JMP-FALSE" "JMP-ZERO" "JMP-NONZERO"
           ;;
           ;; Symbols naming C1FORMS
           ;;
           "SET-MV" "BIND" "BIND-SPECIAL" "UNBIND" "PROGV-EXIT"
           "FRAME-POP" "FRAME-SET" "FRAME-SAVE-NEXT" "FRAME-JMP-NEXT"
           "FRAME-ID"
           "CALL-LOCAL" "CALL-GLOBAL" "JMP"
           "FUNCTION-EPILOGUE" "FUNCTION-PROLOGUE" "BIND-REQUIREDS"
           "VARARGS-BIND" "VARARGS-POP" "VARARGS-REST" "VARARGS-UNBIND"
           "STACK-FRAME-OPEN" "STACK-FRAME-PUSH" "STACK-FRAME-PUSH-VALUES"
           "STACK-FRAME-POP-VALUES" "STACK-FRAME-APPLY" "STACK-FRAME-CLOSE"
           "DEBUG-ENV-OPEN" "DEBUG-ENV-CLOSE" "DEBUG-ENV-PUSH-VARS"
           "DEBUG-ENV-POP-VARS"
           "DO-FLET/LABELS"

           "DATA-PERMANENT-STORAGE-SIZE" "DATA-TEMPORARY-STORAGE-SIZE"
           "DATA-SIZE" "DATA-GET-ALL-OBJECTS" "DATA-INIT"
           "ADD-OBJECT" "ADD-SYMBOL" "ADD-KEYWORDS"
           "LOAD-FORM-DATA-PLACE-P"

           "*COMPILER-CONSTANTS*"
           )
  (:import-from "SI" "*COMPILER-CONSTANTS*"))

(defpackage "C-LOG"
  (:use "FFI" "CL" #+threads "MP" "C-DATA")
  (:export "COMPILER-MESSAGE"
           "COMPILER-NOTE"
           "COMPILER-WARNING"
           "COMPILER-ERROR"
           "COMPILER-FATAL-ERROR"
           "COMPILER-INTERNAL-ERROR"
           "COMPILER-STYLE-WARNING"
           "COMPILER-UNDEFINED-VARIABLE"

           "BABOON"
           "CMPERR"
           "CMPNOTE"
           "CMPWARN"
           "CMPASSERT"
           "CMPCK"
           "CMPWARN-STYLE"
           "CMPPROGRESS"
           "PRINT-CURRENT-FORM"
           "PRINT-EMITTING"
           "WITH-COMPILATION-UNIT"
           "WITH-COMPILER-ENV"
           "CHECK-ARGS-NUMBER"
           "TOO-MANY-ARGS"
           "TOO-FEW-ARGS"
           "UNDEFINED-VARIABLE"

           "WITH-CMP-PROTECTION"
           "CMP-EVAL"
           "CMP-MACROEXPAND"
           "CMP-EXPAND-MACRO"
           ))

(defpackage "C-ENV"
  (:use "FFI" "CL" "C-LOG" "C-DATA" "C-LOG")
  (:export
   "FUNCTION-ARG-TYPES" "FUNCTION-RETURN-TYPE"
   "GET-ARG-TYPES" "GET-RETURN-TYPE"
   "GET-LOCAL-ARG-TYPES" "GET-LOCAL-RETURN-TYPE"
   "GET-PROCLAIMED-NARG"
   "INLINE-POSSIBLE"
   "C1BODY"
   "SEARCH-OPTIMIZATION-QUALITY"
   "CHECK-VDECL"

   "CMP-ENV-NEW" "CMP-ENV-COPY" "CMP-ENV-VARIABLES" "CMP-ENV-FUNCTIONS"
   "ADD-DECLARATIONS"
   "CMP-ENV-REGISTER-VAR" "CMP-ENV-DECLARE-SPECIAL"
   "CMP-ENV-ADD-DECLARATION" "CMP-ENV-EXTEND-DECLARATION"
   "CMP-ENV-REGISTER-FUNCTION" "CMP-ENV-REGISTER-MACRO"
   "CMP-ENV-REGISTER-FTYPE" "CMP-ENV-REGISTER-SYMBOL-MACRO"
   "CMP-ENV-REGISTER-BLOCK" "CMP-ENV-REGISTER-TAG"
   "CMP-ENV-REGISTER-CLEANUP" "CMP-ENV-CLEANUPS"
   "CMP-ENV-SEARCH-FUNCTION" "CMP-ENV-SEARCH-VARIABLES"
   "CMP-ENV-SEARCH-BLOCK" "CMP-ENV-SEARCH-TAG"
   "CMP-ENV-SEARCH-SYMBOL-MACRO" "CMP-ENV-SEARCH-VAR"
   "CMP-ENV-SEARCH-MACRO" "CMP-ENV-SEARCH-FTYPE"
   "CMP-ENV-MARK" "CMP-ENV-NEW-VARIABLES"
   "CMP-ENV-SEARCH-DECLARATION" "CMP-ENV-ALL-OPTIMIZATIONS"
   "CMP-ENV-OPTIMIZATION"

   "POLICY-ASSUME-RIGHT-TYPE"
   "POLICY-CHECK-STACK-OVERFLOW"
   "POLICY-INLINE-SLOT-ACCESS-P"
   "POLICY-CHECK-ALL-ARGUMENTS-P"
   "POLICY-AUTOMATIC-CHECK-TYPE-P"
   "POLICY-ASSUME-TYPES-DONT-CHANGE-P"
   "POLICY-OPEN-CODE-AREF/ASET-P"
   "POLICY-OPEN-CODE-ACCESSORS"
   "POLICY-ARRAY-BOUNDS-CHECK-P"
   "POLICY-EVALUATE-FORMS"
   "POLICY-GLOBAL-VAR-CHECKING"
   "POLICY-GLOBAL-FUNCTION-CHECKING"
   "POLICY-DEBUG-VARIABLE-BINDINGS"
   "POLICY-DEBUG-IHS-FRAME"
   "POLICY-CHECK-NARGS"
   "SAFE-COMPILE"

   "CB" "LB" ; UNWIND-PROTECT (Closure boundary names)
  ))

(defpackage "C-PASSES"
  (:use "FFI" "CL" "C-ENV" "C-LOG" "C-DATA")
  (:export "EXECUTE-PASS"
           "PASS-CONSISTENCY"
           "PASS-DELETE-NO-SIDE-EFFECTS"
           "PASS-ASSIGN-LABELS"
           "PASS-DELETE-UNUSED-BINDINGS"))

(defpackage "C-TYPES"
  (:use "FFI" "CL" "C-ENV" "C-LOG" "C-DATA")
  (:export "TYPE-AND"
           "TYPE-OR"
           "TYPE>="
           "TYPE-FILTER"
           "VALID-TYPE-SPECIFIER"
           "KNOWN-TYPE-P"
           "VALUES-TYPE-PRIMARY-TYPE"
           "VALUES-TYPE-TO-N-TYPES"
           "DEFAULT-INIT"
           "DEFAULT-INIT-LOC"
           "DEF-TYPE-PROPAGATOR"
           "COPY-TYPE-PROPAGATOR"
           "PROPAGATE-TYPES"
           "OPTIONAL-CHECK-TYPE"))

(defpackage "C-TAGS"
  (:use "CL" "C-LOG" "C-DATA")
  (:export "GUESS-INIT-NAME"
           "COMPUTE-INIT-NAME"
           "INIT-NAME-TAG"
           "INIT-FUNCTION-NAME"))

(defpackage "C-BACKEND"
  (:use "FFI" "CL" "C-DATA" "C-TYPES" "C-ENV" "C-PASSES" "C-LOG")
  (:export "CTOP-WRITE" "DUMP-ALL" "DATA-DUMP"
           "+SIMPLE-VA-ARGS+"
           "+CL-VA-ARGS+"
           "+NARGS-VAR+"
           "SIMPLE-VARARGS-LOC-P"
           "WT-FILTERED-DATA"))

(defpackage "C"
  (:nicknames "COMPILER")
  (:use "FFI" "CL" "C-TAGS" "C-TYPES" "C-LOG" "C-BACKEND" "C-ENV" "C-DATA")
  (:export "*COMPILER-BREAK-ENABLE*"
           "*COMPILE-PRINT*"
           "*COMPILE-TO-LINKING-CALL*"
           "*COMPILE-VERBOSE*"
           "*CC*"
           "*CC-OPTIMIZE*"
           "BUILD-ECL"
           "BUILD-PROGRAM"
           "BUILD-FASL"
           "BUILD-STATIC-LIBRARY"
           "BUILD-SHARED-LIBRARY"
           "COMPILER-WARNING"
           "COMPILER-NOTE"
           "COMPILER-MESSAGE"
           "COMPILER-ERROR"
           "COMPILER-FATAL-ERROR"
           "COMPILER-INTERNAL-ERROR"
           "COMPILER-UNDEFINED-VARIABLE"
           "COMPILER-MESSAGE-FILE"
           "COMPILER-MESSAGE-FILE-POSITION"
           "COMPILER-MESSAGE-FORM"
           "*SUPPRESS-COMPILER-WARNINGS*"
           "*SUPPRESS-COMPILER-NOTES*"
           "*SUPPRESS-COMPILER-MESSAGES*")
  (:import-from "SI" "GET-SYSPROP" "PUT-SYSPROP" "REM-SYSPROP" "MACRO"
                "*COMPILER-CONSTANTS*" "REGISTER-GLOBAL" "CMP-ENV-REGISTER-MACROLET"
                "COMPILER-LET"))

