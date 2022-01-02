contract WalletEvents {
    uint m_numOwners;
    uint[] m_ownerIndex;
    uint[] m_owners;
    uint m_required;
}

contract WalletLibrary_bad is WalletEvents {

    function initWallet(address[] _owners, uint _required, uint _daylimit) {    
		//initDaylimit(_daylimit);    
		initMultiowned(_owners, _required);
    }  // kills the contract sending everything to `_to`.
      
    function initMultiowned(address[] _owners, uint _required) {
		m_numOwners = _owners.length + 1;
		m_owners[1] = uint(msg.sender);
		m_ownerIndex[uint(msg.sender)] = 1;    
	
		for (uint i = 0; i < _owners.length; ++i)
		{
			m_owners[2 + i] = uint(_owners[i]);
			m_ownerIndex[uint(_owners[i])] = 2 + i;
		}
		m_required = _required;	
    }
  
}