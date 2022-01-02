contract WalletEvents {
    uint m_numOwners;
    uint[] m_ownerIndex;
    uint[] m_owners;
    uint m_required;
}

contract WalletLibrary_bad is WalletEvents {
	// constructor - just pass on the owner array to the multiowned and
	// the limit to daylimit
	function initWallet(address[] _owners, uint _required, uint _daylimit) only_uninitialized {
		//initDaylimit(_daylimit);
		initMultiowned(_owners, _required);
	}
	
	// constructor is given number of sigs required to do protected "onlymanyowners" transactions
	// as well as the selection of addresses capable of confirming them.
	function initMultiowned(address[] _owners, uint _required) only_uninitialized {
		m_numOwners = _owners.length + 1;
		m_owners[1] = uint(msg.sender);
		m_ownerIndex[uint(msg.sender)] = 1;
		for (uint i = 0; i < _owners.length; ++i) {
			m_owners[2 + i] = uint(_owners[i]);
			m_ownerIndex[uint(_owners[i])] = 2 + i;
		}
		m_required = _required;
	}
	
	// throw unless the contract is not yet initialized.
	modifier only_uninitialized { if (m_numOwners > 0) throw; _; }
}