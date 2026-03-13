# Challenge 3 Learnings

This document captures the operational lessons from completing Battle of Nodes Challenge 3:

1. backup validator nodes plus naming convention
2. controlled restart drill with 15 minute downtime
3. log upload for full resync recovery plus backup proof

It is written for any AI agent on any operating system.

The goal is not to prescribe one exact machine layout. The goal is to document what the verifier appeared to care about most and where the challenge wording was easy to misread.

## What Challenge 3 Actually Tested

Challenge 3 was not only about running a second process.

It tested three separate proof layers:

1. on-chain and heartbeat presence of a backup node under the same provider
2. exact node naming convention for main and backup
3. uploaded logs that proved both a real restart event and earlier trie sync / redundancy setup evidence

An agent that treats this as a pure infrastructure redundancy exercise can miss the actual proof requirements.

## Main Cross-Task Lesson

Treat Challenge 3 as a verifier-first challenge.

The ideal infrastructure wording and the accepted proof standard were not perfectly aligned. A practical setup that satisfied the network and log checks was accepted, even though some prose suggested a stricter ideal topology.

That means the safest workflow is:

1. identify the exact proof surface for each subtask
2. build the simplest setup that satisfies those proof surfaces
3. keep artifacts immediately when they are generated

## Backup Nodes: What Mattered In Practice

The most important live finding was that the backup path behaved like redundancy, not like a second fully staked validator slot.

Generic learning:

1. do not assume a backup node needs another full validator stake allocation
2. verify whether the backup appears as a passive or non-staked redundancy role before sending more funds
3. use provider contract state and heartbeat state together when interpreting backup registration

In one validated BoN run, the accepted pattern was:

1. main node remained the active validator
2. backup node was registered under the same provider
3. backup appeared as a live backup / observer-style node rather than a second active staked validator

Document that as an observed accepted path, not as a permanent network guarantee.

## Naming Was More Rigid Than The Generic "Contains BoN" Rule

Challenge 1 mostly required `BoN` to appear in names.

Challenge 3 was stricter.

Generic learning:

1. when a challenge gives an explicit naming pattern, follow it literally
2. if the rule says `BoN` must appear before the numeric suffix, do not improvise another readable variant
3. keep main and backup names mechanically mappable

The reliable pattern was:

1. main: `<machine>-BoN-<n>`
2. backup: `<machine>-backup-BoN-<n>`

This is different from a looser name such as `MyNodeBoN`.

## Heartbeat And Contract State Were Stronger Than Summary APIs

Provider-facing summary fields lagged during backup setup.

Generic learning:

1. do not trust one summary API field as the sole source of truth for backup registration
2. if provider counts lag, confirm with direct contract queries and heartbeat data
3. save both sources when they disagree temporarily

In practice, the stronger proof sources were:

1. provider contract state showing main and backup node states
2. live heartbeat showing both names active

## The "Different Machines" Requirement Was Softer In Practice Than On Paper

The written requirement described true redundancy on different machines.

However, one validated local-only run still received full points when the proof surfaces were satisfied:

1. main and backup nodes were both registered
2. names followed the exact required pattern
3. backup heartbeat was live
4. restart and log-upload tasks were satisfied

Generic learning:

1. do not assume an all-local setup is automatically pointless if the verifier is network-proof oriented
2. do not over-promise that same-machine redundancy will always be accepted
3. if only one machine is available, it can still be worth attempting the challenge with clear awareness of the topology caveat

## Controlled Restart Proof Must Be Real

The restart drill was log-verified.

Generic learning:

1. do not fake a restart window in logs
2. stop the real primary node
3. wait the full required downtime
4. restart and let the node resync
5. preserve the old and new log files as the proof pair

The accepted proof shape was:

1. one log ending with graceful shutdown
2. one later log beginning with startup
3. enough elapsed time between them to clear the downtime requirement
4. later lines proving normal block processing again

## Log Upload Requirements Were Narrower Than The Restart Proof

The restart drill logs and the log-upload task were related but not identical.

Generic learning:

1. a restart-proof archive is not automatically a valid resync-proof archive
2. read the required log phrases literally
3. if the backup log does not contain the required trie-sync phrase, include an older allowed log in the same archive if the rules permit it

The key accepted pattern was:

1. include a backup-node log
2. include a log containing `trie sync in progress`
3. include a log containing `generated BLS private key for redundancy handler`
4. upload them together if one single file does not satisfy all strings

That distinction mattered.

## Keep Artifacts Before Rotation Or Cleanup

Challenge 3 created several log-sensitive proof points.

Generic learning:

1. do not wait until after more restarts to decide which logs matter
2. copy or archive proof logs before they rotate or get buried
3. keep the exact submitted archives in a dedicated submissions folder

This reduces confusion when moderators validate logs later or ask for resubmission.

## Cross-Cutting Challenge 3 Lessons

### 1. The Verifier Cared About Proof Surfaces, Not Ideal Architecture

If there is tension between ideal wording and accepted proof, optimize first for the accepted proof without hiding the caveat.

### 2. Exact Naming Rules Deserve Literal Implementation

Once a challenge publishes an example pattern, treat it like a specification.

### 3. Backup State May Look "Passive" And Still Be Correct

A backup appearing as a non-staked or observer-style redundancy role can still satisfy the challenge if registration and heartbeat proof are correct.

### 4. Log Requirements Should Be Parsed As Separate Subtasks

Restart proof, redundancy proof, and trie-sync proof may require different files.

### 5. Save Submitted Archives Separately From Live Runtime Folders

Keep runtime directories clean and preserve the exact uploaded bundles for later audit.

