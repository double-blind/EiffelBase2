note
	description: "Iterators over sets, allowing efficient search."
	author: "withheld for double-blind submission"
	model: target, sequence, index_
	manual_inv: true
	false_guards: true

deferred class
	V_SET_ITERATOR [G]

inherit
	V_ITERATOR [G]
		redefine
			target
		end

feature -- Access

	target: V_SET [G]
			-- Set to iterate over.

feature -- Cursor movement

	search (v: G)
			-- Move to an element equivalent to `v'.
			-- If `v' does not appear, go after.
			-- (Use object equality.)
		require
			target_closed: target.closed
			lock_wrapped: target.lock.is_wrapped
			v_locked: target.lock.owns [v]
			modify_model ("index_", Current)
		deferred
		ensure
			index_effect_found: target.set_has (v) implies sequence [index_] = target.set_item (v)
			index_effect_not_found: not target.set_has (v) implies index_ = sequence.count + 1
		end

feature -- Removal

	remove
			-- Remove element at current position. Move to the next position.
		require
			not_off: not off
			target_wrapped: target.is_wrapped
			lock_wrapped: target.lock.is_wrapped
			only_iterator: target.observers = [target.lock, Current]
			modify_model (["sequence", "box"], Current)
			modify_model ("set", target)
		deferred
		ensure
			sequence_effect: sequence ~ old sequence.removed_at (index_)
			target_set_effect: target.set ~ old (target.set / sequence [index_])
			target_wrapped: target.is_wrapped
			index_ = old index_
		end

invariant
	target_set_constraint: target.set ~ sequence.range

end
