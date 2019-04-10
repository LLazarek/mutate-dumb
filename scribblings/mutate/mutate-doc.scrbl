#lang scribble/manual

@(require scribble/core)

@title{Mutate}
@author[(author+email "Lukas Lazarek" "lukas.lazarek@eecs.northwestern.edu")]

@defmodule[mutate]

@;;;;;;;;;;;;;;;@
@; Boilerplate ;@
@;;;;;;;;;;;;;;;@

@(require (for-label racket mutate)
          scribble/example)

@(define mutate-eval (make-base-eval))
@examples[#:eval mutate-eval #:hidden (require racket mutate)]

@;;;;;;;;;;;;;;;;;;;;;;;@
@; Begin documentation ;@
@;;;;;;;;;;;;;;;;;;;;;;;@


@defproc[(mutate-program [stx syntax?] [mutation-index natural?])
         syntax?]{

  Mutates the given module syntax, returning a mutated version. The
  syntax should be a list of top level expressions, like so:

  @racketblock[#'(e ...)]

  Those @racket[e]'s which have the following form will be considered
  candidates for mutation:

  @racketblock[(define head body ...)]

  Within such definitions, the @racket[body] expressions will be mutated.


  The @racket[mutation-index] argument is a kind of index into the set
  of mutants that can be generated for a given program. Providing the
  same index with the same syntax always produces the same mutant.
  There are a finite number of mutants for a single program, so the
  @racket[mutation-index] argument has a maximum value that depends on
  the shape of @racket[stx]. If a @racket[mutation-index] is provided
  that exceeds the maximum number of mutants possible to generate from
  @racket[stx], a @racket[mutation-index-exception?] is raised.

  @examples[#:eval mutate-eval
  (mutate-program #'((define (foo x) any/c (+ 1 2)))
                  0)
  (mutate-program #'((define (foo x) any/c (+ 1 2)))
                  1)
  (mutate-program #'((define (foo x) any/c (+ 1 2)))
                  2)
  (mutate-program #'((define (foo x) any/c (+ 1 2)))
                  3)
  (with-handlers ([mutation-index-exception? (lambda _ (displayln 'end-of-mutants!))])
    (mutate-program #'((define (foo x) any/c (+ 1 2)))
                    4))]

}

@defproc[(mutate-program/with-id [stx syntax?] [mutation-index natural?])
         mutated-program?]{

  Like @racket[mutate-program], but also returns the identifier of the
  definition in @racket[stx] that was mutated.

}

@defproc[(mutation-index-exception? [e any/c]) boolean?]{

  Recognizes index exceptions thrown by @racket[mutate-program] and
  @racket[mutate-program/with-id].

}

@defstruct*[mutated-program ([stx syntax?] [mutated-id symbol?])]{

  A pair of mutated syntax and the identifier of the definition
  mutated inside of @racket[stx].

}

@defproc[(read-module [path path-string?]) syntax?]{

  Reads the syntax of the module located at @racket[path]. This is
  useful if you want to mutate a program in a file. The resulting
  syntax can't be passed directly to @racket[mutate-program], but the
  top-level definitions can easily be extracted with
  @racket[syntax-parse].

}
