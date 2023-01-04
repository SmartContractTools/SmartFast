from smartfast.detectors.abstract_detector import AbstractDetector, DetectorClassification
from smartfast.core.cfg.node import NodeType
from smartfast.smartir.operations import (Assignment,Unpack,Binary,Condition)


class ParityMultisigBug(AbstractDetector):
    """
    Detect function named backdoor
    """

    ARGUMENT = 'parity-multisig-bug'  # smartfast will launch the detector with smartfast.py --mydetector
    HELP = 'initMultiowned is not protected'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.PROBABLY


    WIKI = 'https://github.com/trailofbits/smartfast/wiki/ParityMultisigBug'
    WIKI_TITLE = 'ParityMultisigBug'
    WIKI_DESCRIPTION = 'Hackers can call the initMultiowned function through the initWallet function to obtain the identity of the contract owner.'
    WIKI_EXPLOIT_SCENARIO = '''
```solidity
contract WalletLibrary_bad is WalletEvents {

    function initWallet(address[] _owners, uint _required, uint _daylimit) {    
        initDaylimit(_daylimit);    
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

```'''
    WIKI_RECOMMENDATION = 'Judge m_numOwners.'

    def findparitymultisigbug(self, contract):
        results = []

        # print(contract.name)
        for f in contract.all_functions_called:
            # print(f.is_implemented)
            if not f.is_implemented:
                continue
            # node_val = None
            # inloop = False
            # print(f.name)
            # print(f.visibility)
            # print(f.signature_str)
            # print(f.signature_str == 'initWallet(address[],uint256,uint256) returns()')
            # print(f.signature_str == 'initMultiowned(address[],uint256) returns()')
            if f.signature_str == 'initWallet(address[],uint256,uint256) returns()':
                if f.visibility == 'public' and not f.is_protected():
                    results.append(f)
            elif f.signature_str == 'initMultiowned(address[],uint256) returns()':
                m_owners_num = False
                if f.visibility in ['private', 'internal']:
                    continue
                if f.is_protected():
                    continue
                for modifier in f.modifiers:
                    for node in modifier.nodes:
                        if set(['assert(bool)','require(bool)']).intersection([v.name for v in node.solidity_calls]):
                            if 'm_numOwners' in [v.name for v in node.variables_read]:
                                m_owners_num = True
                        for ir in node.irs:
                            if isinstance(ir,Condition):
                                if 'm_numOwners' in [v.name for v in node.variables_read]:
                                    m_owners_num = True
                for node in f.nodes:
                    if set(['assert(bool)','require(bool)']).intersection([v.name for v in node.solidity_calls]):
                        if 'm_numOwners' in [v.name for v in node.variables_read]:
                            m_owners_num = True
                    for ir in node.irs:
                        if isinstance(ir,Condition):
                            if 'm_numOwners' in [v.name for v in node.variables_read]:
                                m_owners_num = True
                # print(m_owners_num)
                if not m_owners_num:
                    results.append(f)
                
        return results

    def _detect(self):
        results = []
        # print("***************")
        for contract in self.smartfast.contracts:
            paritymultisigbug = self.findparitymultisigbug(contract)
            if paritymultisigbug:
                info = [contract, " has the parity multi-sig bug\n"]
                info += ['\tDangerous functions:\n']
                for func in paritymultisigbug:
                    info += ['\t\t- ', func,'\n']
                res = self.generate_result(info)
                results.append(res)
        # print("***************")
        return results