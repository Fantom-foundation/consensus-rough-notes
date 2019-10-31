/// A consensus protocol that defines a message flow.
///
/// Many algorithms require an RNG which must be supplied on each call. It is up to the caller to
/// ensure that this random number generator is cryptographically secure.
pub trait ConsensusProtocol {
    /// Unique node identifier.
    type NodeId;
    /// The input provided by the user.
    type Input;
    /// The output type. Some algorithms return an output exactly once, others return multiple
    /// times.
    type Output;
    /// The messages that need to be exchanged between the instances in the participating nodes.
    type Message;
    /// The errors that can occur during execution.
    type Error: Fail;
    /// The kinds of message faults that can be detected during execution.
    type FaultKind;

    /// Handles an input provided by the user, and returns
    fn handle_input<R: Rng>(
        &mut self,
        input: Self::Input,
        rng: &mut R,
    ) -> Result<ConsensusStep<Self>, Self::Error>;

    /// Handles a message received from node `sender_id`.
    fn handle_message<R: Rng>(
        &mut self,
        sender_id: &Self::NodeId,
        message: Self::Message,
        rng: &mut R,
    ) -> Result<ConsensusStep<Self>, Self::Error>;

    /// Returns `true` if execution has completed and this instance can be dropped.
    fn terminated(&self) -> bool;

    /// Returns this node's own ID.
    fn our_id(&self) -> &Self::NodeId;
}

/// Single algorithm step outcome.
///
/// Each time input (typically in the form of user input or incoming network messages) is provided
/// to an instance of an algorithm, a `Step` is produced, potentially containing output values, a
/// fault log, and network messages.
///
/// Any `Step` **must always be used** by the client application; at the very least the resulting
/// messages must be queued.
#[must_use = "The algorithm step result must be used."]
pub struct Step<M, O, N, F: Fail> {
    /// The algorithm's output, after consensus has been reached. This is guaranteed to be the same
    /// in all nodes.
    pub output: Vec<O>,
    /// A list of nodes that are not following consensus, together with information about the
    /// detected misbehavior.
    pub fault_log: Vec<(N, F)>,
    /// A list of messages that must be sent to other nodes. Each entry contains a message and a
    /// `Target`.
    pub messages: Vec<TargetedMessage<M, N>>,
}

/// An alias for the type of `Step` returned by `D`'s methods.
pub type ConsensusStep<D> = Step<
    <D as ConsensusProtocol>::Message,
    <D as ConsensusProtocol>::Output,
    <D as ConsensusProtocol>::NodeId,
    <D as ConsensusProtocol>::FaultKind,
>;

/// The intended recipient(s) of a message.
pub enum Target<N> {
    /// The message must be sent to all remote nodes.
    All,
    /// The message must be sent to the node with the given ID.
    Node(N),
    /// The message must be sent to all remote nodes except the passed nodes.
    AllExcept(BTreeSet<N>),
}

/// Message with a designated target.
pub struct TargetedMessage<M, N> {
    /// The node or nodes that this message must be delivered to.
    pub target: Target<N>,
    /// The content of the message that must be serialized and sent to the target.
    pub message: M,
}

// The MIT License

// Copyright (c) 2018, POA Networks, Ltd.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
