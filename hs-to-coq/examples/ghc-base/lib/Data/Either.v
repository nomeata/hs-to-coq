(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Wf.

(* Preamble *)


(* Converted imports: *)

Require Coq.Lists.List.
Require GHC.Base.

(* Converted type declarations: *)

(* Translating `EqEither' failed: type/data families unsupported *)
(* Converted value declarations: *)

Local Definition instance_GHC_Base_Functor__sum_a__fmap {inst_a} : forall {a}
                                                                          {b},
                                                                     (a -> b) -> (sum inst_a) a -> (sum inst_a) b :=
  fun {a} {b} =>
    fun arg_103__ arg_104__ =>
      match arg_103__ , arg_104__ with
        | _ , inl x => inl x
        | f , inr y => inr (f y)
      end.

Local Definition instance_GHC_Base_Functor__sum_a__op_zlzd__ {inst_a}
    : forall {a} {b}, a -> (sum inst_a) b -> (sum inst_a) a :=
  fun {a} {b} =>
    fun x => instance_GHC_Base_Functor__sum_a__fmap (GHC.Base.const x).

Instance instance_GHC_Base_Functor__sum_a_ {a} : GHC.Base.Functor (sum a) :=
  fun _ k =>
    k (GHC.Base.Functor__Dict_Build (sum a) (fun {a} {b} =>
                                      instance_GHC_Base_Functor__sum_a__op_zlzd__) (fun {a} {b} =>
                                      instance_GHC_Base_Functor__sum_a__fmap)).

Local Definition instance_GHC_Base_Applicative__sum_e__op_zlztzg__ {inst_e}
    : forall {a} {b}, (sum inst_e) (a -> b) -> (sum inst_e) a -> (sum inst_e) b :=
  fun {a} {b} =>
    fun arg_98__ arg_99__ =>
      match arg_98__ , arg_99__ with
        | inl e , _ => inl e
        | inr f , r => GHC.Base.fmap f r
      end.

Local Definition instance_GHC_Base_Applicative__sum_e__op_ztzg__ {inst_e}
    : forall {a} {b}, (sum inst_e) a -> (sum inst_e) b -> (sum inst_e) b :=
  fun {a} {b} =>
    fun x y =>
      instance_GHC_Base_Applicative__sum_e__op_zlztzg__ (GHC.Base.fmap (GHC.Base.const
                                                                       GHC.Base.id) x) y.

Local Definition instance_GHC_Base_Applicative__sum_e__pure {inst_e}
    : forall {a}, a -> (sum inst_e) a :=
  fun {a} => inr.

Instance instance_GHC_Base_Applicative__sum_e_ {e} : GHC.Base.Applicative (sum
                                                                          e) := fun _ k =>
    k (GHC.Base.Applicative__Dict_Build (sum e) (fun {a} {b} =>
                                          instance_GHC_Base_Applicative__sum_e__op_ztzg__) (fun {a} {b} =>
                                          instance_GHC_Base_Applicative__sum_e__op_zlztzg__) (fun {a} =>
                                          instance_GHC_Base_Applicative__sum_e__pure)).

Local Definition instance_GHC_Base_Monad__sum_e__op_zgzg__ {inst_e} : forall {a}
                                                                             {b},
                                                                        (sum inst_e) a -> (sum inst_e) b -> (sum inst_e)
                                                                        b :=
  fun {a} {b} => GHC.Base.op_ztzg__.

Local Definition instance_GHC_Base_Monad__sum_e__op_zgzgze__ {inst_e}
    : forall {a} {b}, (sum inst_e) a -> (a -> (sum inst_e) b) -> (sum inst_e) b :=
  fun {a} {b} =>
    fun arg_93__ arg_94__ =>
      match arg_93__ , arg_94__ with
        | inl l , _ => inl l
        | inr r , k => k r
      end.

Local Definition instance_GHC_Base_Monad__sum_e__return_ {inst_e} : forall {a},
                                                                      a -> (sum inst_e) a :=
  fun {a} => GHC.Base.pure.

Instance instance_GHC_Base_Monad__sum_e_ {e} : GHC.Base.Monad (sum e) := fun _
                                                                             k =>
    k (GHC.Base.Monad__Dict_Build (sum e) (fun {a} {b} =>
                                    instance_GHC_Base_Monad__sum_e__op_zgzg__) (fun {a} {b} =>
                                    instance_GHC_Base_Monad__sum_e__op_zgzgze__) (fun {a} =>
                                    instance_GHC_Base_Monad__sum_e__return_)).

(* Translating `instance forall {a} {b}, forall `{GHC.Show.Show b}
   `{GHC.Show.Show a}, GHC.Show.Show (sum a b)' failed: OOPS! Cannot find
   information for class "GHC.Show.Show" unsupported *)

(* Translating `instance forall {a} {b}, forall `{GHC.Read.Read b}
   `{GHC.Read.Read a}, GHC.Read.Read (sum a b)' failed: OOPS! Cannot find
   information for class "GHC.Read.Read" unsupported *)

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__compare {inst_a}
                                                                                                     {inst_b}
                                                                                                     `{GHC.Base.Ord
                                                                                                     inst_b}
                                                                                                     `{GHC.Base.Ord
                                                                                                     inst_a} : sum
                                                                                                               inst_a
                                                                                                               inst_b -> sum
                                                                                                               inst_a
                                                                                                               inst_b -> comparison :=
  fun arg_38__ arg_39__ =>
    match arg_38__ , arg_39__ with
      | a , b => match a with
                   | inl a1 => match b with
                                 | inl b1 => (GHC.Base.compare a1 b1)
                                 | _ => Lt
                               end
                   | inr a1 => match b with
                                 | inr b1 => (GHC.Base.compare a1 b1)
                                 | _ => Gt
                               end
                 end
    end.

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zg__ {inst_a}
                                                                                                     {inst_b}
                                                                                                     `{GHC.Base.Ord
                                                                                                     inst_b}
                                                                                                     `{GHC.Base.Ord
                                                                                                     inst_a} : sum
                                                                                                               inst_a
                                                                                                               inst_b -> sum
                                                                                                               inst_a
                                                                                                               inst_b -> bool :=
  fun arg_82__ arg_83__ =>
    match arg_82__ , arg_83__ with
      | a , b => match a with
                   | inl a1 => match b with
                                 | inl b1 => (GHC.Base.op_zg__ a1 b1)
                                 | _ => false
                               end
                   | inr a1 => match b with
                                 | inr b1 => (GHC.Base.op_zg__ a1 b1)
                                 | _ => true
                               end
                 end
    end.

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zgze__ {inst_a}
                                                                                                       {inst_b}
                                                                                                       `{GHC.Base.Ord
                                                                                                       inst_b}
                                                                                                       `{GHC.Base.Ord
                                                                                                       inst_a} : sum
                                                                                                                 inst_a
                                                                                                                 inst_b -> sum
                                                                                                                 inst_a
                                                                                                                 inst_b -> bool :=
  fun arg_71__ arg_72__ =>
    match arg_71__ , arg_72__ with
      | a , b => match a with
                   | inl a1 => match b with
                                 | inl b1 => (GHC.Base.op_zgze__ a1 b1)
                                 | _ => false
                               end
                   | inr a1 => match b with
                                 | inr b1 => (GHC.Base.op_zgze__ a1 b1)
                                 | _ => true
                               end
                 end
    end.

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zl__ {inst_a}
                                                                                                     {inst_b}
                                                                                                     `{GHC.Base.Ord
                                                                                                     inst_b}
                                                                                                     `{GHC.Base.Ord
                                                                                                     inst_a} : sum
                                                                                                               inst_a
                                                                                                               inst_b -> sum
                                                                                                               inst_a
                                                                                                               inst_b -> bool :=
  fun arg_49__ arg_50__ =>
    match arg_49__ , arg_50__ with
      | a , b => match a with
                   | inl a1 => match b with
                                 | inl b1 => (GHC.Base.op_zl__ a1 b1)
                                 | _ => true
                               end
                   | inr a1 => match b with
                                 | inr b1 => (GHC.Base.op_zl__ a1 b1)
                                 | _ => false
                               end
                 end
    end.

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zlze__ {inst_a}
                                                                                                       {inst_b}
                                                                                                       `{GHC.Base.Ord
                                                                                                       inst_b}
                                                                                                       `{GHC.Base.Ord
                                                                                                       inst_a} : sum
                                                                                                                 inst_a
                                                                                                                 inst_b -> sum
                                                                                                                 inst_a
                                                                                                                 inst_b -> bool :=
  fun arg_60__ arg_61__ =>
    match arg_60__ , arg_61__ with
      | a , b => match a with
                   | inl a1 => match b with
                                 | inl b1 => (GHC.Base.op_zlze__ a1 b1)
                                 | _ => true
                               end
                   | inr a1 => match b with
                                 | inr b1 => (GHC.Base.op_zlze__ a1 b1)
                                 | _ => false
                               end
                 end
    end.

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__min {inst_a}
                                                                                                 {inst_b} `{GHC.Base.Ord
                                                                                                 inst_b} `{GHC.Base.Ord
                                                                                                 inst_a} : sum inst_a
                                                                                                           inst_b -> sum
                                                                                                           inst_a
                                                                                                           inst_b -> sum
                                                                                                           inst_a
                                                                                                           inst_b :=
  fun x y =>
    if instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zlze__
       x y : bool
    then x
    else y.

Local Definition instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__max {inst_a}
                                                                                                 {inst_b} `{GHC.Base.Ord
                                                                                                 inst_b} `{GHC.Base.Ord
                                                                                                 inst_a} : sum inst_a
                                                                                                           inst_b -> sum
                                                                                                           inst_a
                                                                                                           inst_b -> sum
                                                                                                           inst_a
                                                                                                           inst_b :=
  fun x y =>
    if instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zlze__
       x y : bool
    then y
    else x.

Local Definition instance_forall___GHC_Base_Eq__b____GHC_Base_Eq__a___GHC_Base_Eq___sum_a_b__op_zeze__ {inst_a}
                                                                                                       {inst_b}
                                                                                                       `{GHC.Base.Eq_
                                                                                                       inst_b}
                                                                                                       `{GHC.Base.Eq_
                                                                                                       inst_a} : sum
                                                                                                                 inst_a
                                                                                                                 inst_b -> sum
                                                                                                                 inst_a
                                                                                                                 inst_b -> bool :=
  fun arg_29__ arg_30__ =>
    match arg_29__ , arg_30__ with
      | inl a1 , inl b1 => ((GHC.Base.op_zeze__ a1 b1))
      | inr a1 , inr b1 => ((GHC.Base.op_zeze__ a1 b1))
      | _ , _ => false
    end.

Local Definition instance_forall___GHC_Base_Eq__b____GHC_Base_Eq__a___GHC_Base_Eq___sum_a_b__op_zsze__ {inst_a}
                                                                                                       {inst_b} `{_
                                                                                                         : GHC.Base.Eq_
                                                                                                           inst_b} `{_
                                                                                                         : GHC.Base.Eq_
                                                                                                           inst_a} : sum
                                                                                                                     inst_a
                                                                                                                     inst_b -> sum
                                                                                                                     inst_a
                                                                                                                     inst_b -> bool :=
  fun arg_34__ arg_35__ =>
    match arg_34__ , arg_35__ with
      | a , b => negb
                 (instance_forall___GHC_Base_Eq__b____GHC_Base_Eq__a___GHC_Base_Eq___sum_a_b__op_zeze__
                 a b)
    end.

Instance instance_forall___GHC_Base_Eq__b____GHC_Base_Eq__a___GHC_Base_Eq___sum_a_b_ {a}
                                                                                     {b} `{GHC.Base.Eq_ b}
                                                                                     `{GHC.Base.Eq_ a} : GHC.Base.Eq_
                                                                                                         (sum a b) :=
  fun _ k =>
    k (GHC.Base.Eq___Dict_Build (sum a b)
                                instance_forall___GHC_Base_Eq__b____GHC_Base_Eq__a___GHC_Base_Eq___sum_a_b__op_zeze__
                                instance_forall___GHC_Base_Eq__b____GHC_Base_Eq__a___GHC_Base_Eq___sum_a_b__op_zsze__).

Instance instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b_ {a}
                                                                                     {b} `{GHC.Base.Ord b}
                                                                                     `{GHC.Base.Ord a} : GHC.Base.Ord
                                                                                                         (sum a b) :=
  fun _ k =>
    k (GHC.Base.Ord__Dict_Build (sum a b)
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zl__
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zlze__
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zg__
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__op_zgze__
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__compare
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__max
                                instance_forall___GHC_Base_Ord_b____GHC_Base_Ord_a___GHC_Base_Ord__sum_a_b__min).

Definition either {a} {c} {b} : (a -> c) -> (b -> c) -> sum a b -> c :=
  fun arg_14__ arg_15__ arg_16__ =>
    match arg_14__ , arg_15__ , arg_16__ with
      | f , _ , inl x => f x
      | _ , g , inr y => g y
    end.

Definition partitionEithers {a} {b} : list (sum a b) -> list a * list b :=
  let right :=
    fun arg_20__ arg_21__ =>
      match arg_20__ , arg_21__ with
        | a , pair l r => pair l (cons a r)
      end in
  let left :=
    fun arg_24__ arg_25__ =>
      match arg_24__ , arg_25__ with
        | a , pair l r => pair (cons a l) r
      end in
  GHC.Base.foldr (either left right) (pair nil nil).

Definition isLeft {a} {b} : sum a b -> bool :=
  fun arg_2__ => match arg_2__ with | inl _ => true | inr _ => false end.

Definition isRight {a} {b} : sum a b -> bool :=
  fun arg_0__ => match arg_0__ with | inl _ => false | inr _ => true end.

Definition lefts {a} {b} : list (sum a b) -> list a :=
  fun arg_9__ =>
    match arg_9__ with
      | x => let cont_10__ arg_11__ :=
               match arg_11__ with
                 | inl a => cons a nil
                 | _ => nil
               end in
             Coq.Lists.List.flat_map cont_10__ x
    end.

Definition rights {a} {b} : list (sum a b) -> list b :=
  fun arg_4__ =>
    match arg_4__ with
      | x => let cont_5__ arg_6__ :=
               match arg_6__ with
                 | inr a => cons a nil
                 | _ => nil
               end in
             Coq.Lists.List.flat_map cont_5__ x
    end.

(* Unbound variables:
     * Coq.Lists.List.flat_map GHC.Base.Applicative GHC.Base.Applicative__Dict_Build
     GHC.Base.Eq_ GHC.Base.Eq___Dict_Build GHC.Base.Functor
     GHC.Base.Functor__Dict_Build GHC.Base.Monad GHC.Base.Monad__Dict_Build
     GHC.Base.Ord GHC.Base.Ord__Dict_Build GHC.Base.compare GHC.Base.const
     GHC.Base.fmap GHC.Base.foldr GHC.Base.id GHC.Base.op_zeze__ GHC.Base.op_zg__
     GHC.Base.op_zgze__ GHC.Base.op_zl__ GHC.Base.op_zlze__ GHC.Base.op_ztzg__
     GHC.Base.pure Gt Lt bool comparison cons false inl inr list negb nil pair sum
     true
*)
