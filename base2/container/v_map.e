note
	description: "[
		Containers where values are associated with keys. 
		Keys are unique with respect to object equality.
		Immutable interface.
		]"
	author: "withheld for double-blind submission"
	model: map, lock
	manual_inv: true
	false_guards: true

deferred class
	V_MAP [K, V]

inherit
	V_CONTAINER [V]
		redefine
			is_empty
		end

feature -- Measurement

	count: INTEGER
			-- Number of elements.
		deferred
		ensure then
			definition_set: Result = map.count
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is container empty?
		note
			status: dynamic
		do
			check inv end
			Result := count = 0
		ensure then
			definition_set: Result = map.is_empty
		end

feature -- Search

	has_key (k: K): BOOLEAN
			-- Is key `k' contained?
			-- (Uses object equality.)
		require
			k_closed: k.closed
			lock_closed: lock.closed
		deferred
		ensure
			definition: Result = domain_has (k)
		end

	key (k: K): K
			-- Element of `map.domain' equivalent to `v' according to object equality.
		require
			k_closed: k.closed
			has: domain_has (k)
			lock_closed: lock.closed
		deferred
		ensure
			definition: Result = domain_item (k)
		end

	item alias "[]" (k: K): V
			-- Value associated with `k'.
		require
			k_closed: k.closed
			has_key: domain_has (k)
			lock_closed: lock.closed
		deferred
		ensure
			definition: Result = map [domain_item (k)]
		end

feature -- Iteration

	new_cursor: V_MAP_ITERATOR [K, V]
			-- New iterator pointing to a position in the map, from which it can traverse all elements by going `forth'.
		note
			status: impure
		deferred
		end

	at_key (k: K): like new_cursor
			-- New iterator pointing to a position with key `k'.
			-- If key does not exist, iterator is off.
		note
			status: impure
		require
			lock_wrapped: lock.is_wrapped
			v_locked: lock.owns [k]
			modify_field (["observers", "closed"], Current)
		deferred
		ensure
			result_fresh: Result.is_fresh
			result_wrapped: Result.is_wrapped and Result.inv
			result_in_observers: observers = old observers & Result
			target_definition: Result.target = Current
			index_definition_found: domain_has (k) implies Result.sequence [Result.index_] = domain_item (k)
			index_definition_not_found: not domain_has (k) implies Result.index_ = Result.sequence.count + 1
		end

feature -- Specification

	map: MML_MAP [K, V]
			-- Map of keys to values.
		note
			status: ghost
			replaces: bag
			guard: inv
		attribute
		end

	lock: V_LOCK [K, V]
			-- Helper object for keeping items consistent.
		note
			status: ghost
			guard: True
		attribute
		end

	domain_has (k: K): BOOLEAN
			-- Does `set' contain an element equal to `v' under object equality?
		note
			status: ghost, functional, dynamic
		require
			lock_exists: lock /= Void
			k_exists: k /= Void
			domain_non_void: map.domain.non_void
			reads_field (["map", "lock"], Current)
			reads (map.domain, k)
		do
			Result := lock.set_has (map.domain, k)
		end

	domain_item (k: K): K
			-- Element of `map.domain' that is equal to `k' under object equality.
		note
			status: ghost, functional, dynamic
		require
			lock_exists: lock /= Void
			k_exists: k /= Void
			k_in_domain: domain_has (k)
			domain_non_void: map.domain.non_void
			reads_field (["map", "lock"], Current)
			reads (map.domain, k)
		do
			Result := lock.set_item (map.domain, k)
		end

	bag_from (m: like map): like bag
			-- Bag of values in `m'.
		note
			status: ghost, functional, opaque, dynamic
		require
			reads ([])
		do
			Result := m.to_bag
		end

invariant
	domain_non_void: map.domain.non_void
	non_empty_has_lock: not map.is_empty implies lock /= Void
	lock_non_current: lock /= Current
	lock_non_iterator: not attached {V_ITERATOR [V]} lock
	subjects_definition: if lock = Void then subjects.is_empty else subjects = [lock] end
	registered: lock /= Void implies lock.tables [Current]
	observers_constraint: lock /= Void implies observers [lock]
	bag_definition: bag ~ bag_from (map)


end
