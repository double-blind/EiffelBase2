note
	description: "Iterators to read from maps in linear order."
	author: "withheld for double-blind submission"
	model: target, sequence, index_
	manual_inv: true
	false_guards: true

deferred class
	V_MAP_ITERATOR [K, V]

inherit
	V_ITERATOR [V]
		rename
			sequence as value_sequence
		redefine
			target
		end

feature -- Access

	key: K
			-- Key at current position.
		require
			closed: closed
			target_closed: target.closed
			not_off: not off
		deferred
		ensure
			definition: Result = sequence [index_]
		end

	target: V_MAP [K, V]
			-- Table to iterate over.

feature -- Cursor movement

	search_key (k: K)
			-- Move to a position where key is equivalent to `k'.
			-- If `k' does not appear, go after.
			-- (Use object equality.)
		require
			target_closed: target.closed
			lock_wrapped: target.lock.is_wrapped
			k_locked: target.lock.owns [k]
			modify_model ("index_", Current)
		deferred
		ensure
			index_effect_found: target.domain_has (k) implies sequence [index_] = target.domain_item (k)
			index_effect_not_found: not target.domain_has (k) implies index_ = sequence.count + 1
		end

feature -- Specification

	sequence: MML_SEQUENCE [K]
			-- Sequence of keys.
		note
			status: ghost
			replaces: value_sequence
		attribute
		end

	value_sequence_from (seq: like sequence; m: like target.map): MML_SEQUENCE [V]
			-- Value sequnce for key sequence `seq' and target map `m'.			
		note
			status: ghost, functional, dynamic, opaque
		require
			in_domain: seq.range <= m.domain
			reads ([])
		do
			Result := m.sequence_image (seq)
		ensure
			same_count: Result.count = seq.count
		end

	lemma_sequence_no_duplicates
			-- Key sequence has no duplicates.	
		note
			status: lemma, dynamic
		require
			closed: closed
			target_closed: target.closed
		do
			check inv end
			check target.inv_only ("bag_definition") end
			use_definition (target.bag_from (target.map))
			check value_sequence.count = value_sequence.to_bag.count end
			check sequence.to_bag.domain = sequence.range end
			sequence.to_bag.lemma_domain_count
			sequence.lemma_no_duplicates
		ensure
			sequence.no_duplicates
		end

invariant
	target_domain_constraint: target.map.domain ~ sequence.range
	value_sequence_definition: value_sequence ~ value_sequence_from (sequence, target.map)

end
