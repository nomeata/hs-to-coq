{-|
Module      : HsToCoq.Coq.Gallina
Description : An AST for Gallina, the surface language of Coq
Copyright   : Copyright © 2016 Antal Spector-Zabusky, University of Pennsylvania
License     : MIT
Maintainer  : antal.b.sz@gmail.com
Stability   : experimental

<https://coq.inria.fr/distrib/current/refman/Reference-Manual003. Chapter 1, \"The Gallina Specification Language\", in the Coq reference manual.>
-}

{-# LANGUAGE OverloadedStrings, LambdaCase, TemplateHaskell #-}

module HsToCoq.Coq.Gallina (
  -- * Lexical structure
  -- $Lexical
  Ident,
  AccessIdent,
  Num,
  
  -- * Terms
  -- $Terms
  Term(..),
  Arg(..),
  Binders,
  Binder(..),
  Name(..),
  Qualid(..),
  Sort(..),
  FixBodies(..),
  CofixBodies(..),
  FixBody(..),
  CofixBody(..),
  Annotation(..),
  MatchItem(..),
  DepRetType(..),
  ReturnType(..),
  Equation(..),
  MultPattern(..),
  Pattern(..),
  OrPattern(..),
  
  -- * The vernacular
  -- $Vernacular
  Sentence(..),
  Assumption(..),
  AssumptionKeyword(..),
  Assums(..),
  Locality(..),
  Definition(..),
  Inductive(..),
  IndBody(..),
  Fixpoint(..),
  Assertion(..),
  AssertionKeyword(..),
  Tactics,
  Proof(..),

  -- * Formatting
  renderGallina,
  Gallina(..),
  renderIdent, renderAccessIdent,
  renderLocality
  ) where

import Prelude hiding (Num)
import Data.Text (Text)
import qualified Data.Text as T
import Numeric.Natural
import Data.List.NonEmpty (NonEmpty(), (<|))

import HsToCoq.Util.Functor
import HsToCoq.PrettyPrint
import Data.Traversable
import Data.List (foldl')
import qualified Language.Haskell.TH as TH

-- $Lexical
-- <https://coq.inria.fr/distrib/current/refman/Reference-Manual003.html#lexical §1.1, \"Lexical conventions\", in the Coq reference manual.>
--
-- We don't model the lexical conventions.  Values are just strings or numbers
-- or what have you.

-- |@/ident/ ::= /first_letter/ [/subsequent_letter/ … /subsequent_letter/]@
type Ident       = Text
-- |@/access_ident/ ::= . /ident/@
type AccessIdent = Ident
-- |@/num/ ::= /digit/ … /digit/@
type Num         = Natural

-- $Terms
-- <https://coq.inria.fr/distrib/current/refman/Reference-Manual003.html#term §1.2, \"Terms\", in the Coq reference manual.>

-- |@/term/ ::=@
data Term = Forall Binders Term                                       -- ^@forall /binders/, /term/@
          | Fun Binders Term                                          -- ^@fun /binders/ => /term/@
          | Fix FixBodies                                             -- ^@fix /fix_bodies/@
          | Cofix CofixBodies                                         -- ^@cofix /cofix_bodies/@
          | Let Ident [Binder] (Maybe Term) Term Term                 -- ^@let /ident/ [/binders/] [: /term/] := /term/ in /term/@
          | LetFix FixBody Term                                       -- ^@let fix /fix_body/ in /term/@
          | LetCofix CofixBody Term                                   -- ^@let cofix /cofix_body/ in /term/@
          | LetTuple [Name] (Maybe DepRetType) Term Term              -- ^@let ( [/name/ , … , /name/] ) [/dep_ret_type/] := /term/ in /term/@
          | LetTick Pattern (Maybe Term) Term (Maybe ReturnType) Term -- ^@let ' /pattern/ [in /term/] := /term/ [/return_type/] in /term/@
          | If Term (Maybe DepRetType) Term Term                      -- ^@if /term/ [/dep_ret_type/] then /term/ else /term/@
          | HasType Term Term                                         -- ^@/term/ : /term/@
          | CheckType Term Term                                       -- ^@/term/ <: /term/@
          | ToSupportType Term                                        -- ^@/term/ :>@
          | Arrow Term Term                                           -- ^@/term/ -> /term/@
          | App Term (NonEmpty Arg)                                   -- ^@/term/ /arg/ … /arg/@
          | ExplicitApp Qualid [Term]                                 -- ^@\@ /qualid/ [/term/ … /term/]@
          | InScope Term Ident                                        -- ^@/term/ % /ident/@
          | Match (NonEmpty MatchItem) (Maybe ReturnType) [Equation]  -- ^@match /match_item/ , … , /match_item/ [/return_type/] with [[|] /equation/ | … | /equation/] end@
          | Qualid Qualid                                             -- ^@/qualid/@
          | Sort Sort                                                 -- ^@/sort/@
          | Num  Num                                                  -- ^@/num/@
          | Underscore                                                -- ^@_@
          | Parens Term                                               -- ^@( /term/ )@
          deriving (Eq, Ord, Show, Read)

-- |@/arg/ ::=@
data Arg = PosArg Term                                                     -- ^@/term/@
         | NamedArg Ident Term                                             -- ^@( /ident/ := /term/ )@
         deriving (Eq, Ord, Show, Read)

-- |@/binders/ ::= /binder/ … /binder/@
type Binders = NonEmpty Binder

-- |@/binder/ ::=@
data Binder = Inferred Name                                                -- ^@/name/@
            | Typed (NonEmpty Name) Term                                   -- ^@( /name/ … /name/ : /term/ )@
            | BindLet Name (Maybe Term) Term                               -- ^@( /name/ [: /term/] := /term/ )@
            deriving (Eq, Ord, Show, Read)

-- |@/name/ ::=@
data Name = Ident Ident                                                    -- ^@/ident/@
          | UnderscoreName                                                 -- ^@_@
          deriving (Eq, Ord, Show, Read)

-- |@/qualid/ ::=@
data Qualid = Bare Ident                                                   -- ^@/ident/@
            | Qualified Qualid AccessIdent                                 -- ^@/qualid/ /access_ident/@
            deriving (Eq, Ord, Show, Read)

-- |@/sort/ ::=@
data Sort = Prop                                                           -- ^@Prop@
          | Set                                                            -- ^@Set@
          | Type                                                           -- ^@Type@
          deriving (Eq, Ord, Show, Read, Enum, Bounded)

-- |@/fix_bodies/ ::=@
data FixBodies = FixOne FixBody                                            -- ^@/fix_body/@
               | FixMany FixBody (NonEmpty FixBody) Ident                  -- ^@/fix_body/ with /fix_body/ with … with /fix_body/ for /ident/@
               deriving (Eq, Ord, Show, Read)

-- |@/cofix_bodies/ ::=@
data CofixBodies = CofixOne CofixBody                                      -- ^@/cofix_body/@
                 | CofixMany CofixBody (NonEmpty CofixBody) Ident          -- ^@/cofix_body/ with /cofix_body/ with … with /cofix_body/ for /ident/@
                 deriving (Eq, Ord, Show, Read)

-- |@/fix_body/ ::=@
data FixBody = FixBody Ident Binders (Maybe Annotation) (Maybe Term) Term  -- ^@/ident/ /binders/ [/annotation/] [: /term/] := /term/@
             deriving (Eq, Ord, Show, Read)

-- |@/cofix_body/ ::=@
data CofixBody = CofixBody Ident Binders (Maybe Term) Term                 -- ^@/ident/ /binders/ [: /term/] := /term/@
               deriving (Eq, Ord, Show, Read)

-- |@/annotation/ ::=@
newtype Annotation = Annotation Ident                                      -- ^@{ struct /ident/ }@
                   deriving (Eq, Ord, Show, Read)

-- |@/match_item/ ::=@
data MatchItem = MatchItem Term (Maybe Name) (Maybe (Qualid, [Pattern]))   -- ^@/term/ [as /name/] [in /qualid/ [/pattern/ … /pattern/]]@
               deriving (Eq, Ord, Show, Read)

-- |@/dep_ret_type/ ::=@
data DepRetType = DepRetType (Maybe Name) ReturnType                       -- ^@[as /name/] /return_type/@
                deriving (Eq, Ord, Show, Read)

-- |@/return_type/ ::=@
newtype ReturnType = ReturnType Term                                       -- ^@return /term/@
                   deriving (Eq, Ord, Show, Read)

-- |@/equation/ ::=@
data Equation = Equation (NonEmpty MultPattern) Term                       -- ^@/mult_pattern/ | … | /mult_pattern/ => /term/@
              deriving (Eq, Ord, Show, Read)

-- |@/mult_pattern/ ::=@
newtype MultPattern = MultPattern (NonEmpty Pattern)                       -- ^@/pattern/ , … , /pattern/@
                    deriving (Eq, Ord, Show, Read)

-- |@/pattern/ ::=@
data Pattern = ArgsPat Qualid (NonEmpty Pattern)                           -- ^@/qualid/ /pattern/ … /pattern/@
             | ExplicitArgsPat Qualid (NonEmpty Pattern)                   -- ^@\@ /qualid/ /pattern/ … /pattern/@
             | AsPat Pattern Ident                                         -- ^@/pattern/ as /ident/@
             | InScopePat Pattern Ident                                    -- ^@/pattern/ % /ident/@
             | QualidPat Qualid                                            -- ^@/qualid/@
             | UnderscorePat                                               -- ^@_@
             | NumPat Num                                                  -- ^@/num/@
             | OrPats (NonEmpty OrPattern)                                 -- ^@( /or_pattern/ , … , /or_pattern/ )@
             deriving (Eq, Ord, Show, Read)

-- |@/or_pattern/ ::=@
newtype OrPattern = OrPattern (NonEmpty Pattern)                           -- ^@/pattern/ | … | /pattern/@
                  deriving (Eq, Ord, Show, Read)

-- $Vernacular
-- <https://coq.inria.fr/distrib/current/refman/Reference-Manual003.html#Vernacular §1.3, \"The Vernacular\", in the Coq reference manual.>.

-- |@/sentence/ ::=@
data Sentence = AssumptionSentence Assumption                              -- ^@/assumption/@
              | DefinitionSentence Definition                              -- ^@/definition/@
              | InductiveSentence  Inductive                               -- ^@/inductive/@
              | FixpointSentence   Fixpoint                                -- ^@/fixpoint/@
              | AssertionSentence  Assertion Proof                         -- ^@/assertion/ /proof/@
              deriving (Eq, Ord, Show, Read)

-- |@/assumption/ ::=@
data Assumption = Assumption AssumptionKeyword Assums                      -- ^@/assumption_keyword/ /assums/ .@
                deriving (Eq, Ord, Show, Read)

-- |@/assumption_keyword/ ::=@
data AssumptionKeyword = Axiom                                             -- ^@Axiom@
                       | Axioms                                            -- ^@Axioms@ – not in the grammar, but accepted.
                       | Conjecture                                        -- ^@Conjecture@
                       | Parameter                                         -- ^@Parameter@
                       | Parameters                                        -- ^@Parameters@
                       | Variable                                          -- ^@Variable@
                       | Variables                                         -- ^@Variables@
                       | Hypothesis                                        -- ^@Hypothesis@
                       | Hypotheses                                        -- ^@Hypotheses@
                       deriving (Eq, Ord, Show, Read, Enum, Bounded)

-- |@/assums/ ::=@
data Assums = UnparenthesizedAssums (NonEmpty Ident) Term                  -- ^@/ident/ … /ident/ : /term/@
            | ParenthesizedAssums (NonEmpty (NonEmpty Ident, Term))        -- ^@( /ident/ … /ident/ : /term ) … ( /ident/ … /ident/ : /term)@
            deriving (Eq, Ord, Show, Read)

-- |@[Local] ::=@ – not a part of the grammar /per se/, but a common fragment
data Locality = Global                                                     -- ^@@ – (nothing)
              | Local                                                      -- ^@Local@
              deriving (Eq, Ord, Show, Read, Enum, Bounded)

-- |@/definition/ ::=@
data Definition = DefinitionDef Locality Ident [Binder] (Maybe Term) Term  -- ^@[Local] Definition /ident/ [/binders/] [: /term/] := /term/ .@
                | LetDef Ident [Binder] (Maybe Term) Term                  -- ^@Let /ident/ [/binders/] [: /term/] := /term/ .@
                deriving (Eq, Ord, Show, Read)

-- |@/inductive/ ::=@
data Inductive = Inductive   (NonEmpty IndBody)                            -- ^@Inductive /ind_body/ with … with /ind_body/ .@
               | CoInductive (NonEmpty IndBody)                            -- ^@CoInductive /ind_body/ with … with /ind_body/ .@
               deriving (Eq, Ord, Show, Read)

-- |@/ind_body/ ::=@
data IndBody = IndBody Ident [Binder] Term [(Ident, [Binder], Maybe Term)] -- ^@/ident/ [/binders/] : /term/ := [[|] /ident/ [/binders/] [: /term/] | … | /ident/ [/binders/] [: /term/]]@
             deriving (Eq, Ord, Show, Read)

-- |@/fixpoint/ ::=@
data Fixpoint = Fixpoint   (NonEmpty FixBody)                              -- ^@Fixpoint /fix_body/ with … with /fix_body/ .@
              | CoFixpoint (NonEmpty CofixBody)                            -- ^@CoFixpoint /fix_body/ with … with /fix_body/ .@
              deriving (Eq, Ord, Show, Read)

-- |@/assertion/ ::=@
data Assertion = Assertion AssertionKeyword Ident [Binder] Term            -- ^@/assertion_keyword/ /ident/ [/binders/] : /term/ .@
               deriving (Eq, Ord, Show, Read)

-- |@/assertion_keyword/ ::=@
data AssertionKeyword = Theorem                                            -- ^@Theorem@
                      | Lemma                                              -- ^@Lemma@
                      | Remark                                             -- ^@Remark@
                      | Fact                                               -- ^@Fact@
                      | Corollary                                          -- ^@Corollary@
                      | Proposition                                        -- ^@Proposition@
                      | Definition                                         -- ^@Definition@
                      | Example                                            -- ^@Example@
                      deriving (Eq, Ord, Show, Read, Enum, Bounded)

-- |A \"representation\" of tactics; left as @…@ in the grammar
type Tactics = Text

-- |@/proof/ ::=@
data Proof = ProofQed      Tactics                                         -- ^@Proof . … Qed .@
           | ProofDefined  Tactics                                         -- ^@Proof . … Defined .@
           | ProofAdmitted Tactics                                         -- ^@Proof . … Admitted .@
           deriving (Eq, Ord, Show, Read)


-- Formatting
----------------------------------------------------------------------

class Gallina a where
  renderGallina' :: Int -> a -> Doc

renderGallina :: Gallina a => a -> Doc
renderGallina = renderGallina' 0

renderIdent :: Ident -> Doc
renderIdent = text

renderAccessIdent :: AccessIdent -> Doc
renderAccessIdent = text . T.cons ':'

renderNum :: Num -> Doc
renderNum = integer . toInteger

-- Module-local
render_type :: Term -> Doc
render_type ty = softline <> ":" <+> align (renderGallina ty)

-- Module-local
render_opt_type :: Maybe Term -> Doc
render_opt_type = maybe mempty render_type

-- Module-local
render_opt_rtype :: Gallina a => Maybe a -> Doc
render_opt_rtype = maybe mempty $ \rty -> nest 2 $ softline <> renderGallina rty

-- Module-local
data Orientation = H | V
                 deriving (Eq, Ord, Show, Read, Enum, Bounded)

ocat :: Foldable f => Orientation -> f Doc -> Doc
ocat H = fillSep
ocat V = vcat

-- Module-local
render_args :: (Functor f, Foldable f, Gallina a) => Orientation -> f a -> Doc
render_args o = align . ocat o . fmap renderGallina

-- Module-local
render_args_and :: (Functor f, Foldable f, Gallina a) => Orientation -> (b -> Doc) -> f a -> b -> Doc
render_args_and o f args x = render_args o args <> f x

-- Module-local
render_args_ty :: (Functor f, Foldable f, Gallina a) => Orientation -> f a -> Term -> Doc
render_args_ty o = render_args_and o $ nest 2 . render_type

-- Module-local
render_args_oty :: (Functor f, Foldable f, Gallina a) => Orientation -> f a -> Maybe Term -> Doc
render_args_oty o = render_args_and o $ nest 2 . render_opt_type
                        
-- Module-local
render_mutual_def :: Gallina a => Doc -> NonEmpty a -> Doc
render_mutual_def def bodies =
  def <+> foldr1 (\body doc -> body <!> "with" <+> doc) (renderGallina <$> bodies) <> "."

-- TODO: Precedence!
instance Gallina Term where
  renderGallina' _p (Forall vars body) = parens $
    group $ "forall" <+> render_args V vars <> nest 2 ("," <!> renderGallina body)
  
  renderGallina' _p (Fun vars body) = parens $
    group $ "fun" <+> render_args V vars <+> nest 2 ("=>" <!> renderGallina body)
  
  renderGallina' _p (Fix fbs) = parens $
    "fix" <+> renderGallina fbs
  
  renderGallina' _p (Cofix cbs) = parens $
    "cofix" <+> renderGallina cbs
  
  renderGallina' _p (Let var args oty val body) = parens $
         "let" <+> group (   renderIdent var
                         <>  spaceIf args <> render_args_oty V args oty
                         <+> nest 2 (":=" <!> renderGallina val))
    <!>  "in" <+> align (renderGallina body)
  
  renderGallina' _p (LetFix def body) = parens $
    "let fix" <+> renderGallina def <!> "in" <+> align (renderGallina body)
  
  renderGallina' _p (LetCofix def body) = parens $
    "let cofix" <+> renderGallina def <!> "in" <+> align (renderGallina body)
  
  renderGallina' _p (LetTuple vars orty val body) = parens $
        "let" <+> group (   (parens . align . vsep . punctuate "," $ renderGallina <$> vars)
                        <>  render_opt_rtype orty
                        <+> nest 2 (":=" <!> renderGallina val))
    <!> "in" <+> align (renderGallina body)
  
  renderGallina' _p (LetTick pat oin val orty body) = parens $
        "let" <+> align (group $   "'" <> align (renderGallina pat)
                               <>  maybe mempty (\inT -> softline <> "in" <+> renderGallina inT) oin
                               <+> nest 2 (  ":=" <!> renderGallina val
                                                  <>  render_opt_rtype orty))
    <!> "in" <+> align (renderGallina body)

  renderGallina' _p (If c odrty t f) = parens $
        "if"   <+> align (renderGallina c <> render_opt_rtype odrty)
    <!> "then" <+> align (renderGallina t)
    <!> "else" <+> align (renderGallina f)
  
  renderGallina' _p (HasType tm ty) = parens $
    renderGallina tm <+> ":" <+> renderGallina ty
  
  renderGallina' _p (CheckType tm ty) = parens $
    renderGallina tm <+> "<:" <+> renderGallina ty
  
  renderGallina' _p (ToSupportType tm) = parens $
    renderGallina tm <+> ":>"
  
  renderGallina' _p (Arrow ty1 ty2) = parens $
    renderGallina ty1 <+> "->" <+> renderGallina ty2
  
  renderGallina' _p (App f args) = parens $
    renderGallina f </> render_args H args
  
  renderGallina' _p (ExplicitApp qid args) = parens $
    "@" <> renderGallina qid <> softlineIf args <> render_args H args
  
  renderGallina' _p (InScope tm scope) = parens $
    renderGallina tm <+> "%" <+> renderIdent scope
  
  renderGallina' _p (Match discriminees orty eqns) = parens $
       "match" <+> group (align . nest (-2)
                           $ (sepWith (<!>) (<+>) "," $ renderGallina <$> discriminees)
                           <> maybe mempty (\rty -> line <> renderGallina rty) orty)
               <+> "with"
    <> (case eqns of
          [] -> space
          _  -> nest 2 (line <> "| " <> sepWith (<!>) (<+>) "|" (renderGallina <$> eqns))
             <> line)
    <> "end"
  
  renderGallina' _ (Qualid qid) =
    renderGallina qid
  
  renderGallina' _ (Sort sort) =
    renderGallina sort
  
  renderGallina' _ (Num num) =
    renderNum num
  
  renderGallina' _ Underscore =
    char '_'
  
  renderGallina' _ (Parens t) =
    parens $ renderGallina t

instance Gallina Arg where
  renderGallina' p (PosArg t) =
    renderGallina' p t
  renderGallina' _ (NamedArg name t) =
    hang 2 . parens $ renderIdent name </> ":=" <+> align (renderGallina t)

instance Gallina Binder where
  renderGallina' _ (Inferred name)  =
    renderGallina name
  renderGallina' _ (Typed names ty) =
    parens $ render_args_ty H names ty
  renderGallina' _ (BindLet name oty val) =
    hang 2 . parens $ renderGallina name <> render_opt_type oty </> ":=" <+> align (renderGallina val)

instance Gallina Name where
  renderGallina' _ (Ident ident)  = renderIdent ident
  renderGallina' _ UnderscoreName = char '_'

instance Gallina Qualid where
  renderGallina' _ (Bare ident)        = renderIdent ident
  renderGallina' _ (Qualified qid aid) = renderGallina qid <> renderAccessIdent aid

instance Gallina Sort where
  renderGallina' _ Prop = "Prop"
  renderGallina' _ Set  = "Set"
  renderGallina' _ Type = "Type"

instance Gallina FixBodies where
  renderGallina' p (FixOne fb) =
    renderGallina' p fb
  renderGallina' p (FixMany fb fbs var) =
    spacedSepPre "with" (align . renderGallina' p <$> fb <| fbs) </> "for" <+> renderIdent var

instance Gallina CofixBodies where
  renderGallina' p (CofixOne cb) =
    renderGallina' p cb
  renderGallina' p (CofixMany cb cbs var) =
    spacedSepPre "with" (align . renderGallina' p <$> cb <| cbs) </> "for" <+> renderIdent var

instance Gallina FixBody where
  renderGallina' _ (FixBody f args oannot oty def) =
    hang 2 $
      renderIdent f </> align (    fillSep (renderGallina <$> args)
                              </?> (renderGallina <$> oannot))
                    <>  render_opt_type oty </> ":=" <+> align (renderGallina def)

instance Gallina CofixBody where
  renderGallina' _ (CofixBody f args oty def) =
    renderIdent f </> render_args_oty H args oty
                  </> ":=" <+> align (renderGallina def)

instance Gallina Annotation where
  renderGallina' _ (Annotation var) = braces $ "struct" <+> renderIdent var

instance Gallina MatchItem where
  renderGallina' _ (MatchItem scrutinee oas oin) =
    hang 2 $
      renderGallina scrutinee
        </?> (oas <&> \as         -> "as" <+> renderGallina as)
        </?> (oin <&> \(qid,pats) -> "in" <+> renderGallina qid
                                          <+> render_args H pats)

instance Gallina DepRetType where
  renderGallina' _ (DepRetType oname rty) =
    maybe mempty (\name -> "as" <+> renderGallina name <> softline) oname <> renderGallina rty

instance Gallina ReturnType where
  renderGallina' _ (ReturnType ty) = "return" <+> align (renderGallina ty)

instance Gallina Equation where
  renderGallina' _ (Equation mps body) =
    spacedSepPre "|" (align . renderGallina <$> mps) <+> nest 2 ("=>" </> align (renderGallina body))

instance Gallina MultPattern where
  renderGallina' _ (MultPattern pats) = spacedSepPost "," $ renderGallina <$> pats

instance Gallina Pattern where
  renderGallina' _p (ArgsPat qid args) = parens $
    renderGallina qid </> render_args H args
  
  renderGallina' _p (ExplicitArgsPat qid args) = parens $
    "@" <> renderGallina qid <> softlineIf args <> render_args H args
  
  renderGallina' _p (AsPat pat id) = parens $
    renderGallina pat <+> "as" <+> renderIdent id
  
  renderGallina' _p (InScopePat pat scope) = parens $
    renderGallina pat <+> "%" <+> renderIdent scope
  
  renderGallina' _p (QualidPat qid) =
    renderGallina qid
  
  renderGallina' _ (UnderscorePat) =
    char '_'
  
  renderGallina' _ (NumPat n) =
    renderNum n
  
  renderGallina' _ (OrPats orPats) =
    parens . align . group $ sepWith (<>) (</>) "," (renderGallina <$> orPats)

instance Gallina OrPattern where
  renderGallina' _ (OrPattern pats) = spacedSepPre "|" (align . renderGallina <$> pats)

instance Gallina Sentence where
  renderGallina' p (AssumptionSentence ass)    = renderGallina' p ass
  renderGallina' p (DefinitionSentence def)    = renderGallina' p def
  renderGallina' p (InductiveSentence  ind)    = renderGallina' p ind
  renderGallina' p (FixpointSentence   fix)    = renderGallina' p fix
  renderGallina' p (AssertionSentence  ass pf) = renderGallina' p ass <!> renderGallina' p pf

instance Gallina Assumption where
  renderGallina' p (Assumption kw ass) = renderGallina' p kw <+> align (renderGallina ass) <> "."

instance Gallina AssumptionKeyword where
  renderGallina' _ Axiom      = "Axiom"
  renderGallina' _ Axioms     = "Axioms"
  renderGallina' _ Conjecture = "Conjecture"
  renderGallina' _ Parameter  = "Parameter"
  renderGallina' _ Parameters = "Parameters"
  renderGallina' _ Variable   = "Variable"
  renderGallina' _ Variables  = "Variables"
  renderGallina' _ Hypothesis = "Hypothesis"
  renderGallina' _ Hypotheses = "Hypotheses"

instance Gallina Assums where
  renderGallina' _ = \case
    UnparenthesizedAssums ids ty -> renderAss ids ty
    ParenthesizedAssums   groups -> group . vsep $ parens . align . uncurry renderAss <$> groups
    where
      renderAss ids ty = fillSep (renderIdent <$> ids) <> nest 2 (render_type ty)

instance Gallina Locality where
  renderGallina' _ Global = "(*Global*)"
  renderGallina' _ Local  = "Local"

renderLocality :: Locality -> Doc
renderLocality Global = empty
renderLocality Local  = "Local" <> space
                        
instance Gallina Definition where
  renderGallina' _ = \case
    DefinitionDef loc name args oty body -> renderDef (renderLocality loc <> "Definition") name args oty body
    LetDef            name args oty body -> renderDef "Let"                                name args oty body
    where
      renderDef def name args oty body =
        def <+> renderIdent name
            <>  spaceIf args <> render_args_oty H args oty
            <+> nest 2 (":=" </> align (renderGallina body))
            <>  "."

instance Gallina Inductive where
  renderGallina' _ (Inductive   bodies) = render_mutual_def "Inductive"   bodies
  renderGallina' _ (CoInductive bodies) = render_mutual_def "CoInductive" bodies

instance Gallina IndBody where
  renderGallina' _ (IndBody name params ty cons) =
    renderIdent name <> spaceIf params <> render_args_ty H params ty
                     <> nest 2 (softline <> renderCons cons)
    where
      renderCons []         = ":="
      renderCons (con:cons) = align $ foldl' (<!>) (renderCon ":=" con) (renderCon "| " <$> cons)
      
      renderCon delim (cname, cargs, coty) =
        delim <+> renderIdent cname <> spaceIf cargs <> render_args_oty H cargs coty

instance Gallina Fixpoint where
  renderGallina' _ (Fixpoint   bodies) = render_mutual_def "Fixpoint"   bodies
  renderGallina' _ (CoFixpoint bodies) = render_mutual_def "CoFixpoint" bodies

instance Gallina Assertion where
  renderGallina' _ (Assertion kw name args ty) =
    renderGallina kw <+> renderIdent name <> spaceIf args <> group (render_args V args)
                     <+> group (nest 2 $ ":" </> renderGallina ty)
                     <>  "."

instance Gallina AssertionKeyword where
  renderGallina' _ Theorem      = "Theorem"
  renderGallina' _ Lemma        = "Lemma"
  renderGallina' _ Remark       = "Remark"
  renderGallina' _ Fact         = "Fact"
  renderGallina' _ Corollary    = "Corollary"
  renderGallina' _ Proposition  = "Proposition"
  renderGallina' _ Definition   = "Definition"
  renderGallina' _ Example      = "Example"

instance Gallina Proof where
  renderGallina' _ = \case
    ProofQed      body -> renderProof "Qed"      body
    ProofDefined  body -> renderProof "Defined"  body
    ProofAdmitted body -> renderProof "Admitted" body
    where
      renderProof end body = "Proof." <!> indent 2 (string body) <!> end <> "."

-- Make all 'Gallina' types 'Pretty' types in the default way
let abort = fail "Internal error: unexpected result from `reify'" in
  TH.reify ''Gallina >>= \case
    TH.ClassI _ is ->
      fmap concat . for is $ \case
        TH.InstanceD _ (TH.AppT (TH.ConT _gallina) ty) _ ->
          [d|instance Pretty $(pure ty) where pretty = renderGallina|]
        _ -> abort
    _ -> abort

