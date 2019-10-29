From mathcomp Require Import all_ssreflect.
Set Implicit Arguments.
Unset Strict Implicit.
(* Unset Printing Implicit Defensive. *)
Set Printing Implicit.

(* We take the notion of a local state of a process to be primitive. *)
Parameter local_state: Set.
Axiom local_state_eqMixin: Equality.mixin_of local_state.
Canonical local_state_eqType := Eval hnf in EqType local_state local_state_eqMixin.

Parameter num_processes: nat.
Definition processes := iota 0 num_processes.

Parameter tag: Set.
Record message :=
  Message
    {
      message_sender:    'I_num_processes;
      message_recipient: 'I_num_processes;
      message_body: tag;
    }.
Axiom message_eqMixin: Equality.mixin_of message.
Canonical message_eqType := Eval hnf in EqType message message_eqMixin.
Parameter messages: seq message.
(* We assume, for ease of exposition only, that messages are unique. *)
Axiom uniq_messages: uniq messages.

Inductive action :=
| ActionSend     of message
| ActionReceive  of message
| ActionInternal.

Definition action_eq (a b: action) :=
  match a with
  | ActionSend m => match b with
                    | ActionSend n => m == n
                    | _ => false
                    end
  | ActionReceive m => match b with
                    | ActionReceive n => m == n
                    | _ => false
                    end
  | ActionInternal => match b with
                    | ActionInternal => true
                    | _ => false
                    end
  end.

Lemma action_eqP: Equality.axiom action_eq.
Proof.
  move=> a b; apply: (iffP idP) => [|<-]; last by case: a => //=.
  case: a; case: b; move=> //= m n /eqP-> //.
Qed.
Definition action_eqMixin := Equality.Mixin action_eqP.
Canonical action_eqType := Eval hnf in EqType action action_eqMixin.

Record event :=
  Event
    {
      prev_state: local_state;
      event_action: action;
      next_state: local_state;
    }.

Record transition :=
  Transition
    {
      transition_action: action;
      transition_state: local_state;
    }.

Definition transition_eq (t1 t2: transition) :=
  match t1 with
  | Transition a1 s1 => match t2 with
                        | Transition a2 s2 => (a1 == a2) && (s1 == s2)
                        end
  end.

Lemma transition_eqP: Equality.axiom transition_eq.
Proof.
  move=> t1 t2; apply: (iffP idP) => [|<-]; last by case: t1 => a1 s1; apply/andP => [].
  case: t1; case t2 => a2 s2 a1 s1 /andP [] /eqP-> /eqP-> //=.
Qed.
Definition transition_eqMixin := Equality.Mixin transition_eqP.
Canonical transition_eqType := Eval hnf in EqType transition transition_eqMixin.

(* A local history of a process is a (FIXME: possibly infinite) sequence of
alternating local states and actions. *)
Record local_history :=
  LocalHistory
    {
      init_state: local_state;
      transitions: seq transition;
    }.
(* FIXME: prove *)
Axiom local_history_eqMixin: Equality.mixin_of local_history.
Canonical local_history_eqType := Eval hnf in EqType local_history local_history_eqMixin.

(* A statement of `l` being a prefix of `m`. *)
Fixpoint prefix (A: eqType) (l m: seq A) :=
  match l with
  | [::] => true
  | a :: l => match m with
              | [::] => false
              | b :: m => (a == b) && prefix l m
              end
  end.

Definition local_history_prefix (h1 h2: local_history) :=
  init_state h1 = init_state h2 /\ prefix (transitions h1) (transitions h2).

(* A helper function to get the transition at a given index in the local history. *)
Definition nth_transition (h: local_history) :=
  nth (Transition ActionInternal (init_state h)) (transitions h).

(* Each asynchronous run is a vector of local histories, one per process,
indexed by process identifiers. *)
Definition async_run := num_processes.-tuple local_history.
(* FIXME: A _set_ A of asynchronous runs. *)
Parameter async_runs: seq async_run.
Axiom async_runs_uniq: uniq async_runs.

Parameter channels: {set ('I_num_processes * 'I_num_processes)}.

(* Constraint 1 *)
Axiom send_chan: forall (r: async_run) (i j: 'I_num_processes) (t: tag),
  r \in async_runs ->
  ActionSend (Message i j t) \in map transition_action (transitions (tnth r i)) ->
  (i, j) \in channels.

(* Constraint 2 *)
Axiom receive_send: forall (r: async_run) (i j: 'I_num_processes) (t: tag),
  r \in async_runs ->
  ActionReceive (Message i j t) \in map transition_action (transitions (tnth r j)) ->
  (i, j) \in channels.

(* Additional channel constraint, not admitted: Reliability *)
Definition send_receive := forall (r: async_run) (i j: 'I_num_processes) (t: tag),
  r \in async_runs ->
  ActionSend (Message i j t) \in map transition_action (transitions (tnth r i)) ->
  ActionReceive (Message i j t) \in map transition_action (transitions (tnth r j)).

(* Additional channel constraint, not admitted: FIFO *)
Definition send_receive_fifo :=
  forall (r: async_run) (i j: 'I_num_processes) (t1 t2: tag) (w x y z: nat),
  r \in async_runs ->
  ActionSend (Message i j t1) ==
    transition_action (nth_transition (tnth r i) w) ->
  ActionSend (Message i j t2) ==
    transition_action (nth_transition (tnth r i) x) ->
  w < x ->
  ActionReceive (Message i j t1) ==
    transition_action (nth_transition (tnth r j) y) ->
  ActionReceive (Message i j t2) ==
    transition_action (nth_transition (tnth r j) z) ->
  y < z.

Definition happens_imm_before (r: async_run) (i j: 'I_num_processes) (x y: nat) :=
  r \in async_runs ->
  (i = j /\ x < y) \/ (exists t, let m := Message i j t in
    ActionSend    m = transition_action (nth_transition (tnth r i) x) /\
    ActionReceive m = transition_action (nth_transition (tnth r j) y)).

(* The happens-before relation is the transitive closure of
happens-immediately-before. *)
Definition happens_before (r: async_run) (i j: 'I_num_processes) (x y: nat) :=
  r \in async_runs ->
  happens_imm_before r i j x y \/
  (exists k z, happens_imm_before r i k x z /\ happens_imm_before r k j z y).

(* Our final requirement is that → be anti-symmetric, which is necessary if the
system is to model actual executions. *)
Axiom happens_before_antisym: forall (r: async_run) (i j: 'I_num_processes) (x y: nat),
  r \in async_runs ->
  ~(happens_imm_before r i j x y /\ happens_imm_before r j i y x).

(* A global state of run `r` is a vector of prefixes of local histories of `r`,
one prefix per process. *)
Record global_state (r: async_run) :=
  GlobalState
    {
      global_state0: async_run;
      _: forall i: 'I_num_processes,
          local_history_prefix (tnth global_state0 i) (tnth r i);
    }.

(* The happens-before relation can be used to define a consistent global state,
often termed a consistent cut, as follows. *)
Record consistent_cut (r: async_run) :=
  ConsistentCut
    {
      cc_global_state: global_state r;
      _: forall i j x y, happens_before r i j x y ->
         length (transitions (tnth (global_state0 cc_global_state) j)) > y ->
         length (transitions (tnth (global_state0 cc_global_state) i)) > x
    }.

(* FIXME: Record message_chain (r: async_run) := *)

(* Lemma 1 (in two parts). In any asynchronous run of any system, each local
state of each process is included in some consistent cut of the system. *)
Lemma async_run_cc0: forall (r: async_run),
  r \in async_runs ->
  forall (i: 'I_num_processes),
    exists (c: consistent_cut r),
      init_state (tnth (global_state0 (cc_global_state c)) i) = init_state (tnth r i).
Admitted.

Lemma async_run_cc1: forall (r: async_run),
  r \in async_runs ->
  forall (i: 'I_num_processes) x,
    exists (c: consistent_cut r),
      transition_state (nth_transition (tnth (global_state0 (cc_global_state c)) i) x) =
      transition_state (nth_transition (tnth r i) x).
Admitted.

(* We assume that there is a set of primitive propositions; these typically will
be statements like "variable x in process i is 0" or "process i has sent a
message m to process j". We represent these by lower-case letters p, q, ... *)
Parameter prop: Set.
Axiom prop_eqMixin: Equality.mixin_of prop.
Canonical prop_eqType := Eval hnf in EqType prop prop_eqMixin.

(* Indistinguishability *)
Definition indis a1 c1 a2 c2 i

(* FIXME *)
Definition knows (i: 'I_num_processes)
