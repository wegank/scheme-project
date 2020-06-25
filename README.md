# Scheme Project

Projet de L2 : réimplémentation d’un sous-ensemble de Scheme en OCaml.
Les fonctions de bases sont fournies : parser et types de bases.

# Table des matières

- [Introduction](#introduction) 
- [Installation](#installation)
- [Implémentations](#implementations)
  - [Pour débuter](#pour-débuter)
  - [Pour aller plus loin](#pour-aller-plus-loin)
  - [Bonus](#bonus)
- [Fichiers](#fichiers)
  - [Types](#types)
  - [Parser](#parser)

## Introduction

On souhaite ré-implémenter un interprète d’un sous-ensemble de Scheme en OCaml.  
Le langage Scheme est un dialecte de Lisp à notation préfixe. La grammaire du langage est donc identique pour toute expression, aussi nommées s-expression ou sexpr : `(function-name arg-1 arg-2 arg-3 ... arg-n)`. Ainsi on écrira `(+ 1 2)` pour `1 + 2`, `(/ 1 2 3 4)` pour `1 / 2 / 3 / 4` ou `(lambda (x) (+ 1 x))` pour `function x -> x + 1`.

L’interprétation d’un langage se fait en 3 étapes : l’analyse lexicale, durant laquelle on vérifie que les code est correct vis-à-vis du langage ; l’analyse syntaxique, durant laquelle on vérifie que la syntaxe et la grammaire du langage sont respectées et qui génère un arbre de syntaxe abstrait – ou AST ; l’interprétation, durant laquelle on utilise l’AST construit pour évaluer le programme en tant que tel.

> Un AST est une structure utilisable en informatique pour représenter une langue ou un langage.

Dans notre sous-ensemble, on dénote 9 primitives : `+`, `-`, `*`, `/`, `=`, `<`, `if`, `lambda` et `let.`  
Le parser du langage est fourni. Le but va être de créer l’interprète capable d’évaluer le code, étape par étape.

Deux modules sont fournis : `Types` et `Parser`. `Types` définit tous les types utilisés par l’AST pour parser le code, et `Parser` dispose d’une fonction `parse`, de signature `string -> sexpr list`. Ceux-ci se trouvent dans `/src`.

Si besoin, vous trouverez une transcriptions des types plus bas.

<!-- 4. On souhaite exécuter le programme `(print "Bonjour monde")`. Celui-ci se présente sous la forme `List [ Atom (Primitive Print); Atom (Str_ "Bonjour monde") ] : sexpr`. Écrire une fonction `eval` de signature `sexpr -> sexpr` et une fonction `apply_primitive` de signature `primitive -> sexpr list -> sexpr`, et gérer le cas de `Print` et de `Str_`. On s’aidera du pattern matching (`match ... with`) et on renverra une erreur dans tous les cas non gérés. Pour rappel, une erreur peut-être déclenchée avec la fonction `failwith`.
   Indice : gérer `List` et `Atom` dans `eval` et `Print` dans `apply_primitive`. `print` à comme valeur de retour `Unit`. -->

<!-- Indice professeur : `(let (x 10) body)` est équivalent à `((lambda (x) body) 10)`-->

## Installation

- Cloner le dépôt
```bash
# SSH Users
git clone git@github.com/ghivert/scheme-project-clear.git
# HTTPS Users
git clone https://github.com/ghivert/scheme-project-clear.git
```
- [Installer OPAM](https://opam.ocaml.org/doc/Install.html)
```bash
opam init
```
- Installer dune
```bash
opam install dune
```
- Aller dans le dossier `/src`
```bash
cd src
```
- Lancer la compilation
```bash
dune build main.exe && ../_build/default/src/main.exe
```

## Implémentations
### Pour débuter

1. Analyser la structure d’un programme dans l’interprète. Pour cela, n’hésitez pas à afficher des programmes parsés directement dans le top-level. Utilisez `Parser.parse "(+ 1 3)"` par exemple.
2. Le fichier `main.ml` vous est fourni. Il contient le squelette de code nécessaire pour implémenter le projet. Nous allons commencer par ajouter le support des opérateurs arithmétiques : `+`, `-`, `*` et `/`.
    1. Écrire le corps de la fonction `eval`. Celle-ci devra prendre une sexpr en entrée et l’évaluer. Si c’est un atom, renvoyer l’atom, si c’est un Call, appeler `eval_call` sur le corps de l’expression. On ignorera l’env pour le moment.
    2. Écrire le corps de `eval_call`. Si l’expression est un `Special`, alors renvoyer l’évaluation de `eval_special`, sinon appliquer `apply` sur tout le corps du `Call`. On ignorera l’env pour le moment.
    3. Écrire le corps de `apply`. Vérifier que l’expression est une primitive, et l’appliquer sur ses arguments à l’aide de `apply_primitive`. On ignorera l’env pour le moment.
    4. Écrire le corps de `apply_primitive`. Celui-ci prends une primitive et des arguments, et cherche à matcher la primitive avec un opérateur arithmétique. S’il le trouve, alors il applique séquentiellement l’opération sur tous les arguments et retourne la valeur.
3. On souhaite rajouter le support de `=` et `<`. Proposez une implémentation en appliquant la même démarche qu’au-dessus. Ces deux opérateurs suivent le même schéma que pour les opérateurs arithmétiques.

### Pour aller plus loin

1. On souhaite rajouter le support de `if`. La syntaxe de `if` est la suivante : `(if condition consequence alternant)` avec `condition`, `consequence` et `alternant` des sexpr. Attention, il ne faut évaluer qu’un seul des opérandes : `consequence` si `condition` est vraie, sinon `alternant`.
   Indice: Il faut rajouter le support de `Special If` dans `eval`.
    1. Rajouter le support de `Special` dans `eval_call`. Pour cela, écrire la fonction `is_special` puis `eval_special` avec le cas du `if`. 
    2. Évaluer la condition. Si elle est vraie, évaluer la conséquence, sinon évaluer l’alternant.
1. On souhaite rajouter le support de `lambda`. `lambda` crée une fonction anonyme de la même manière que `function` en OCaml. La syntaxe de `lambda` est la suivante : `(lambda (x) (print x))`. Il est nécessaire de rajouter le support de l’environnement.
    1. Rajouter le support de `Lambda` dans `eval_special`. Il s’évalue vers un `Atom`. Pensez à gérer les arguments de la fonction. Vous pouvez vous aider de la fonction `string_of_symbol`.
    2. Rajouter le support de `Fun` dans `apply`. Il faut appliquer la fonction avec `apply_function`.
    3. Écrire le corps de `apply_function`. Récupérer la liste de arguments de la fonction, mettez-là dans un nouvel environnement qui hérite du précédent (portée lexicale), et évaluer la fonction dans le nouvel environnement.
    4. Rajouter la gestion des `Symbol` dans `eval`.
1. Rajouter le support de `let`. La syntaxe de `let` est la suivante : `(let (x 10) body)` avec `body` une sexpr. À l’évaluation, il est possible de transformer `let` en `lambda`. Proposez une solution.  
   Indice : gérer `let` dans `eval_special` uniquement.

### Bonus :

- Proposez une implémentation pour `cons`, `car` et `cdr`.
```ocaml
let cons : sexpr -> sexpr -> sexpr
 (* Tel que (cons x y) construit la liste avec x en tête de la liste
      y et lance Invalid_argument "cons" si y n'est pas une liste *)
 
let car : sexpr -> sexpr 
 (* Telle que (car x) accède à la tête de la liste x 
      et lance Invalid_argument "cons" si x n'est pas une liste *)

let cdr : sexpr -> sexpr 
 (* Telle que (cdr x) accède aux reste de la liste x 
      et lance Invalid_argument "cons" si x n'est pas une liste. *)
``` 
- Pour cela, if faut rajouter un `Atom` dans les types de type `List of sexpr list` et dans le parser un `Special` `Cdr`, `Car` et `Cons`.  
On pourra alors écrire des listes du type `(cons 1 (cons 2 (cons 3)))`.

## Fichiers
### Types

```ocaml
type sexpr
  = Atom of atom
  | Special of special
  | Symbol of string
  | Call of sexpr list

and atom
  = Int of int
  | Bool of bool
  | Str_ of string
  | Primitive of primitive
  | Fun of env * code

and special
  = If
  | Lambda
  | Let

and primitive
  = Add
  | Sub
  | Mul
  | Div
  | Eq
  | Lt

and env = (string * sexpr) list

and code = (string list * sexpr)
```

### Parser

```ocaml
open Types

let split_expressions (chars : string) : string list =
  let open_matcher = Str.regexp "("
  and close_matcher = Str.regexp ")"
  and newline_matcher = Str.regexp "\n"
  in
    chars
    |> Str.global_replace newline_matcher " "
    |> Str.global_replace open_matcher " ( "
    |> Str.global_replace close_matcher " ) "
    |> Str.split @@ Str.regexp " "
    |> List.filter @@ fun x -> x <> ""

let match_atom (atom : string) : atom =
  let ft = Str.first_chars atom 1
  and lt = Str.last_chars atom 1
  in if ft = "\"" && lt = "\"" then
    Str_ (String.sub atom 1 @@ String.length atom - 2)
  else if atom = "true" then
    Bool true
  else if atom = "false" then
    Bool false
  else
    Int (int_of_string atom)

let try_to_match_atom (atom : string) : sexpr =
  try
    Atom (match_atom atom)
  with Failure _ ->
    Symbol atom

let sexpr_of_string x : sexpr =
  match x with
  | "+"      -> Atom (Primitive Add)
  | "-"      -> Atom (Primitive Sub)
  | "*"      -> Atom (Primitive Mul)
  | "/"      -> Atom (Primitive Div)
  | "="      -> Atom (Primitive Eq)
  | "<"      -> Atom (Primitive Lt)
  | "if"     -> Special If
  | "lambda" -> Special Lambda
  | "let"    -> Special Let
  | others   -> try_to_match_atom others

let rec group_expressions (acc : sexpr list) (chars : string list) =
  match chars with
  | [] -> (acc, [])
  | hd :: tl ->
    if hd = "(" then
      let (expr, next) = group_expressions [] tl in
      group_expressions (expr @ acc) next
    else if hd = ")" then
      ([ Call (List.rev acc) ], tl)
    else
      group_expressions (sexpr_of_string hd :: acc) tl

let parse (program : string) : sexpr list =
  program
  |> split_expressions
  |> group_expressions []
  |> fst
  |> List.rev
```
