note
	description: "Iterators to read and write from/to a container in linear order."
	author: "withheld for double-blind submission"
	model: target, sequence, index_
	manual_inv: true
	false_guards: true

deferred class
	V_IO_ITERATOR [G]

inherit
	V_ITERATOR [G]
		redefine
			index_
		end

	V_OUTPUT_STREAM [G]
		undefine
			is_model_equal
		end

feature -- Replacement

	put (v: G)
			-- Replace item at current position with `v'.
		require
			not_off: not off
			target_wrapped: target.is_wrapped
			target_observers_open: across target.observers as o all o.item /= Current implies o.item.is_open end
			modify_model (["sequence", "box"], Current)
			modify_model (["bag"], target)
		deferred
		ensure
			sequence_effect: sequence ~ old sequence.replaced_at (index_, v)
			target_wrapped: target.is_wrapped
			target_bag_effect: target.bag ~ old ((target.bag / sequence [index_]) & v)
		end

	output (v: G)
			-- Replace item at current position with `v' and go to the next position.
		note
			status: dynamic
		require else
			modify_model (["sequence", "index_"], Current)
		do
			check inv_only ("subjects_definition", "subjects_contraint") end
			put (v)
			check inv end
			forth
		ensure then
			sequence_effect: sequence ~ old (sequence.replaced_at (index_, v))
			index_effect: index_ = old index_ + 1
		end

feature -- Specification

	index_: INTEGER
			-- Current position.
		note
			status: ghost
			replaces: off_
		attribute
		end

invariant
	off_definition: off_ = not sequence.domain [index_]

end
