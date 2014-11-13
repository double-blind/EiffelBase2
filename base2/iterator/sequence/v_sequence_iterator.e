note
	description: "Itreators to read from sequences."
	author: "withheld for double-blind submission"
	model: target, index_
	manual_inv: true
	false_guards: true

deferred class
	V_SEQUENCE_ITERATOR [G]

inherit
	V_ITERATOR [G]
		redefine
			target
		end

feature -- Access

	target_index: INTEGER
			-- Target index at current position.
		note
			status: dynamic
		require
			target_closed: target.closed
			not_off: not off
		do
			check inv end
			Result := target.lower + index_ - 1
		ensure
			definition: Result = target.lower + index_ - 1
		end

	target: V_SEQUENCE [G]
			-- Sequence to iterate over.

invariant
	sequence_definition: sequence ~ target.sequence

end
