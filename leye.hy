#!/usr/bin/env hy

(import [math [pi]])
(import [hy.lex [tokenize]])
(import [cairo])

(def W 1000)
(def H 1000)


(defn list? [l]
  (isinstance l list))


(defn size [tree]
  (if (list? tree)
    (if tree
      (+
         (size (car tree))
         (size (cdr tree)))
      0)
    1))


(defn draw [tree]

  ; cairo boilerplate
  (setv surface
    (cairo.ImageSurface cairo.FORMAT_ARGB32 W H))
  (setv cr (cairo.Context surface))

  (let [[sz    (size tree)]
        [sz/2  (/ sz 2)]
        [ratio (/ (min W H) sz)]]
    (.scale     cr ratio ratio)
    (.translate cr sz/2 sz/2))

  (.scale cr 0.5 0.5)
  (.set_line_width cr 1)
  ; ---

  ; drawing functions (stuff> means draw-stuff)
  (defn color! [r g b]
    (.set-source-rgb cr r g b))

  (defn circle> [r]
    (.arc cr 0 0 r 0 (* 2 pi))
    (.stroke cr))

  (defn atom> [atom])

  (defn cell> [cell]
    (color! 0 0 0)
    (circle> (size cell))

    (if (list? (car cell))
      (cell> (car cell))
      (atom> (car cell)))

    (when (cdr cell)
      (cell> (cdr cell))))
  ; ---

  ; actual drawing
  (cell> tree)
  ; ---

  (.write-to-png surface "out.png"))


(defmain [&rest args]
  (setv file-name
    (get args (if (cdr args)
                1 0)))
  (setv code
    (with [[f (open file-name)]]
    (.read f)))

  (setv tree
    (tokenize code))

  (draw tree))
