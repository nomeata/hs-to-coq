Require Import Id.
Require Import Core. (* For [Var] only *)
Require Import Unique.

Require Import Coq.Structures.Equalities.

Require Import GHC.Base.
Import GHC.Base.ManualNotations.

Require Import Proofs.GHC.Base.

Require Import Proofs.Unique.

Ltac unfold_zeze :=
  unfold GHC.Base.op_zeze__, Core.Eq___Var, op_zeze____, 
  Core.Eq___Var_op_zeze__, Eq_Char___;
  unfold GHC.Base.op_zeze__, Nat.Eq_nat, op_zeze____.  
Ltac unfold_zsze :=
  unfold GHC.Base.op_zsze__, Core.Eq___Var, op_zsze____, 
  Core.Eq___Var_op_zsze__, Eq_Char___;
  unfold GHC.Base.op_zsze__, Nat.Eq_nat, op_zsze____.  


(** ** Stuff about [Var] and [Unique] *)

Lemma getUnique_varUnique: 
    (Unique.getUnique : Var -> Unique.Unique) = varUnique.
Proof.
  unfold Unique.getUnique, Unique.getUnique__,Uniquable__Var,
     Core.Uniquable__Var_getUnique.
  auto.
Qed.


(** ** Properties about [GHC.Base.==] for Var. *)

(* Equal vars have equal keys *)
Lemma eq_unique : forall (v1 v2: Var), 
    (v1 GHC.Base.== v2) = true <->
    Unique.getWordKey (Unique.getUnique v1) = 
    Unique.getWordKey (Unique.getUnique v2). 
Proof.
  intros v1 v2.
  unfold_zeze.
  unfold Unique.getUnique.
  unfold Uniquable__Var, getUnique__, Core.Uniquable__Var_getUnique, 
  varUnique.
  destruct v1; destruct v2; simpl;
  apply N.eqb_eq.
Qed.

Instance EqLaws_Var : EqLaws Var := {}.
Proof.
  - unfold ssrbool.reflexive.
    unfold_zeze.
    intros. unfold is_true.
    apply N.eqb_refl.
  - unfold ssrbool.symmetric.
    intros. unfold_zeze.
    rewrite N.eqb_sym; auto.
  - unfold ssrbool.transitive.
    unfold_zeze.
    unfold is_true.
    intros x y z. 
    destruct x; destruct y; destruct z; simpl;
    repeat erewrite N.eqb_eq; intro h; rewrite h; auto.
  - intros.
    unfold_zsze.
    unfold_zeze.
    rewrite negb_involutive.
    reflexivity.
Qed.

(** ** A DecidableType structure based on  [GHC.Base.==]. *)

(* Define the Var type as a decidable type by using the Eq instance.
   (This instance only looks at the Unique components of the Var *)

Module Var_as_DT <: BooleanDecidableType <: DecidableType.
  Definition t := Var.

  Definition eqb : t -> t -> bool := _GHC.Base.==_.

  Definition eq : t -> t -> Prop := fun x y => eqb x y = true.

  Definition eq_equiv : Equivalence eq.
  Proof.
  split. 
  - unfold eq, eqb, Reflexive.
    apply Eq_refl.
  - unfold eq, eqb, Symmetric.
    eauto using Eq_sym.
  - unfold eq, eqb, Transitive.
    intros x y z h1 h2.
    eapply  Eq_trans; eauto.
  Defined.

  Definition eq_dec : forall x y : t, { eq x y } + { ~ (eq x y) }.
  Proof.
  intros x y.
  unfold eq, eqb.
  unfold_zeze.
  destruct x eqn:X; destruct y eqn:Y;  simpl.
  all: destruct (N.eqb n0 n2) eqn:EQ ; [left; auto | right; auto].
  Defined.

  Lemma eqb_eq : forall x y, eqb x y = true <-> eq x y.
    unfold eq. tauto.
  Qed. 

 Definition eq_refl := eq_equiv.(@Equivalence_Reflexive _ _).
 Definition eq_sym := eq_equiv.(@Equivalence_Symmetric _ _).
 Definition eq_trans := eq_equiv.(@Equivalence_Transitive _ _).

End Var_as_DT.


(** ** [almostEqual] *)

(* Two [Var]s are almostEqual if they differ only in 
   their IdInfo. All other components must be identitical.

   We define this as a [Prop] rather than a bool because
   we do not have a function that determines structural
   equality.
*)

Inductive almostEqual : Var -> Var -> Prop :=
 | AE_TyVar   : forall n u ty,
   almostEqual (Mk_TyVar n u ty)
               (Mk_TyVar n u ty)
 | AE_TcTyVar : forall n u ty1 ty2,
   almostEqual (Mk_TcTyVar n u ty1 ty2)
               (Mk_TcTyVar n u ty1 ty2)
 | AE_Id : forall n u ty ids idd id1 id2,
   almostEqual (Mk_Id n u ty ids idd id1)
               (Mk_Id n u ty ids idd id2).


Lemma almostEqual_refl:
  forall v, almostEqual v v.
Proof. intros. destruct v; constructor. Qed.

Lemma almostEqual_sym:
  forall v1 v2,
    almostEqual v1 v2 -> almostEqual v2 v1.
Proof.
  intros v1 v2 H.
  inversion H; subst; eauto.
  econstructor.
Qed.

Lemma almostEqual_trans:
  forall v1 v2 v3, 
    almostEqual v1 v2 -> almostEqual v2 v3 -> almostEqual v1 v3.
Proof.
  intros v1 v2 v3 H1 H2. 
  inversion H1; inversion H2; subst; inversion H3; eauto.
  econstructor.
Qed.

Lemma almostEqual_eq :
  forall v1 v2, 
    almostEqual v1 v2 -> (v1 GHC.Base.== v2 = true).
Proof.
  intros v1 v2 H.
  inversion H; unfold_zeze; simpl; apply N.eqb_refl.
Qed.

(** ** [isJoinId] etc. *)

Lemma isJoinId_eq : forall v,
  isJoinId v = match isJoinId_maybe v with | None => false |Some _ => true end.
Proof.
  unfold isJoinId.
  induction v; auto.
  now destruct i0.
Qed.

Lemma isJoinId_ae: forall v1 v2,
  almostEqual v1 v2 ->
  isJoinId v1 = isJoinId v2.
Proof.
  intros.
  induction H; reflexivity.
Qed.


Lemma isJoinId_isJoinId_maybe: forall v,
  isJoinId v = true ->
  isJoinId_maybe v = Some (idJoinArity v).
Proof.
  unfold isJoinId.
  induction v; simpl; intros; auto; try discriminate.
  now destruct i0.
Qed.

Lemma idJoinArity_join: forall v a,
  isJoinId_maybe v = Some a -> idJoinArity v = a.
Proof.
  unfold isJoinId, isJoinId_maybe, idJoinArity.
  induction v; simpl; intros; auto; try discriminate.
  destruct i0; simpl; try discriminate.
  now inversion H.
Qed.


Axiom isJoinId_maybe_setIdOccInfo:
  forall v occ_info, 
  isJoinId_maybe (setIdOccInfo v occ_info) = isJoinId_maybe v.

Axiom isJoinId_maybe_asJoinId:
  forall v a,
  isJoinId_maybe (asJoinId v a) = Some a.

Lemma realUnique_eq: forall v v',
    (realUnique v =? realUnique v')%N = Var_as_DT.eqb v v'.
Proof.
  intros.
  unfold Var_as_DT.eqb. cbn. reflexivity.
Qed.
