note
	description: "Dispensers where the latest added element is accessible."
	author: "withheld for double-blind submission"
	model: sequence
	manual_inv: true
	false_guards: true

deferred class
	V_STACK [G]

inherit
	V_DISPENSER [G]
		redefine
			extend,
			is_model_equal
		end

feature -- Extension

	extend (v: G)
			-- Push `v' on the stack.
		deferred
		ensure then
			sequence_effect: sequence ~ old sequence.prepended (v)
		end

feature -- Specification

	is_model_equal (other: like Current): BOOLEAN
			-- Is the abstract state of `Current' equal to that of `other'?
		note
			status: ghost, functional, dynamic
		do
			Result := sequence ~ other.sequence
		end

end
