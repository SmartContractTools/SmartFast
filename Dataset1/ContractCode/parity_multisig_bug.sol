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

contract WalletLibrary_bad1 is WalletEvents {
  
    modifier only_uninitialized { 
	if (m_numOwners > 0) {throw;}
	_;
    }  
  
    function initWallet(address[] _owners, uint _required, uint _daylimit) only_uninitialized {    
	//initDaylimit(_daylimit);
	initMultiowned(_owners, _required);
    }  // kills the contract sending everything to `_to`.

    function initMultiowned(address[] _owners, uint _required) { //直接调用这个函数
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

contract WalletLibrary_good1 is WalletEvents {
  
    modifier only_uninitialized { 
	if (m_numOwners > 0) {throw;}
	_;
    }

    function initMultiowned(address[] _owners, uint _required) only_uninitialized {
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

contract WalletLibrary_good2 is WalletEvents {
    address owner;
    modifier only_user { 
	require(msg.sender == owner);
	_;
    }

    function initMultiowned(address[] _owners, uint _required) only_user {
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

contract WalletLibrary_good3 is WalletEvents {

    function initMultiowned(address[] _owners, uint _required) {
	if (m_numOwners > 0) {throw;}
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
